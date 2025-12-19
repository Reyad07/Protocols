module spi_slave (
    input logic mosi,
    input logic sclk,
    input logic cs, // chip select, active low
    output logic [7:0] dout,
    output logic done
);

    typedef enum logic { idle, recv } state_type;
    state_type state;

    logic [3:0] bit_count = '0;
    logic [7:0] data = '0;

    always_ff @(negedge sclk) begin
        case (state)
            idle: begin
                done <= 1'b0;
                if (cs!= 1'b1)
                    state <= recv;
                else
                    state <= idle;
            end
            recv: begin
                if (bit_count < 8) begin
                    bit_count <= bit_count + 1;
                    data <= {data[6:0], mosi}; // perform shift left because mosi is MSB first
                    state <= recv;
                end
                else begin
                    done <= 1'b1;
                    bit_count <= '0;
                    state <= idle;
                end
            end
            default: state <= idle;
        endcase
    end

    assign dout = data;

endmodule
