module datapath(clk,writenum,write,readnum,vsel,sximm5,sximm8,mdata,asel,bsel,shift,ALUop,looada,looadb,looadc,looads,datapath_out);
  input [15:0] sximm5, sximm8, mdata;
  input write, clk, asel, bsel, looada, looadb, looadc, looads;
  input [2:0] writenum, readnum;
  input [1:0] vsel, ALUop, shift;
  output [15:0] datapath_out;
  wire [15:0] data_out, loada, loadb, newloadb, loadc, IR;
  wire [7:0] PC;
  wire [2:0] status, status_out;
  wire loadpc, msel, mwrite, loadir, reset;
  reg [15:0] data_in, Ain, Bin;

  Program_counter PCx(clk, reset, loadpc, loadb, loadc, msel, loadir, mwrite, PC, mdata, IR);
  instruction_dec Instruc_Decx(IR, nsel, opcode, op, ALUop, readnum, writenum, shift, sximm8, sximm5);
  cpu FSMx(clk, reset, opcode, op, loadpc, msel, mwrite, loadir, nsel, vsel, write, looada, looadb, looadc, looads, asel, bsel);

  always @(*)begin
    case(vsel)
      2'b11 : data_in = mdata;
      2'b10 : data_in = sximm8;
      2'b01 : data_in = {8'b0,PC};
      2'b00 : data_in = loadc;
     endcase
  end
  register_file regfilex(writenum, write, data_in, clk, readnum, data_out);
  vDFFE loadax(clk, looada, data_out, loada);
  vDFFE loadbx(clk, looadb, data_out, loadb);
  shifter shiftx(loadb, shift, newloadb);
  always@(*)begin
     case(asel)
       1'b0 : Ain=loada;
       1'b1 : Ain=16'b0000000000000000;
     endcase
  end
  always@(*)begin
     case(bsel)
       1'b0 : Bin=newloadb;
       1'b1 : Bin=sximm5;
     endcase
  end
  ALU ALUx(Ain, Bin, ALUop, loadc, status);
  vDFFE loadcx(clk, looadc, loadc, datapath_out);
  vDFFE loadsx(clk, looads, status, status_out);
endmodule

