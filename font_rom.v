module font_rom(
  input [11:0] addr,
  output [7:0] data_out
);

  reg [7:0] store[0:4095] /* verilator public_flat */;

  initial
  begin
		$readmemh("font_vga.mem", store);
  end

	assign data_out = store[addr];
endmodule
