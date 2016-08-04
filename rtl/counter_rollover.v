/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2016 Dmitry Murzinov (kakstattakim@gmail.com)   //
/////////////////////////////////////////////////////////////////////


///////////////// Cascaded Synchronous Counter /////////////////

module counter_rollover
#(parameter       W = 256, // width of counter
  parameter       N = 4)   // how many parts contain counter?
 (input  wire         CLK,
  input  wire         ENABLE,
  input  wire         LOAD,
  input  wire [W-1:0] DI,
  output wire [W-1:0] DO
  );

reg [(W/N)-1:0] cnt [N-1:0];

wire [N-1:0] tc; // TerminalCount
wire [N-1:0] ro; // RollOver


genvar k;
generate
  for (k=0;k<N;k=k+1) begin: gen_counter

    assign tc[k] = (k==0) ? 1'b1 : (tc[k-1] && (& cnt[k-1]));
    assign ro[k] = tc[k] & ENABLE;

    always @(posedge CLK) begin
      if (LOAD)
        cnt[k] <= DI[W/N*(k+1)-1:W/N*k];
      else if (ro[k])
        cnt[k] <= cnt[k] + 1;
    end

    assign DO[W/N*(k+1)-1:W/N*k] = cnt[k];

  end
endgenerate

`ifndef SYNTHESIS
  integer kk;
  initial begin
  $dumpfile("counter_rollover.vcd");
  for (kk=0;kk<N;kk=kk+1)
      $dumpvars(0,cnt[kk]);
  end
`endif

endmodule
//EOF



module counter_rollover2
#(parameter       W = 8, // width of counter
  parameter       N = 2) // not used, always equal to 2
 (input  wire         CLK,
  input  wire         ENABLE,
  input  wire         LOAD,
  input  wire [W-1:0] DI,
  output wire [W-1:0] DO
  );

  reg [(W/2)-1:0] CounterMSB;
  reg [(W/2)-1:0] CounterLSB;

  wire TerminalCount = & CounterLSB;

  wire RollOver = TerminalCount & ENABLE;

  always @(posedge CLK)
  if (LOAD)
    CounterMSB <= DI[W-1:W/2];
  else if (RollOver)
    CounterMSB <= CounterMSB + 1;

  always @(posedge CLK)
  if (LOAD)
    CounterLSB <= DI[(W/2)-1:0];
  else if (ENABLE)
    CounterLSB <= CounterLSB + 1;

  assign DO = {CounterMSB,CounterLSB};

endmodule
//EOF

