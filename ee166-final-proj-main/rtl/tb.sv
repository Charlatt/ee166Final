module tb;
  logic signed [9:0] samples;
  logic signed [9:0] params [62:0];
  logic signed [9:0] out;
  logic signed [9:0] input_samples [249:0];
  logic signed [9:0] params_l;
  logic CLK, EN, RSTN, param_en;

  logic [19:0] en_seq = 20'b11010001000010100010;
  
  FIR_63TAP u_dut (.samples, .params_l, .param_en, .CLK, .EN, .RSTN, .out);
   always begin
    CLK = 1'b0; #5; CLK = 1'b1; #5;
  end
  
  int i;
  int j;
  
  initial begin
    $readmemh("../rtl/input.txt", input_samples);
  	$readmemh("../rtl/filter_params.txt", params);
    $timeformat(-9, 5, " ns", 10);
    $dumpfile("../rtl/FIR_63TAP.vcd"); 
    RSTN = 1'b0;
    EN = 1'b0;
    param_en = 1'b0;
    #5
    #5 RSTN = 1'b1;
    EN = 1'b0;
    param_en = 1'b1;
    #5
    
    for (i = 0; i < 63; i = i + 1) begin
      @(negedge CLK);
      #5
      params_l = params[i];
    end
    #5 
    param_en = 1'b0;
    EN = 1'b1;
        
    
    //for (i = 0; i < 20; i = i + 1) begin
        //EN = en_seq[i];
        for (j = 0; j < 240; j = j + 1) begin
            @(negedge CLK); 
            #5
            samples = input_samples[j];
            $display("%b", out);
            $dumpvars(0);
        end
    //end

    
    
	// #30000;
	// $display("Timeout"); // Avoids running the simulation indefinitely
	$finish;
    //$dumpvars;
  end

endmodule
