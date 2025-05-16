module CSA4(
    input [191:0] a, // 4-bit input a
    input [191:0] b, // 4-bit input b
    input [191:0] c, // 4-bit input c
    input [191:0] d, // 4th input for cascading
    output [191:0] ps, // Partial Sum
    output [191:0] sc  // Shift Carry
);
    wire [191:0] ps1, sc1; // Intermediate values from first CSA

    // First Carry-Save Adder
    genvar i;
    generate
        for (i = 0; i < 192; i = i + 1) begin : csa1
            assign ps1[i] = a[i] ^ b[i] ^ c[i]; // Partial Sum
            assign sc1[i] = ((a[i] & b[i]) | (a[i] & c[i]) | (b[i] & c[i])) << 1; // Shift Carry using Barrel Shifter
        end
    endgenerate

    // Second Carry-Save Adder (Cascading)
    generate
        for (i = 0; i < 192; i = i + 1) begin : csa2
            assign ps[i] = ps1[i] ^ sc1[i] ^ d[i]; // Final Partial Sum
            assign sc[i] = ((ps1[i] & sc1[i]) | (ps1[i] & d[i]) | (sc1[i] & d[i])) << 1; // Final Shift Carry
        end
    endgenerate

endmodule