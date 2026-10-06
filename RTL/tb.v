module tb();
    reg clk,rst,tx_start;
    reg [15:0]tx_data;
     wire rx_done;
    wire [15:0]rx_data;
    wire tx,rx;
    // inst

    top DUT( .clk(clk),
    .rst(rst),
    .tx_start(tx_start),
    .tx(tx),
    .rx(rx),
    .tx_data(tx_data),
    .rx_data(rx_data),
    .rx_done(rx_done)
    );


    initial begin
        clk=0;
        forever begin
            #10  clk=~clk;
        end
    end
     assign rx =tx ;
    initial begin
      
        // reset condition
        rst=1'd0;
        tx_start=1'd0;
        tx_data=16'd0;
        //after reset
        #200;
        rst=1'd1;
        #200;
        tx_data=16'd1234;
        tx_start=1'd1;
        #20;
        tx_start=1'd0;
        
       wait(rx_done);
        
        
      
        if (!rx_done) begin
            $display("Test Failed:rx_done not compelete ");
        end 
        else if (rx_data != tx_data) begin
            $display("Test Failed: tx_data = %d , rx_data = %d ", 
                     tx_data, rx_data);
        end 
        else begin
            $display("Test Success");
        end
    end
  

endmodule
