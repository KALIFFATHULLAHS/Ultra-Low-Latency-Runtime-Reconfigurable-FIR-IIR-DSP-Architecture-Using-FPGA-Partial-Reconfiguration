`timescale 1ns / 1ps

module rm_pr_fir64 (
    input  wire clk,
    input  wire reset,
    input  wire sample_tick,
    input  wire signed [15:0] x_in,
    output reg  signed [15:0] y_out,
    output wire ready_out,
    output reg  valid_out
);

parameter NTAPS = 64;

reg signed [15:0] shift_reg [0:NTAPS-1];
reg signed [31:0] acc;
reg [6:0] tap_idx = 0; // 0 to 63
integer i;

/* Combinational ROM for Coefficients */
reg signed [15:0] current_coef;
always @(*) begin
    case (tap_idx)
        7'd0:  current_coef = 16'sd12;  7'd1:  current_coef = 16'sd24;  7'd2:  current_coef = 16'sd40;  7'd3:  current_coef = 16'sd60;
        7'd4:  current_coef = 16'sd85;  7'd5:  current_coef = 16'sd110; 7'd6:  current_coef = 16'sd135; 7'd7:  current_coef = 16'sd160;
        7'd8:  current_coef = 16'sd185; 7'd9:  current_coef = 16'sd210; 7'd10: current_coef = 16'sd230; 7'd11: current_coef = 16'sd245;
        7'd12: current_coef = 16'sd255; 7'd13: current_coef = 16'sd260; 7'd14: current_coef = 16'sd260; 7'd15: current_coef = 16'sd255;
        
        7'd16: current_coef = 16'sd255; 7'd17: current_coef = 16'sd260; 7'd18: current_coef = 16'sd260; 7'd19: current_coef = 16'sd255;
        7'd20: current_coef = 16'sd245; 7'd21: current_coef = 16'sd230; 7'd22: current_coef = 16'sd210; 7'd23: current_coef = 16'sd185;
        7'd24: current_coef = 16'sd160; 7'd25: current_coef = 16'sd135; 7'd26: current_coef = 16'sd110; 7'd27: current_coef = 16'sd85;
        7'd28: current_coef = 16'sd60;  7'd29: current_coef = 16'sd40;  7'd30: current_coef = 16'sd24;  7'd31: current_coef = 16'sd12;

        7'd32: current_coef = 16'sd12;  7'd33: current_coef = 16'sd24;  7'd34: current_coef = 16'sd40;  7'd35: current_coef = 16'sd60;
        7'd36: current_coef = 16'sd85;  7'd37: current_coef = 16'sd110; 7'd38: current_coef = 16'sd135; 7'd39: current_coef = 16'sd160;
        7'd40: current_coef = 16'sd185; 7'd41: current_coef = 16'sd210; 7'd42: current_coef = 16'sd230; 7'd43: current_coef = 16'sd245;
        7'd44: current_coef = 16'sd255; 7'd45: current_coef = 16'sd260; 7'd46: current_coef = 16'sd260; 7'd47: current_coef = 16'sd255;

        7'd48: current_coef = 16'sd255; 7'd49: current_coef = 16'sd260; 7'd50: current_coef = 16'sd260; 7'd51: current_coef = 16'sd255;
        7'd52: current_coef = 16'sd245; 7'd53: current_coef = 16'sd230; 7'd54: current_coef = 16'sd210; 7'd55: current_coef = 16'sd185;
        7'd56: current_coef = 16'sd160; 7'd57: current_coef = 16'sd135; 7'd58: current_coef = 16'sd110; 7'd59: current_coef = 16'sd85;
        7'd60: current_coef = 16'sd60;  7'd61: current_coef = 16'sd40;  7'd62: current_coef = 16'sd24;  7'd63: current_coef = 16'sd12;
        
        default: current_coef = 16'sd0;
    endcase
end


localparam [1:0] S_IDLE = 2'd0,
                 S_CALC = 2'd1,
                 S_DONE = 2'd2;

reg [1:0] state = S_IDLE;

always @(posedge clk) begin
    if(reset) begin
        for(i=0;i<NTAPS;i=i+1)
            shift_reg[i] <= 0;
        y_out     <= 0;
        acc       <= 0;
        state     <= S_IDLE;
        tap_idx   <= 0;
        valid_out <= 1'b0;
    end
    else begin
        valid_out <= 1'b0;
        case(state)
            S_IDLE: begin
                if(sample_tick) begin
                    /* Fast parallel shift logic */
                    for(i=NTAPS-1;i>0;i=i-1)
                        shift_reg[i] <= shift_reg[i-1];
                    shift_reg[0] <= x_in;

                    /* Prepare sequential MAC pipeline */
                    acc     <= 0;
                    tap_idx <= 0;
                    state   <= S_CALC;
                end
            end

            S_CALC: begin
                /* Single DSP slice sequential math using purely Combinational ROM */
                acc <= acc + (shift_reg[tap_idx] * current_coef);

                if(tap_idx == NTAPS - 1) begin
                    state <= S_DONE;
                end else begin
                    tap_idx <= tap_idx + 1;
                end
            end

            S_DONE: begin
                /* Scale and saturate to prevent noisy wrapping on large steps */
                y_out     <= sat16(acc >>> 14);
                valid_out <= 1'b1;
                state     <= S_IDLE;
            end

            default: state <= S_IDLE;
        endcase
    end
end

function signed [15:0] sat16;
    input signed [31:0] v;
    begin
        if (v > 32'sd32767)      sat16 = 16'sd32767;
        else if (v < -32'sd32768) sat16 = -16'sd32768;
        else                     sat16 = v[15:0];
    end
endfunction

assign ready_out = 1'b1;

endmodule