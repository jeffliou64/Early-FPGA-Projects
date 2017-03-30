module lab7_top(KEY,SW,LEDR,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,CLOCK_50);
  input [3:0] KEY;
  input [9:0] SW;
  
  output [9:0] LEDR; 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  input CLOCK_50;
  
  wire [15:0] Cout;
  wire clk, reset;

  cpu CPU1(CLOCK_50, reset, Cout);

  sseg seg0(Cout[3:0], HEX0);
  sseg seg1(Cout[7:4], HEX1);
  sseg seg2(Cout[11:8], HEX2);
  sseg seg3(Cout[15:12], HEX3);
  sseg seg4(4'b0000, HEX4);
  sseg seg5(4'b0000, HEX5);
endmodule

module sseg(in,segs);
  input [3:0] in;
  output [6:0] segs;
  reg [6:0] segs;

  always @(*) begin
    case(in)
      0: segs = 7'b1000000;
      1: segs = 7'b1111001;
      2: segs = 7'b0100100;
      3: segs = 7'b0110000;
      4: segs = 7'b0011001;
      5: segs = 7'b0010010;
      6: segs = 7'b0000010;
      7: segs = 7'b1111000;
      8: segs = 7'b0000000;
      9: segs = 7'b0010000;
      10: segs = 7'b0001000;
      11: segs = 7'b0000011;
      12: segs = 7'b1000110;
      13: segs = 7'b0100001;
      14: segs = 7'b0000110;      
      15: segs = 7'b0001110;
    endcase
  end 

endmodule
