module AddressGenerationUnit (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [15:0] data_count,  // Combined {stage, cycle_count} index
    output reg [3:0] bank_num,     // Assigned bank
    output reg [11:0] addr         // Address within the bank
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bank_num <= 0;
            addr <= 0;
        end else if (start) begin
            // Compute Bank Number using MOD-16 indexing
            bank_num <= data_count[3:0];  // Last 4 bits determine bank (ensures even distribution)
            
            // Compute Address inside the assigned Bank (Ensuring conflict-free access)
            addr <= data_count[15:4];  // Upper 12 bits as address
        end
    end
endmodule
