/*******************************************************************************
Copyright (c) 2012, Stanford University
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
   must display the following acknowledgement:
   This product includes software developed at Stanford University.
4. Neither the name of Stanford Univerity nor the
   names of its contributors may be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY STANFORD UNIVERSITY ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL STANFORD UNIVERSITY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*******************************************************************************/

// TicTacToe
// Generates a move for X in the game of tic-tac-toe
// Inputs:
//   xin, oin - (9-bit) current positions of X and O.
// Out:
//   oout - (9-bit) one hot position of next O.
//
// Inputs and outputs use a board mapping of:
//
//   0 | 1 | 2
//  ---+---+---
//   3 | 4 | 5
//  ---+---+---
//   6 | 7 | 8 
//
// The top-level circuit instantiates strategy modules that each generate
// a move according to their strategy and a selector module that selects
// the highest-priority strategy module with a move.
//
// The win strategy module picks a space that will win the game if any exists.
//
// The block strategy module picks a space that will block the opponent
// from winning.
//
// The empty strategy module picks the first open space - using a particular
// ordering of the board.
//-----------------------------------------------------------------------------

// The following module, RArb, is combinational logic.  The input is a set
// of "requests" r -- one request per bit of r.  The output "g" is a set of
// grant signals.  If "r" is not all zeros, then a single bit of "g" will be
// set to 1.  Which bit?  The bit of "g" that will be set to 1 will be the
// bit that is in the same position as the first bit of "r" that is set to 
// 1 starting from the highest index bit position in "r".
//
// Note that r is declared as "input [n-1:0]".  This means it contains "n" 
// bits with index values from n-1 for the leftmost bit down to 0 for the
// right most bit.  By default n is set to 8, but we can change n when we
// instantiate the RArb module.  For example, using the notation "RArb #(9)"
// we change n to 9 when we instantiate RArb inside the module Empty.
//
// Suppose now that input r = 8'b00101111. Then, the bit with highest index,
// bit 7, has a value of 1'b0 and the bit with lowest index has value 1'b1.
// The output "g" will be 8'b00100000.  I recommend creating a small 
// testbench script and simulating just this module with different input 
// values until you are sure you understand how the output "g" depends upon 
// the input "r".
//
// NOTE:  The TAs will NOT expect you to know how the RArb module works 
// internally.  Specifically, you do not need to understand the following
// lines for Lab 3:
//
//    wire   [n-1:0] c = {1'b1,(~r[n-1:1] & c[n-1:1])} ;
//    assign g = r & c ;
//
// We will discuss a similar module Arb in class when we cover Slide Set 4, but
// if we have not done that yet, the above is all you need to know. However,
// if you are curious the textbook describes the operation of this module 
// in Chapter 8 (this code is in Figure 8.31).
module RArb(r, g) ;
  parameter n=8 ;
  input  [n-1:0] r ;
  output [n-1:0] g ;
  wire   [n-1:0] c = {1'b1,(~r[n-1:1] & c[n-1:1])} ;
  assign g = r & c ;
endmodule // RArb

//Figure 9.12 (note: this version slightly modified from book)
module TicTacToe(xin, oin, oout) ;
  input [8:0] xin, oin ;
  output [8:0] oout ;
  wire [8:0] win, block, adj, empty ;

  TwoInArray winx(oin, xin, win) ;              // win if we can
  TwoInArray blockx(xin, oin, block);            // try to block o from winning
  PlayAdjacentEdge adjacentx(xin, oin, adj);    // if player places in opposing corners
  Empty      emptyx(~(oin | xin), empty) ;      // otherwise pick empty space
  Select4    comb(win, block, adj, empty, oout) ;    // pick highest priority
endmodule // TicTacToe

//Figure 9.13
module TwoInArray(ain, bin, cout) ;
  input [8:0] ain, bin ;
  output [8:0] cout ;

  wire [8:0] rows, cols ;
  wire [2:0] ddiag, udiag ;

  // check each row
  TwoInRow topr(ain[2:0],bin[2:0],rows[2:0]) ;
  TwoInRow midr(ain[5:3],bin[5:3],rows[5:3]) ;
  TwoInRow botr(ain[8:6],bin[8:6],rows[8:6]) ;

  // check each column
  TwoInRow leftc({ain[6],ain[3],ain[0]},
                  {bin[6],bin[3],bin[0]},
                  {cols[6],cols[3],cols[0]}) ;
  TwoInRow midc({ain[7],ain[4],ain[1]},
                  {bin[7],bin[4],bin[1]},
                  {cols[7],cols[4],cols[1]}) ;
  TwoInRow rightc({ain[8],ain[5],ain[2]},
                  {bin[8],bin[5],bin[2]},
                  {cols[8],cols[5],cols[2]}) ;

  // check both diagonals
  TwoInRow dndiagx({ain[8],ain[4],ain[0]},{bin[8],bin[4],bin[0]},ddiag) ;
  TwoInRow updiagx({ain[6],ain[4],ain[2]},{bin[6],bin[4],bin[2]},udiag) ;

  //OR together the outputs
  assign cout = rows | cols |
         {ddiag[2],1'b0,1'b0,1'b0,ddiag[1],1'b0,1'b0,1'b0,ddiag[0]} |
         {1'b0,1'b0,udiag[2],1'b0,udiag[1],1'b0,udiag[0],1'b0,1'b0} ;
endmodule // TwoInArray

//Figure 9.14
module TwoInRow(ain, bin, cout) ;
  input [2:0] ain, bin ;
  output [2:0] cout ;

  assign cout[0] = ~bin[0] & ~ain[0] & ain[1] & ain[2] ;
  assign cout[1] = ~bin[1] & ain[0] & ~ain[1] & ain[2] ;
  assign cout[2] = ~bin[2] & ain[0] & ain[1] & ~ain[2] ;
endmodule // TwoInRow

//Figure 9.15
module Empty(in, out) ;
  input [8:0] in ;
  output [8:0] out ;

  RArb #(9) ra({in[4],in[0],in[2],in[6],in[8],in[1],in[3],in[5],in[7]},
          {out[4],out[0],out[2],out[6],out[8],out[1],out[3],out[5],out[7]}) ;
