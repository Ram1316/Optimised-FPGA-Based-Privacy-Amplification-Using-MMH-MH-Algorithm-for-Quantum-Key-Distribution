parameter STAGES = 4;
parameter CYCLES_PER_STAGE = 4096;
module FFT_Processor (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [TOTAL_POINTS*DATA_WIDTH-1:0] a,  // Full 64k samples input (stored in memory banks)
    input wire [RADIX*DATA_WIDTH-1:0] w,        // 16 x 64-bit twiddle factors from ROM
    output reg done
);
    // Internal Signals
    wire [RADIX*DATA_WIDTH-1:0] memory_out;
    wire [RADIX*DATA_WIDTH-1:0] interchanged_out; // Interchanged data before FFT
    wire [RADIX*DATA_WIDTH-1:0] radix16_out;
    wire [RADIX*DATA_WIDTH-1:0] mult_out;
    wire [RADIX*DATA_WIDTH-1:0] permuted_out;
    reg wr_en;
    reg [11:0] cycle_count;
    reg [3:0] stage;
    wire [11:0] addr;
    wire [3:0] bank_num;
    wire [15:0] data_count; // Combined {stage, cycle_count}

    // Control State Machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycle_count <= 0;
            stage <= 0;
            done <= 0;
            wr_en <= 0;
        end else if (start) begin
            wr_en <= 1;  // Enable writing after first cycle
            if (cycle_count < CYCLES_PER_STAGE - 1) begin
                cycle_count <= cycle_count + 1;
            end else if (stage < STAGES - 1) begin  // Fix: stage should be < STAGES - 1
                cycle_count <= 0;
                stage <= stage + 1;
            end else begin
                done <= 1;
            end
        end
    end 

    assign data_count = {stage, cycle_count}; // Fix: Explicitly define data_count

    // Address Generation Unit (Following the conflict-free mapping)
    AddressGenerationUnit addr_gen (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_count(data_count),  // Fix: Correct input mapping
        .addr(addr),
        .bank_num(bank_num)
    );

    // Memory Banks: Stores input and processes data in-place
    MemoryBanks memory_banks (
        .clk(clk),
        .rst(rst),
        .a(a),
        .wr_en(wr_en),  // Fix: Ensure wr_en is correctly controlled
        .bank_num(bank_num),
        .addr(addr),
        .data_in((cycle_count == 0 | stage == 0) ? a[(addr*DATA_WIDTH)+:16*DATA_WIDTH] : permuted_out), // Initial storage, then overwrites
        .data_out(memory_out)
    );
    
    permutation_module permute_b (
        .clk(clk),
        .rst(rst),
        .stage(stage),
        .data_in(memory_out),
        .data_out(interchanged_out)
    );

    // Radix-16 FFT Computation
    Radix16FFT radix16 (
        .clk(clk),
        .rst(rst),
        .data_in(interchanged_out), // Fix: Pass interchanged data
        .final_out(radix16_out)
    );

    // Modular Multiplication with Twiddle Factors
    genvar k;
    generate
        for (k = 0; k < RADIX; k = k + 1) begin : multiplier_loop
            modular_multiplier multiplier (
                .clk(clk),
                .rst(rst),
                .x(radix16_out[k*DATA_WIDTH +: DATA_WIDTH]),
                .y(w[k*DATA_WIDTH +: DATA_WIDTH]),
                .result(mult_out[k*DATA_WIDTH +: DATA_WIDTH])
            );
        end
    endgenerate

    // Permutation Module: Ensures correct output storage
    permutation_module permute (
        .clk(clk),
        .rst(rst),
        .stage(stage),
        .data_in(mult_out),
        .data_out(permuted_out)
    );

endmodule
