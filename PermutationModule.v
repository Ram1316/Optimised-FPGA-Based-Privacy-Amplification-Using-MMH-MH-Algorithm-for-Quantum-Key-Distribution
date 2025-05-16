module permutation_module (
    input wire clk,
    input wire rst,
    input wire [64*16-1:0] data_in,       // 16 x 64-bit input data from memory banks
    input wire [16*4-1:0] bank_num,       // Bank assignment for current chunk
    input wire fft_enable,
    input wire [11:0] cycle_count,        // Cycle count to track processing
    output reg [64*16-1:0] data_out       // Ordered output data
);

    parameter DATA_WIDTH = 64;  
    parameter BANK_COUNT = 16;   

    reg [DATA_WIDTH-1:0] temp_data [0:BANK_COUNT-1];    // Temporary storage for fetched data
    reg [3:0] data_count [0:BANK_COUNT-1];              // Data count for reordering

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0;
        end else if (fft_enable) begin
            // Step 1: Fetch data from banks using `bank_num`
            for (i = 0; i < BANK_COUNT; i = i + 1) begin
                temp_data[i] = data_in[bank_num[i*4 +: 4] * DATA_WIDTH +: DATA_WIDTH];
            end

            // Step 2: Generate `data_count` for reordering
            for (i = 0; i < BANK_COUNT; i = i + 1) begin
                data_count[i] = (cycle_count + i) % BANK_COUNT;
            end

            // Step 3: Reorder data using `data_count`
            for (i = 0; i < BANK_COUNT; i = i + 1) begin
                data_out[data_count[i] * DATA_WIDTH +: DATA_WIDTH] <= temp_data[i];
            end
        end
        // else: retain previous data_out
    end

endmodule
