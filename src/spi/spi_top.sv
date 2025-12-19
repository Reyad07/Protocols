// encapsulates spi_fsm (master) and spi_slave (slave)
module spi_top #(parameter MASTER = 0) (
    input logic clk,
    input logic rst,
    input logic tx_en,
    output logic [7:0] received_data,
    output logic done
);

    // signals between spi_fsm and spi_slave
    logic sclk;
    logic cs;
    logic mosi;

   // instantiate spi_fsm (master): MASTER = 1 -> spi_fsm instantiated
   //                               MASTER = 0 -> alt_spi_fsm instantiated
    generate
        if (MASTER) begin
        spi_fsm u_spi_fsm (
            .clk    (clk),
            .rst    (rst),
            .tx_en  (tx_en),
            .sclk   (sclk),
            .cs     (cs),
            .mosi   (mosi)
        );
        end
        else begin
        alt_spi_fsm u_alt_spi_fsm (
            .clk    (clk),
            .rst    (rst),
            .tx_en  (tx_en),
            .sclk   (sclk),
            .cs     (cs),
            .mosi   (mosi)
        );
        end
    endgenerate
    
    // instantiate spi_slave
    spi_slave u_spi_slave (
        .mosi   (mosi),
        .sclk   (sclk),
        .cs     (cs),
        .dout   (received_data),
        .done   (done)
    );

endmodule