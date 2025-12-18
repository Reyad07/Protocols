module fsm_spi(
    input logic clk,
    input logic rst,
    input logic tx_en,
    output logic sclk
    output logic CS,
    output logic MOSI
);

    typedef enum [1:0] {idle, tx_start, tx_data, tx_done} state_type;
    state_type current_state, next_state;

    reg [7:0] din = 8'b1010_0011;   // 8'hA3

    // assuming sclk is 1/8th of clk since we will transmit
    // 8 bit of data.

endmodule