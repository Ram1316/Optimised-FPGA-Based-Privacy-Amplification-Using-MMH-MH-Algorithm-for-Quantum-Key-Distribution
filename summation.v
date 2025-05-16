module summation #(
    parameter GAMMA = 13,        // Bit-width of data elements
    parameter K = 16,         // Number of elements
    parameter P = 64'h7F  // Prime modulus
)(
    input wire clk,
    input wire rst,
    input wire valid_in,
    input wire [GAMMA*K-1:0] data_in, // Flattened input for y_i
    output reg [GAMMA-1:0] sum_out,  // Summed value y
    output reg valid_out
);

    reg [GAMMA-1:0] sum; // Accumulator for sum
    integer i;

    // *Summation Logic*
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sum <= 0;
            valid_out <= 0;
        end else if (valid_in) begin
            sum = 0; // Use blocking assignment inside sequential logic
            for (i = 0; i < K; i = i + 1) begin
                sum = (sum + data_in[GAMMA*i +: GAMMA]) % P; // Modular Summation
            end
            sum_out <= sum;
            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end

endmodule