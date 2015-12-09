module Equalizer_tb();
  ////////////////////////////
  // Shell of a test bench //
  //////////////////////////

  reg clk,RST_n;
  
  wire [15:0] aout_lft,aout_rht;
  
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
  
  end
  
  always
    #10 clk = ~clk;

endmodule