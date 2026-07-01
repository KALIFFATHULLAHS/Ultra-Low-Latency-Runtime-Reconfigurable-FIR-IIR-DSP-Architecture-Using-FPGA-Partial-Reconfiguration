`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:07:38
// Design Name: 
// Module Name: iir_coef_bank4
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


module iir_coef_bank4(
    input  wire clk,
    input  wire reset,

    input  wire        we,
    input  wire [1:0]  wr_bank,
    input  wire [2:0]  wr_addr,
    input  wire signed [15:0] wr_data,

    input  wire [1:0]  rd_bank,
    output reg signed [15:0] b0,
    output reg signed [15:0] b1,
    output reg signed [15:0] b2,
    output reg signed [15:0] a1,
    output reg signed [15:0] a2
);

    reg signed [15:0] bank [0:3][0:4];

    // RESET PRELOAD
    always @(posedge clk) begin
        if (reset) begin

            // -------- Bank 0 : LPF 200Hz ----------
            bank[0][0] <= 16'sd3;
            bank[0][1] <= 16'sd6;
            bank[0][2] <= 16'sd3;
            bank[0][3] <= -16'sd32161;
            bank[0][4] <= 16'sd15788;

            // -------- Bank 1 : HPF ----------
            bank[1][0] <= 16'sd16083;
            bank[1][1] <= -16'sd32167;
            bank[1][2] <= 16'sd16083;
            bank[1][3] <= -16'sd32161;
            bank[1][4] <= 16'sd15788;

            // -------- Bank 2 : BPF 50Hz ----------
            bank[2][0] <= 16'sd5;
            bank[2][1] <= 16'sd0;
            bank[2][2] <= -16'sd5;
            bank[2][3] <= -16'sd32757;
            bank[2][4] <= 16'sd16373;

            // -------- Bank 3 : NOTCH 50Hz ----------
            bank[3][0] <= 16'sd16381;
            bank[3][1] <= -16'sd32762;
            bank[3][2] <= 16'sd16381;
            bank[3][3] <= -16'sd32762;
            bank[3][4] <= 16'sd16379;

        end
        else if (we) begin
            bank[wr_bank][wr_addr] <= wr_data;
        end
    end

    always @(*) begin
        b0 = bank[rd_bank][0];
        b1 = bank[rd_bank][1];
        b2 = bank[rd_bank][2];
        a1 = bank[rd_bank][3];
        a2 = bank[rd_bank][4];
    end

endmodule