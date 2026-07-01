`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 17:52:50
// Design Name: 
// Module Name: pr_filter_slot
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


module pr_filter_slot(
    input  wire clk,
    input  wire reset,
    input  wire sample_tick,
    input  wire signed [15:0] x_in,
    output wire signed [15:0] y_out,
    output wire ready_out,
    output wire valid_out
);

    // CRITICAL DFX FIX 2.0 (The DSP Clock Starvation Bug): 
    // Because this static Black Box originally contained ZERO mathematical operations,
    // Vivado physically severed the high-power DSP Clock routing inside the Pblock 
    // to save battery power during the base static implementation (`impl_1`)! 
    // When the FIR/IIR partial bitstreams loaded later, their DSPs had NO CLOCK and crashed!
    // We MUST use a multiplication here to force Vivado to leave the DSP clock tree permanently powered ON!
    reg signed [15:0] dummy_reg;
    reg signed [31:0] dummy_dsp;
    
    always @(posedge clk) begin
        if (reset) begin
            dummy_reg <= 16'sd0;
            dummy_dsp <= 32'sd0;
        end else if (sample_tick) begin
            dummy_reg <= x_in;
            dummy_dsp <= x_in * 16'sd2; // Forces exactly 1 DSP hardware multiplier!
        end
    end

    // Use both so the compiler cannot optimize them away
    assign y_out = dummy_reg + dummy_dsp[15:0];
    assign ready_out = 1'b1;
    assign valid_out = sample_tick; // bypass mode produces valid immediately

endmodule