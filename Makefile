TARGET=lcd_test
.PHONY: $(TARGET)

all: $(TARGET)

$(TARGET):
	verilator -Wno-fatal --cc $(@).v --trace --exe ../test.cpp  -Mdir $(@) -LDFLAGS "`sdl-config --libs` -lpthread"  -CFLAGS "-g"
	make -C $(@) -f V$(@).mk
	lcd_test/Vlcd_test
clean:: 
	rm -rf *.o $(TARGET)
distclean:: clean
	rm -rf *~ *.txt *.vcd *.mif *.orig
