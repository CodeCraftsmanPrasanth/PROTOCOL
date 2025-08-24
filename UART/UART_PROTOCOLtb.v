`timescale 1ns / 1ps
module UART_PROTOCOLtb;
    parameter Data_length=8,
              parity_en=1;
     reg [7:0] parallel_datain;
     wire tx_clk,rx_clk;
     reg  send;
     wire baudratetx;
     wire tx_serialout,tx_done;
     wire baudraterx;
     wire [7:0] data_out;
     wire rx_done,error;
     reg rst,parity_type;
     
    UART_TOPMODULE #(.Data_length(Data_length),.parity_en(parity_en)) uut (.parallel_datain(parallel_datain),.tx_clk(tx_clk),.rx_clk(rx_clk),.rst(rst),.send(send),.baudratetx(baudratetx),.tx_serialout(tx_serialout),.tx_done(tx_done),.baudraterx(baudraterx),.data_out(data_out),.rx_done(rx_done),.error(error),.parity_type(parity_type));
     
    
    initial begin
    parity_type=0;
    rst = 1;
    #20; // Wait for a few cycles
    rst = 0;
    
    // Initialize testbench signals
    parallel_datain = 0;
    send = 0;

    @(posedge baudratetx); parallel_datain=8'b00000001; send=1;
    @(posedge baudratetx); send=0;
    @(posedge tx_done ); parallel_datain=8'b00000011; send=1;
    @(posedge baudratetx); send=0;
    @(posedge tx_done );  parallel_datain=8'b00000111; send=1;
    @(posedge baudratetx); send=0;
    @(posedge tx_done );  parallel_datain=8'b00001111; send=1;
    @(posedge baudratetx); send=0;
    @(posedge tx_done );  parallel_datain=8'b00011111; send=1;
    @(posedge baudratetx); send=0;
    @(posedge tx_done );  parallel_datain=8'b00111111; send=1;
    @(posedge baudratetx); send=0;
    @(posedge tx_done );  parallel_datain=8'b01111111; send=1;
    @(posedge baudratetx); send=0;
    @(posedge tx_done ); parallel_datain=8'b11111111; send=1;
    @(posedge baudratetx); send=0;
     #10000 $finish;
end

endmodule
