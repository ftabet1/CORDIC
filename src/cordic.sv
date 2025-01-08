module cordic(
    input logic          clk,
    input logic          reset,
    input logic[15:0]    v0_i,
    input logic[15:0]    v1_i,
    output logic[15:0]   v0_o,
    output logic[15:0]   v1_o
);

    localparam [15:0] angle = 16'h00AC;



endmodule

module test_cordic();

    logic signed[15:0] m_i1 = 0;
    logic signed[15:0] m_i2 = 0;

    logic signed[31:0] m_o = m_i1*m_i2;
    logic[15:0] m_o_norm = m_o[22:7];
	//always #1 clk ^= 1;

	initial begin
		$dumpfile("test_cordic.wcd");
		$dumpvars(1, test_cordic);
		m_i1 = 16'h00AC;
        m_i2 = 16'h00BA;
        #2
        m_i1 = 16'h08AC;
        m_i2 = 16'h80BA;
        #2
		$finish;
	end
endmodule