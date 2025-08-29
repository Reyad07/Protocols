//////////////////////////////////////////////////////////////////////////////////
// Engineer: Md. Mohiuddin Reyad 
// Contact : reyad.mdmohiuddin@gmail.com
//
// Design Name: axis_top
// Module Name: tb_axis_slave 
// Project Name: AXI stream design and verification
// Tool Versions: vivado 2024.2
// Description: axi stream slave module verification
// 
// Dependencies: 
// 
// Revision: 1.0
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_axis_slave;
    logic        s_axis_aclk = 0;
    logic        s_axis_arstn;
    logic  [7:0] s_axis_tdata;
    logic        s_axis_tvalid;
    logic        s_axis_tlast;
    logic [7:0]  data_out;
    logic        s_axis_tready;

    axis_slave dut_axis_slave(
        .s_axis_aclk    ( s_axis_aclk   ),
        .s_axis_arstn   ( s_axis_arstn  ),
        .s_axis_tdata   ( s_axis_tdata  ),
        .s_axis_tvalid  ( s_axis_tvalid ),
        .s_axis_tlast   ( s_axis_tlast  ),
        .data_out       ( data_out      ),
        .s_axis_tready  ( s_axis_tready )
    );

    always #10 s_axis_aclk = ~s_axis_aclk;

    task apply_reset;
        s_axis_arstn = 1'b0;
        s_axis_tdata = '0;
        s_axis_tvalid= 1'b0;
        s_axis_tlast = 1'b0;
        repeat(10) @(posedge s_axis_aclk);
        s_axis_arstn = 1'b1;
    endtask

    task apply_stimuli(input logic [3:0] n_transfer);
        for (int i = 0; i< n_transfer; i++)
        begin
            @(posedge s_axis_aclk);
            s_axis_tvalid = 1'b1;
            s_axis_tdata = $random;
            wait (s_axis_tready == 1);      // magic part: unless we do this handshake wont happen
        end
        @(posedge s_axis_aclk);
        s_axis_tlast = 1'b1;
        @(posedge s_axis_aclk);
        s_axis_tlast = 1'b0;
        s_axis_tvalid = 1'b0;
    endtask

    initial begin
        apply_reset;
        apply_stimuli(10);
        $finish;
    end

endmodule
