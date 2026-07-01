`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:05:21
// Design Name: 
// Module Name: UART RX
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


module uart_rx #(
    parameter integer CLK_FREQ = 100_000_000,
    parameter integer BAUD     = 115200
)(
    input  wire clk,
    input  wire reset,
    input  wire rx,

    output reg        rx_valid,
    output reg [7:0]  rx_byte
);
    localparam integer DIV = (CLK_FREQ + BAUD/2) / BAUD;

    localparam S_IDLE  = 2'd0;
    localparam S_START = 2'd1;
    localparam S_DATA  = 2'd2;
    localparam S_STOP  = 2'd3;

    reg [1:0] state;
    reg [$clog2(DIV+1)-1:0] cnt;
    reg [2:0] bitpos;
    reg [7:0] data;

    reg rx_sync1, rx_sync2;
    always @(posedge clk) begin
        rx_sync1 <= rx;
        rx_sync2 <= rx_sync1;
    end

    always @(posedge clk) begin
        if (reset) begin
            state    <= S_IDLE;
            cnt      <= 0;
            bitpos   <= 0;
            data     <= 8'd0;
            rx_valid <= 1'b0;
            rx_byte  <= 8'd0;
        end else begin
            rx_valid <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (rx_sync2 == 1'b0) begin
                        state <= S_START;
                        cnt   <= (DIV/2);
                    end
                end

                S_START: begin
                    if (cnt == 0) begin
                        if (rx_sync2 == 1'b0) begin
                            state  <= S_DATA;
                            bitpos <= 0;
                            cnt    <= DIV-1;
                        end else begin
                            state <= S_IDLE;
                        end
                    end else cnt <= cnt - 1;
                end

                S_DATA: begin
                    if (cnt == 0) begin
                        data[bitpos] <= rx_sync2;
                        cnt <= DIV-1;

                        if (bitpos == 3'd7) state <= S_STOP;
                        else bitpos <= bitpos + 1;
                    end else cnt <= cnt - 1;
                end

                S_STOP: begin
                    if (cnt == 0) begin
                        rx_byte  <= data;
                        rx_valid <= 1'b1;
                        state    <= S_IDLE;
                    end else cnt <= cnt - 1;
                end
            endcase
        end
    end
endmodule