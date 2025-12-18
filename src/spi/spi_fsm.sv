module spi_fsm(
    input logic clk,
    input logic rst,
    input logic tx_en,
    output logic sclk,
    output logic cs,
    output logic mosi
);

    typedef enum logic [1:0] {idle, start_tx, data_tx, done_tx} state_type;
    state_type current_state, next_state;

    reg [7:0] din = 8'b1010_0011;   // 8'hA3 -> send MSB first

    // since we will transmit 8 bit of data,
    // half sclk = 4 clk this way we get sclk = 1/8 of clk
    // sclk is slower than system clk
    logic spi_sclk = 0;
    logic [2:0] count = 0;  // to transmit 8 bit data, we count to 8 sclk tick
    logic [3:0] bit_count = 0;  // to track 8 bit data transfer

    always_ff @( posedge clk ) begin : reset_block
        if(rst)
            current_state <= idle;
        else
            current_state <= next_state;
    end

    always_ff @( posedge clk ) begin : sclk_generator
        case (next_state)
            idle: spi_sclk <= 1'b0;
            // for rest of the states we generate spi_sclk
            // we make spi_sclk high only when either count is less than
            // 3'b011 or equal to 3'b111 (meaning 8)
            start_tx, data_tx, done_tx: begin
                if (count < 3'b011 || count == 3'b111)
                    spi_sclk <= 1'b1;
                else
                    spi_sclk <= 1'b0;
            end
            data_tx: begin
                if (count < 3'b011 || count == 3'b111)
                    spi_sclk <= 1'b1;
                else
                    spi_sclk <= 1'b0;
            end
            done_tx: begin
                if (count < 3'b011 || count == 3'b111)
                    spi_sclk <= 1'b1;
                else
                    spi_sclk <= 1'b0;
            end
            default: spi_sclk <= 1'b0;
        endcase
    end

    always_comb begin : mosi_CS_block
        case(current_state)
        idle: begin
            mosi = 1'b0;
            cs   = 1'b1;
            if (tx_en)
                next_state = start_tx;
            else
                next_state = idle;
        end
        start_tx: begin
            cs = 1'b0;  // start transaction
            if (count == 3'b111)    // 8 clk
                next_state = data_tx;
            else
                next_state = start_tx;
        end
        data_tx: begin
            mosi = din [7 - bit_count];
            if (bit_count == 8) begin
                    next_state = done_tx;
                    mosi = 1'b0;
                end
            else begin
                next_state = data_tx;
            end
        end
        done_tx: begin
            cs = 1'b1;
            mosi = 1'b0;
            if (count == 3'b111)
                next_state = idle;
            else
                next_state = done_tx;
        end
        default: next_state = idle;
        endcase
    end

    always_ff @( posedge clk ) begin : counters
        case(current_state)
            idle: begin
                count <= 'b0;
                bit_count <= 'b0;
            end
            start_tx: count <= count + 1;
            data_tx: begin
                if (bit_count != 8) begin
                    if (count < 3'b111) 
                        count <= count + 1;
                    else begin
                        count <= 'b0; // reset count after 8 clk
                        bit_count <= bit_count + 1; // increment bit_count after 8 clk
                    end
                end
            end
            done_tx: begin
                count <= count + 1;
                bit_count <= '0;
            end
            default: begin
                count <= '0;
                bit_count <= '0;
            end
        endcase
    end

    assign sclk = spi_sclk;

endmodule