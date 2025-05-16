parameter BANK_SIZE = 4096; // 4096 locations per bank
parameter TOTAL_POINTS = 65536;
parameter BANK_COUNT = 16;
module MemoryBanks (
    input wire clk,
    input wire rst,               // Reset to initialize memory
    input wire wr_en,             // Write enable
    input wire [3:0] bank_num,    // Bank selection
    input wire [11:0] addr,       // Address in the assigned bank
    input wire [DATA_WIDTH*16-1:0] data_in,  // 16 samples input (1024 bits)
    input wire [65536*DATA_WIDTH-1:0] a,  // Full 64k samples input
    output reg [DATA_WIDTH*16-1:0] data_out  // 16 samples output
);

    // ? Declare 16 memory banks, each with 4096 locations of 64-bit words
    reg [DATA_WIDTH-1:0] mem [0:BANK_COUNT-1][0:BANK_SIZE-1];

    integer i, j;

    // ? **Initial Data Loading at Reset**
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < BANK_COUNT; i = i + 1) begin
                for (j = 0; j < BANK_SIZE; j = j + 1) begin
                    mem[i][j] <= a[(i * BANK_SIZE + j) * DATA_WIDTH +: DATA_WIDTH];
                end
            end
        end else if (wr_en) begin
            // ? **Write Only the Updated 16 Samples into Correct Bank**
            for (i = 0; i < 16; i = i + 1) begin
                mem[i][addr] <= data_in[i*DATA_WIDTH +: DATA_WIDTH];  
            end
        end 
    end

    // ? **Read 16 Samples from Correct Banks**
    always @(posedge clk) begin
        for (i = 0; i < 16; i = i + 1) begin
            data_out[i*DATA_WIDTH +: DATA_WIDTH] <= mem[i][addr];  
        end
    end

endmodule
