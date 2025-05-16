parameter RADIX =16;
module Radix16FFT (
    input wire clk,
    input wire rst,
    input wire [DATA_WIDTH*RADIX-1:0] data_in, // 16 x 64-bit input data
    output wire [DATA_WIDTH*RADIX-1:0] final_out // Final sum output with carry
);

    wire [192*RADIX*16-1:0] data_shifted;
    wire [192*RADIX-1:0] sum_final;

    // Instantiate the circular left shift module
    circular_left_shift_16x64 shifter (
        .clk(clk),
        .rst(rst),
        .data_in(data_in),
        .data_shifted(data_shifted)
    );

    // Instantiate 16 CSA Tree modules
    genvar k;
    generate
        for (k = 0; k < RADIX; k = k + 1) begin : csa_trees
            CSA_Tree csa_tree (
                .in_bus(data_shifted[k*3072 +: 3072]),
                .sum_final(sum_final[k*192 +: 192])
            );
            Normalize Normalizer(
                .sum_in(sum_final[k*192 +: 192]),
                .norm_out(final_out[k*DATA_WIDTH +: DATA_WIDTH])
                );
        end
    endgenerate
endmodule