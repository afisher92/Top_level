module slide_intf(clk, cnv_cmplt, rst_n, chnnl, strt_cnv, POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME);

input clk, rst_n, cnv_cmplt;

output reg [2:0]chnnl;
output reg strt_cnv;
output reg [11:0]POT_LP, POT_B1, POT_B2, POT_B3, POT_HP, VOLUME;

reg [2:0]cnt;
reg state, nxtstate;
reg [2:0] nxtcnt = 3'b0;

localparam IDLE = 1'b0;
localparam CNV = 1'b1;

//Instantiate A2D_intf
A2D_intf A2D(.clk(clk), .rst_n(rst_n), .chnnl(chnnl), .strt_cnv(strt_cnv), .MISO(MISO), .cnv_cmplt(cnv_cmplt), .res(res), .a2d_SS_n(a2d_SS_n), .SCLK(SCLK), .MOSI(MOSI));

//Potentiometer outputs
always @(posedge clk) begin
 if(cnt==3'b000)
  POT_LP <= res;
 else
  POT_LP <= POT_LP;
end

always @(posedge clk) begin
 if(cnt==3'b001)
  POT_B1 <= res;
 else
  POT_B1 <= POT_B1;
end

always @(posedge clk) begin
 if(cnt==3'b010)
  POT_B2 <= res;
 else
  POT_B2 <= POT_B2;
end

always @(posedge clk) begin
 if(cnt==3'b011)
  POT_B3 <= res;
 else
  POT_B3 <= POT_B3;
end

always @(posedge clk) begin
 if(cnt==3'b100)
  POT_HP <= res;
 else
  POT_HP <= POT_HP;
end

always @(posedge clk) begin
 if(cnt==3'b111)
  VOLUME <= res;
 else
  VOLUME <= VOLUME;
end

//Next state logic
always_ff @(posedge clk, negedge rst_n)
 if(!rst_n)
  state <= IDLE;
 else
  state <= nxtstate;

//Implement cnt
always_ff @(posedge clk, negedge rst_n)
 if(!rst_n)
  cnt <= 3'b000;
 else if(cnt == 111)
  cnt <= 3'b000;  //resets cnt when cnt = 111
 else
  cnt <= nxtcnt; //nxtcnt assigned in state machine for next chnnl

//Implement state machine
always @(*) begin
chnnl = cnt;
nxtstate = IDLE;
case(state)
 IDLE:  begin
 if(!rst_n)begin
  nxtcnt <= 3'b000;
 end
strt_cnv = 1'b1;
nxtstate = CNV;
chnnl = cnt;
end

 CNV: if(!cnv_cmplt) begin
nxtstate = CNV;
strt_cnv = 1'b0;
end else begin
 if(!rst_n)begin
  nxtcnt <= 3'b000;
 end
strt_cnv = 1'b0;
nxtstate = IDLE;
chnnl = cnt;
if(cnt == 3'b101)
 nxtcnt = 3'b111;
else
 nxtcnt = cnt + 1;
end
endcase
end
endmodule
