`include "RTL.svh"
module FIR_63TAP (
  input 
  	logic signed [9:0] samples,
  logic signed  [9:0] params_l,
  logic param_en,
  	logic CLK, EN, RSTN,
  output 
  	logic signed [9:0] out
);

  // logic signed [9:0] history [62:0];
  // logic signed [19:0] interm_prod [31:0];
  logic signed [19:0] interm_prod [62:0];
  logic signed [9:0] params [62:0];
  // logic signed [9:0] interm_add [30:0];

  always_comb out = interm_prod[62][17:8];

  genvar i;
  genvar j;

  `FF(samples * params[0], interm_prod[0], CLK, EN, RSTN, '0)                                                 

  generate
  	for (i = 0; i < 62; i = i + 1) begin: output_latches
      `FF(samples * params[i+1] + interm_prod[i], interm_prod[i+1], CLK, EN, RSTN, '0)
  	end
  endgenerate
  
    `FF(params_l, params[0], CLK, param_en, RSTN, '0);
  generate
    for (j = 0; j < 62; j = j + 1) begin: gen_pi
      always_ff @(posedge CLK, negedge RSTN) begin
        if (!RSTN) begin
          params[j+1] <= '0;
        end else if (param_en) begin
          params[j+1] <= params[j];
        end
      end
    end
  endgenerate
    
 endmodule