module Program_counter(clk, reset, loadpc, loadb, loadc, msel, loadir, mwrite, PC, mdata, IR);
  input clk, loadpc, reset, msel, loadir, mwrite;
  input [15:0] loadb, loadc;
  output [15:0] IR, mdata;
  output [7:0] PC;
  wire [7:0] pc1, reset_wire, address;
  wire [15:0] mdata,IR;

  assign pc1=loadpc ? (PC+1) : PC;
  assign reset_wire= ~reset ? (pc1) : 8'b00000000;
  vDFFE PCx(clk, 1'b1, reset_wire, PC);
  assign address=msel ? (loadc[7:0]) : PC;

  RAM ramx(clk, address, address, mwrite, loadb, mdata);       //not sure what the addresses are supposed to be
  vDFFE IRx(clk, loadir, mdata, IR);
endmodule

module instruction_dec(IR, nsel, opcode, op, ALUop, readnum, writenum, shift, sximm8, sximm5);
  input [15:0] IR;
  output [2:0] opcode, readnum, writenum, nsel;
  output [1:0] ALUop, op, shift;
  output [15:0] sximm8, sximm5;
  wire [2:0] Rn, Rd, Rm;
  reg [15:0] sximm8, sximm5;
  reg [2:0] readnum, writenum;

  assign opcode=IR[15:13];
  assign op=IR[12:11];
  assign ALUop=IR[12:11];
  assign shift=IR[4:3];
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
      3'b001 : {readnum,writenum}={IR[10:8],IR[10:8]}; //Rn
      3'b010 : {readnum,writenum}={IR[7:5],IR[7:5]};  //Rd
      3'b100 : {readnum,writenum}={IR[2:0],IR[2:0]};  //Rm
      default: {readnum,writenum}={3'b000,3'b000};
    endcase
  end
endmodule

module RAM(clk, read_address, write_address, write, din, dout);
  parameter data_width = 16;
  parameter addr_width = 8;
  parameter filename = "data.txt";

  input clk;
  input [addr_width-1:0] read_address, write_address;
  input write;
  input [data_width-1:0] din;
  output [data_width-1:0] dout;
  reg [data_width-1:0] dout;
  reg [data_width-1:0] mem [2**addr_width-1:0];

  initial $readmemb(filename,mem);

  always @(posedge clk) begin
    if (write)
      mem[write_address] <=din;
    dout <= mem[read_address];
  end
endmodule

module PC_tb();
  reg clk, loadpc, reset, msel, loadir, mwrite;
  reg [15:0] loadb, loadc;
  wire [15:0] IR, mdata;
  wire [7:0] PC;

  Program_counter dut(clk, reset, loadpc, loadb, loadc, msel, loadir, mwrite,PC, mdata, IR);

  initial begin
    clk=1'b0; reset=1'b1; loadb=16'b1111111111111111;loadc=16'b0000000000000000; loadpc=1'b0; loadir=1'b0; msel=1'b0; mwrite=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; reset=1'b0; loadpc=1'b0; loadir=1'b0; msel=1'b0; mwrite=1'b0;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadir=1'b1;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadir=1'b0; loadpc=1'b1;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadpc=1'b0;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadir=1'b1;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadir=1'b0; loadpc=1'b1;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadpc=1'b0;
    #10
    clk=1'b0;
    #20;

    clk=1'b1;
    #10
    clk=1'b1; loadir=1'b1;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadir=1'b0; loadpc=1'b1;
    #10
    clk=1'b0;
    #20

    clk=1'b1;
    #10
    clk=1'b1; loadpc=1'b0;
    #10
    clk=1'b0;
    #20;

    clk=1'b1;
    #10
    clk=1'b1; loadir=1'b1;
    #10
    clk=1'b0;
    #20;
  end
endmodule

/*
module datapath_tb();
  reg [15:0] datapath_in;
  reg vsel, write, clk,selecta, selectb;
  reg [2:0] writenum, readnum;
  reg [1:0] ALUop, shift;
  reg looada,looadb,looadc,looads;
  wire [15:0] datapath_out;

  datapath dut(datapath_in, writenum, write, readnum, clk,vsel, selecta, selectb, shift, ALUop, looada, looadb, looadc, looads, datapath_out);

  initial begin
        datapath_in=16'b0000000000000111 ; writenum=3'b000; write=1'b1; readnum =3'b000; clk =1'b0 ; vsel =1'b1; selecta= 1'b0; selectb=1'b0; shift=2'b00; ALUop=2'b00;looada=1'b1;looadb=1'b1;looadc=1'b1;looads=1'b1;
    #100
   datapath_in=16'b0000000000000111 ; clk =1'b1 ; looada=1'b1;looadb=1'b1;looadc=1'b1;looads=1'b1;
    #100                           //7  through registerE R0 into loadb & loada
        datapath_in=16'b0000000000000111 ; clk =1'b0 ;                              looadb=1'b0;
    #50
   datapath_in=16'b0000000000000010 ; clk =1'b1 ;                  looada=1'b1;
    #100                           //2 through registerE R0 into loada, 7 into ALU
        datapath_in=16'b0000000000000010 ; clk =1'b0 ;
    #50
   datapath_in=16'b0000000000000010 ; clk =1'b1 ;                  looada=1'b1;
    #100                          //2 into ALU, 7 in ALU
        datapath_in=16'b0000000000000010 ; clk =1'b0 ;
    #50
   writenum=3'b000; write=1'b0; clk =1'b1 ;
    #100
        clk =1'b0 ;
    #50
   clk =1'b1 ;
    #100
        clk =1'b0 ;
    #50
   clk =1'b1 ;
    #100
        clk =1'b0 ;
    #50;
   clk =1'b1 ;
    #100
        clk =1'b0 ;
    #50
   clk =1'b1 ;
    #100
        clk =1'b0 ;
    #50;
  end
endmodule
*/
