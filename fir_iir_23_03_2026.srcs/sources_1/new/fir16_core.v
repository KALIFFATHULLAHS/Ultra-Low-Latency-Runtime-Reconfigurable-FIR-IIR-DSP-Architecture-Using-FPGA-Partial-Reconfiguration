module fir16_core(
    input  wire clk,
    input  wire reset,
    input  wire sample_tick,

    input  wire signed [15:0] x_in,

    // coeff memory interface
    output reg  [3:0]  coef_addr,
    input  wire signed [15:0] coef_data,

    output reg  signed [15:0] y_out
);
    reg signed [15:0] xdelay [0:15];
    reg [4:0] mac_i;
    reg signed [31:0] acc;
    reg mac_busy;

    integer k;

    always @(posedge clk) begin
        if (reset) begin
            for (k=0; k<16; k=k+1) xdelay[k] <= 16'sd0;
            mac_i     <= 5'd0;
            acc       <= 32'sd0;
            coef_addr <= 4'd0;
            y_out     <= 16'sd0;
            mac_busy  <= 1'b0;
        end else begin
            // start a new MAC on sample tick
            if (sample_tick && !mac_busy) begin
                // shift in new sample
                for (k=15; k>0; k=k-1) xdelay[k] <= xdelay[k-1];
                xdelay[0] <= x_in;

                acc       <= 32'sd0;
                mac_i     <= 5'd0;
                coef_addr <= 4'd0;
                mac_busy  <= 1'b1;
            end
            else if (mac_busy) begin
                // accumulate one tap per clock
                acc <= acc + (xdelay[mac_i[3:0]] * coef_data);

                mac_i <= mac_i + 1;
                coef_addr <= mac_i[3:0] + 1; // next tap address

                if (mac_i == 5'd15) begin
                    // finished last tap this cycle; next cycle acc updates,
                    // so latch output using (acc + last_product) is tricky.
                    // easiest: latch output one cycle later:
                    mac_busy <= 1'b0;
                end
            end
            else begin
                // when MAC just finished, output the accumulated result
                // NOTE: output uses the final acc value (already accumulated)
                // scale Q1.15
                y_out <= acc >>> 15;
            end
        end
    end
endmodule