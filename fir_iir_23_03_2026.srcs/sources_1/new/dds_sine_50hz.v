`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:05:21
// Design Name: 
// Module Name: dds_sine_50hz
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


module dds_sine_50hz #(
    parameter integer FS_HZ   = 48000,
    parameter integer SINE_HZ = 50
)(
    input  wire clk,
    input  wire reset,
    input  wire tick,                 // advance one audio sample on tick
    output wire [7:0] lut_addr,
    input  wire signed [15:0] lut_data,
    output reg  signed [15:0] sine_out
);
    // phase accumulator
    reg [31:0] phase;

    // phase_inc = round( SINE_HZ * 2^32 / FS_HZ )
    localparam [31:0] PHASE_INC = (SINE_HZ * 64'd4294967296 + (FS_HZ/2)) / FS_HZ;

    assign lut_addr = phase[31:24]; // top 8 bits => 256 entries

    always @(posedge clk) begin
        if (reset) begin
            phase    <= 32'd0;
            sine_out <= 16'sd0;
        end else if (tick) begin
            phase    <= phase + PHASE_INC;
            sine_out <= lut_data;
        end
    end
endmodule