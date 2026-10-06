module rx (
    input clk,
    input rst,
    input rx,
    input baud_tick,
    output reg  [15:0]rx_data,
    output reg rx_done
);
reg [1:0] cs,ns;
localparam IDLE=2'b00; 
     localparam START=2'b01; 
      localparam DATA=2'b10; 
       localparam STOP=2'b11;
        reg [3:0]bit_counter;
        reg [15:0]rx_data_reg;




    // next state logic
    always @(*) begin
    
    case(cs)
   IDLE:
    if(!rx)
    ns=START;
    else begin
        ns=IDLE;
    end
START:
    if(baud_tick)
        ns=DATA ;
        else
        ns=START;
DATA:
    if(baud_tick&&bit_counter==4'd15)
    ns=STOP;
    else
    ns=DATA;
STOP:
    if(baud_tick)
    ns=IDLE;
    else
    ns=STOP;

    default :ns=IDLE;
        
    endcase
            end  



       // state memory
        always @(posedge clk or negedge rst)           
            begin                                        
                if(!rst)                               
                    cs<=IDLE;                                   
                                          
                else
                cs<=ns;                                    
            end                                          
   
        //data regigester ,bit count
        always @(posedge clk or negedge rst)begin 
            if(!rst)begin
                bit_counter<=4'd0;
                rx_data_reg<=16'd0;
            end
            else begin 
                if(cs==START)begin
                    bit_counter<=4'd0;
                    
                end
                
                   
                   else if(cs==DATA&&baud_tick)begin
                  
                    rx_data_reg[bit_counter]<=rx;
        
                    bit_counter<=bit_counter+1;
                   end
                
                
                    
            
                    
                
            end
        end
        // output
           always @(posedge clk or negedge rst)           
               begin                                        
                   if(!rst)  begin
                    rx_data<=16'd0;
                    rx_done<=1'd0;
                   end                             
                                                                                                  
                   else  begin

                    if(cs==STOP&&baud_tick)begin
                        rx_data<=rx_data_reg;
                        rx_done<=1;
                    end
                    else
                    rx_done<=0;
                   end                                   
               end                                          

 endmodule
