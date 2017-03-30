// DetectWinner
// Detects whether either ain or bin has three in a row 
// Inputs:
//   ain, bin - (9-bit) current positions of type a and b
// Out:
//   win_line - (8-bit) if A/B wins, one hot indicates along which row, col or diag
//   win_line(0) = 1 means a win in row 8 7 6 (i.e., either ain or bin has all ones in this row)
//   win_line(1) = 1 means a win in row 5 4 3
//   win_line(2) = 1 means a win in row 2 1 0
//   win_line(3) = 1 means a win in col 8 5 2
//   win_line(4) = 1 means a win in col 7 4 1
//   win_line(5) = 1 means a win in col 6 3 0
//   win_line(6) = 1 means a win along the downward diagonal 8 4 0
//   win_line(7) = 1 means a win along the upward diagonal 2 4 6

module DetectWinner( input [8:0] ain, bin, output [7:0] win_line );
  // CPEN 211 LAB 3, PART 1: your implementation goes here
  //input [8:0] ain, bin;
  //output [7:0] win_line;

  assign win_line[0] = (ain[8] & ain[7] & ain[6]) | (bin[8] & bin[7] & bin[6]);
  assign win_line[1] = (ain[5] & ain[4] & ain[3]) | (bin[5] & bin[4] & bin[3]);
  assign win_line[2] = (ain[2] & ain[1] & ain[0]) | (bin[2] & bin[1] & bin[0]);
  assign win_line[3] = (ain[8] & ain[5] & ain[2]) | (bin[8] & bin[5] & bin[2]);
  assign win_line[4] = (ain[7] & ain[4] & ain[1]) | (bin[7] & bin[4] & bin[1]);
  assign win_line[5] = (ain[6] & ain[3] & ain[0]) | (bin[6] & bin[3] & bin[0]);
  assign win_line[6] = (ain[8] & ain[4] & ain[0]) | (bin[8] & bin[4] & bin[0]);
  assign win_line[7] = (ain[2] & ain[4] & ain[6]) | (bin[2] & bin[4] & bin[6]);
endmodule


module Detect_tb();
   reg [8:0] ain, bin;
   wire [7:0] win_line;

   DetectWinner dut(ain, bin, win_line);

   initial begin
     //testing win_line[0] for ain and bin
     ain = 9'b111000000; bin = 9'b000000000;
     #100
     bin = 9'b111000000; ain = 9'b000000000;
     #100
     //testing win_line[1] for ain and bin
     ain = 9'b000111000; bin = 9'b000000000;
     #100
     bin = 9'b000111000; ain = 9'b000000000;
     #100
     //testing win_line[2] for ain and bin
     ain = 9'b000000111; bin = 9'b000000000;
     #100
     bin = 9'b000000111; ain = 9'b000000000;
     #100
     //testing win_line[3] for ain and bin
     ain = 9'b100100100; bin = 9'b000000000;
     #100
     bin = 9'b100100100; ain = 9'b000000000;
     #100
     //testing win_line[4] for ain and bin
     ain = 9'b010010010; bin = 9'b000000000;
     #100
     bin = 9'b010010010; ain = 9'b000000000;
     #100
     //testing win_line[5] for ain and bin
     ain = 9'b001001001; bin = 9'b000000000;
     #100
     bin = 9'b001001001; ain = 9'b000000000;
     #100
     //testing win_line[6] for ain and bin
     ain = 9'b100010001; bin = 9'b000000000;
     #100
     bin = 9'b100010001; ain = 9'b000000000;
     #100
     //testing win_line[7] for ain and bin
     ain = 9'b001010100; bin = 9'b000000000;
     #100
     bin = 9'b001010100; ain = 9'b000000000;
     #100
     //testing when win_line should not result in a win
     ain = 9'b011000000; bin = 9'b000110101;
     #100
     //testing that win_line separates ain and bin results
     ain = 9'b000100000; bin = 9'b000011000;
     #100

     $display("All tests ran successfully");

   end
endmodule
