module ALU (ain, bin, ALUop, loadc, statusout);
  input  [15:0] ain,bin;
  input  [1:0]  ALUop;
  output [15:0] loadc;
  output statusout;
  reg [15:0] loadc;

  always @(*) begin
    case(ALUop)
      2'b00 : {loadc}={ain+bin};
      2'b01 : {loadc}={ain-bin};
      2'b10 : {loadc}={ain & bin};
      2'b11 : {loadc}={~bin};
    endcase
  end
  assign statusout = {~loadc[15]& ~loadc[14]& ~loadc[13]& ~loadc[12]& ~loadc[11]&
                      ~loadc[10]& ~loadc[9]& ~loadc[8]& ~loadc[7]& ~loadc[6]& ~loadc[5]&
                      ~loadc[4]& ~loadc[3]& ~loadc[2]& ~loadc[1]& ~loadc[0]};
endmodule


module ALU_tb();
  reg  [15:0] ain,bin;
  reg  [1:0]  ALUop;
  wire [15:0] loadc;
  wire statusout;

  ALU dut(ain,bin,ALUop,loadc,statusout);

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
