module dadda_multiplier(
input [15:0] a,
input [15:0] b,
output [31:0] product
);

wire [15:0] pp [0:15];
genvar i;
generate
for (i = 0; i < 16; i=i+1) begin
assign pp[i] = a & {16{b[i]}};
end
endgenerate

wire [31:0] spp [0:15];
generate
for (i = 0; i < 16; i=i+1) begin
assign spp[i] = {16'b0, pp[i]} << i;
end
endgenerate

reg [31:0] stage1 [0:7];
integer j;
always @(*) begin
for (j = 0; j < 8; j=j+1) begin
stage1[j] = spp[j*2] + spp[j*2+1];
end
end

reg [31:0] stage2 [0:3];
integer k;
always @(*) begin
for (k = 0; k < 4; k=k+1) begin
stage2[k] = stage1[k*2] + stage1[k*2+1];
end
end

reg [31:0] stage3 [0:1];
always @(*) begin
stage3[0] = stage2[0] + stage2[1];
stage3[1] = stage2[2] + stage2[3];
end

assign product = stage3[0] + stage3[1];

endmodule