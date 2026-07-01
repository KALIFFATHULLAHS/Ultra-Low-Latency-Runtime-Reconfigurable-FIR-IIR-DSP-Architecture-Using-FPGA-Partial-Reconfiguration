`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:05:21
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD     = 115200
)(
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] data_in,
    input  wire       start,
    output reg        tx,
    output reg        busy
);
    localparam integer DIV = (CLK_FREQ + BAUD/2) / BAUD;

    reg [$clog2(DIV+1)-1:0] cnt;
    reg [3:0] bitpos;
    reg [9:0] frame;

    always @(posedge clk) begin
        if (reset) begin
            tx     <= 1'b1;
            busy   <= 1'b0;
            cnt    <= 0;
            bitpos <= 0;
            frame  <= 10'h3FF;
        end else begin
            if (!busy) begin
                tx <= 1'b1;
                if (start) begin
                    frame  <= {1'b1, data_in, 1'b0}; // {stop, data, start}
                    busy   <= 1'b1;
                    bitpos <= 0;
                    cnt    <= DIV-1;
                    tx     <= 1'b0; // start bit now
                end
            end else begin
                if (cnt == 0) begin
                    cnt    <= DIV-1;
                    bitpos <= bitpos + 1;

                    if (bitpos == 4'd9) begin
                        busy <= 1'b0;
                        tx   <= 1'b1;
                    end else begin
                        tx <= frame[bitpos+1];
                    end
                end else begin
                    cnt <= cnt - 1;
                end
            end
        end
    end
endmodule