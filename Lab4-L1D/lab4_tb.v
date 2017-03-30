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

module lab4_tb();  //testbench module
  reg [9:0] SW;
  reg [3:0] KEY;
  wire [6:0] HEX0;

  lab4_top dut(SW,KEY,HEX0);

  initial begin //total of 28 different tests
     SW=10'b0000000001; KEY=4'b0011; //2
     #10
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000001; KEY=4'b0011;  //2->4 [0100100->0011001] (1 press)
     #30
     SW=10'b0000000001; KEY=4'b0010;  //releasing KEY0 to allow next press to activate properly
     #10

     SW=10'b0000000001; KEY=4'b0011;  //4->0 [0011001->1000000] (2nd press)
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000001; KEY=4'b0011;  //0->3 [1000000->0110000] (3rd press)
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000001; KEY=4'b0011;  //3->1 [0110000->1111001] (4th press)
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000001; KEY=4'b0011;  //1->2 [1111001->0100100] (5th press, 1 full cycle)
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000001; KEY=4'b0011;  //2->4 [0100100->0011001] (cycle continues)
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000001; KEY=4'b0001;  //resetting (4->2 in this case) [0011001->0100100]
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //changes direction, 2->1 [0100100->1111001]
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //1->3 [1111001->0110000]
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //3->0 [0110000->1000000]
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //0->4 [1000000->0011001]
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //4->2 [0011001->0100100]
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //2->1 [0100100->1111001]
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //1->3 [1111001->0110000]
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0001;  //resetting while in reverse (3->2 in this case)
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b1110;  //testing what happens if another key is pressed (should have no affect)
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0111;  //2->1  testing Key0,1,2 at the same time (should still work regardless)
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000001; KEY=4'b0011;  //changes direction, 1->2
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000000; KEY=4'b0011;  //checking that direction change works each time (2->1)
     #30
     SW=10'b0000000000; KEY=4'b0010;
     #10

     SW=10'b0000000011; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000000111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000001111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000011111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0000111111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0001111111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0011111111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b0111111111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10

     SW=10'b1111111111; KEY=4'b0011;  //checking that altering other switches has no effect
     #30
     SW=10'b0000000001; KEY=4'b0010;
     #10
     $display("Tests are finished.");
  end
endmodule
