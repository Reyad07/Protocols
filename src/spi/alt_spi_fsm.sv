module alt_spi_fsm(
    input logic clk,
    input logic rst,
    input logic tx_en,
    output logic sclk,
    output logic cs,
    output logic mosi
);

    typedef enum logic { idle, data_tx } state_type;
    state_type state;

    reg [7:0] din = 8'b1010_0111;   // 8'ha7 -> send MSB first
    logic spi_sclk = 0;
    logic [2:0] count = 0;  // to transmit 8 bit data, we count to 8 sclk tick
    logic [3:0] bit_count = 0;  // to track 8 bit data transfer

    always_ff @( posedge clk) begin
        if (!rst && tx_en) begin
            if (count < 3) begin
                count <= count + 1;
            end
            else begin
                count <= 0;
                spi_sclk <= ~spi_sclk;
            end
        end
    end

    always_ff @( posedge spi_sclk) begin
        case (state)
            idle: begin
                mosi <= 1'b0;
                cs   <= 1'b1;
                if (!rst && tx_en) begin
                    state <= data_tx;
                    cs   <= 1'b0;
                end
                else begin
                    state <= idle;
                end
            end
            data_tx: begin
                if (bit_count < 8) begin
                    mosi <= din[7-bit_count];
                    bit_count <= bit_count + 1;
                end
                else begin
                    mosi <= 1'b0;
                    bit_count <= '0;
                    cs <= 1'b1;
                    state <= idle;
                end
            end
            default: state <= idle;
        endcase
    end

    assign sclk = spi_sclk;

endmodule