module modular_multiplier (
    input clk,                 // Clock signal
    input rst,                 // Reset signal
    input [DATA_WIDTH:0] x, y,         // 64-bit inputs
    output reg [DATA_WIDTH:0] result   // 64-bit modular multiplication result
);

    // Split inputs into 32-bit parts
    wire [DATA_WIDTH/2:0] xH, xL, yH, yL;
    assign xH = x[DATA_WIDTH-1:DATA_WIDTH/2];
    assign xL = x[DATA_WIDTH/2 - 1:0];
    assign yH = y[DATA_WIDTH-1:DATA_WIDTH/2];
    assign yL = y[DATA_WIDTH/2 - 1:0];

    // Pipeline registers for partial products
    reg [63:0] p1, p2, p3, p4;  // 32-bit * 32-bit results
    reg [127:0] product;  // Stores the full 128-bit multiplication result

    // Stage 1: Compute Partial Products
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            p1 <= 0; p2 <= 0; p3 <= 0; p4 <= 0;
        end else begin
            p1 <= xH * yH;  // High x High
            p2 <= xH * yL;  // High x Low
            p3 <= xL * yH;  // Low x High
            p4 <= xL * yL;  // Low x Low
        end
    end

    // Stage 2: Compute Full 128-bit Product
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            product <= 0;
        end else begin
        //TO-D0 64,32 FOR 64 AND 4,2 FOR 4
            product <= {p1, 64'b0} + {p2, 32'b0} + {p3, 32'b0} + p4;
        end
    end

    // Extract 32-bit components from the 128-bit product
    wire [31:0] a, b, c, d;
    assign a = product[2*DATA_WIDTH-1:3*DATA_WIDTH/2];
    assign b = product[3*DATA_WIDTH/2-1:DATA_WIDTH];
    assign c = product[DATA_WIDTH-1:DATA_WIDTH/2];
    assign d = product[DATA_WIDTH/2-1:0];

    // Pipeline registers for modular reduction
    reg [31:0] add_ab, add_bc, shifted_bc, sub_result, reg_d;
    reg [31:0] reg_addmod;

    // Stage 3: Compute Intermediate Values
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            add_ab <= 0;
            add_bc <= 0;
        end else begin
            add_ab <= a + b;    
            add_ab <= b + c;    // Addition
        end
    end

    // Stage 4: Subtraction and Register Storage
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sub_result <= 0;
            reg_d <= 0;
            shifted_bc <= 0;
        end else begin
            shifted_bc <= add_ab << 32;
            sub_result <= add_ab - shifted_bc;  // Subtraction
            reg_d <= d;  // Store d in a register
        end
    end

    // Stage 5: Final Modular Addition
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_addmod <= 0;
        end else begin
            reg_addmod <= sub_result + reg_d; // Final modular addition
        end
    end

    // Stage 6: Assign Final Modular Multiplication Result
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
        end else begin
            result <= reg_addmod;
        end
    end

endmodule
