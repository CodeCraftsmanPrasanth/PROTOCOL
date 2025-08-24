`timescale 1ns / 1ps
module UART_TOPMODULE
    #(parameter Data_length=8,
                parity_en=0)
     (input [7:0] parallel_datain,
     input rst,send,parity_type,
     output tx_serialout,
     output baudratetx,tx_clk,rx_clk,tx_done,error,
     output rx_done,baudraterx,
     output [7:0] data_out);
    
    Transmitter  #( .Data_length(Data_length),.parity_en(parity_en)) a1 (.datain(parallel_datain),.tx_clk(tx_clk),.rst(rst),.send(send),.parity_type(parity_type),.baudratetx(baudratetx),.serialdata_out(tx_serialout),.tx_done(tx_done));
    Receiver  #( .Data_length(Data_length),.parity_en(parity_en)) a2 (.serialdata_in(tx_serialout),.rx_clk(rx_clk),.rst(rst),.tx_done(tx_done),.parity_type(parity_type),.parallel_dataout(data_out),.error(error), .rx_done(rx_done),.baudraterx(baudraterx));
endmodule
