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

generate
  for (k=0;k<N;k=k+1) begin

    assign tc[k] = & cnt[k];
    assign ro[k] = tc[k] & ENABLE;

    always @(posedge clk)
      if (LOAD)
        cnt[k] <= DI[W/N*(k+1)-1:W/N*k];
      else if (ro[k])
        cnt[k] <= cnt[k] + 1;

    assign DO[W/N*(k+1)-1:W/N*k] = cnt[k];

  end
endgenerate

endmodule
//EOF
