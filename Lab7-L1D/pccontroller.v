module pccontroller(clk,reset, opcode, op, cond, Bout, Cout, sximm8, status, IR, PC);
  input clk;
  input reset;
  input [2:0] opcode, cond;
  input [1:0] op;

  input [15:0] Bout, Cout, sximm8;
  input [2:0] status;

  output [15:0] IR;
  output [7:0] PC;

  wire mwrite, msel, execb, incp, loadir;
  wire asel, bsel, loada, loadb, loadc, loads, write;
  wire [1:0] op, ALUop, shift, vsel, nsel;
  wire [2:0] opcode, readnum, writenum, status, cond;
  wire [15:0] Bout, sximm5, sximm8, mdata, IR;
  wire [7:0] PC;


  Program_counter pcx(clk, reset, sximm8, incp, execb, status, cond, msel, Bout, Cout, mwrite, loadir, PC, mdata, IR);

  controller controlx(clk, reset, opcode, op, loadir, incp, execb, msel, mwrite, loada, loadb,
            asel, bsel, loadc, loads, write, nsel, vsel);

endmodule


module pccontroller_tb();
  reg clk;
  reg reset;
  reg [2:0] opcode, cond;
  reg [1:0] op;
  reg [15:0] Bout, Cout, sximm8;
  reg [2:0] status;
  wire [15:0] IR;
  wire [7:0] PC;

  pccontroller dut (clk, reset, opcode, op, cond, Bout, Cout, sximm8, status, IR, PC);

  initial begin
    clk=1'b0;reset=1'b1;opcode=3'b001; op=2'b00; cond=3'b000; Bout=16'b0000000000000000; Cout=16'b1100110011001100; sximm8=16'b0111111111111111; status=3'b111;
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

    clk=1'b1;
    #100
    clk=1'b0;
    #100;
  end
endmodule
