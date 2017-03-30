module ALU (Ain, Bin, ALUop, ALUout, status);
  parameter n=16;
  input  [n-1:0] Ain,Bin;
  input  [1:0]  ALUop;
  output [n-1:0] ALUout;
  output [2:0] status;
  reg [n-1:0] ALUout;

  always @(*) begin
    case(ALUop)
      2'b00 : {ALUout}={Ain+Bin};
      2'b01 : {ALUout}={Ain-Bin};
      2'b10 : {ALUout}={Ain & Bin};
      2'b11 : {ALUout}={~Bin};
    endcase
  end

  assign status[0] = ALUout[15];  //negative flag [N]
  assign status[1] = ALUout ? 0 : 1; //zero flag  [Z]
  assign status[2] = Ain ^ Bin;  //overflow flag [V]
endmodule


module ALU_tb();
  reg  [15:0] ain,bin;
  reg  [1:0]  ALUop;
  wire [15:0] loadc;

  ALU dut(ain,bin,ALUop,loadc);

  initial begin
    ain=16'b1000100010001001;
    bin=16'b0010001000100001;
    ALUop=2'b00;
    #100

    ain=16'b0000100001001110;
    bin=16'b0000100001000111;
    ALUop=2'b01;
    #100

    ain=16'b0111010010110011;
    bin=16'b0111010100101100;
    ALUop=2'b10;
    #100

    ain=16'b0100001010001010;
    bin=16'b0100010001101100;
    ALUop=2'b11;
    #100

    ain=16'b0100001010001010;
    bin=16'b0000000000000000;
    ALUop=2'b10;
    #100

    ain=16'b0010010010010010;
    bin=16'b0010010010010010;
    ALUop=2'b01;
    #100;
  end
endmodule
