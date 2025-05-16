module interchange_module (
    input wire clk,
    input wire reset,
    input wire [15:0] cycle_count, // {stage, cycle_count[11:0]}
    input wire [1023:0] data_in,   // 16 x 64-bit input
    output reg [1023:0] data_out
);

    reg [11:0] index_map [0:15];  // Address mapping
    integer i;
    reg [63:0] permuted_data [0:15];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 0;
        end else begin
            for (i = 0; i < 16; i = i + 1) begin
                index_map[i] = cycle_count[11:0] + i * 4096; // Distribute across memory banks
                case (cycle_count[15:12])  // Extract stage from cycle_count
                    4'd0: index_map[i] = i;  // No change in first stage

                    4'd1: index_map[i] = (i[3:2] << 2) | (i[1:0]); // Swap inner groups

                    4'd2: index_map[i] = {i[1:0], i[3:2]}; // Swap 2-bit groups for bit-reversal

                    4'd3: index_map[i] = {i[2], i[3], i[0], i[1]}; // Deep bit swap for memory alignment

                    default: index_map[i] = i;
                endcase
                
                permuted_data[i] = data_in[index_map[i] * 64 +: 64];
            end
            
            data_out = {permuted_data[15], permuted_data[14], permuted_data[13], permuted_data[12],
                        permuted_data[11], permuted_data[10], permuted_data[9], permuted_data[8],
                        permuted_data[7], permuted_data[6], permuted_data[5], permuted_data[4],
                        permuted_data[3], permuted_data[2], permuted_data[1], permuted_data[0]};
        end
    end

endmodule
