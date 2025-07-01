module carry_save_adder(
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    output [31:0] sum,
    output [31:0] cout
);

wire [31:0] partial_sum;
wire [31:0] carry_out;

genvar i;
generate
for (i = 0; i < 32; i=i+1) begin : csa_loop
    full_adder fa(
        .a(a[i]),
        .b(b[i]),
        .cin(c[i]),
        .sum(partial_sum[i]),
        .cout(carry_out[i])
    );
end
endgenerate

ripple_carry_adder_32bit rca(
    .a(partial_sum),
    .b(carry_out),
    .sum(sum)
    //.cout(cout)
);

endmodule
