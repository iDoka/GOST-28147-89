/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2016 Dmitry Murzinov (kakstattakim@gmail.com)   //
/////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ns

///////////////// Cascaded Synchronous Counter /////////////////
module counter_rollover_tb();

parameter WIDTH_DATA = 8;

// clock generator settings:
parameter cycles_reset =  2;  // rst active  (clk)
parameter clk_period   = 10;  // clk period ns
parameter clk_delay    =  0;  // clk initial delay

reg clk;    // clock
reg rst;    // sync reset
reg enable;
reg load;


//reg  [WIDTH_KEY-1:0]  key;   // cipher key  input
reg  [WIDTH_DATA-1:0] init_value; // plain  text input
wire [WIDTH_DATA-1:0] data; // cipher text output

reg [WIDTH_DATA-1:0] clk_counter; // clock counter for reference

wire EQUAL = (data == clk_counter);
wire [8*4-1:0] STATUS = EQUAL ? "OK" : "FAIL";

// DUT
counter_rollover
#(.W(WIDTH_DATA), // width of counter
  .N(2)) // how many parts contain counter?
counter_rollover_u0(
  .CLK(clk),
  .ENABLE(enable),
  .LOAD(load),
  .DI(init_value),
  .DO(data));


// Clock generation
 always begin
 # (clk_delay);
   forever # (clk_period/2) clk = ~clk;
 end

/////// clock counter for reference
always begin
 @( posedge clk );
   if (load)
     clk_counter <= init_value;
   else
     clk_counter <= clk_counter + 1;
end


// Initial statement
initial begin
 #0 clk  = 1'b0;
    clk_counter = 0;
    enable = 1;
    load = 0;
    init_value = 0;
  @(posedge clk)
    load = 1;
  @(posedge clk)
    load = 0;

  #(clk_period*20);
  $finish;
  //$finish_and_return(code);
end


///// displyaing
always @(posedge clk)
  if (!load)
    #1 $display("REFOUT: %03d \t OUT: %03d  ---> %s", clk_counter, data, STATUS);


///// condition of end simulation
always @(posedge clk)
  if (&data)
    $finish;


/////////////// dumping
initial
 begin
    $dumpfile("counter_rollover.vcd");
    $dumpvars(0,counter_rollover_tb);
 end

endmodule
// eof

