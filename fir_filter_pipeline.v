
module fir_filter_pipeline(
    input clk,
    input reset,
    input [15:0] sample,
    output [31:0] result,
    output [31:0] noisy_sample
);

    reg [15:0] coeff [0:20];
    reg [31:0] noise;
    reg [31:0] noisy_sample_reg;
    reg [9:0] count;
    reg signed [15:0] sin_lut [0:999];
    integer i;

    initial begin
        for (i = 0; i < 1000; i=i+1) begin
            sin_lut[i] = $rtoi(1000 * $sin(2 * 3.14159 * i / 1000));
        end
        coeff[0] = 16'd0;
        coeff[1] = 16'd301;
        coeff[2]= 16'd1317;
        coeff[3] = 16'd3323;
        coeff[4] = 16'd6580;
        coeff[5] = 16'd11141;
        coeff[6] = 16'd16705;
        coeff[7] = 16'd22583;
        coeff[8] = 16'd27826;
        coeff[9] = 16'd31463;
        coeff[10] = 16'd32767;
        coeff[11] = 16'd31463;
        coeff[12] = 16'd27826;
        coeff[13] = 16'd22583;
        coeff[14] = 16'd16705;
        coeff[15] = 16'd11141;
        coeff[16] = 16'd6580;
        coeff[17] = 16'd3323;
        coeff[18] = 16'd1317;
        coeff[19] = 16'd301;
        coeff[20] = 16'd0;
    end

    reg [15:0] notch_coeff [0:2];
    initial begin
        notch_coeff[0] = 16'd1;
        notch_coeff[1] = -16'd2;
        notch_coeff[2] = 16'd1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            noise <= 0;
            noisy_sample_reg <= 0;
        end else begin
            count <= count + 1;
            if (count >= 1000) count <= 0;
            noise <= sin_lut[count] <<< 4;
            noisy_sample_reg <= ({sample, 16'd0} + noise);
        end
    end

    reg [31:0] sample_reg [0:20];
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 21; i = i + 1) begin
                sample_reg[i] <= 0;
            end
        end else begin
            sample_reg[0] <= noisy_sample_reg;
            for (i = 1; i < 21; i = i + 1) begin
                sample_reg[i] <= sample_reg[i-1];
            end
        end
    end

    wire [31:0] product [0:20];
    reg [31:0] product_reg [0:20];
    genvar j;
    generate
        for (j = 0; j < 21; j=j+1) begin : mult_stage
            dadda_multiplier dadda_mult (
                .a(sample_reg[j][31:16]),
                .b(coeff[j]),
                .product(product[j])
            );
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    product_reg[j] <= 0;
                end else begin
                    product_reg[j] <= product[j];
                end
            end
        end
    endgenerate

    reg [31:0] sum [0:20];
    wire [31:0] add_out [0:20];
    genvar k;
    generate
        for (k = 0; k < 21; k=k+1) begin : add_stage
            if (k == 0) begin
                assign add_out[k] = product_reg[k];
            end else begin
                ripple_carry_adder_32bit rca (
                    .a(sum[k-1]),
                    .b(product_reg[k]),
                    .sum(add_out[k])
                );
            end
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    sum[k] <= 0;
                end else begin
                    sum[k] <= add_out[k];
                end
            end
        end
    endgenerate

    reg [31:0] notch_sample_reg [0:2];
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            notch_sample_reg[0] <= 0;
            notch_sample_reg[1] <= 0;
            notch_sample_reg[2] <= 0;
        end else begin
            notch_sample_reg[0] <= sum[20];
            notch_sample_reg[1] <= notch_sample_reg[0];
            notch_sample_reg[2] <= notch_sample_reg[1];
        end
    end

    wire [31:0] notch_product [0:2];
    reg [31:0] notch_product_reg [0:2];
    generate
        for (j = 0; j < 3; j=j+1) begin : notch_mult_stage
            dadda_multiplier dadda_mult (
                .a(notch_sample_reg[j][31:16]),
                .b(notch_coeff[j]),
                .product(notch_product[j])
            );
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    notch_product_reg[j] <= 0;
                end else begin
                    notch_product_reg[j] <= notch_product[j];
                end
            end
        end
    endgenerate

    wire [31:0] rca_sum_wire;
    wire [31:0] rca2_sum_wire;
    carry_save_adder csa (
        .a(notch_product_reg[0]),
        .b(notch_product_reg[1]),
        .c(32'd0),
        .sum(rca_sum_wire),
        .cout()
    );
    ripple_carry_adder_32bit rca2 (
        .a(rca_sum_wire),
        .b(notch_product_reg[2]),
        .sum(rca2_sum_wire)
    );

    dff_32bit dff_result(
        .clk(clk),
        .reset(reset),
        .d(rca2_sum_wire >>> 18),
        .q(result)
    );

    assign noisy_sample = noisy_sample_reg;

endmodule