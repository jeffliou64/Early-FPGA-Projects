module cpu(clk, reset, opcode, op,loadpc, msel, mwrite, loadir, nsel, vsel, write, looada, looadb, looadc, looads, asel, bsel);
  input reset, clk;
  input [2:0] opcode;
  input [1:0] op;
  output loadir, loadpc, msel, mwrite, looada, looadb, looadc, looads, asel, bsel, write;
  output [2:0] nsel;
  output [1:0] vsel;
  wire [4:0] current_state, next_state_reset;
  reg [4:0] next_state;
  reg [15:0] out;
   //loadpc(1),msel(1),mwrite(1),loadir(1),nsel(3),vsel(2),write(1),looada(1),looadb(1),looadc(1),looads(1),asel(1),bsel(1)
  `define HW 5
  `define H0 5'b00000//1st state after reset
  `define H1 5'b00001//loadIR
  `define H2 5'b00010//update PC
  `define H3 5'b00011//read decode (opcode)
  `define H4 5'b00100//1st step in operation
  `define H5 5'b00101//2nd step in operation
  `define H6 5'b00110//3rd step in operation

  vDFFE #(`HW) STATE(clk,1'b1, next_state_reset,current_state);
  assign next_state_reset= reset ? `H0 : next_state;

  always @(*) begin
    casex ({current_state,opcode,op})
    {`H0,3'bxxx,2'bxx} : {next_state,out} = {`H1,16'b0000000000000000};//1st state after reset
    {`H1,3'bxxx,2'bxx} : {next_state,out} = {`H2,16'b0001001000000000};//loadIR
    {`H2,3'bxxx,2'bxx} : {next_state,out} = {`H3,16'b1000001001000000};//update PC
    {`H3,3'bxxx,2'bxx} : {next_state,out} = {`H4,16'b0000100000100000};//decode state (reading decode)

    {`H4,3'b110,2'b10} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H5,4'b0000,3'b100,9'b001010000};//mov Rn,#<imm8>
    {`H5,3'b110,2'b10} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H6,4'b0000,3'b000,9'b000001100};
    {`H6,3'b110,2'b10} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H1,4'b0000,3'b001,9'b100000000};

    {`H4,3'b110,2'b00} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H5,4'b0000,3'b100,9'b001010000};//mov Rd,Rm{,<sh_op>}
    {`H5,3'b110,2'b00} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H6,4'b0000,3'b000,9'b000001100};
    {`H6,3'b110,2'b00} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H1,4'b0000,3'b010,9'b100000000};

    {`H4,3'b101,2'bx0} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H5,4'b0000,3'b100,9'b001010000};  //ADD & AND
    {`H5,3'b101,2'bx0} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H6,4'b0000,3'b000,9'b000001100};
    {`H6,3'b101,2'bx0} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H1,4'b0000,3'b010,9'b100000000};

    {`H4,3'b101,2'b11} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H5,4'b0000,3'b100,9'b001010000};   //MVN
    {`H5,3'b101,2'b11} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H6,4'b0000,3'b000,9'b000001100};
    {`H6,3'b101,2'b11} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H1,4'b0000,3'b010,9'b100000000};

    {`H4,3'b101,2'b01} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H5,4'b0000,3'b100,9'b001010000}; //CMP
    {`H5,3'b101,2'b01} : {next_state,out[15:12],out[11:9],out[8:0]} = {`H1,4'b0000,3'b010,9'b000000100};
    endcase
  end
   //loadpc(1),msel(1),mwrite(1),loadir(1),nsel(3),vsel(2),write(1),looada(1),looadb(1),looadc(1),looads(1),asel(1),bsel(1)
  assign {loadpc,msel,mwrite,loadir}={out[15:12]};
  assign {nsel,vsel}={out[11:7]};
  assign {write,looada,looadb,looadc,looads,asel,bsel}={out[6:0]};
endmodule

module cpu_tb();
  reg reset, clk;
  reg [2:0] opcode;
  reg [1:0] op;
  wire loadir, loadpc, msel, mwrite, looada, looadb, looadc, looads, asel, bsel, write;
  wire [2:0] nsel;
  wire [1:0] vsel;
  cpu dut(clk, reset, opcode, op, loadpc, msel, mwrite, loadir, nsel, vsel, write, looada, looadb, looadc, looads, asel, bsel);

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
