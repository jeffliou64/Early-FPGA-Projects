module datapath(clk,writenum,write,readnum,vsel,sximm5,sximm8,mdata,asel,bsel,shift,ALUop,loada,loadb,loadc,loads,status,Bout,Cout,PC, data_out, ALUout, Aout);
  input [15:0] sximm5, sximm8, mdata;
  input clk, write, asel, bsel, loada, loadb, loadc, loads;
  input [2:0] writenum, readnum;
  input [1:0] vsel, ALUop, shift;
  input [7:0] PC;
  output [15:0] Bout, Cout, data_out, ALUout ,Aout;
  output [2:0] status;
  wire [15:0] data_out, Aout, Bout, shiftedB,Ain,Bin, ALUout;
  wire [2:0] status_in, writenum, readnum;
  reg [15:0] data_in;

  always @(*)begin
    case(vsel)
      2'b11 : data_in = mdata;
      2'b10 : data_in = sximm8;
      2'b01 : data_in = {8'b00000000,PC};
      2'b00 : data_in = Cout;
     endcase
  end
  register_file regfilex (writenum, write, data_in, clk, readnum, data_out);
  vDFFE #(16) loadax (clk, loada, data_out, Aout);
  vDFFE #(16) loadbx (clk, loadb, data_out, Bout);

  amux amuxx(asel, Aout, Ain);
  shifter shiftx (Bout, shift, shiftedB);
  bmux bmuxx(bsel,shiftedB, sximm5, Bin);

  ALU ALUx (Ain, Bin, ALUop, ALUout, status_in);
  vDFFE #(16) loadcx (clk, loadc, ALUout, Cout);
  vDFFE #(3) loadsx (clk, loads, status_in, status);
endmodule

module amux(asel, Aout, Ain);
  input asel;
  input [15:0] Aout;
  output [15:0] Ain;
  reg [15:0]Ain;

  always@(*)begin
     case(asel)
       1'b0 : Ain=Aout;
       1'b1 : Ain=16'b0000000000000000;
     endcase
  end
endmodule

module bmux(bsel, shiftedB, sximm5, Bin);
  input [15:0] shiftedB, sximm5;
  input bsel;
  output [15:0] Bin;
  reg [15:0]Bin;

  always@(*)begin
     case(bsel)
       1'b0 : Bin=shiftedB;
       1'b1 : Bin=sximm5;
     endcase
  end
endmodule



module instruction_dec(IR, nsel, opcode, op, cond, ALUop, readnum, writenum, shift, sximm8, sximm5);
  input [15:0] IR;
  output [2:0] opcode, cond, readnum, writenum;
  output [1:0] ALUop, op, shift, nsel;
  output [15:0] sximm8, sximm5;
  wire [2:0] Rn, Rd, Rm;
  reg [15:0] sximm8, sximm5;
  reg [2:0] readnum, writenum;

  assign opcode=IR[15:13];
  assign op=IR[12:11];
  assign ALUop=IR[12:11];
  assign shift=IR[4:3];
  assign cond=IR[10:8];
  assign {Rn,Rd,Rm}={IR[10:8],IR[7:5],IR[2:0]};

  always @(*)begin
    case (IR[7])
      1'b0 : sximm8={8'b0,IR[7:0]};
      1'b1 : sximm8={8'b1,IR[7:0]};
    endcase
  end
  always @(*)begin
    case(IR[4])
      1'b0 : sximm5={11'b0,IR[4:0]};
      1'b1 : sximm5={11'b1,IR[4:0]};
    endcase
  end
  always @(*)begin
    case(nsel)
      2'b00 : {readnum,writenum}={IR[2:0],IR[2:0]};  //Rm
      2'b01 : {readnum,writenum}={IR[7:5],IR[7:5]};  //Rd
      2'b10 : {readnum,writenum}={IR[10:8],IR[10:8]};  //Rn
      default: {readnum,writenum}={2'bxx,2'bxx};
    endcase
  end
endmodule

module datapath_tb();
reg clk, write, loada, loadb, loadc, loads, asel, bsel;
reg [15:0] mdata,sximm5,sximm8;
reg [7:0] PC;
reg [2:0] writenum, readnum;
reg [1:0] shift, ALUop, vsel;
wire [15:0] Bout, Cout, data_out, ALUout,Aout;
wire [2:0] status;

datapath dut (clk,writenum,write,readnum,vsel,sximm5,sximm8,mdata,asel,bsel,shift,ALUop,loada,loadb,loadc,loads,status,Bout,Cout,PC,data_out,ALUout,Aout);

initial begin
    clk = 1'b0; write = 1'b1; loada = 1'b1; loadb = 1'b0; loadc = 1'b0; loads = 1'b0; asel = 1'b0; bsel = 1'b0; mdata = 16'b0000000000100000; sximm5 = {16{1'b0}}; sximm8 = {16{1'b0}};
    PC = {8{1'b0}}; writenum = 3'b000; readnum = 3'b000; shift = 2'b00; ALUop = 2'b00; vsel = 2'b11;
        #100
    clk=1'b1;
    #100
    clk = 1'b0; write = 1'b0; loada = 1'b1; mdata = {16{1'b0}}; vsel=2'b00;
    #100
    clk=1'b1;                 loada = 1'b0;
    #100
    clk = 1'b0; write = 1'b1; loada = 1'b0; sximm8 = 16'b0010111111100000;
    writenum = 3'b001; readnum = 3'b001; vsel = 2'b10; loadb = 1'b1;
    #100
    clk=1'b1;
    #100
    clk = 1'b0; write = 1'b0; loadb = 1'b1; sximm8 = {16{1'b0}}; vsel = 2'b00; loadc = 1'b1;
    #100
    clk = 1'b1;                loadb = 1'b0;
    #100
    clk = 1'b0; ALUop = 2'b00; loadb = 1'b0; loadc = 1'b1;
    #100
    clk = 1'b1;
    #100
    clk = 1'b0; write = 1'b0; writenum = 3'b010; loadc = 1'b1; ALUop = 2'b00;
    #100
    clk = 1'b1;
    #100
    clk = 1'b0; loadc=1'b0;
    #100;

    $display("All tests work!");
end
endmodule

