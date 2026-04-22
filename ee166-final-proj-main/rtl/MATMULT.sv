`include "RTL.svh"
module MATMULT (
    input
      logic [2:0] ctrl,
      logic signed [7:0] a1, a2, b1, b2,
      logic CLK, EN, RSTN,
    output 
      logic signed [7:0] c1, c2, c3, c4,
      logic done
);

    logic unsigned [5:0] a_idx, b_idx, c_idx;

    logic signed [7:0] a_mat [63:0];
    logic signed [7:0] b_mat [63:0];
    logic signed [7:0] c_mat [63:0];

    genvar i,j,k;


    // status = 000 => idle
    // status = 001 => load
    // status = 010 => calculate
    // status = 100 => output

    // Load in A, B matrices
    // Clear C matrix
    always_ff @(posedge CLK, negedge RSTN) begin
        if (!RSTN) begin
            a_idx <= '0;
            b_idx <= '0;
        end else begin
          if (ctrl[0]) begin
                c_mat[a_idx] <= '0;
                c_mat[a_idx+1] <= '0;
                a_mat[a_idx] <= a1;
                a_mat[a_idx+1] <= a2;
                b_mat[b_idx] <= b1;
                b_mat[b_idx+1] <= b2;
                a_idx <= a_idx + 2;
                b_idx <= b_idx + 2;
            end
        end
    end

    // Calculate C matrix
    generate
        for (i = 0; i < 8; i = i + 1) begin: gen_calc_outer
            for (j = 0; j < 8; j = j + 1) begin: gen_calc_inner
                for (k = 0; k < 8; k = k + 1) begin: gen_calc_inner_inner
                  `FF(a_mat[i*8 + k] * b_mat[k*8 + j], c_mat[i*8 + j], CLK, ctrl[1], RSTN, '0)
                end
            end
        end
    endgenerate

    // Output C matrix
    always_ff @(posedge CLK, negedge RSTN) begin
        if (!RSTN) begin
            c_idx <= '0;
        end else begin
          if (ctrl[2]) begin
                c1 <= c_mat[c_idx];
                c2 <= c_mat[c_idx+1];
                c3 <= c_mat[c_idx+2];
                c4 <= c_mat[c_idx+3];
                c_idx <= c_idx + 4;
            end
        end
    end


    
endmodule

