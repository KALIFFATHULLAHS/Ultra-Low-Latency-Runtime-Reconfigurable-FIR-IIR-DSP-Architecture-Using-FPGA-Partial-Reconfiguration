`timescale 1ns / 1ps

module latency_tester (
    input wire clk,
    input wire reset,

    // Probe signals
    input wire sample_tick,
    input wire valid_out,
    input wire [1:0] mode_sel,
    input wire ready_out,
    
    // Command signals
    input wire start_pr_meas,
    
    // Results (in cycles)
    output reg [31:0] filter_latency,
    output reg [31:0] static_switch_latency,
    output reg [31:0] pr_load_latency,
    output reg [31:0] pr_total_latency
);

    // 1. Filter Processing Latency
    reg [31:0] filt_cnt;
    reg filt_measuring;
    
    always @(posedge clk) begin
        if (reset) begin
            filt_cnt <= 0;
            filt_measuring <= 1'b0;
            filter_latency <= 0;
        end else begin
            if (sample_tick) begin
                filt_cnt <= 1;
                filt_measuring <= 1'b1;
            end else if (filt_measuring) begin
                if (valid_out) begin
                    filter_latency <= filt_cnt;
                    filt_measuring <= 1'b0;
                end else begin
                    filt_cnt <= filt_cnt + 1;
                end
            end
        end
    end

    // 2. Static Switching Latency
    reg [1:0] mode_prev;
    reg [31:0] static_cnt;
    reg static_measuring;
    
    always @(posedge clk) begin
        if (reset) begin
            mode_prev <= 0;
            static_cnt <= 0;
            static_measuring <= 1'b0;
            static_switch_latency <= 0;
        end else begin
            mode_prev <= mode_sel;
            if (mode_sel != mode_prev) begin
                static_cnt <= 1;
                static_measuring <= 1'b1;
            end else if (static_measuring) begin
                if (valid_out) begin
                    static_switch_latency <= static_cnt;
                    static_measuring <= 1'b0;
                end else begin
                    static_cnt <= static_cnt + 1;
                end
            end
        end
    end

    // 3. PR Latency
    // Note: We "ARM" the measurement via UART command.
    // The measurement stops when ready_out goes high (new bitstream loaded).
    reg pr_measuring;
    reg pr_total_measuring;
    reg [31:0] pr_cnt;
    reg ready_prev;

    always @(posedge clk) begin
        if (reset) begin
            pr_measuring <= 1'b0;
            pr_total_measuring <= 1'b0;
            pr_cnt <= 0;
            ready_prev <= 1'b0;
            pr_load_latency <= 0;
            pr_total_latency <= 0;
        end else begin
            ready_prev <= ready_out;
            
            if (start_pr_meas) begin
                pr_cnt <= 1;
                pr_measuring <= 1'b1;
                pr_total_measuring <= 1'b1;
            end else begin
                if (pr_measuring || pr_total_measuring) begin
                    pr_cnt <= pr_cnt + 1;
                end

                // Detect PR Load Finish (ready_out rising edge)
                // In DFX, the region is usually disconnected during PR.
                // ready_out will be seen as 0 or 1 depending on decoupling.
                // We assume it goes from 'unknown/0' to '1' when loaded.
                if (pr_measuring && ready_out && !ready_prev) begin
                    pr_load_latency <= pr_cnt;
                    pr_measuring <= 1'b0;
                end
                
                // Detect First Valid Output after PR
                if (pr_total_measuring && valid_out) begin
                    pr_total_latency <= pr_cnt;
                    pr_total_measuring <= 1'b0;
                end
            end
        end
    end

endmodule
