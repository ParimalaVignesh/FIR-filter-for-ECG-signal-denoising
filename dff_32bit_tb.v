module dff_32bit_tb();

    reg clk;
    reg reset;
    reg [31:0] d;
    wire [31:0] q;

    dff_32bit uut(
        .clk(clk),
        .reset(reset),
        .d(d),
        .q(q)
    );

    initial begin
        clk = 0;
        reset = 1;
        d = 32'd0;
        #100;

        reset = 0;
        d = 32'd12345678;
        #100;

        clk = 1;
        #50;
        clk = 0;
        #50;

        $display("Output q = %d", q);

        d = 32'd87654321;
        #100;

        clk = 1;
        #50;
        clk = 0;
        #50;

        $display("Output q = %d", q);

        reset = 1;
        #100;
        $display("Output q after reset = %d", q);
    end

    always #50 clk = ~clk;

endmodule