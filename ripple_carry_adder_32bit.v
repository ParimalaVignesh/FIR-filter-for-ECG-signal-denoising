module ripple_carry_adder_32bit(
input [31:0] a,
input [31:0] b,
output [31:0] sum
);

wire [31:0] carry;
genvar i;
generate
for (i = 0; i < 32; i=i+1) begin
if (i == 0) begin
full_adder fa(
.a(a[i]),
.b(b[i]),
.cin(1'b0),
.sum(sum[i]),
.cout(carry[i])
);
end else begin
full_adder fa(
.a(a[i]),
.b(b[i]),
.cin(carry[i-1]),
.sum(sum[i]),
.cout(carry[i])
);
end
end
endgenerate
endmodule