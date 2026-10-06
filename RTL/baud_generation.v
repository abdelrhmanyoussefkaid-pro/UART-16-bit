module baud_generation#(
    parameter clk_freq=50000000,
parameter baud_rate =9600 
)(
    input clk,rst, // aschronous active low
    output reg baud_tick
) ;


localparam divisor =clk_freq/baud_rate;
integer counter;
always @(posedge clk or negedge rst)begin 
       if(!rst)
       begin 
        counter<=0;
        baud_tick<=0;
       end
       else begin 
        
        if(counter==divisor-1)
        begin
        counter<=0;
        baud_tick<=1;

        end else begin
        counter<=counter+1;
        baud_tick<=0;
        end
       end



end




 endmodule
