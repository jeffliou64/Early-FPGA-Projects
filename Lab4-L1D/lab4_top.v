module lab4_top(SW,KEY,HEX0);  //prints 2-4-0-3-1
  input [9:0] SW;
  input [3:0] KEY;
  output [6:0] HEX0;
  reg [4:0] next_state;
  reg [6:0] HEX0;
  wire [4:0] reset_state, present_state; //the next state after pressing KEY
                                 //and initializing it to the first state
  `define HW 5
  `define H0 5'b00001 //2  7'b0100100
  `define H1 5'b00010 //4  7'b0011001
  `define H2 5'b00100 //0  7'b1000000
  `define H3 5'b01000 //3  7'b0110000
  `define H4 5'b10000 //1  7'b1111001
  //assign present_state=7'b0100100;

  vDFF #(`HW) STATE(KEY[0],reset_state,present_state);
  assign reset_state= ~KEY[1] ? `H0 : next_state;

  always @(*)begin //number changes only on the rising edge of the clock
                   //otherwise the number will change
      case(present_state)
        `H0 : {next_state, HEX0}={(SW[0] ? `H1 : `H4),7'b0100100};   //if switch is on, then the program goes through in one direction
        `H1 : {next_state, HEX0}={(SW[0] ? `H2 : `H0),7'b0011001};
        `H2 : {next_state, HEX0}={(SW[0] ? `H3 : `H1),7'b1000000};
        `H3 : {next_state, HEX0}={(SW[0] ? `H4 : `H2),7'b0110000};   //if switch is off, then the program
        `H4 : {next_state, HEX0}={(SW[0] ? `H0 : `H3),7'b1111001};   //will print in the opposite direction
        default {next_state, HEX0}={`H0,7'b0100100};                     //default to '2' or first state
      endcase
  end
endmodule

module vDFF(clk, in, out);
 parameter n=1;
 input clk;
 input [n-1:0] in;
 output [n-1:0] out;
 reg [n-1:0] out;

 always @(posedge clk)
  out=in;
endmodule
