//////////////////////////////////////////////////////////////////////////////////
// Engineer: Md. Mohiuddin Reyad
// Contact : reyad.mdmohiuddin@gmail.com
//
// Design Name: axis_top
// Module Name: axis_slave
// Project Name: AXI stream design and verification
// Tool Versions: vivado 2024.2
// Description: This module implements a simple AXI4-Stream (AXIS) slave interface.
//              It receives streaming data from a master via standard AXIS signals
//              and provides it to the user logic.
//
// Dependencies:
//
// Revision: 1.0
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module axis_slave(
    input logic        s_axis_aclk,
    input logic        s_axis_arstn,
    input logic  [7:0] s_axis_tdata,
    input logic        s_axis_tvalid,
    input logic        s_axis_tlast,
    output logic [7:0] data_out,
    output logic       s_axis_tready
    );


    typedef enum bit [1:0] {idle = 2'b00, store = 2'b01, last_byte = 2'b10} state_type_e;
    state_type_e current_state = idle, next_state = idle;

    always @(posedge s_axis_aclk)
    begin
        if (s_axis_arstn == 1'b0) current_state <= idle;
        else current_state <= next_state;
    end
    always_comb
    begin
        case(current_state)
            idle:
            begin
                if(s_axis_tvalid == 1'b1)
                    next_state = store;
                else
                    next_state = idle;
            end
            store:
            begin
                if (s_axis_tlast == 1'b1 && s_axis_tvalid == 1'b1)
                    next_state = idle;
                else if (s_axis_tlast == 1'b0 && s_axis_tvalid == 1'b1)
                    next_state = store;
                else
                    next_state = idle;
            end
            default: next_state = idle;
        endcase
    end

    assign s_axis_tready = (current_state == store);
    assign data_out = (current_state == store) ? s_axis_tdata : '0;

endmodule
