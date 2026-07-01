`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:07:38
// Design Name: 
// Module Name: ir_coef_bank4
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


module fir_coef_bank4(
    input  wire clk,
    input  wire reset,

    input  wire        we,
    input  wire [1:0]  wr_bank,
    input  wire [3:0]  wr_addr,
    input  wire signed [15:0] wr_data,

    input  wire [1:0]  rd_bank,
    input  wire [3:0]  rd_addr,
    output reg  signed [15:0] rd_data
);

    reg signed [15:0] bank [0:3][0:15];

    integer i;

    // ---------------------------
    // RESET PRELOAD
    // ---------------------------
    always @(posedge clk) begin
        if (reset) begin

            // -------- Bank 0 : LPF (16-pt average) ----------
            for (i=0; i<16; i=i+1)
                bank[0][i] <= 16'sd2048; // 1/16

            // -------- Bank 1 : HPF ----------
            bank[1][0] <= 16'sd32767;
            bank[1][1] <= -16'sd32767;
            for (i=2; i<16; i=i+1)
                bank[1][i] <= 16'sd0;

            // -------- Bank 2 : Identity ----------
            bank[2][0] <= 16'sd32767;
            for (i=1; i<16; i=i+1)
                bank[2][i] <= 16'sd0;

            // -------- Bank 3 : 8-pt LPF ----------
            for (i=0; i<8; i=i+1)
                bank[3][i] <= 16'sd4096; // 1/8
            for (i=8; i<16; i=i+1)
                bank[3][i] <= 16'sd0;
        end
        else if (we) begin
            bank[wr_bank][wr_addr] <= wr_data;
        end
    end

    always @(*) begin
        rd_data = bank[rd_bank][rd_addr];
    end

endmodule