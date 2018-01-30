`timescale 1ns / 1ps
module lcd_test(
	 input lcd_clk, 
 
	 output lcd_dclk,
	 output [7:0] lcd_r,
   output [7:0] lcd_g,
   output [7:0] lcd_b,
   output lcd_hsync,
   output lcd_vsync,
   output lcd_de
);


  //-----------------------------------------------------------//
  // 480*272 60Hz LCD
  //-----------------------------------------------------------//
  parameter lcd_video_full_width = 525;           
  parameter lcd_horiz_sync_pulse=41;            
  parameter lcd_horiz_de_start=43;
  parameter lcd_horiz_de_end=523;
  parameter lcd_video_full_height =286;          
  parameter lcd_vert_sync_pulse=10;            
  parameter lcd_vert_de_start=12;
  parameter lcd_vert_de_end=284;


  reg[10 : 0] x_cnt;
  reg[9 : 0]  y_cnt;
  reg[7 : 0]  lcd_r_reg;
  reg[7 : 0]  lcd_g_reg;
  reg[7 : 0]  lcd_b_reg;  
  reg hsync_r;
  reg vsync_r; 
  reg hsync_de;
  reg vsync_de;
      
  assign lcd_dclk = ~lcd_clk;
  assign lcd_hsync = hsync_r;
  assign lcd_vsync = vsync_r;
  assign lcd_de = hsync_de & vsync_de;
  assign lcd_r = (hsync_de & vsync_de)?lcd_r_reg:8'b00000000;
  assign lcd_g = (hsync_de & vsync_de)?lcd_g_reg:8'b00000000;
  assign lcd_b = (hsync_de & vsync_de)?lcd_b_reg:8'b00000000;
 
  wire [23:0] palette[0:15];
  
  assign palette[0] = 24'h000000;
  assign palette[1] = 24'h0000aa;
  assign palette[2] = 24'h00aa00;
  assign palette[3] = 24'h00aaaa;
  assign palette[4] = 24'haa0000;
  assign palette[5] = 24'haa00aa;
  assign palette[6] = 24'haa5500;
  assign palette[7] = 24'haaaaaa;
  assign palette[8] = 24'h555555;
  assign palette[9] = 24'h5555ff;
  assign palette[10] = 24'h55ff55;
  assign palette[11] = 24'h55ffff;
  assign palette[12] = 24'hff5555;
  assign palette[13] = 24'hff55ff;
  assign palette[14] = 24'hffff55;
  assign palette[15] = 24'hffffff;
  
  wire [7:0] data_out;
  wire [7:0] char;
  wire [7:0] attr;
  
  wire [10 : 0] x_screen;
  wire [9 : 0]  y_screen;

  assign x_screen = x_cnt - lcd_horiz_de_start;
  assign y_screen = y_cnt - lcd_vert_de_start;
  


  font_rom vga_font(.addr(char*16 + (y_cnt-lcd_vert_de_start) % 16 ),.data_out(data_out));
  
  text_rom text_mem(.addr((y_screen/16)*60 +(x_screen)/8),.data_out(char));
  attr_rom attr_mem(.addr((y_screen/16)*60 +(x_screen)/8),.data_out(attr));


// count X position
always @ (posedge lcd_clk)
      if(x_cnt == lcd_video_full_width) 
        x_cnt <= 1;
      else 
        x_cnt <= x_cnt+ 1;
		 
// HSYNC and HSYNC data enable
always @ (posedge lcd_clk)
   begin
      if(x_cnt == 1) 
        hsync_r <= 1'b0;
      if(x_cnt == lcd_horiz_sync_pulse) 
        hsync_r <= 1'b1;

	    if(x_cnt == lcd_horiz_de_start)
        hsync_de <= 1'b1; 
      if(x_cnt == lcd_horiz_de_end) 
        hsync_de <= 1'b0;	
	end

// count Y position
always @ (posedge lcd_clk)
      if (y_cnt == lcd_video_full_height) 
        y_cnt <= 1;
      else 
        if(x_cnt == lcd_video_full_width) 
          y_cnt <= y_cnt+1;

// VSYNC and VSYNC data enable
always @ (posedge lcd_clk)
  begin
      if(y_cnt == 1) 
        vsync_r <= 1'b0; 
      if(y_cnt == lcd_vert_sync_pulse) 
        vsync_r <= 1'b1;
		 
	    if(y_cnt == lcd_vert_de_start)
        vsync_de <= 1'b1;
      if(y_cnt == lcd_vert_de_end) 
        vsync_de <= 1'b0;	 
  end
		 
	
//----------------------------------------------------------------
 always @(posedge lcd_clk)      
   begin
      lcd_r_reg <= (data_out[7-(x_screen % 8)]==1'b1) ? palette[attr[3:0]][23:16] : palette[attr[7:4]][23:16];
      lcd_g_reg <= (data_out[7-(x_screen % 8)]==1'b1) ? palette[attr[3:0]][15:8]  : palette[attr[7:4]][15:8];
      lcd_b_reg <= (data_out[7-(x_screen % 8)]==1'b1) ? palette[attr[3:0]][7:0]   : palette[attr[7:4]][7:0];
    end
			
endmodule



