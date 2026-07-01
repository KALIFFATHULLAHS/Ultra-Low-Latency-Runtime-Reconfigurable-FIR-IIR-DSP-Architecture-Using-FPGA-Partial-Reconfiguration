`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 19:08:56
// Design Name: 
// Module Name: rm_pr_iir_chain
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rm_pr_iir_chain (
    input  wire clk,
    input  wire reset,
    input  wire sample_tick,
    input  wire signed [15:0] x_in,
    output wire signed [15:0] y_out,
    output wire ready_out,
    output wire valid_out
);

    wire signed [15:0] y1;
    wire signed [15:0] y2;

    // Stage 1
    biquad_core_pr #(
        .B0(16'sd16384),
        .B1(16'sd32767),
        .B2(16'sd16384),
        .A1(-16'sd29491),
        .A2(16'sd13107)
    ) U_BQ1 (
        .clk(clk),
        .reset(reset),
        .sample_tick(sample_tick),
        .x_in(x_in),
        .y_out(y1)
    );

    // Stage 2
    biquad_core_pr #(
        .B0(16'sd16384),
        .B1(16'sd32767),
        .B2(16'sd16384),
        .A1(-16'sd26214),
        .A2(16'sd9830)
    ) U_BQ2 (
        .clk(clk),
        .reset(reset),
        .sample_tick(sample_tick),
        .x_in(y1),
        .y_out(y2)
    );

    assign y_out     = y2;
    assign ready_out = 1'b1;

    reg valid_ff;
    always @(posedge clk) begin
        if (reset) valid_ff <= 1'b0;
        else       valid_ff <= sample_tick;
    end
    assign valid_out = valid_ff;

endmodule


module biquad_core_pr #(
    parameter signed [15:0] B0 = 16'sd16384,
    parameter signed [15:0] B1 = 16'sd0,
    parameter signed [15:0] B2 = 16'sd0,
    parameter signed [15:0] A1 = 16'sd0,
    parameter signed [15:0] A2 = 16'sd0
)(
    input  wire clk,
    input  wire reset,
    input  wire sample_tick,
    input  wire signed [15:0] x_in,
    output reg  signed [15:0] y_out
);

    reg signed [15:0] x1, x2;
    reg signed [15:0] y1, y2;

    reg signed [31:0] acc;
    reg signed [15:0] y_next;

    always @(posedge clk) begin
        if (reset) begin
            x1    <= 16'sd0;
            x2    <= 16'sd0;
            y1    <= 16'sd0;
            y2    <= 16'sd0;
            y_out <= 16'sd0;
        end else if (sample_tick) begin
            acc = 32'sd0;
            acc = acc + (B0 * x_in);
            acc = acc + (B1 * x1);
            acc = acc + (B2 * x2);
            acc = acc - (A1 * y1);
            acc = acc - (A2 * y2);

            y_next = sat16(acc >>> 15);

            x2 <= x1;
            x1 <= x_in;
            y2 <= y1;
            y1 <= y_next;

            y_out <= y_next;
        end
    end

    function signed [15:0] sat16;
        input signed [31:0] v;
        begin
            if (v > 32'sd32767)
                sat16 = 16'sd32767;
            else if (v < -32'sd32768)
                sat16 = -16'sd32768;
            else
                sat16 = v[15:0];
        end
    endfunction

endmodule