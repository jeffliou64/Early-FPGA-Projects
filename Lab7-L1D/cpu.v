module cpu(clk, reset, Cout);
  input clk,reset;
  //output loada,loadb,loadc,loads;
  //output [7:0] PC;
  //output [15:0] mdata, IR, Cout;
  //output [1:0] vsel;
  //output execb;
  //output [2:0] status;
  output [15:0] Cout;

  wire mwrite, msel, execb, incp, loadir;
  wire asel, bsel, loada, loadb, loadc, loads, write;
  wire [1:0] op, ALUop, shift, vsel, nsel;
  wire [2:0] opcode, readnum, writenum,  status, cond;
  wire [15:0] Bout, sximm5, sximm8, mdata, IR;
  wire [7:0] PC;

  datapath datapathx (clk, writenum, write, readnum, vsel, sximm5, sximm8, mdata, asel, bsel, shift, ALUop, loada,
                     loadb, loadc, loads, status, Bout, Cout, PC);

  Program_counter PCx (clk, reset, sximm8, incp, execb, status, cond, msel, Bout, Cout, mwrite, loadir, PC, mdata, IR);

  //controller controllerx (clk, reset, opcode, op, cond, incp, execb, msel, mwrite, loadir, nsel, vsel, write, loada,
                         //loadb, loadc, loads, asel, bsel);

  controller controllerx (clk, reset, opcode, op, loadir, incp, execb, msel, mwrite, loada, loadb, asel, bsel, loadc, loads,
                          write, nsel, vsel);

  instruction_dec instruction_decx (IR, nsel, opcode, op, cond, ALUop, readnum, writenum, shift, sximm8, sximm5);

endmodule



module cpu_tb();
  reg clk, reset;
  wire loada,loadb,loadc,loads;
  wire [7:0] PC;
  wire [15:0] mdata, IR, Cout;
  wire [1:0] vsel;
  wire execb;
  wire [2:0] status;

  cpu DUT(clk, reset, Cout, loada,loadb,loadc,loads,PC,mdata,IR,vsel,execb,status);

  initial begin
    clk = 1'b0; #5;
    reset = 1'b1; #5;
    clk = 1'b1; #5;
    clk = 1'b0;
    reset = 1'b0; #5;
    repeat (80) begin
      clk = 1'b1; #5;
      clk = 1'b0; #5;
    end
  end
endmodule






