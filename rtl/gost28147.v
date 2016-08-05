/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2016 Dmitry Murzinov (kakstattakim@gmail.com)   //
/////////////////////////////////////////////////////////////////////

module gost28147 (
  input             clk,    // Input clock signal for synchronous design
  input             rst,    // Syncronous Reset input
  input             mode,   // 0 - encrypt, 1 - decrypt
  input     [255:0] key,    // cipher key
  input      [63:0] pdata,  // plain text data  input
  input             pvalid, // plain text valid input
  output reg        pready, // plain text ready handshake
  output reg [63:0] cdata,  // cipher text data  output
  output reg        cvalid, // cipher text valid (ready for output read)
  input             cready  // cipher text ready handshake
);

`include "sbox.vh"


////////////////////////////////////////////////////////////////////////////////
////  Crypto Stream state machine                                           ////
////////////////////////////////////////////////////////////////////////////////
reg [1:0] state;
reg [1:0] next_state;

localparam IDLE  = 2'b00,
           RUN   = 2'b01,
           READY = 2'b10;

always @(posedge clk) begin: stream_fsm
  if (rst)
    state <= IDLE;
  else
    state <= next_state;
end

always @(*) begin
  case (state)

    IDLE : begin : idle_state
      if (pvalid && pready)
        next_state = RUN;
      else
        next_state = IDLE;
    end : idle_state

    RUN : begin : run_state
      if (&i)
        next_state = READY;
      else
        next_state = RUN;
    end : run_state

    READY : begin : ready_state
      if (cready == 1)
        next_state = IDLE;
      else
        next_state = READY;
    end : ready_state

    default : next_state = IDLE;
  endcase
end


////////////////////////////////////////////////////////////////////////////////
////  Crypto Engine                                                         ////
////////////////////////////////////////////////////////////////////////////////

reg [4:0] i; // cipher cycles counter: 0..31;

always @(posedge clk)
  if((state == IDLE) || (state == READY))
    i <= 5'h0;
  else
    i <= i + 1;

wire [2:0] enc_index = (&i[4:3]) ? ~i[2:0] : i[2:0]; // cipher key index for encrypt
wire [2:0] dec_index = (|i[4:3]) ? ~i[2:0] : i[2:0]; // cipher key index for decrypt
wire [2:0] kindex    = mode ? dec_index : enc_index; // cipher key index

wire [31:0] K [0:7]; // cipher key storage
assign {K[0],K[1],K[2],K[3],K[4],K[5],K[6],K[7]} = key;

reg   [31:0] b, a; // MSB, LSB of input data
wire  [31:0] addmod32 = a + K[kindex];  // Adding by module 32
wire  [31:0] sbox     = `Sbox(addmod32); // S-box replacing
wire  [31:0] shift11  = {sbox[20:0],sbox[31:21]}; // <<11

always @(posedge clk)
  if(rst)
    {b,a} <= {64{1'b0}};
  else if (pvalid && pready) // load plain text and start cipher cycles
    {b,a} <= pdata;
  else if (state == RUN)
    {b,a} <= {a, b^shift11};

always @(posedge clk)
  if (state == READY)
    cdata <= {a,b};

always @(posedge clk)
  if (state == READY)
    cvalid <= 1'b1;
  else
    cvalid <= 1'b0;

always @(posedge clk)
  if ((state == RUN) || (state == READY))
    pready <= 1'b0;
  else if (cready)
    pready <= 1'b1;
 /// else if (state == RUN)
 ///  pready <= 1'b0;

////////////////////////////////////////////////////////////////////////////////


endmodule

