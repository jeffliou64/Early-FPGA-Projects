/*module controller(clk, reset, opcode, op, cond, incp, execb, msel, mwrite, loadir, nsel, vsel, write, loada, loadb, loadc, loads, asel, bsel);
  input reset, clk;
  input [2:0] opcode, cond;
  input [1:0] op;
  output loadir, incp, execb, msel, mwrite, loada, loadb, loadc, loads, asel, bsel, write;
  output [2:0] nsel;
  output [1:0] vsel;
  wire [4:0] current_state, next_state_reset;
  reg [4:0] next_state;
  reg [16:0] out;
  //incp(1),execb(1),msel(1),mwrite(1),loadir(1),nsel(3),vsel(2),write(1),loada(1),loadb(1),loadc(1),loads(1),asel(1),bsel(1)
  `define HW  5
  `define H0  5'b00000//1st state after reset
  `define H1  5'b00001//2nd state
  `define H2  5'b00010//loadIR
  `define H3  5'b00011//update PC
  `define H4  5'b00100
  `define H5  5'b00101//read decode (opcode)
  `define H6  5'b00110//1st step in operation
  `define H7  5'b00111//2nd step in operation
  `define H8  5'b01000//3rd step in operation
  `define H9  5'b01001//4th step in operation
  `define H10 5'b01010
  `define H11 5'b01011

  vDFFE #(`HW) STATE(clk,1'b1, next_state_reset,current_state);
  assign next_state_reset= reset ? `H0 : next_state;

  always @(*) begin
    casex ({current_state,opcode,op})
    {`H0,3'bxxx,2'bxx} : {next_state,out} = {`H1,17'b00000000000000000};//1st state after reset
    {`H1,3'bxxx,2'bxx} : {next_state,out} = {`H2,17'b00000000000000000};//2nd state after reset
    {`H2,3'bxxx,2'bxx} : {next_state,out} = {`H3,17'b00001000000000000};//loadIR
    {`H3,3'bxxx,2'bxx} : {next_state,out} = {`H4,17'b10000000000000000};//update PC
    {`H4,3'bxxx,2'bxx} : {next_state,out} = {`H5,17'b00000000000000000};
    {`H5,3'bxxx,2'bxx} : {next_state,out} = {`H6,17'b00000000000000000};//decode state (reading decode)

    {`H6,3'b110,2'b10} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H7,5'b00000,3'b001,9'b111000000}; //mov Rn,#<imm8>
    {`H7,3'b110,2'b10} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H8,5'b00000,3'b100,9'b000001010};
    {`H8,3'b110,2'b10} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H2,5'b00000,3'b010,9'b100000000};

    {`H6,3'b110,2'b00} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H7,5'b00000,3'b100,9'b000010000}; //mov Rd,Rm{,<sh_op>}
    {`H7,3'b110,2'b00} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H8,5'b00000,3'b100,9'b000001010};
    {`H8,3'b110,2'b00} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H2,5'b00000,3'b010,9'b100000000};

    {`H6,3'b101,2'bx0} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H7,5'b00000,3'b100,9'b000010000}; //ADD & AND
    {`H7,3'b101,2'bx0} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H8,5'b00000,3'b001,9'b000100000};
    {`H8,3'b101,2'bx0} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H9,5'b00000,3'b100,9'b000001000};
    {`H9,3'b101,2'bx0} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H2,5'b00000,3'b010,9'b001000000};

    {`H6,3'b101,2'b11} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H7,5'b00000,3'b100,9'b000010000}; //MVN
    {`H7,3'b101,2'b11} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H8,5'b00000,3'b100,9'b000001010};
    {`H8,3'b101,2'b11} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H2,5'b00000,3'b010,9'b001000000};

    {`H6,3'b101,2'b01} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H7,5'b00000,3'b100,9'b000010000}; //CMP
    {`H7,3'b101,2'b01} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H2,5'b00000,3'b001,9'b000100000};


    {`H5,3'b001,2'bxx} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H6,5'b01000,3'b000,9'b000000000}; //B
    {`H6,3'b001,2'bxx} : {next_state,out[16:12],out[11:9],out[8:0]} = {`H2,5'b01000,3'b000,9'b000000000};
    default : {next_state,out}={22{1'bx}};
    endcase
  end
   //loadpc(1),msel(1),mwrite(1),loadir(1),nsel(3),vsel(2),write(1),looada(1),looadb(1),looadc(1),looads(1),asel(1),bsel(1)
  assign {incp,execb,msel,mwrite,loadir}={out[16:12]};
  assign {nsel,vsel}={out[11:7]};
  assign {write,loada,loadb,loadc,loads,asel,bsel}={out[6:0]};
endmodule*/

