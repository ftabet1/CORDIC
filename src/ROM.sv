module ROM #(parameter OPSIZE = 12, parameter CELLS = 128, parameter ADDR_SIZE = 8, parameter string MEM_H = "memh_test")
(
	input logic 				i_oe,
	input logic[ADDR_SIZE-1:0] 	i_addr,
	output logic[OPSIZE-1:0] 	o_data
);

	logic[OPSIZE-1:0] rom_data[0:CELLS-1];
	
	always_comb begin
		if(i_addr < CELLS) begin
			o_data = i_oe ? rom_data[i_addr] : 0;
		end else begin
			o_data = 0;
		end
	end
	
	initial begin
		$readmemh(MEM_H, rom_data);
		$display(MEM_H);
	end

endmodule

module rom_test();
	localparam 	MEM_H 		= "memh_test";
	localparam 	OPSIZE 		= 12;
	localparam 	CELLS 		= 5;
	localparam 	ADDR_SIZE 	= 8;
	logic 	rom_oe;
	logic[ADDR_SIZE-1:0] 	rom_addr;
	logic[OPSIZE-1:0]		rom_data;
	
	ROM	#(OPSIZE, CELLS, ADDR_SIZE, MEM_H) rom_uut 
	(
		rom_oe,
		rom_addr,
		rom_data
	);
	
	logic ADDR_OVF = rom_addr >= CELLS ? 1 : 0;;
	
	integer i = 0;
	initial begin
		$dumpfile("test_rom.wcd");
		$dumpvars(1, rom_test);
		rom_oe = 1;
		for(i = 0; i < CELLS+5; i++) begin
			#1
			rom_addr++;
		end
		#1
		rom_addr = 0;
		rom_oe = 0;
		for(i = 0; i < CELLS+5; i++) begin
			#1
			rom_addr++;
		end
		#1
		$finish;
		
	end
endmodule