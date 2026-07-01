module biquad_core(
    input  wire clk,
    input  wire reset,
    input  wire sample_tick,

    input  wire signed [15:0] x_in,

    input  wire signed [15:0] b0,
    input  wire signed [15:0] b1,
    input  wire signed [15:0] b2,
    input  wire signed [15:0] a1,
    input  wire signed [15:0] a2,

    output reg signed [15:0] y_out
);
    reg signed [15:0] x1, x2;
    reg signed [15:0] y1, y2;
    reg signed [15:0] x_r;
    reg signed [15:0] b0_r, b1_r, b2_r, a1_r, a2_r;
    reg signed [31:0] acc;
    reg signed [15:0] y_next;
    
    always @(posedge clk) begin
        if (reset) begin
            x_r  <= 16'sd0;
            b0_r <= 16'sd0; b1_r <= 16'sd0; b2_r <= 16'sd0;
            a1_r <= 16'sd0; a2_r <= 16'sd0;
        end else if (sample_tick) begin
            x_r  <= x_in;
            b0_r <= b0; b1_r <= b1; b2_r <= b2;
            a1_r <= a1; a2_r <= a2;
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            x1 <= 0; x2 <= 0;
            y1 <= 0; y2 <= 0;
            y_out <= 0;
        end else if (sample_tick) begin
            acc = 32'sd0;

            acc = acc + (b0 * x_in);
            acc = acc + (b1 * x1);
            acc = acc + (b2 * x2);
            acc = acc - (a1 * y1);
            acc = acc - (a2 * y2);

            y_next = acc >>> 14;

            // update states
            x2 <= x1;
            x1 <= x_in;
            y2 <= y1;
            y1 <= y_next;

            y_out <= y_next;
        end
    end
endmodule