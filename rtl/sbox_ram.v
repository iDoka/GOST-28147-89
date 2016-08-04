/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2016 Dmitry Murzinov (kakstattakim@gmail.com)   //
/////////////////////////////////////////////////////////////////////

module sbox_ram (
    input   wire       CLK, // Clock
    input   wire       CEN, // ChipEnable
    input   wire       WEN, // Write (otherwise read)
    input   wire      INIT, // 0 - normal mode, 1 - loading S-box
    input   wire [31:0] SA, // SBox Individual Addresses
    input   wire  [3:0] CA, // Common Address for All rams
    input   wire [31:0] SI, // Data Input
    output  reg  [31:0] SO  // Data output
);
///////////////////////////////////////////////////

wire [3:0] AMUX [7:0]; // for address multiplexer

genvar i;
generate
  for (i = 0; i < 8; i = i + 1) begin: sbox_ram
    ram16x4bit
      sbox_ram_u0
       (.CLK(CLK          ),
        .CEN(CEN          ),
        .WEN(WEN          ),
        .A(  AMUX[i]      ),
        .D(  SI[i*4+3:i*4]),
        .Q(  SO[i*4+3:i*4])
        );
    assign AMUX[i] = INIT ? CA : SA[i*4+3:i*4];
  end
endgenerate

endmodule
//EOF
