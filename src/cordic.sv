module cordic(
    input logic          clk,
    input logic          reset,
    input logic          start,
    input logic[15:0]    v0_i,
    input logic[15:0]    v1_i,
    output logic[15:0]   v0_o,
    output logic[15:0]   v1_o,
    output logic         ready = 1
);

    localparam P_STATE_IDLE     = 0;
    localparam P_STATE_CALC     = 1;
    localparam P_STATE_SCALE    = 2;
    localparam signed[15:0] ANGLE = 16'h562B; //1.3464 rad; 77.143 ang        Q=14
    localparam signed[15:0] SCALE = 16'h4D  ; //0.6073;                       Q8.7

    logic[1:0]  state       = P_STATE_IDLE;
    logic[3:0]  cnt         = 0;

    logic signed[15:0]  v0_data;
    logic signed[15:0]  v1_data;
    logic signed[15:0]  rot_acc     = ANGLE;

    logic signed[15:0]  rot_acc_add;
    logic signed[15:0]  v0_data_add;
    logic signed[15:0]  v1_data_add;
    logic signed[31:0]  scale_mul;

    logic[15:0] rom_ang_data;
    logic[2:0]  rom_ang_addr = cnt[2:0];

    ROM #(16, 8, 3, "angle_table.hex") ROM_ANG_i (
        .i_oe(1),
        .i_addr(rom_ang_addr),
        .o_data(rom_ang_data)
    );

    always_comb begin
        v0_data_add = rot_acc[15] ? v0_data + (v1_data >>> cnt) : v0_data - (v1_data >>> cnt);
        v1_data_add = rot_acc[15] ? v1_data - (v0_data >>> cnt) : v1_data + (v0_data >>> cnt);
        rot_acc_add = rot_acc[15] ? rot_acc + rom_ang_data : rot_acc - rom_ang_data;
        scale_mul   = cnt == 9    ? SCALE * v1_data : SCALE * v0_data;
    end

    always_ff@(posedge(clk)) begin
        if(reset) begin
            v0_data     = 0;
            v1_data     = 0;
            v0_o        = 0;
            v1_o        = 0;
            rot_acc     = ANGLE;
            ready       = 1;
            state       = P_STATE_IDLE;
            cnt         = 0;
        end else begin
            if(state == P_STATE_IDLE && start) begin
                state = P_STATE_CALC;
                v0_data = v0_i;
                v1_data = v1_i;
                rot_acc = ANGLE;
                ready   = 0;
                cnt = 0;
            end else if(state == P_STATE_CALC) begin
                v0_data = v0_data_add;
                v1_data = v1_data_add;
                rot_acc = rot_acc_add;

                if(cnt == 7) begin
                    state = P_STATE_SCALE;
                end
                cnt = cnt + 1;
            end else if(state == P_STATE_SCALE) begin
                if(cnt == 8) begin
                    v0_data = scale_mul[22:7];
                end else if(cnt == 9) begin
                    v1_data = scale_mul[22:7];
                    v0_o = v0_data;
                    v1_o = v1_data;
                    state = P_STATE_IDLE;
                    ready = 1;
                end
                cnt = cnt + 1;
            end
        end
    end

endmodule

module test_cordic();

    logic[15:0] v0_i = 0;
    logic[15:0] v1_i = 0;
    logic[15:0] v0_o;
    logic[15:0] v1_o;

    logic ready;
    logic start = 0;
    logic reset = 0;
    logic clk = 0;
	always #1 clk ^= 1;

    cordic cordic_uut(
        .clk(clk),
        .ready(ready),
        .reset(reset),
        .start(start),
        .v0_i(v0_i),
        .v1_i(v1_i),
        .v0_o(v0_o),
        .v1_o(v1_o)
    );

	initial begin
		$dumpfile("test_cordic.wcd");
		$dumpvars(1, test_cordic);
        reset = 1;
        v0_i = 0;
        v1_i = 16'h80;
        #2
        reset = 0;
        start = 1;
        #2
        start = 0;
        #30
        v0_i = 16'h80;
        v1_i = 0;
        start = 1;
        #2
        start = 0;
        #30
        v0_i = 16'hFEFF;
        v1_i = 16'h0180;
        start = 1;
        #2
        start = 0;
        #30
		$finish;
	end
endmodule