`define SET_PC1     5'b00000
`define SET_PC2     5'b00001
`define L_IR        5'b00010
`define UPDATE_PC1  5'b00011
`define UPDATE_PC2  5'b00100
`define DEC_READ_RN 5'b00101
`define MOV1        5'b00110
`define MOV2        5'b00111
`define MOV3        5'b01000
`define ALU1        5'b01001
`define ALU2        5'b01010
`define ALU3        5'b01011
`define ALU4        5'b01100
`define MEM1a       5'b01101
`define MEM2a       5'b01110
`define MEM3a       5'b01111
`define MEM4a       5'b10000
`define MEM1b       5'b10001
`define MEM2b       5'b10010
`define MEM3b       5'b10011
`define MEM4b       5'b10100
`define BRN1        5'b10101
`define BRN2        5'b10110
module controller(clk, reset, opcode, op, loadir, incp, execb, msel, mwrite, loada, loadb,
            asel, bsel, loadc, loads, write, nsel, vsel);
  input clk, reset;
  input [2:0] opcode;
  input [1:0] op;
  output loadir, incp, execb, msel, mwrite, loada, loadb, asel, bsel, loadc, loads, write;
  reg loadir, incp, execb, msel, mwrite, loada, loadb, asel, bsel, loadc, loads, write;
  output [1:0] nsel, vsel;
  reg [1:0] nsel, vsel;
  wire [4:0] state;
  reg [4:0] next_state;
  wire [4:0] next_state_reset;

  always @(*) begin
    casex({state, opcode, op})
      {`SET_PC1, 5'bxxxxx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`SET_PC2, 16'b0000000000000000};
      {`SET_PC2, 5'bxxxxx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0000000000000000};
      {`L_IR, 5'bxxxxx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`UPDATE_PC1, 16'b1000000000000000};
      {`UPDATE_PC1, 5'bxxxxx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`UPDATE_PC2, 16'b0100000000000000};
      {`UPDATE_PC2, 5'bxxxxx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`DEC_READ_RN, 16'b0000000000000000};
      {`DEC_READ_RN, 5'b110x0}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MOV1, 16'b0000000000000000};
      {`DEC_READ_RN, 5'b101xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU1, 16'b0000000000000000};
      {`DEC_READ_RN, 5'b01100}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM1a, 16'b0000000000000000};
      {`DEC_READ_RN, 5'b10000}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM1b, 16'b0000000000000000};
      {`DEC_READ_RN, 5'b001xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`BRN1, 16'b0000000000000000};
      {`MOV1, 5'bxxx10}: {next_state, loadir, incp, execb,  msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0000010100000001};
      {`MOV1, 5'bxxx00}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MOV2, 16'b0000000000100000};
      {`MOV2, 5'bxxx00}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MOV3, 16'b0000000000010100};
      {`MOV3, 5'bxxx00}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0000001000000001};
      {`ALU1, 5'bxxx00}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU2, 16'b0000000000100000};
      {`ALU2, 5'bxxx00}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU3, 16'b0000010001000000};
      {`ALU3, 5'bxxx00}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU4, 16'b0000000000000100};
      {`ALU4, 5'bxxx00}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0000001000000001};
      {`ALU1, 5'bxxx01}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU2, 16'b0000000000100000};
      {`ALU2, 5'bxxx01}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU3, 16'b0000010001000000};
      {`ALU3, 5'bxxx01}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0000000000000010};
      {`ALU1, 5'bxxx10}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU2, 16'b0000000000100000};
      {`ALU2, 5'bxxx10}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU3, 16'b0000010001000000};
      {`ALU3, 5'bxxx10}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU4, 16'b0000000000000100};
      {`ALU4, 5'bxxx10}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0000001000000001};
      {`ALU1, 5'bxxx11}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU2, 16'b0000000000100000};
      {`ALU2, 5'bxxx11}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`ALU3, 16'b0000000000010100};
      {`ALU3, 5'bxxx11}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0000001000000001};
      {`MEM1a, 5'b011xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM2a, 16'b0000010001000000};
      {`MEM2a, 5'b011xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM3a, 16'b0000000000001100};
      {`MEM3a, 5'b011xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM4a, 16'b0001000000000000};
      {`MEM4a, 5'b011xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0001001110000001};
      {`MEM1b, 5'b100xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM2b, 16'b0000010001000000};
      {`MEM2b, 5'b100xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM3b, 16'b0000000000001100};
      {`MEM3b, 5'b100xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`MEM4b, 16'b0000001000100000};
      {`MEM4b, 5'b100xx}: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0001100000000000};
      {`BRN1,5'b001xx} : {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`BRN2, 16'b0010000000000000};
      {`BRN2,5'b001xx} : {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} =
               {`L_IR, 16'b0010000000000000};
      default: {next_state, loadir, incp, execb, msel, mwrite, nsel, vsel, loada, loadb, asel, bsel, loadc, loads, write} = {21{1'bx}};
    endcase
  end
  assign next_state_reset = reset ? `SET_PC1 : next_state;
  vDFFE #(5) stateDFF(clk, 1'b1, next_state_reset, state);
endmodule









module controller_tb();
  reg reset, clk;
  reg [2:0] opcode;
  reg [1:0] op;
  wire loadir, loadpc, msel, mwrite, looada, looadb, looadc, looads, asel, bsel, write;
  wire [2:0] nsel;
  wire [1:0] vsel;
  controller dut(clk, reset, opcode, op, loadpc, msel, mwrite, loadir, nsel, vsel, write, looada, looadb, looadc, looads, asel, bsel);

  initial begin
    clk=1'b0;reset=1'b1;opcode=3'b110; op=2'b10;
    #100

    clk=1'b1;reset=1'b0;
    #100
    clk=1'b0;
    #100

    clk=1'b1;
    #100
    clk=1'b0;
    #100

    clk=1'b1;
    #100
    clk=1'b0;
    #100

    clk=1'b1;
    #100
    clk=1'b0;
    #100

    clk=1'b1;//enter mov function
    #100
    clk=1'b0;
    #100

    clk=1'b1;
    #100
    clk=1'b0;
    #100

    clk=1'b1;
    #100
    clk=1'b0;
    #100     //get output here

    clk=1'b1;opcode=3'b101; op=2'b00;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;     //finish ADD

    clk=1'b1;opcode=3'b101;op=2'b01;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;

    clk=1'b1;
    #100
    clk=1'b0;
    #100;
  end
endmodule
