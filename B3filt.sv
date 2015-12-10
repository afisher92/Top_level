module B3filt(rght_in, lft_in, sequencing, rst_n, rght_out, lft_out, clk);

input rst_n, clk, sequencing;
input [15:0] rght_in, lft_in;

output wire [15:0]rght_out, lft_out;

reg[15:0]dout;
reg[31:0]laccum, raccum, lmult, rmult;
reg[9:0]addr;
reg FF_seq, pos_seq;

//Instantiates the ROM
ROM_LP B3(.dout(dout), .clk(clk), .addr(addr));

/*Implements coefficient multiplication
always_ff @(posedge clk, negedge rst_n)
 if(!rst_n) begin
  rmult <= 32'h00000000;
  lmult <= 32'h00000000;
 end else begin
  rmult <= dout * rght_in;
  lmult <= dout * lft_in;
 end */

//Implements addr
always_ff @(posedge clk, negedge rst_n)
 if(!rst_n)
  addr <= 10'h000;
 else if(!sequencing)
	    addr <= 10'h000;
	   else
	    addr <= addr + 1;

//Sequencing posedge detect
always @(posedge clk, negedge rst_n)
 if(!rst_n)
  FF_seq <= 1'b0;
 else
  FF_seq <= sequencing;

assign pos_seq = ~FF_seq && sequencing;

//Implements the accum
always_ff @(posedge clk, negedge rst_n)
if(!rst_n) begin
	    raccum <= 32'h00000000;
	    laccum <= 32'h00000000;
end else if(pos_seq) begin
	    raccum <= 32'h00000000;
	    laccum <= 32'h00000000;
	  end else begin
	    raccum <= raccum + (dout * rght_in);
	    laccum <= laccum + (dout * lft_in);
	  end
assign rght_out = (addr == 1022) ? raccum[30:15] : 16'h0000;
assign lft_out = (addr == 1022) ? laccum[30:15] : 16'h0000;

endmodule
