`timescale 1ns/1ps

module tb(); 

logic clk;
logic rst_n;
logic en;
logic [2:0] ctrl;
logic [7:0] a1_in;
logic [7:0] a2_in;
logic [7:0] b1_in;
logic [7:0] b2_in;
logic [7:0] c1_out;
logic [7:0] c2_out;
logic [7:0] c3_out;
logic [7:0] c4_out;
logic done;

integer write_file;
integer read_file_a;
integer read_file_b;


MAT_MULT dut (
    .CLK(clk),
    .RSTN(rst_n),
    .EN(en),
    .ctrl(ctrl),
    .a1_in(a1_in),
    .a2_in(a2_in),
    .b1_in(b1_in),
    .b2_in(b2_in),
    .done(done),
    .c1_out(c1_out),
    .c2_out(c2_out),
    .c3_out(c3_out),
    .c4_out(c4_out)
);

// clock gen 
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
end 

initial begin 
    // start from reset 
    rst_n = 0;
    en = 0;
    ctrl = 3'b000; // idle state
    a1_in = 8'h00;
    a2_in = 8'h00;
    b1_in = 8'h00;
    b2_in = 8'h00;    
    #20; 

    // enable
    write_file = $fopen("output.txt", "w");
    read_file_a = $fopen("a.txt", "r");
    read_file_b = $fopen("b.txt", "r");
    rst_n = 1;
    en = 1;
    #20; 

    ctrl = 3'b001; // load state
    while (!$feof(read_file_a) && !$feof(read_file_b)) begin 
        @(negedge clk);
        $fscanf(read_file_a, "%h \n", a1_in);
        $fscanf(read_file_a, "%h \n", a2_in);
        $fscanf(read_file_b, "%h \n", b1_in);
        $fscanf(read_file_b, "%h \n", b2_in);
end 
    // reached end of input 
    a1_in = 8'h00;
    a2_in = 8'h00;
    b1_in = 8'h00;
    b2_in = 8'h00;
    #20;

    // start compute 
    ctrl = 3'b010; // calculate state
    #20;

    // wait for done then readout
    wait (done == 1);
    #20;
    ctrl = 3'b100; // output state


    #1000; // wait to make sure all outputs written
    $fclose(write_file);
    $fclose(read_file_a);
    $fclose(read_file_b);
    $finish;    

end 

always @(posedge clk) begin
    #1; 
    // write output to file
    if (ctrl == 3'b100) begin
        $fwrite(write_file, "%h\n", c1_out);
        $fwrite(write_file, "%h\n", c2_out);
        $fwrite(write_file, "%h\n", c3_out);    
        $fwrite(write_file, "%h\n", c4_out);
    end 
end 

initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb);
end

endmodule

