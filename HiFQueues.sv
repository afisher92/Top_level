module HiFQueues (
	input 			clk, rst_n,
	input [15:0] 	new_smpl,
	input 			wrt_smpl,
	output [15:0] 	smpl_out,
	output 			sequencing
);

/* ------ Define any internal variables ------------------------------------------------------------- */
/*	Pointers designated as 'new' signify where the array is going to be written to
	Pointers designated as 'old' signify where the array is going to read from */
	
reg [10:0] 		new_ptr, old_ptr, next_new, next_old;
reg [10:0]		read_ptr;
wire [10:0]		next_read;

/* Define high frequency registers */
reg [10:0]		cnt;				//Counts how many addresses have samples writen to them

/* Define Output Buffer */
reg [15:0] 		data_out;

/* ------ Instantiate the dual port modules -------------------------------------------------------- */
dualPort1536x16 i536Port(.clk(clk),.we(wrt_smpl),.waddr(new_ptr),.raddr(read_ptr),.wdata(new_smpl),.rdata(data_out));

/* ------ Always Block to Update States ------------------------------------------------------------ */
always @(posedge wrt_smpl, negedge rst_n) begin 
	if(!rst_n) begin
		// Reset Pointers
		new_ptr  <= 11'h1FD;
		old_ptr  <= 11'h000;
	end else begin
		// Set Pointers
		new_ptr	 <= next_new;
		old_ptr	 <= next_old;
	end
end

always @(posedge clk, negedge rst_n)
	if(!rst_n)
		read_ptr <= 11'h1FD;
	else if(sequencing)
		read_ptr <= next_read;

//Update Sequencing
assign sequencing = (cnt == 1531);
assign smpl_out   = (sequencing) ? data_out : 16'h0000;

/* ------ Manage pointers in high frequency queue ------------------------------------------------- */
always @(posedge clk, negedge rst_n)
	if(!rst_n)
		next_new <= 11'h1FE;
	else if(wrt_smpl & next_new == 1535)
		next_new <= 11'h000;
	else
		next_new <= new_ptr + 1;

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		next_old <= 11'h000;
	else if(old_ptr == 1535)
		next_old <= 11'h000;
	else if (sequencing)
		next_old <= old_ptr + 1;
end

assign next_read = (read_ptr == 11'h5FF) ? 11'h000 : read_ptr + 1;

/* ------ Manage Queue Counters ------------------------------------------------------------------- */
// High Frequency Q Counter
always @(posedge wrt_smpl, negedge rst_n) 
	if (!rst_n)
		cnt <= 11'h000;
	else if(cnt != 1531) begin
		cnt <= cnt + 1;
	end
	

endmodule
