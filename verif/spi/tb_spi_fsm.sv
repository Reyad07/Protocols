module tb_spi_fsm;

    logic clk = 1'b0;
    logic rst = 1'b0;
    logic tx_en = 1'b0;
    logic sclk;
    logic cs;
    logic mosi;

    spi_fsm u_spi_fsm(
        .clk    (clk  ),
        .rst    (rst  ),
        .tx_en  (tx_en),
        .sclk   (sclk ),
        .cs     (cs   ),
        .mosi   (mosi )
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin
        tx_en = 0;
        repeat (10) @(posedge clk);
        tx_en = 1'b1;
    end

endmodule