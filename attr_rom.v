module attr_rom(
  input [9:0] addr,
  output [7:0] data_out
);

  reg [7:0] store[0:1023] /* verilator public_flat */;

  initial
  begin
		$readmemh("attr.mem", store);
  end

	assign data_out = store[addr];
endmodule
