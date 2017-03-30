//main register file
module register_file (writenum, write, data_in, clk, readnum, data_out);
  input [2:0] writenum, readnum; //binary
  input write, clk;
  input [15:0] data_in;
  output [15:0] data_out;
  wire [7:0] hot_code_out;
  reg [15:0] R0,R1,R2,R3,R4,R5,R6,R7;
  wire [15:0] a0,a1,a2,a3,a4,a5,a6,a7;

  Dec #(3,8) dec_write(writenum, hot_code_out);
  assign a0=R0;
  assign a1=R1;
  assign a2=R2;
  assign a3=R3;
  assign a4=R4;
  assign a5=R5;
  assign a6=R6;
  assign a7=R7;
  vDFFE #(16) R0_next(clk,write,data_in,a0);
  vDFFE #(16) R1_next(clk,write,data_in,a1);
  vDFFE #(16) R2_next(clk,write,data_in,a2);
  vDFFE #(16) R3_next(clk,write,data_in,a3);
  vDFFE #(16) R4_next(clk,write,data_in,a4);
  vDFFE #(16) R5_next(clk,write,data_in,a5);
  vDFFE #(16) R6_next(clk,write,data_in,a6);
  vDFFE #(16) R7_next(clk,write,data_in,a7);

  always@(*)begin
    case(hot_code_out)
    8'b00000001 : {R0}={data_in};
    8'b00000010 : {R1}={data_in};
    8'b00000100 : {R2}={data_in};
    8'b00001000 : {R3}={data_in};
    8'b00010000 : {R4}={data_in};
    8'b00100000 : {R5}={data_in};
    8'b01000000 : {R6}={data_in};
    8'b10000000 : {R7}={data_in};
    default {R0,R1,R2,R3,R4,R5,R6,R7}={128'b0};
    endcase
  end
  Mux_DEC mux_readx(R7,R6,R5,R4,R3,R2,R1,R0,readnum,data_out);
endmodule

//decoder
module Dec(a, b);
  parameter n=3;
  parameter m=8;

  input[n-1:0] a;
  output[m-1:0] b;
  wire [m-1:0] b = 1<<a;
endmodule

//individual register with load enable
module vDFFE (clk, write, in, out) ;
  parameter n = 16;  // width
  input clk, write ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out;

  assign next_out = write ? in : out;
  always @(posedge clk)
    out = next_out;
endmodule

//multiplexer + 38decoder
module Mux_DEC (a7,a6,a5,a4,a3,a2,a1,a0,readnum,data_out);
  parameter j=8;
  parameter k=16;
  input [k-1:0] a7,a6,a5,a4,a3,a2,a1,a0;
  input [2:0] readnum; //binary
  output [k-1:0] data_out;
  reg [k-1:0] data_out;
  wire [j-1:0] s;

  Dec #(3,8) dec_read(readnum,s);
  always@(*)begin
    case(s)
      8'b00000001 : data_out=a0;
      8'b00000010 : data_out=a1;
      8'b00000100 : data_out=a2;
      8'b00001000 : data_out=a3;
      8'b00010000 : data_out=a4;
      8'b00100000 : data_out=a5;
      8'b01000000 : data_out=a6;
      8'b10000000 : data_out=a7;
      //default: {data_out=16'b0};
    endcase
  end
endmodule

module vDFFE_tb();
  parameter n = 16;
  reg clk, write ;
  reg  [n-1:0] in ;
  wire [n-1:0] out ;

  vDFFE dut(clk, write, in, out);
  initial begin
    clk=1'b1; write=1'b1;in=16'b0001110001110001;
    #100
    clk=1'b0; write=1'b0;in=16'b0001110001110001;
    #100
    clk=1'b1; write=1'b0;in=16'b0001110001110001;
    #100
    clk=1'b0; write=1'b1;in=16'b0001110001110001;
    #100
    clk=1'b1; write=1'b1;in=16'b0100011100101010;
    #100
    clk=1'b0; write=1'b1;in=16'b0100011100101010;
    #100
    clk=1'b1; write=1'b1;in=16'b0001110001110001;
    #100
    clk=1'b0; write=1'b1;in=16'b0001110001110001;
    #100;
  end
endmodule

module regfile_tb();
  reg [2:0] writenum, readnum;
  reg write, clk;
  reg [15:0] data_in;
  wire [15:0] data_out;

  register_file dut(writenum, write, data_in, clk, readnum, data_out);

  initial begin
     writenum=3'b010; write=1'b1; data_in=16'b1111000000000000; clk=1'b1; readnum=3'b010;
     #100
     writenum=3'b010; write=1'b1; data_in=16'b0000111100000000; clk=1'b1; readnum=3'b010;
     #100
     writenum=3'b100; write=1'b1; data_in=16'b0000000011110000; clk=1'b1; readnum=3'b100;
     #100
     writenum=3'b001; write=1'b1; data_in=16'b0000000000001111; clk=1'b1; readnum=3'b001;
     #100
     writenum=3'b110; write=1'b1; data_in=16'b0000000011111111; clk=1'b1; readnum=3'b111;
     #100
     writenum=3'b000; write=1'b1; data_in=16'b0000111111111111; clk=1'b1; readnum=3'b000;
     #100
     writenum=3'b110; write=1'b1; data_in=16'b1111111111111111; clk=1'b1; readnum=3'b000;
     #100
     writenum=3'b001; write=1'b1; data_in=16'b0000111111111111; clk=1'b1; readnum=3'b001;
     #100
     writenum=3'b011; write=1'b1; data_in=16'b0000000011111111; clk=1'b1; readnum=3'b011;
     #100;
     writenum=3'b110; write=1'b1; data_in=16'b0000000000001111; clk=1'b1; readnum=3'b110;
     #100
     writenum=3'b100; write=1'b1; data_in=16'b0000000000000000; clk=1'b1; readnum=3'b100;
     #100;
  end
endmodule



