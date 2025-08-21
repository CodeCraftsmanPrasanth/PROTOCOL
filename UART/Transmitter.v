`timescale 1ns / 1ps
module Transmitter
    #(parameter Data_length=8,
                parity_en=0)
    (
    input [Data_length-1:0] datain,
    input clk1,rst,send,parity_type,
    output baudrattx,
    output reg serialdata_out, tx_done);
    baud_rate_TX a1(.clk1(clk1),.rst(rst),.baud_clk_T(baudrattx));

    localparam idle=3'b000,
               frame=3'b001,
               start=3'b010,
               data=3'b011,
               parity=3'b100,
               stop=3'b101;
   reg [2:0] ps,ns;
   reg [3:0] framegen;
   reg [3:0] datacount;
   reg [2:0] framecount;
  
   always @(posedge baudrattx or posedge rst) begin
    if (rst) begin
        serialdata_out<=1;
        tx_done<=1;
        ps<=idle;
        framegen<=0;
        datacount<=0;
        framecount<=3; end
    else begin
        case (ps)
            idle : if (send) begin tx_done<=0; framegen<=Data_length+parity_en+1'b1+1'b1; ps<=frame; end
                  else begin ps<=idle; end
            frame : if (framecount>0) begin  serialdata_out<=framegen[framecount]; /*framegen=framegen<<1;*/framecount=framecount-1; end
                    else begin serialdata_out<=framegen[framecount];ps<=start;framecount<=3 ; end
            start: begin serialdata_out<=0; ps<=data; end
            data : if (datacount < Data_length-1 ) begin serialdata_out<=datain[datacount];datacount=datacount+1; end
                   else if (parity_en) begin serialdata_out<=datain[datacount]; datacount<=0; ps<=parity; end 
                   else begin serialdata_out<=datain[datacount]; datacount<=0;  ps<=stop; end
            parity:  if (~parity_type) begin serialdata_out<=^datain; ps<=stop; end
                     else begin serialdata_out<=~(^datain); ps<=stop; end
           stop: begin serialdata_out<=1;tx_done<=1;ps<=idle; end
       endcase
   end 
   end
endmodule

module baud_rate_TX(
  input clk1,rst,
  output reg baud_clk_T
);
  parameter integer baud_rate = 1152000;
  parameter integer fqr = 50000000;
  integer count;
  parameter integer clk_div = fqr / baud_rate;
  
  always@(posedge clk1 ) begin
    if(rst) begin
      count <= 0;
      baud_clk_T <= 0;
    end
    else begin
      if(count == clk_div) begin
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
