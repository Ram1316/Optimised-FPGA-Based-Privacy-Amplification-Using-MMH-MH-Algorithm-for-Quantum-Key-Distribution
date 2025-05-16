module CSA_Tree (
    input  wire [192*16-1:0] in_bus, // 16 inputs packed into a single bus
    output wire [63:0] final // Final sum output with carry included
);

    wire [191:0] in [15:0];
    wire [191:0] ps1 [3:0], sc1 [3:0]; // Outputs of first stage
    wire [191:0] ps2 [1:0], sc2 [1:0]; // Outputs of second stage
    wire [191:0] ps3, sc3;            // Outputs of third stage
    wire [191:0] final_sum;            // Final sum with carry bit
    
    // Unpacking input bus into individual 192-bit signals
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : unpack_inputs
            assign in[i] = in_bus[i*192 +: 192];
        end
    endgenerate

    // Stage 1: 16 inputs -> 8 outputs (4 CSA4 units)
    CSA4 csa_stage1_0 (.a(in[0]), .b(in[1]), .c(in[2]), .d(in[3]), .ps(ps1[0]), .sc(sc1[0]));
    CSA4 csa_stage1_1 (.a(in[4]), .b(in[5]), .c(in[6]), .d(in[7]), .ps(ps1[1]), .sc(sc1[1]));
    CSA4 csa_stage1_2 (.a(in[8]), .b(in[9]), .c(in[10]), .d(in[11]), .ps(ps1[2]), .sc(sc1[2]));
    CSA4 csa_stage1_3 (.a(in[12]), .b(in[13]), .c(in[14]), .d(in[15]), .ps(ps1[3]), .sc(sc1[3]));

    // Stage 2: 8 inputs -> 4 outputs (2 CSA4 units)
    CSA4 csa_stage2_0 (.a(ps1[0]), .b(ps1[1]), .c(sc1[0]), .d(sc1[1]), .ps(ps2[0]), .sc(sc2[0]));
    CSA4 csa_stage2_1 (.a(ps1[2]), .b(ps1[3]), .c(sc1[2]), .d(sc1[3]), .ps(ps2[1]), .sc(sc2[1]));

    // Stage 3: 4 inputs -> 2 outputs (1 CSA4 unit)
    CSA4 csa_stage3 (.a(ps2[0]), .b(ps2[1]), .c(sc2[0]), .d(sc2[1]), .ps(ps3), .sc(sc3));
    
    // Final Addition (Full Addition to obtain final sum)
    assign final_sum = ps3 + sc3;
    assign sum_final = final_sum; 
    Normalize Normalizer(
                .sum_in(sum_final),
                .norm_out(final)
                );
    
endmodule
