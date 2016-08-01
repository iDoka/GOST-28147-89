/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2016 Dmitry Murzinov (kakstattakim@gmail.com)   //
/////////////////////////////////////////////////////////////////////

module ram16x4bit (
    input   wire       CLK, // Clock
    input   wire       CEN, // ChipEnable
    input   wire       WEN, // Write (otherwise read)
    input   wire [3:0] A,   // Address
    input   wire [3:0] D,   // Data Input
    output  reg  [3:0] Q    // Data output
);

///////////////////////////////////////////////////
// Declare the RAM array
reg [7:0] mem [3:0];

always @(posedge CLK)
  if (CEN & WEN)
    mem[A] <= D;

always @(posedge CLK)
  if (CEN & !WEN)
    Q <= mem[A];

endmodule
//EOF
