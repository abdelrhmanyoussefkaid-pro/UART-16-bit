module top(
    input clk,rst,tx_start,rx,
    input [15:0]tx_data,
    output rx_done,
    output [15:0]rx_data,
    output tx
);
   wire baud_tick;
   wire rx_sync;
   // baud generation
    baud_generation inst1(.clk(clk),.rst(rst),.baud_tick(baud_tick));
    
    // rx synchronizer
    synchronizer inst2(.clk(clk),.rst(rst),.rx(rx),.rx_sync(rx_sync));
    
    // tx 
    tx inst3(.clk(clk),.rst(rst),.tx_start(tx_start),.tx_data(tx_data),.baud_tick(baud_tick),.tx(tx));

    // rx
    rx inst4(.clk(clk),.rst(rst),.rx(rx_sync),.rx_data(rx_data),.baud_tick(baud_tick),.rx_done(rx_done));



endmodule
