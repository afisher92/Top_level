module HiFQueues (
	input [10:0]	addrs,
	input 			clk, rst_n,
	input [15:0] 	new_smpl,
	input 			wrt_smpl,
	output [15:0] 	smpl_out,
	output 			sequencing,
	output [15:0]	read_ptr
);

/* ------ Define any internal variables ------------------------------------------------------------- */
/*	Pointers designated as 'new' signify where the array is going to be written to
	Pointers designated as 'old' signify where the array is going to read from */
	
parameter SIZE = $bits(addrs);			//The bit addrs of the queue
reg [SIZE-1:0] 		new_ptr, old_ptr, next_new, next_old;
reg [SIZE-1:0]		read_ptr, next_read;

/* Define high frequency registers */
reg 				full_reg;			//High freq Q is full
reg					read; 				//FALSE until high freq Q is full for the first time
reg [SIZE-1:0]		cnt;				//Counts how many addresses have samples writen to them

/* ------ Instantiate the dual port modules -------------------------------------------------------- */
dualPort1536x16 i536Port(.clk(clk),.we(wrt_smpl),.waddr(new_ptr),.raddr(read_ptr),.wdata(new_smpl),.rdata(smpl_out));

/* ------ Always Block to Update States ------------------------------------------------------------ */
always @(posedge wrt_smpl, negedge rst_n) begin 
	if(!rst_n) begin
		// Reset Pointers
		if(SIZE > 10)
			new_ptr  <= 'h1FD;
		else
			new_ptr  <= 'h000;
		old_ptr  <= 'h000;
	end else begin
		// Set Pointers
		new_ptr	 <= next_new;
		old_ptr	 <= next_old;
	end
end

always @(posedge clk, negedge rst_n)
	if(!rst_n)
		next_read <= old_ptr;
	else if(read)
		read_ptr <= next_read;

//Update Sequencing
assign sequencing = read;

/* ------ Control for read/write pointers and empty/full registers -------------------------------- */
// Mimic LowFQueue end_ptr
always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		read <= 1'b0;
	else if(old_ptr == 0 && new_ptr == addrs)
		read <= 1'b1;
end

assign full_reg	= (!rst_n) ? 1'b0 : (cnt == addrs);

/* ------ Manage pointers in high frequency queue ------------------------------------------------- */
always @(posedge clk, negedge rst_n)
	if(!rst_n) begin
		if(SIZE > 10)
			new_ptr  <= 'h1FD;
		else
			new_ptr  <= 'h000;
	end else if(wrt_smpl & next_new == addrs)
		next_new <= 'h000;
	else
		next_new <= new_ptr + 1;

always @(posedge clk, negedge rst_n) begin
	if(!rst_n)
		next_old <= 'h000;
	else if(old_ptr == addrs)
		next_old <= 'h000;
	else if (read)
		next_old <= old_ptr + 1;
end

always @(posedge clk, negedge rst_n) begin
	if (!rst_n)
		next_read <= 'h000;
	else if(read_ptr == addrs)
		next_read <= 'h000;
	else if (read & read_ptr != new_ptr - 1)
		next_read <= read_ptr + 1;
	else
		next_read <= old_ptr;
end


/* ------ Manage Queue Counters ------------------------------------------------------------------- */
// High Frequency Q Counter
always @(posedge wrt_smpl, negedge rst_n) 
	if (!rst_n)
		cnt <= 11'h000;
	else if(cnt != addrs) begin
		cnt <= cnt + 1;
	end

endmodule
