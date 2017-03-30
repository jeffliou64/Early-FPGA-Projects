module Program_counter(clk, reset, sximm8, incp, execb, status, cond, msel, Bout, Cout, mwrite, loadir, PC, mdata, IR);
  input clk, reset, incp, execb, msel, loadir, mwrite;
  input [2:0] status, cond;
  input [15:0] sximm8, Bout, Cout;
  output [15:0] IR, mdata;
  output [7:0] PC;
  wire [7:0] pc1, loadpc, reset_out, address, pctgt, pc_next, loadpc_out;
  wire [15:0] mdata,IR;
  reg taken;

  always @(*) begin
    casex({execb, status, cond})
      {1'b1, 3'bxxx, 3'b000} : {taken} = {1'b1};
      {1'b1, 3'bx1x, 3'b001} : {taken} = {1'b1};
      {1'b1, 3'bx0x, 3'b010} : {taken} = {1'b1};
      {1'b1, 3'b1x0, 3'b011} : {taken} = {1'b1};
      {1'b1, 3'b0x1, 3'b011} : {taken} = {1'b1};
      {1'b1, 3'b0x1, 3'b100} : {taken} = {1'b1};
      {1'b1, 3'b1x0, 3'b100} : {taken} = {1'b1};
      {1'b1, 3'bx1x, 3'b100} : {taken} = {1'b1};
      default : {taken} = {1'b0};
    endcase
  end
  assign pctgt = sximm8[7:0] + PC;
  assign loadpc = taken | incp;
  assign pc_next = incp ? (PC + 1) : pctgt;

  assign loadpc_out = loadpc ? pc_next : PC;
  assign reset_out = ~reset ? (loadpc_out) : 8'b00000000;
  vDFFE #(8) PCx (clk, 1'b1, reset_out, PC);
  assign address = msel ? (Cout[7:0]) : PC;

  RAM #(16,8) ramx (clk, address, address, mwrite, Bout, mdata);
  vDFFE #(16) IRx (clk, loadir, mdata, IR);
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
  reg clk, reset, incp, execb, msel, loadir, mwrite;
  reg [2:0] status, cond;
  reg [15:0] sximm8, Bout, Cout;
  wire [15:0] IR, mdata;
  wire [7:0] PC;

  Program_counter dut(clk, reset, sximm8, incp, execb, status, cond, msel, Bout, Cout, mwrite, loadir, PC, mdata, IR);

  initial begin
    clk=1'b0; reset=1'b1; incp=1'b0; execb=1'b1; loadir=1'b1; mwrite=1'b0; status=3'b111; cond=3'b000; msel=1'b0;
    sximm8=16'b1110001110001110; Bout=16'b0000111100001111; Cout=16'b1100110011001100;
    #10
    clk=1'b1;
    #10
    clk=1'b0; reset=1'b0;
    #10

    clk=1'b1;
    #10
    clk=1'b0;
    #10

    clk=1'b1;
    #10
    clk=1'b0;
    #10

    clk=1'b1; status=3'b111; cond=3'b001;
    #10
    clk=1'b0;
    #10

    clk=1'b1;
    #10
    clk=1'b0;
    #10

    clk=1'b1; status=3'b101; cond=3'b010;
    #10
    clk=1'b0;
    #10

    clk=1'b1; reset=1'b1;
    #10
    clk=1'b0;
    #10

    clk=1'b1; status=3'b110; cond=3'b011;
    #10
    clk=1'b0; reset=1'b0;
    #10;

    clk=1'b1;
    #10
    clk=1'b0;
    #10;

    clk=1'b1; status=3'b001; cond=3'b100;
    #10
    clk=1'b0;
    #10;

    clk=1'b1;
    #10
    clk=1'b0;
    #10;

    clk=1'b1;  status=3'b111; cond=3'b100;
    #10
    clk=1'b0;
    #10;

  end
endmodule
