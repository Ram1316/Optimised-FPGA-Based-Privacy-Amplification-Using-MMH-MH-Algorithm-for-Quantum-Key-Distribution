module Normalize (
    input  [191:0] sum_in,
    output [63:0] norm_out
);
    
    wire [31:0] a, b, c, d, e, f;
    assign {a, b, c, d, e, f} = sum_in;

    assign norm_out = (e + f) + ((d + a) << 32) - ((b + c) << 32) - (a + d);
endmodule