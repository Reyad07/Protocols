//////////////////////////////////////////////////////////////////////////////////
// Engineer: Md. Mohiuddin Reyad
// Contact : reyad.mdmohiuddin@gmail.com
//
// Design Name: axis_top
// Module Name: tb_axis_master
// Project Name: AXI stream design and verification
// Tool Versions: vivado 2024.2
// Description: axi stream master module verification
//
// Dependencies:
//
// Revision: 1.0
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module tb_axis_master;
    logic       m_axis_aclk = 0;
    logic       m_axis_arstn;
    logic       new_data;
    logic       m_axis_tready;
    logic [7:0] data_in;
    logic [7:0] m_axis_tdata;
    logic       m_axis_tvalid;
    logic       m_axis_tlast;


    axis_master axis_master_dut(
        .m_axis_aclk    ( m_axis_aclk   ),
        .m_axis_arstn   ( m_axis_arstn  ),
        .new_data       ( new_data      ),
        .m_axis_tready  ( m_axis_tready ),
        .data_in        ( data_in       ),
        .m_axis_tdata   ( m_axis_tdata  ),
        .m_axis_tvalid  ( m_axis_tvalid ),
        .m_axis_tlast   ( m_axis_tlast  )
    );

    //TODO: implement using task
    always #10 m_axis_aclk = ~m_axis_aclk;

    task static apply_reset;
        m_axis_arstn = 0;
        m_axis_tready = 1'b0;
        new_data = 1'b0;
        data_in = 0;
        repeat(10) @(posedge m_axis_aclk);
        m_axis_arstn = 1'b1;
    endtask

    task automatic apply_stimuly(input logic [3:0] n_transfer);
        for(int i = 0; i<n_transfer; i++)    //for 5 transfer
        begin
            m_axis_tready = 1'b1;
            new_data = 1'b1;
            data_in = $urandom_range(0,255);
            @(negedge m_axis_tlast);
            m_axis_tready = 1'b0;
        end
    endtask

    initial begin
        apply_reset;
        apply_stimuly(6);
        $finish;

    end

endmodule
