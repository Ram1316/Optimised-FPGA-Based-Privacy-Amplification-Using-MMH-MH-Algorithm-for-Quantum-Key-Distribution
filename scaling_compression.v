module scaling_compression #(
    parameter GAMMA = 13,        // Bit-width of data elements
    parameter ALPHA = 24,        // ? value
    parameter BETA = 16          // ? value (? > ?)
)(
    input wire clk,
    input wire rst,
    input wire valid_in,
    input wire [GAMMA-1:0] data_z_in,  // Input: z from INTT(z)
    input wire [GAMMA-1:0] c,          // Random value c
    output reg [GAMMA-1:0] data_z_out, // Output: final processed z
    output reg valid_out
);

    reg [GAMMA-1:0] z_mod; // Intermediate storage

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_z_out <= 0;
            valid_out  <= 0;
        end 
        else if (valid_in) begin
            // Step 1: Compute (z + c) mod 2^?
            z_mod <= (data_z_in + c) & ((1 << ALPHA) - 1);
            
            // Step 2: Divide by 2^(?-?) using right shift
            data_z_out <= z_mod >> (ALPHA - BETA);

            valid_out <= 1;
        end 
        else begin
            valid_out <= 0;
        end
    end

endmodule