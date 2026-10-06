module tx(
input clk,rst,tx_start,baud_tick,
input[15:0] tx_data,
output tx
);
 localparam IDLE=2'b00; 
     localparam START=2'b01; 
      localparam DATA=2'b10;
       localparam STOP=2'b11;
reg [3:0]bit_counter;// we know the bit which send for example b0 until b16
reg [15:0]tx_data_reg;
reg[1:0] ns,cs;
//next state logic
always @(*) begin
    
    case(cs)
   IDLE:
    if(tx_start)
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
   
        always @(posedge clk or negedge rst)begin
            if(!rst)begin
            bit_counter<=0;
            tx_data_reg<=0;
            end
            else begin
                if(cs==IDLE&&tx_start)begin
                 bit_counter<=0;
                 tx_data_reg<=tx_data;end       
                 else begin

              if(cs==DATA&&baud_tick&&bit_counter<4'd15)begin
                bit_counter<=bit_counter+1;
              end
              
              
                
              end
                 end
            
            end 
        
        
        assign tx=(cs==IDLE)?1'D1:
        (cs==START)?1'D0:
        (cs==DATA)?tx_data_reg[bit_counter]:
            1'D1;


     
        
   

endmodule
