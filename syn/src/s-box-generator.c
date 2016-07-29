/////////////////////////////////////////////////////////////////////
//   This file is part of the GOST 28147-89 CryptoCore project     //
//                                                                 //
//   Copyright (c) 2014 Dmitry Murzinov (kakstattakim@gmail.com)   //
/////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include <stdio.h>
#include <unistd.h>
////////////////////
#include <string.h>
#include <stdlib.h>

#include "s-box-parameter.h"

int main(int argc, const char *argv[]) {

  int i, j;
  uint8_t index;

  printf("\n\n`define Sbox(x) {S8(x[31:28]),S7(x[27:24]),S6(x[23:20]),S5(x[19:16]),S4(x[15:12]),S3(x[11:8]),S2(x[7:4]),S1(x[3:0])}\n");


  for ( i = 0; i < 8; i++ ) {
    index = i+1;
    printf("\n\nfunction [3:0] S%d( input [3:0] x );\n", index);
    printf("  begin\n");
    printf("    case(x)\n");
    for ( j = 0; j < 16; j++ ) {
      printf("      4'd%02d: S%d = 4'h%01X;\n", j, index, SBOX[i][j]);
    }
    printf("      default: S%d = 4'hX;\n", index);
    printf("    endcase\n");
    printf("  end\n");
    printf("endfunction\n");
  }
  printf("\n\n");

  return EXIT_SUCCESS;
}

