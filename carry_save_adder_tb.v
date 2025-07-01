module carry_save_adder_tb;

    reg [31:0] a;
    reg [31:0] b;
    reg [31:0] c;
    wire [31:0] sum;
    wire cout;

    carry_save_adder csa(
        .a(a),
        .b(b),
        .c(c),
        .sum(sum),
        .cout(cout)
    );

    initial begin
        $dumpfile("carry_save_adder.vcd");
        $dumpvars(0, carry_save_adder_tb);

        a = 32'h00000001;
        b = 32'h00000002;
        c = 32'h00000003;
        #100;
        $display("a = %h, b = %h, c = %h, sum = %h, cout = %b", a, b, c, sum, cout);

        a = 32'h0fffffff;
        b = 32'h00ffffff;
        c = 32'h00000001;
        #100;
        $display("a = %h, b = %h, c = %h, sum = %h, cout = %b", a, b, c, sum, cout);

        a = 32'h00005678;
        b = 32'h0000cdef;
        c = 32'h00001111;
        #100;
        $display("a = %h, b = %h, c = %h, sum = %h, cout = %b", a, b, c, sum, cout);

        #100;
        $finish;
    end

endmodule