`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.02.2026 13:05:21
// Design Name: 
// Module Name: uart_cmd_parser_4bank
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


module uart_cmd_parser_4bank(
    input  wire        clk,
    input  wire        reset,
    input  wire        rx_valid,
    input  wire [7:0]  rx_byte,

    output reg  [1:0]  mode_sel,
    output reg  [1:0]  fir_bank_sel,
    output reg  [1:0]  iir_bank_sel,

    output reg         fir_we,
    output reg  [1:0]  fir_wr_bank,
    output reg  [3:0]  fir_wr_addr,
    output reg  signed [15:0] fir_wr_data,

    output reg         iir_we,
    output reg  [1:0]  iir_wr_bank,
    output reg  [2:0]  iir_wr_addr,
    output reg  signed [15:0] iir_wr_data,

    output reg         lat_trigger,
    output reg         get_lat_cmd
);
    reg [7:0] cmd [0:47];
    reg [5:0] idx;
    reg cmd_ready;
    integer k;

    function automatic signed [15:0] parse_sdddd;
        input [7:0] signc, d0, d1, d2, d3;
        integer v;
        integer neg;
    begin
        v = 0;
        neg = (signc == "-");
        if (d0 >= "0" && d0 <= "9") v = v*10 + (d0 - "0");
        if (d1 >= "0" && d1 <= "9") v = v*10 + (d1 - "0");
        if (d2 >= "0" && d2 <= "9") v = v*10 + (d2 - "0");
        if (d3 >= "0" && d3 <= "9") v = v*10 + (d3 - "0");
        parse_sdddd = neg ? -v[15:0] : v[15:0];
    end
    endfunction

    function automatic [3:0] parse_2d;
        input [7:0] d0, d1;
        integer v;
    begin
        v = (d0 - "0")*10 + (d1 - "0");
        parse_2d = v[3:0];
    end
    endfunction

    // collect bytes into cmd[] until newline
    always @(posedge clk) begin
        if (reset) begin
            idx       <= 0;
            cmd_ready <= 1'b0;
            for (k=0; k<48; k=k+1) cmd[k] <= 8'h00;
        end else begin
            cmd_ready <= 1'b0;

            if (rx_valid) begin
                if (rx_byte == 8'h0A || rx_byte == 8'h0D) begin
                    if (idx != 0) begin
                        cmd_ready <= 1'b1;
                        idx <= 0;
                    end
                end else begin
                    if (idx < 47) begin
                        cmd[idx] <= rx_byte;
                        idx <= idx + 1;
                    end
                end
            end
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            mode_sel     <= 2'd0;
            fir_bank_sel <= 2'd0;
            iir_bank_sel <= 2'd0;

            fir_we       <= 1'b0;
            iir_we       <= 1'b0;

            fir_wr_bank  <= 2'd0;
            fir_wr_addr  <= 4'd0;
            fir_wr_data  <= 16'sd0;

            iir_wr_bank  <= 2'd0;
            iir_wr_addr  <= 3'd0;
            iir_wr_data  <= 16'sd0;

            lat_trigger  <= 1'b0;
            get_lat_cmd  <= 1'b0;
        end else begin
            fir_we      <= 1'b0;
            iir_we      <= 1'b0;
            lat_trigger <= 1'b0;
            get_lat_cmd <= 1'b0;

            if (cmd_ready) begin
                // MODE m
                if (cmd[0]=="M" && cmd[1]=="O" && cmd[2]=="D" && cmd[3]=="E" && cmd[4]==" ") begin
                    mode_sel <= cmd[5] - "0";
                end
                // FBANK b
                else if (cmd[0]=="F" && cmd[1]=="B" && cmd[2]=="A" && cmd[3]=="N" && cmd[4]=="K" && cmd[5]==" ") begin
                    fir_bank_sel <= cmd[6] - "0";
                end
                // IBANK b
                else if (cmd[0]=="I" && cmd[1]=="B" && cmd[2]=="A" && cmd[3]=="N" && cmd[4]=="K" && cmd[5]==" ") begin
                    iir_bank_sel <= cmd[6] - "0";
                end
                // FIR b aa sdddd   e.g. "FIR 2 07 -0123"
                else if (cmd[0]=="F" && cmd[1]=="I" && cmd[2]=="R" && cmd[3]==" ") begin
                    fir_wr_bank <= cmd[4] - "0";
                    fir_wr_addr <= parse_2d(cmd[6], cmd[7]);
                    fir_wr_data <= parse_sdddd(cmd[9], cmd[10], cmd[11], cmd[12], cmd[13]);
                    fir_we      <= 1'b1;
                end
                // IIR b a sdddd     e.g. "IIR 3 4 +0256"
                else if (cmd[0]=="I" && cmd[1]=="I" && cmd[2]=="R" && cmd[3]==" ") begin
                    iir_wr_bank <= cmd[4] - "0";
                    iir_wr_addr <= cmd[6] - "0";
                    iir_wr_data <= parse_sdddd(cmd[8], cmd[9], cmd[10], cmd[11], cmd[12]);
                    iir_we      <= 1'b1;
                end
                // LAT
                else if (cmd[0]=="L" && cmd[1]=="A" && cmd[2]=="T") begin
                    lat_trigger <= 1'b1;
                end
                // GETLAT
                else if (cmd[0]=="G" && cmd[1]=="E" && cmd[2]=="T" && cmd[3]=="L" && cmd[4]=="A" && cmd[5]=="T") begin
                    get_lat_cmd <= 1'b1;
                end
            end
        end
    end
endmodule