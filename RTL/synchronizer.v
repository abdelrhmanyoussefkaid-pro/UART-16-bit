module  synchronizer (

        input clk ,rst,rx,
        output rx_sync





);


    reg rx_ff1,rx_ff2;


    always @(posedge clk or negedge rst)begin
        if(!rst)begin
        rx_ff1<=1;
        rx_ff2<=1;
        end
        else begin
            rx_ff1<=rx;
            rx_ff2<=rx_ff1;
            
        end
        
    end

    assign rx_sync =rx_ff2 ;



endmodule
