module circular_left_shift_unit (
    input  wire clk,
    input  wire rst,
    input  wire [16*64-1:0] data_in,  // 1024-bit input (16 x 64-bit)
    input  wire [3:0] k,              // Shift pattern index (0 to 15)
    output reg  [16*192-1:0] data_shifted // 1024-bit shifted output
);

    integer n;
    integer shift_amt;
    reg [191:0] padded_segment;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_shifted <= 1024'b0;
        end else begin
            for (n = 0; n < 16; n = n + 1) begin
                shift_amt = (k * n * 12) % 192; // Compute shift dynamically
                padded_segment = {128'b0, data_in[n*64 +: 64]}; // Zero pad to 192 bits
                data_shifted[n*192 +: 192] <= (padded_segment << shift_amt) | (padded_segment >> (192 - shift_amt));
            end
        end
    end
endmodule