module tb_spi_top;
    logic clk = 1'b0;
    logic rst = 1'b0;
    logic tx_en;
    logic [7:0] received_data;
    logic done;
    
    spi_top  #(.MASTER(1)) 
        u_spi_top (
            .clk            (clk            ),
            .rst            (rst            ),
            .tx_en          (tx_en          ),
            .received_data  (received_data  ),
            .done           (done           )
    );

    always #5 clk = ~clk;

    initial begin
        rst = 1'b1;
        repeat (5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin
        tx_en = '0;
        repeat (7) @(posedge clk);
        tx_en = 1'b1;
    end
    
    initial begin
        $dumpfile("spi.vcd");
        $dumpvars;
    end

endmodule