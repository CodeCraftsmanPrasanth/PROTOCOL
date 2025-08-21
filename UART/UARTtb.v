`timescale 1ns / 1ps
module UART_PROTOCOLtb;
    parameter Data_length=8,
              parity_en=0;
    reg [Data_length-1:0] datain;
    reg clk1,rst,send,parity_type;
    wire baudrattx, serialdata_out, tx_done;
    Transmitter #( .Data_length(Data_length),.parity_en(parity_en)) uut (.datain(datain),.clk1(clk1),.rst(rst),.send(send),.parity_type(parity_type),.baudrattx(baudrattx),.serialdata_out(serialdata_out),.tx_done(tx_done));
    always #5 clk1=~clk1;
    initial begin
    parity_type=0;
    clk1=0;
    rst = 1;
    #10; // Wait for a few cycles
    rst = 0;
    
    // Initialize testbench signals
    datain = 0;
    send = 0;

    @(posedge baudrattx); datain=8'b00000100; send=1;
   
    @(posedge baudrattx); send=0;
    @(posedge tx_done ); 
    @(posedge baudrattx); datain=8'b00000011; send=1;
    @(posedge baudrattx); send=0;
    @(posedge tx_done ); 
    @(posedge baudrattx); datain=8'b00000111; send=1;
    @(posedge baudrattx); send=0;
    @(posedge tx_done ); 
    @(posedge baudrattx); datain=8'b00001111; send=1;
    @(posedge baudrattx); send=0;
    @(posedge tx_done ); 
    @(posedge baudrattx); datain=8'b00011111; send=1;
    @(posedge baudrattx); send=0;
    @(posedge tx_done ); 
    @(posedge baudrattx); datain=8'b00111111; send=1;
    @(posedge baudrattx); send=0;
    @(posedge tx_done ); 
    @(posedge baudrattx); datain=8'b01111111; send=1;
    @(posedge baudrattx); send=0;
    @(posedge tx_done ); 
    @(posedge baudrattx); datain=8'b11111111; send=1;
    @(posedge baudrattx); send=0;
     #20000 $finish;
end

endmodule
