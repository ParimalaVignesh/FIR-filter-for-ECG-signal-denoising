module dff_32bit(
input clk,
input reset,
input [31:0] d,
output reg [31:0] q
);

always @(posedge clk or posedge reset) begin
if (reset) begin
q <= 0;
end else begin
q <= d;
end
end
endmodule