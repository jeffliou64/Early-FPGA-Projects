module shifter (loadb, shift, newloadb);
  parameter n=16;
  input [n-1:0] loadb;
  input [1:0] shift;
  output [n-1:0] newloadb;
  reg [n-1:0] newloadb;

  always @(*) begin
    case(shift)
    2'b00 : {newloadb}={loadb};
    2'b01 : {newloadb[n-1:1],newloadb[0]}={loadb[n-2:0],1'b0};
    2'b10 : {newloadb[n-2:0],newloadb[n-1]}={loadb[n-1:1],1'b0};
    2'b11 : {newloadb[n-2:0],newloadb[n-1]}={loadb[n-1:1],loadb[n-1]};
    endcase
  end
endmodule


module shifter_tb();
  reg [15:0] loadb;
  reg [1:0] shift;
  wire [15:0] newloadb;

  shifter #(16) dut(loadb,shift,newloadb);

  initial begin
  loadb=16'b0000100001000111; shift=2'b00;
  #100
  loadb=16'b1110001000100011; shift=2'b01;
  #100
  loadb=16'b1110000111011101; shift=2'b10;
  #100
  loadb=16'b1110100001000100; shift=2'b11;
  #100
  loadb=16'b0110100001000100; shift=2'b11;
  #100;
  loadb=16'b1111111111111111; shift=2'b10;
  #100;
  loadb=16'b1111111111111111; shift=2'b01;
  #100;
  loadb=16'b1110100001000101; shift=2'b11;
  #100;
  end
endmodule
