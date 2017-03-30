module datapath(datapath_in, writenum, write, readnum, clk,vsel, selecta, selectb, shift, ALUop, loooada, loooadb, loooadc, loooadd, datapath_out);
  input [15:0] datapath_in;
  input vsel, write,clk, selecta, selectb;
  input [2:0] writenum, readnum;
  input [1:0] ALUop, shift;
  input loooada,loooadb,loooadc,loooadd;
  output [15:0] datapath_out;
  wire [15:0] data_out, loada, loadb, newloadb, Ain, Bin, loadc;
  wire status10;
  reg [15:0]data_in;

  always @(*)begin
    case(vsel)
      1'b0 : data_in = datapath_out;
      1'b1 : data_in = datapath_in;
     endcase
  end

  register_file registerE(writenum, write, data_in, clk, readnum, data_out);
  vDFFE loadax(clk, loooada, data_out, loada);
  vDFFE loadbx(clk, loooadb, data_out, loadb);
  shifter shiftx(loadb, shift, newloadb);
  asel aselx(loada, selecta, Ain);
  bsel bselx(newloadb, selectb, datapath_in, Bin);

  ALU ALUx(Ain, Bin, ALUop, loadc, statusout);
  vDFFE loadcx(clk, loooadc, loadc, datapath_out);
  vDFFE loadsx(clk, loooadd, statusout, status10);
endmodule

module asel(loada, selecta, Ain);
  input selecta;
  input [15:0] loada;
  output [15:0] Ain;
  reg [15:0]Ain;

  always@(*)begin
     case(selecta)
       1'b0 : Ain=loada;
       1'b1 : Ain=16'b0000000000000000;
     endcase
  end
endmodule

module bsel(newloadb, selectb, datapath_in, Bin);
  input [15:0] datapath_in, newloadb;
  input selectb;
  output [15:0] Bin;
  reg [15:0]Bin;

  always@(*)begin
     case(selectb)
       1'b0 : Bin=newloadb;
       1'b1 : {Bin}={11'b00000000000, datapath_in[4:0]};
     endcase
  end
endmodule

module datapath_tb();
  reg [15:0] datapath_in;
  reg vsel, write, clk,selecta, selectb;
  reg [2:0] writenum, readnum;
  reg [1:0] ALUop, shift;
  reg loooada,loooadb,loooadc,loooadd;
  wire [15:0] datapath_out;

  datapath dut(datapath_in, writenum, write, readnum, clk,vsel, selecta, selectb, shift, ALUop, loooada, loooadb, loooadc, loooadd, datapath_out);

  initial begin
  /*1*/ datapath_in=16'b0000000000000111 ; writenum=3'b000; write=1'b1; readnum =3'b000; clk =1'b1 ; vsel =1'b1; selecta= 1'b0; selectb=1'b0; shift=2'b00; ALUop=2'b00; loooada=1'b1;loooadb=1'b1;loooadc=1'b0;loooadd=1'b1;
    #100                           //7  through registerE R0
        datapath_in=16'b0000000000000111 ; writenum=3'b000; write=1'b1; readnum =3'b000; clk =1'b0 ;
    #10
 /*2*/  datapath_in=16'b0000000000000010 ; writenum=3'b001; write=1'b1; readnum =3'b001; clk =1'b1 ;                                                                    loooada=1'b0;loooadb=1'b1;loooadc=1'b0;loooadd=1'b1;
    #100                           //2 through registerE R1, 7 through LoadB
        datapath_in=16'b0000000000000010 ; writenum=3'b001; write=1'b1; readnum =3'b001; clk =1'b0 ;
    #10
 /*3*/  datapath_in=16'b0000000000000010 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b1 ;                                                                    loooada=1'b1;loooadb=1'b0;loooadc=1'b0;loooadd=1'b1;
    #100                          //2 through LoadA
        datapath_in=16'b0000000000000010 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b0 ;
    #10
 /*4*/  datapath_in=16'b0000000001010101 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b1 ;                                                                    loooada=1'b1;loooadb=1'b0;loooadc=1'b0;loooadd=1'b1;
    #100
        datapath_in=16'b0000000000000010 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b0 ;
    #10
 /*5*/  datapath_in=16'b1111111111111111 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b1 ;                                                                    loooada=1'b1;loooadb=1'b1;loooadc=1'b1;loooadd=1'b1;
    #100
        datapath_in=16'b0000000000000000 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b0 ;
    #10;
 /*6*/  datapath_in=16'b0000000000000000 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b1 ;                                                                    loooada=1'b1;loooadb=1'b1;loooadc=1'b1;loooadd=1'b1;
    #100
        datapath_in=16'b0000000000000000 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b0 ;
    #10;
 /*7*/  datapath_in=16'b0011001100110011 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b1 ;                                                                    loooada=1'b1;loooadb=1'b1;loooadc=1'b1;loooadd=1'b1;
    #100
        datapath_in=16'b0011001100110011 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b0 ;
    #10;
 /*8*/  datapath_in=16'b0011001100110011 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b1 ;                                                                    loooada=1'b1;loooadb=1'b1;loooadc=1'b1;loooadd=1'b1;
    #100
        datapath_in=16'b0011001100110011 ; writenum=3'b010; write=1'b1; readnum =3'b000; clk =1'b0 ;
    #10;
  end
endmodule
