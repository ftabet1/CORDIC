module cordic_hb(
    input logic          clk,
    input logic          reset,
    input logic          start,
    input logic[15:0]    angle,
    output logic[15:0]   v0_o,
    output logic[15:0]   v1_o,
    output logic         ready = 1
);

    localparam P_STATE_IDLE     = 0;
    localparam P_STATE_CALC     = 1;
    localparam P_STATE_SCALE    = 2;
    localparam signed[15:0] ANGLE = 16'h562B; //1.3464 rad; 77.143 ang        Q=14
    localparam signed[15:0] SCALE = 16'h9A  ; //1.2075;                       Q8.7

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
    logic[2:0]  rom_ang_addr;

    ROM #(16, 8, 3, "angle_table_hb.hex") ROM_ANG_i (
        .i_oe(1),
        .i_addr(rom_ang_addr),
        .o_data(rom_ang_data)
    );

    assign rom_ang_addr =  cnt[2:0];

    always_comb begin
        v0_data_add = rot_acc[15] ? v0_data - (v1_data >>> (cnt+1)) : v0_data + (v1_data >>> (cnt+1));
        v1_data_add = rot_acc[15] ? v1_data - (v0_data >>> (cnt+1)) : v1_data + (v0_data >>> (cnt+1));
        rot_acc_add = rot_acc[15] ? rot_acc + rom_ang_data : rot_acc - rom_ang_data;
        scale_mul   = cnt == 9    ? SCALE * v1_data : SCALE * v0_data;
    end

    always_ff@(posedge(clk)) begin
        if(reset) begin
            v0_data     = 0;
            v1_data     = 0;
            v0_o        = 0;
            v1_o        = 0;
            rot_acc     = 0;
            ready       = 1;
            state       = P_STATE_IDLE;
            cnt         = 0;
        end else begin
            if(state == P_STATE_IDLE && start) begin
                state = P_STATE_CALC;
                v0_data = 16'h80;
                v1_data = 0;
                rot_acc = angle;
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

function real norm(real v0, real v1);
    return $sqrt(v0*v0+v1*v1);
endfunction

function real dot(real v0_0, real v1_0, real v0_1, real v1_1);
    return v0_0 * v0_1 + v1_0 * v1_1;
endfunction

module test_cordic_hb();

    logic[15:0] v0_i = 0;
    logic[15:0] v1_i = 0;
    logic[15:0] angle = 0;
    logic signed[15:0] v0_o;
    logic signed[15:0] v1_o;

    logic ready;
    logic start = 0;
    logic reset = 0;
    logic clk = 0;
	always #1 clk ^= 1;

    cordic_hb cordic_uut(
        .clk(clk),
        .ready(ready),
        .reset(reset),
        .start(start),
        .angle(angle),
        .v0_o(v0_o),
        .v1_o(v1_o)
    );

    logic signed[15:0] v0_i_val[0:4] = {16'h0, 16'h80, 16'hFEFF, 16'h1234, 16'h80};
    logic signed[15:0] v1_i_val[0:4] = {16'h80, 16'h0, 16'h0180, 16'h3210, 16'hEFF0};
    logic signed[15:0] angles[0:4]    = {16'h1199, 16'h2333, 16'h34CC, 16'h4665, 16'h8C};
    real pi = 3.14;
    real v0_real = 0;
    real v1_real = 0;
    real v0_real_a = 0;
    real v1_real_a = 0;
    real X_axis[0:1] = {1.0, 0.0};
    real v_norm_p = 0;
    real v_norm_a = 0;
    real v_rad_p  = 0;
    real v_rad_a  = 0;

	initial begin
		$dumpfile("test_cordic_hb.wcd");
		$dumpvars(1, test_cordic_hb);
        reset = 1;
        #2
        reset = 0;
        for(integer i = 0; i < 4; i++) begin
            v0_real = v0_i_val[i];
            v1_real = v1_i_val[i];
            v0_real = v0_real / (1 << 7);
            v1_real = v1_real / (1 << 7);
            v_norm_p = norm(v0_real, v1_real);
            v_rad_p = $acos(dot(v0_real, v1_real, X_axis[0], X_axis[1])/(norm(v0_real, v1_real) * norm(X_axis[0], X_axis[1])));
            $display("----------VECTOR %d: [%f, %f]----------\n", i, v0_real, v1_real);
            angle = angles[i];
            start = 1;
            #4
            start = 0;
            while(!ready) #2;
            v0_real_a = v0_o;
            v1_real_a = v1_o;
            v0_real_a = v0_real_a / (1 << 7);
            v1_real_a = v1_real_a / (1 << 7);

            v_norm_a = norm(v0_real_a, v1_real_a);
            v_rad_a = $acos(dot(v0_real_a, v1_real_a, X_axis[0], X_axis[1])/(norm(v0_real_a, v1_real_a) * norm(X_axis[0], X_axis[1])));
            #2
            $display("BEFORE: RAD = %f; NORM = %f\n", v_rad_p, v_norm_p);
            $display("AFTER: RAD = %f; NORM = %f\n", v_rad_a, v_norm_a);
            $display("DIFF: RAD = %f; NORM = %f\n", v_rad_a-v_rad_p, v_norm_a-v_norm_p);
            
        end
		$finish;
	end
endmodule