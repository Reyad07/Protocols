//////////////////////////////////////////////////////////////////////////////////
// Engineer: Md. Mohiuddin Reyad 
// Contact : reyad.mdmohiuddin@gmail.com
//
// Design Name: axis_top
// Module Name: axis_master 
// Project Name: AXI stream design and verification
// Tool Versions: vivado 2024.2
// Description: axi stream master module that receives streams of data and convert
//              them into axi stream specific signals
// 
// Dependencies: 
// 
// Revision: 1.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axis_master(
    input logic             m_axis_aclk,
    input logic             m_axis_arstn,
    input logic             new_data,    //check for new data in
    input logic             m_axis_tready,
    input logic     [7:0]   data_in,
    output logic    [7:0]   m_axis_tdata,
    output logic            m_axis_tvalid,
    output logic            m_axis_tlast
    );
    
    // TODO: use global parameter for count aka stream length
    logic [1:0] count = 0;    // assuming we need to transfer 3 bytes

    typedef enum bit {idle = 1'b0, transfer = 1'b1} state_type;
    state_type current_state = idle, next_state = idle;
    
    always @(posedge m_axis_aclk)
    begin
        if (m_axis_arstn == 1'b0) current_state <= idle;
        else current_state <= next_state;
    end
    
    // count update block
    always @(posedge m_axis_aclk)
    begin
        if (current_state == idle) 
            count <= 0;
        else if (current_state == transfer && count != 3 && m_axis_tready == 1'b1)
            count <= count + 1;
        else
            count <= count;
    end

    //next state FSM
    //we will not assign tdata, tvalid and tlast in this block
    //because these will be continuously assigned
    always@(*)  //TODO: use always_comb block
    begin
        case(current_state)
            idle:
            begin
                if(new_data) next_state = transfer;
                else next_state = idle;
            end
            transfer:
            begin
                if(m_axis_tready)
                begin
                    if(count != 3) next_state = transfer;
                    else next_state =idle;
                end
                else next_state = transfer; 
            end
        endcase
    end

    assign m_axis_tdata = (m_axis_tvalid) ? data_in*count : 0;  // count mult is to track data
    assign m_axis_tlast = (count == 3 && current_state == transfer) ? 1'b1 : 1'b0;
    assign m_axis_tvalid = (current_state == transfer) ? 1'b1 : 1'b0;


endmodule
