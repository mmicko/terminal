#include <SDL/SDL.h>

#include <verilated.h>
#include "Vlcd_test.h"

bool running = true;

void DoEvents()
{
	SDL_Event sevent;
	while(SDL_PollEvent(&sevent))
	{
		switch(sevent.type)
		{
		case SDL_KEYDOWN:
			if(sevent.key.keysym.sym == SDLK_ESCAPE) running = false;
			break;			
		case SDL_KEYUP:
			break;			
			
		case SDL_QUIT:
			running = false;
			break;
		}
	}
}

int main(int argc, char **argv) 
{
	vluint64_t main_time = 0;
	Vlcd_test *top = new Vlcd_test;
    //The images
    SDL_Surface* screen = NULL;
    SDL_Init(SDL_INIT_VIDEO);
    //Set up screen
    screen = SDL_SetVideoMode( 480, 272, 32, SDL_SWSURFACE | SDL_RESIZABLE );

    //Update Screen
    SDL_Flip( screen );
	
	Uint8 *p = (Uint8 *)screen->pixels;
	
    Verilated::commandArgs(argc, argv);
    Verilated::debug(0);

    top->lcd_clk = 0;
	vluint64_t hs_cnt = 0;
	vluint64_t vs_cnt = 0;
	vluint64_t frames = 0;
	int x = 0;
	int y = 0;
    while (!Verilated::gotFinish() && running) 
	{
		int prev_hs = top->lcd_hsync;
		int prev_vs = top->lcd_vsync;
		top->lcd_clk = top->lcd_clk ? 0 : 1;

		top->eval();		// Evaluate model
		
		if ((main_time % 2) == 0) 
		{
			if (top->lcd_de==1 && y>3) 
			{
				*p++ = top->lcd_b;
                *p++ = top->lcd_g;
                *p++ = top->lcd_r;
                p++;
				x++;
			}
			if (prev_hs==0 && top->lcd_hsync==1) 
			{
				x=0;
				p = (Uint8 *)screen->pixels + (y-3)*480*4;
				y++; 
			}
			if (prev_vs==0 && top->lcd_vsync==1) 
			{
				y =0;
				SDL_Flip( screen );
				p = (Uint8 *)screen->pixels;
			}

		}
		main_time++;
		DoEvents();
	}

    top->final();
    //Quit SDL
    SDL_Quit();
	
    exit(0);
}
