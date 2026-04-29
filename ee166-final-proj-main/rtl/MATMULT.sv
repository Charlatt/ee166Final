`include "RTL.svh"
module MATMULT (
    input
      logic [2:0] ctrl,
      logic signed [7:0] a1_in, a2_in, b1_in, b2_in,
      logic CLK, EN, RSTN,
    output 
      logic signed [7:0] c1_out, c2_out, c3_out, c4_out,
      logic done
);

    logic unsigned [6:0] a_idx_r, b_idx_r;
    logic unsigned [6:0] a_idx_c, b_idx_c;
    logic unsigned [5:0] c_idx, c_idx_rst;
    logic unsigned [4:0] skip_ctr;

    logic signed [7:0] a_mat [7:0][14:0];
    logic signed [7:0] b_mat [14:0][7:0];
    logic signed [7:0] c_mat [63:0];

    logic signed [7:0] rows [8:0][8:0];
    logic signed [7:0] cols [8:0][8:0];
    logic signed [7:0] last;
    
    logic signed [4:0] a_load_idx, b_load_idx;

    genvar i,j,k;


    // status = 000 => idle
    // status = 001 => load
    // status = 010 => calculate
    // status = 100 => output

    // Load in A, B matrices
    // Clear C matrix
    always_ff @(posedge CLK, negedge RSTN) begin
        if (!RSTN) begin
            a_idx_r <= '0;
            a_idx_c <= 7;
            a_idx_r <= 7;
            a_idx_c <= '0;
            c_idx_rst <= '0;
            skip_ctr <= '0;
        end else begin
          if (ctrl[0]) begin
              // We skip 6 places every 8 inputs
              c_mat[c_idx_rst++] <= '0;
              a_mat[a_idx_r][a_idx_c] <= a1_in;
              a_mat[a_idx_r][a_idx_c + 1] <= a1_in;
              b_mat[b_idx_r][b_idx_c] <= b1_in;
              b_mat[b_idx_r + 1][b_idx_c] <= b2_in;
              skip_ctr <= skip_ctr + 2; 
              if (skip_ctr == 8) begin
                  skip_ctr <= '0;
                  a_idx_r <= a_idx_r + 1;
                  a_idx_c <= 7 - a_idx_r;
                  b_idx_c <= b_idx_c + 1;
                  b_idx_r <= 7 - b_idx_c;
              end else begin
                a_idx_c <= a_idx_c + 2;
                b_idx_r <= b_idx_r + 2;
              end
            end
        end
    end

    // Calculate C matrix
    generate
        for (i = 0; i < 8; i = i + 1) begin: gen_out
            `FF(a_mat[i][a_load_idx], rows[i][0], CLK, ctrl[1], RSTN, '0)
            `FF(b_mat[b_load_idx][i], cols[0][i], CLK, ctrl[1], RSTN, '0)
            for (j = 0; j < 8; j = j + 1) begin: gen_inn
                systolic_unit u_sysu(
                        .a_prev(rows[i][j]),
                        .b_prev(cols[i][j]),
                        .c_prev(c_mat[i*8+j]),
                        .CLK(CLK),
                        .enable(ctrl[1]),
                        .RSTN(RSTN),
                        .a_next(rows[i][j+1]),
                        .b_next(cols[i+1][j]),
                        .c_next(c_mat[i*8+j])
                    );  
            end
        end
    endgenerate
    `FF(a_load_idx - 1, a_load_idx, CLK, ctrl[1], RSTN, 14)
    `FF(b_load_idx - 1, b_load_idx, CLK, ctrl[1], RSTN, 14)
    `FF(rows[7][7], last, CLK, ctrl[1], RSTN, '0)
    always_comb done = (last != rows[7][7]);

    // Output C matrix
    always_ff @(posedge CLK, negedge RSTN) begin
        if (!RSTN) begin
            c_idx <= '0;
        end else begin
          if (ctrl[2] && done) begin
                c1_out <= c_mat[c_idx];
                c2_out <= c_mat[c_idx+1];
                c3_out <= c_mat[c_idx+2];
                c4_out <= c_mat[c_idx+3];
                c_idx <= c_idx + 4;
            end
        end
    end



endmodule

module systolic_unit(
    input logic signed [7:0] a_prev, b_prev, c_prev,
        logic CLK, enable, RSTN,
    output logic signed [7:0] a_next, b_next, c_next
);
    `FF(c_prev + a_prev * b_prev, c_next, CLK, enable, RSTN, '0)
    `FF(a_prev, a_next, CLK, enable, RSTN, '0)
    `FF(b_prev, b_next, CLK, enable, RSTN, '0)
endmodule

