`timescale 1ns / 1ps
module Receiver
    #(parameter Data_length=8,
                parity_en=1)
    (input serialdata_in,
     input clk2,
     input rst,
    input tx_done,
    input parity_type,
    output reg [Data_length-1:0] parallel_dataout,
    output reg error, rx_done,
    output baudraterx);
    
    baud_rate_RX a1(.clk2(clk2),.rst(rst),.baud_clk_R(baudraterx));
    
    localparam idle=3'b000,
               start=3'b001,
               data=3'b010,
               parity=3'b011,
               stop=3'b100;
             
    reg  [Data_length-1:0] paralleldata;
    reg [2:0]ns;
    reg [3:0] count;
    reg [3:0] addrlength;
    reg [3:0] bitlength;
    reg i;
    
    always @(posedge baudraterx or posedge rst) begin
        if (rst) begin
            ns<=idle;
            paralleldata<=0;
            rx_done<=1;
            error<=0;
            bitlength<=0;
            parallel_dataout<=0;
            count<=5;
            addrlength<=0;
            i<=0;
        end 
        else begin
            case (ns)
                idle: begin ns<=start; end
                start: if (~tx_done) begin 
                            rx_done<=0;
                            if (count > 1 & ~i ) begin 
                                addrlength[count-2]<=serialdata_in;
                                count<=count-1; 
                            end
                            else if (~serialdata_in) begin 
                                bitlength<=addrlength-parity_en-2; 
                                ns<= data;count<=0;
                                i<=1; 
                            end
                            else begin 
                                ns<= start; 
                            end 
                        end
                data: if (count < bitlength-1) begin 
                            paralleldata[count]<=serialdata_in;
                            count<=count+1; 
                        end
                      else if (parity_en) begin 
                              paralleldata[count]<=serialdata_in;
                              count<=3; 
                              ns<=parity; 
                          end
                      else begin 
                              paralleldata[count]<=serialdata_in; 
                              ns<=stop; 
                      end
                parity: if (~parity_type) begin 
                            error<=^{paralleldata,serialdata_in}; 
                            ns<=stop; 
                        end
                        else begin 
                            error<=~(^{paralleldata,serialdata_in}); 
                            ns<=stop; 
                        end
                stop: begin 
                        parallel_dataout<=paralleldata; 
                        rx_done<=1; 
                        ns<=start;
                        count<=5;
                        error<=0; 
                    end                      
           endcase
       end
    end      
endmodule

module baud_rate_RX(
  input clk2,rst,
  output reg baud_clk_R
);
  parameter integer baud_rate = 1152000;
  parameter integer fqr = 50000000;
  integer count;
  parameter integer clk_div = fqr / baud_rate;
  
  always@(posedge clk2 ) begin
    if(rst) begin
      count <= 0;
      baud_clk_R <= 0;
    end
    else begin
      if(count == clk_div-1) begin
      count <= 0;
      baud_clk_R <= 1;
    end
    else begin
      count =count + 1;
      baud_clk_R <= 0;
    end
    end
  end
endmodule
