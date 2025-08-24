`timescale 1ns / 1ps
module Transmitter
    #(parameter Data_length=8,
                parity_en=0)
    (
    input [Data_length-1:0] datain,
    input rst,
    input send,
    input parity_type,
    output baudratetx,tx_clk,
    output reg serialdata_out, tx_done);
    
    baud_rate_TX a1(.rst(rst),.baud_clk_T(baudratetx),.tx_clk(tx_clk));

    localparam idle=3'b000,
               frame=3'b001,
               start=3'b010,
               data=3'b011,
               parity=3'b100,
               stop=3'b101;
    
   reg [2:0] ns;
   reg [3:0] framegen;
   reg [3:0] datacount;
   reg [2:0] framecount;
   reg  i;
    
   always @(posedge baudratetx or posedge rst) begin
    if (rst) begin
        serialdata_out<=1;
        tx_done<=1;
        ns<=idle;
        framegen<=0;
        datacount<=0;
        framecount<=3;// 
        i<=0; end
    else begin
        case (ns)
            idle : if (send) begin  
                        framegen<=Data_length+parity_en+1'b1+1'b1; 
                        ns<=frame; 
                    end
                    else begin 
                        ns<=idle; 
                    end
            frame : if (framecount>0) begin 
                        tx_done<=0; 
                        serialdata_out<=framegen[framecount];
                        framecount=framecount-1; 
                    end
                    else begin 
                            serialdata_out<=framegen[framecount];
                            ns<=start;framecount<=3 ; 
                    end
            start: if (send) begin 
                        tx_done<=0; 
                        serialdata_out<=0; 
                        ns<=data; 
                    end
                   else if (~i) begin 
                           tx_done<=0; 
                           serialdata_out<=0; 
                           ns<=data; 
                   end
            data : if (datacount < Data_length-1 ) begin 
                        serialdata_out<=datain[datacount];
                        datacount=datacount+1;     
                    end
                   else if (parity_en) begin 
                           serialdata_out<=datain[datacount]; 
                           datacount<=0; 
                           ns<=parity; 
                   end 
                   else begin 
                           serialdata_out<=datain[datacount]; 
                           datacount<=0;  
                           ns<=stop; 
                   end
            parity:  if (~parity_type) begin 
                            serialdata_out<=^datain ; 
                            ns<=stop; 
                    end
                     else begin 
                             serialdata_out<=~(^datain); 
                             ns<=stop; 
                     end
           stop: begin 
                   serialdata_out<=1;
                   tx_done<=1;
                   ns<=start;
                   i<=1; 
               end
       endcase
   end 
   end
endmodule

module baud_rate_TX(
  input rst,
  output reg baud_clk_T, tx_clk);
  parameter integer baud_rate = 9600;
  parameter integer fqr = 5;
  integer count;
  parameter integer clk_per_bit = 20;
  
  initial begin
    tx_clk=0;
    forever #fqr tx_clk=~tx_clk;
  end 
  
  always@(posedge tx_clk ) begin
    if(rst) begin
      count <= 0;
      baud_clk_T <= 0;
    end
    else begin
        if(count == clk_per_bit-1) begin
            count <= 0;
            baud_clk_T <= 1;
        end
        else begin
            count =count + 1;
            baud_clk_T <= 0;
        end
    end
  end
endmodule
