module dadda_multiplier_tb();

    reg [15:0] a;
    reg [15:0] b;
    wire [31:0] product;

    dadda_multiplier uut(
        .a(a),
        .b(b),
        .product(product)
    );

    initial begin
        a = 16'd0;
        b = 16'd0;
        #100;

        a = 16'd10;
        b = 16'd20;
        #100;
        $display("Product of %d and %d is %d", a, b, product);

        a = 16'd100;
        b = 16'd200;
        #100;
        $display("Product of %d and %d is %d", a, b, product);

        a = 16'd65535;
        b = 16'd65535;
        #100;
        $display("Product of %d and %d is %d", a, b, product);
    end

endmodule