`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// top_static.v  (PURE VERILOG)
// DDS(50Hz) / STEP -> {BYPASS/FIR/IIR/HYBRID} -> UART TX stream
// Switch control for mode/banks + step select.
// UART RX parser kept only for coeff writes (future).
//////////////////////////////////////////////////////////////////////////////////

module top_static #(
    parameter integer CLK_FREQ = 50_000_000,
    parameter integer BAUD     = 115200,
    parameter integer FS_HZ    = 48000,
    parameter integer UART_SPS = 1000,
    parameter integer SINE_HZ  = 50
)(
    input  wire clk,
    input  wire reset,

    // UART
    input  wire uart_rx_i,
    output wire uart_tx_o,

    // SWITCHES
    input  wire [1:0] sw_mode,
    input  wire [1:0] sw_fir_bank,
    input  wire [1:0] sw_iir_bank,
    input  wire       sw_step,      // 1 = STEP, 0 = SINE

    // LEDS
    output wire [7:0] led
);

    // ------------------------------------------------------------
    // UART RX/TX
    // ------------------------------------------------------------
    wire       rx_valid;
    wire [7:0] rx_byte;

    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) U_RX (
        .clk(clk),
        .reset(reset),
        .rx(uart_rx_i),
        .rx_valid(rx_valid),
        .rx_byte(rx_byte)
    );

    reg        tx_start;
    reg  [7:0] tx_data;
    wire       tx_busy;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD(BAUD)) U_TX (
        .clk(clk),
        .reset(reset),
        .data_in(tx_data),
        .start(tx_start),
        .tx(uart_tx_o),
        .busy(tx_busy)
    );

    // ------------------------------------------------------------
    // UART command parser (KEPT for future coeff updates)
    // ------------------------------------------------------------
    wire [1:0] mode_sel_uart;
    wire [1:0] fir_bank_sel_uart;
    wire [1:0] iir_bank_sel_uart;
    wire       lat_trigger;
    wire       get_lat_cmd;

    wire         fir_we;
    wire [1:0]   fir_wr_bank;
    wire [3:0]   fir_wr_addr;
    wire signed [15:0] fir_wr_data;

    wire         iir_we;
    wire [1:0]   iir_wr_bank;
    wire [2:0]   iir_wr_addr;
    wire signed [15:0] iir_wr_data;

    uart_cmd_parser_4bank U_CMD (
        .clk(clk),
        .reset(reset),
        .rx_valid(rx_valid),
        .rx_byte(rx_byte),

        .mode_sel(mode_sel_uart),
        .fir_bank_sel(fir_bank_sel_uart),
        .iir_bank_sel(iir_bank_sel_uart),

        .fir_we(fir_we),
        .fir_wr_bank(fir_wr_bank),
        .fir_wr_addr(fir_wr_addr),
        .fir_wr_data(fir_wr_data),

        .iir_we(iir_we),
        .iir_wr_bank(iir_wr_bank),
        .iir_wr_addr(iir_wr_addr),
        .iir_wr_data(iir_wr_data),

        .lat_trigger(lat_trigger),
        .get_lat_cmd(get_lat_cmd)
    );

    // ------------------------------------------------------------
    // Sample tick generator (FS_HZ)
    // ------------------------------------------------------------
    localparam integer FS_DIV = (CLK_FREQ + FS_HZ/2) / FS_HZ;
    reg [$clog2(FS_DIV+1)-1:0] fs_cnt;
    reg sample_tick;

    always @(posedge clk) begin
        if (reset) begin
            fs_cnt      <= 0;
            sample_tick <= 1'b0;
        end else begin
            sample_tick <= 1'b0;
            if (fs_cnt == FS_DIV-1) begin
                fs_cnt      <= 0;
                sample_tick <= 1'b1;
            end else begin
                fs_cnt <= fs_cnt + 1;
            end
        end
    end

    // ------------------------------------------------------------
    // UART send tick generator (UART_SPS)
    // ------------------------------------------------------------
    localparam integer UART_DIV = (CLK_FREQ + UART_SPS/2) / UART_SPS;
    reg [$clog2(UART_DIV+1)-1:0] uart_cnt;
    reg uart_tick;

    always @(posedge clk) begin
        if (reset) begin
            uart_cnt  <= 0;
            uart_tick <= 1'b0;
        end else begin
            uart_tick <= 1'b0;
            if (uart_cnt == UART_DIV-1) begin
                uart_cnt  <= 0;
                uart_tick <= 1'b1;
            end else begin
                uart_cnt <= uart_cnt + 1;
            end
        end
    end

    // ------------------------------------------------------------
    // Switch synchronizers (REAL control signals)
    // ------------------------------------------------------------
    reg [1:0] sw_mode_ff1, sw_mode_ff2;
    reg [1:0] sw_fir_ff1,  sw_fir_ff2;
    reg [1:0] sw_iir_ff1,  sw_iir_ff2;
    reg       sw_step_ff1, sw_step_ff2;

    always @(posedge clk) begin
        sw_mode_ff1 <= sw_mode;
        sw_mode_ff2 <= sw_mode_ff1;

        sw_fir_ff1  <= sw_fir_bank;
        sw_fir_ff2  <= sw_fir_ff1;

        sw_iir_ff1  <= sw_iir_bank;
        sw_iir_ff2  <= sw_iir_ff1;

        sw_step_ff1 <= sw_step;
        sw_step_ff2 <= sw_step_ff1;
    end

    wire [1:0] mode_sel_sw     = sw_mode_ff2;
    wire [1:0] fir_bank_sel_sw = sw_fir_ff2;
    wire [1:0] iir_bank_sel_sw = sw_iir_ff2;
    wire       step_sel_sw     = sw_step_ff2;

    // ------------------------------------------------------------
    // DDS Sine (50 Hz) using LUT256
    // ------------------------------------------------------------
    wire [7:0] lut_addr;
    wire signed [15:0] lut_data;
    wire signed [15:0] sine_x;

    sin_lut256 U_LUT (
        .addr(lut_addr),
        .data(lut_data)
    );

    dds_sine_50hz #(.FS_HZ(FS_HZ), .SINE_HZ(SINE_HZ)) U_DDS (
        .clk(clk),
        .reset(reset),
        .tick(sample_tick),
        .lut_addr(lut_addr),
        .lut_data(lut_data),
        .sine_out(sine_x)
    );

    // ------------------------------------------------------------
    // STEP generator (verification)
    // ------------------------------------------------------------
    localparam signed [15:0] STEP_A = 16'sd20000;

    reg step_state;
    always @(posedge clk) begin
        if (reset) step_state <= 1'b0;
        else if (sample_tick) step_state <= 1'b1; // step after first tick
    end

    wire signed [15:0] step_x = step_state ? STEP_A : 16'sd0;

    // FINAL INPUT:
    wire signed [15:0] x_in = step_sel_sw ? step_x : sine_x;
    
    // latch bank select ONLY on sample_tick (safe, stable)
    reg [1:0] fir_bank_lat, iir_bank_lat;

    always @(posedge clk) begin
        if (reset) begin
            fir_bank_lat <= 2'd0;
            iir_bank_lat <= 2'd0;
        end else if (sample_tick) begin
            fir_bank_lat <= fir_bank_sel_sw;
            iir_bank_lat <= iir_bank_sel_sw;
        end
    end

    // ------------------------------------------------------------
    // 4-bank coefficient memories
    // ------------------------------------------------------------
    wire signed [15:0] fir_tap_rd;
    wire [3:0]         fir_tap_addr;

    fir_coef_bank4 U_FIRBANK (
        .clk(clk),
        .reset(reset),
        .we(fir_we),
        .wr_bank(fir_wr_bank),
        .wr_addr(fir_wr_addr),
        .wr_data(fir_wr_data),

        .rd_bank(fir_bank_lat),
        .rd_addr(fir_tap_addr),
        .rd_data(fir_tap_rd)
    );

    wire signed [15:0] b0, b1, b2, a1, a2;

    iir_coef_bank4 U_IIRBANK (
        .clk(clk),
        .reset(reset),
        .we(iir_we),
        .wr_bank(iir_wr_bank),
        .wr_addr(iir_wr_addr),
        .wr_data(iir_wr_data),

        .rd_bank(iir_bank_lat),
        .b0(b0), .b1(b1), .b2(b2), .a1(a1), .a2(a2)
    );

    // ------------------------------------------------------------
    // DSP cores
    // ------------------------------------------------------------
    wire signed [15:0] y_fir;
    wire signed [15:0] y_iir;
    wire signed [15:0] y_hybrid;

    fir16_core U_FIR (
        .clk(clk),
        .reset(reset),
        .sample_tick(sample_tick),
        .x_in(x_in),
        .coef_addr(fir_tap_addr),
        .coef_data(fir_tap_rd),
        .y_out(y_fir)
    );

    biquad_core U_IIR (
        .clk(clk),
        .reset(reset),
        .sample_tick(sample_tick),
        .x_in(x_in),
        .b0(b0), .b1(b1), .b2(b2), .a1(a1), .a2(a2),
        .y_out(y_iir)
    );

    biquad_core U_IIR_HYB (
        .clk(clk),
        .reset(reset),
        .sample_tick(sample_tick),
        .x_in(y_fir),
        .b0(b0), .b1(b1), .b2(b2), .a1(a1), .a2(a2),
        .y_out(y_hybrid)
    );

    // ------------------------------------------------------------
    // Output mux (switch mode)
    // ------------------------------------------------------------
    reg signed [15:0] y_static;

always @(posedge clk) begin
    if (reset) begin
        y_static <= 16'sd0;
    end else if (sample_tick) begin
        case (mode_sel_sw)
            2'd0: y_static <= x_in;     
            2'd1: y_static <= y_fir;    
            2'd2: y_static <= y_iir;    
            2'd3: y_static <= y_hybrid; 
            default: y_static <= x_in;
        endcase
    end
end

wire signed [15:0] y_pr;
wire ready_out_pr;
wire valid_out_pr;

// ------------------------------------------------------------
// LATENCY TESTER (Measurement Logic)
// ------------------------------------------------------------
wire [31:0] lat_filt, lat_stat, lat_pr_load, lat_pr_total;

latency_tester U_LAT_TESTER (
    .clk(clk),
    .reset(reset),
    .sample_tick(sample_tick),
    .valid_out(valid_out_pr),
    .mode_sel(mode_sel_sw),
    .ready_out(ready_out_pr),
    .start_pr_meas(lat_trigger),
    .filter_latency(lat_filt),
    .static_switch_latency(lat_stat),
    .pr_load_latency(lat_pr_load),
    .pr_total_latency(lat_pr_total)
);

// ------------------------------------------------------------
// PR FILTER SLOT (reconfigurable region input)
// ------------------------------------------------------------
pr_filter_slot U_PR_SLOT (
    .clk(clk),
    .reset(reset),
    .sample_tick(sample_tick),
    .x_in(y_static),
    .y_out(y_pr),
    .ready_out(ready_out_pr),
    .valid_out(valid_out_pr)
);
   // ------------------------------------------------------------
// UART streamer: framed output = AA 55 LSB MSB
// ------------------------------------------------------------
reg [4:0] tx_state;
reg signed [15:0] y_latched;
reg [31:0] lat1, lat2, lat3, lat4;
reg get_lat_req; // Latch for the GETLAT command

always @(posedge clk) begin
    if (reset) begin
        tx_state  <= 5'd0;
        tx_start  <= 1'b0;
        tx_data   <= 8'h00;
        y_latched <= 16'sd0;
        get_lat_req <= 1'b0;
    end else begin
        tx_start <= 1'b0;
        if (get_lat_cmd) get_lat_req <= 1'b1;

        case (tx_state)
            5'd0: begin
                if (get_lat_req && !tx_busy) begin
                    get_lat_req <= 1'b0; // Clear the memory
                    lat1 <= lat_filt;
                    lat2 <= lat_stat;
                    lat3 <= lat_pr_load;
                    lat4 <= lat_pr_total;
                    tx_data  <= 8'hEE;
                    tx_start <= 1'b1;
                    tx_state <= 5'd10;
                end else if (uart_tick && !tx_busy) begin
                    y_latched <= y_pr;
                    tx_data   <= 8'hAA;
                    tx_start  <= 1'b1;
                    tx_state  <= 5'd1;
                end
            end

            5'd1: if (!tx_busy) begin tx_data <= 8'h55;          tx_start <= 1'b1; tx_state <= 5'd2; end
            5'd2: if (!tx_busy) begin tx_data <= y_latched[7:0];   tx_start <= 1'b1; tx_state <= 5'd3; end
            5'd3: if (!tx_busy) begin tx_data <= y_latched[15:8];  tx_start <= 1'b1; tx_state <= 5'd0; end

            // Latency reporting states (EE FF + 4x32-bit + 55 AA)
            5'd10: if (!tx_busy) begin tx_data <= 8'hFF;     tx_start <= 1'b1; tx_state <= 5'd11; end
            
            // Lat 1
            5'd11: if (!tx_busy) begin tx_data <= lat1[7:0];   tx_start <= 1'b1; tx_state <= 5'd12; end
            5'd12: if (!tx_busy) begin tx_data <= lat1[15:8];  tx_start <= 1'b1; tx_state <= 5'd13; end
            5'd13: if (!tx_busy) begin tx_data <= lat1[23:16]; tx_start <= 1'b1; tx_state <= 5'd14; end
            5'd14: if (!tx_busy) begin tx_data <= lat1[31:24]; tx_start <= 1'b1; tx_state <= 5'd15; end
            
            // Lat 2
            5'd15: if (!tx_busy) begin tx_data <= lat2[7:0];   tx_start <= 1'b1; tx_state <= 5'd16; end
            5'd16: if (!tx_busy) begin tx_data <= lat2[15:8];  tx_start <= 1'b1; tx_state <= 5'd17; end
            5'd17: if (!tx_busy) begin tx_data <= lat2[23:16]; tx_start <= 1'b1; tx_state <= 5'd18; end
            5'd18: if (!tx_busy) begin tx_data <= lat2[31:24]; tx_start <= 1'b1; tx_state <= 5'd19; end
            
            // Lat 3
            5'd19: if (!tx_busy) begin tx_data <= lat3[7:0];   tx_start <= 1'b1; tx_state <= 5'd20; end
            5'd20: if (!tx_busy) begin tx_data <= lat3[15:8];  tx_start <= 1'b1; tx_state <= 5'd21; end
            5'd21: if (!tx_busy) begin tx_data <= lat3[23:16]; tx_start <= 1'b1; tx_state <= 5'd22; end
            5'd22: if (!tx_busy) begin tx_data <= lat3[31:24]; tx_start <= 1'b1; tx_state <= 5'd23; end
            
            // Lat 4
            5'd23: if (!tx_busy) begin tx_data <= lat4[7:0];   tx_start <= 1'b1; tx_state <= 5'd24; end
            5'd24: if (!tx_busy) begin tx_data <= lat4[15:8];  tx_start <= 1'b1; tx_state <= 5'd25; end
            5'd25: if (!tx_busy) begin tx_data <= lat4[23:16]; tx_start <= 1'b1; tx_state <= 5'd26; end
            5'd26: if (!tx_busy) begin tx_data <= lat4[31:24]; tx_start <= 1'b1; tx_state <= 5'd27; end
            
            // Tail
            5'd27: if (!tx_busy) begin tx_data <= 8'h55;       tx_start <= 1'b1; tx_state <= 5'd28; end
            5'd28: if (!tx_busy) begin tx_data <= 8'hAA;       tx_start <= 1'b1; tx_state <= 5'd0; end

            default: tx_state <= 5'd0;
        endcase
    end
end

    // ------------------------------------------------------------
    // LEDs (debug / alive)
    // ------------------------------------------------------------
    reg hb_sample, hb_uart, hb_wr;

    always @(posedge clk) begin
        if (reset) hb_sample <= 1'b0;
        else if (sample_tick) hb_sample <= ~hb_sample;
    end

    always @(posedge clk) begin
        if (reset) hb_uart <= 1'b0;
        else if (uart_tick) hb_uart <= ~hb_uart;
    end

    always @(posedge clk) begin
        if (reset) hb_wr <= 1'b0;
        else if (fir_we || iir_we) hb_wr <= ~hb_wr;
    end

    assign led[0]   = hb_sample;
    assign led[1]   = hb_uart;
    assign led[2]   = tx_busy;
    assign led[3]   = hb_wr;
    assign led[5:4] = mode_sel_sw;
    assign led[7:6] = fir_bank_sel_sw; // change if you prefer IIR bank display

endmodule