endmodule // Empty

module PlayAdjacentEdge(ain, bin, dout);
  input[8:0] ain,bin;
  output[8:0] dout;

  assign dout[5]= (ain[0]&~ain[1]&~ain[2]&~ain[3]&~ain[4]&~ain[5]&~ain[6]&~ain[7]&ain[8] & ~bin[0]&~bin[1]&~bin[2]&~bin[3]&bin[4]&~bin[5]&~bin[6]&~bin[7]&~bin[8])|(~ain[0]&~ain[1]&ain[2]&~ain[3]&~ain[4]&~ain[5]&ain[6]&~ain[7]&~ain[8] & ~bin[0]&~bin[1]&~bin[2]&~bin[3]&bin[4]&~bin[5]&~bin[6]&~bin[7]&~bin[8]);


endmodule //Pla yAdjacentEdge

//Figure 9.16
module Select4(a, b, d, c, out) ;
  input [8:0] a, b, d, c;
  output [8:0] out ;
  wire [35:0] x ;

  RArb #(36) ra({a,b,d,c},x) ;

  assign out = x[35:27] | x[26:18] | x[17:9] | x[8:0] ;
endmodule // modified Select3 into Select4, now with PlayAdjacentEdge

//Figure 9.18 (note: this version slightly modified from book)
module TestTic ;
  reg [8:0] xin, oin ;
  wire [8:0] xout, oout ;

  TicTacToe dut(xin, oin, oout) ;
  TicTacToe opponent(oin, xin, xout) ;

  initial begin
    // all zeros, should pick middle
    xin = 0 ; oin = 0 ;
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // can win across the top
    xin = 9'b101 ; oin = 0 ;
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // near-win: can't win across the top due to block
    xin = 9'b101 ; oin = 9'b010 ;
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // block in the first column
    xin = 0 ; oin = 9'b100100 ;
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // block along a diagonal
    xin = 0 ; oin = 9'b010100 ;
    #100 $display("%b %b -> %b", xin, oin, xout) ;
    // start a game - x goes first
    xin = 0 ; oin = 0 ;
    #100
    xin = 9'b100000001; oin = 9'b000010000;
    #100
    repeat (7) begin
      #100
      $display("%h %h %h", {xin[0],oin[0]},{xin[1],oin[1]},{xin[2],oin[2]}) ;
      $display("%h %h %h", {xin[3],oin[3]},{xin[4],oin[4]},{xin[5],oin[5]}) ;
      $display("%h %h %h", {xin[6],oin[6]},{xin[7],oin[7]},{xin[8],oin[8]}) ;
      $display(" ") ;
      xin = (xout | xin) ;
      #100
      $display("%h %h %h", {xin[0],oin[0]},{xin[1],oin[1]},{xin[2],oin[2]}) ;
      $display("%h %h %h", {xin[3],oin[3]},{xin[4],oin[4]},{xin[5],oin[5]}) ;
      $display("%h %h %h", {xin[6],oin[6]},{xin[7],oin[7]},{xin[8],oin[8]}) ;
      $display(" ") ;
      oin = (oout | oin) ;
    end
  end
endmodule

module TestPlayAdjacentEdge ;
  reg [8:0] xin, oin;
  wire [8:0] dout;

  TicTacToe dut(xin,oin,dout);

  initial begin
   //testing playadjacentedge
    xin = 9'b100000001; oin = 9'b000010000;
    #100
    $display("the output dout=%h%h%h%h%h%h%h%h%h", dout[8],dout[7],dout[6],dout[5],dout[4],dout[3],dout[2],dout[1],dout[0]);

    xin = 9'b001000100; oin = 9'b000010000;
    #100
    $display("the output dout=%h%h%h%h%h%h%h%h%h", dout[8],dout[7],dout[6],dout[5],dout[4],dout[3],dout[2],dout[1],dout[0]);
  end
endmodule
