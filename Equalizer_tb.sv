module Equalizer_tb();
  ////////////////////////////
  // Shell of a test bench //
  //////////////////////////

  reg clk,RST_n;
  integer rsum,lsum, i;
  
  wire [7:0] LEDS
  wire [2:0] chnnl
  wire [15:0] aout_lft,aout_rht;
  
  output reg AMP_ON;
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  Equalizer iDUT(.clk(clk),.RST_n(RST_n),.LED(LED),.A2D_SS_n(A2D_SS_n),.A2D_MOSI(A2D_MOSI),
                 .A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),.MCLK(MCLK),.SCL(SCLK),.LRCLK(LRCLK),
				 .SDout(SDout),.SDin(SDin),.AMP_ON(AMP_ON),.RSTn(RSTn));
				 
  //////////////////////////////////////////
  // Instantiate model of CODEC (CS4271) //
  ////////////////////////////////////////
  CS4272  iModel( .MCLK(MCLK), .SCLK(SCLK), .LRCLK(LRCLK),
                .RSTn(RSTn),  .SDout(SDout), .SDin(SDin),
                .aout_lft(aout_lft), .aout_rht(aout_rht));
				
  ///////////////////////////////////////////////////////////////////////
  // Instantiate Model of A2D converter modeling slide potentiometers //
  /////////////////////////////////////////////////////////////////////
  ADC128S iA2D(.clk(clk),.rst_n(rst_n),.SS_n(A2D_SS_n),.SCLK(A2D_SCLK),
               .MISO(A2D_MISO),.MOSI(A2D_MOSI));
				
  initial begin
  file = $fopen(audio_out.csv, "w");
  clk = 0;
  i = 0;
  RST_n =1;
  lft_max = -3000;
  lft_min = 3000;
  rht_max = -3000;
  rht_min = 3000;
  rht_crossing = 0;
  lft_crossing = 0;
  lft_blanking = 0;
  rht_blanking = 0;
  lft_avg = 0;
  rht_avg = 0;
  
 //write the audio out to the file 
  always@(posedge clk)
    i = i+1;
    if (i == 8195) begin
    $fclose(file);
    if (i>2) begin
     $fdisplay ( file,"%d,%d", aout_rht, aout_lft);
    end
  end
  
 //check the max and min of the left and right channels
  always@(posedge clk) begin
    if (aout_rht > rht_max)
      rht_max = aout_rht;
    if (aout_lft > lft_max)
      lft_max = aout_lft;
    if (aout_rht < rht_min)
      rht_min = aout_rht;
    if (aout_lft < lft_max)
      lft_min = aout_lft;      
  end
  
  //get the averages of the signals
  always@(posedge clk) begin
    rsum = rsum+ aout_rht;
    lsum = lsum+ aout_lft;
    lft_avg = lsum/i;
    rht_avg = rsum/i;
  end
  
  //check for the crossings
  always@(posedge clk) begin
    if(aout_rht == 0)
     rht_crossing = rht_crossing+1;
    if(aout_lft == 0)
     lft_crossing = lft_crossing+1;  
  end
  
  always
    #10 clk = ~clk;

endmodule
