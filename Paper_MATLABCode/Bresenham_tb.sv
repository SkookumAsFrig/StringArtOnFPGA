`timescale 1ps/1ps
module Bresenham_tb;

logic clk;
logic reset;
logic req_val;
logic resp_rdy;
logic [8:0] point_1_x;
logic [8:0] point_1_y;
logic [8:0] point_2_x;
logic [8:0] point_2_y;

logic req_rdy;
logic resp_val;
logic address_val;
logic signed [18:0] reduction;

initial
begin
    clk = 0;
    reset = 0;
    #1500
    reset = 1;
end

always #500 clk = ~clk;

always_ff @( posedge clk)
begin
    if(reset == 1)
    begin
        point_1_x = 200;
        point_1_y = 100;
        point_2_x = 100;
        point_2_y = 150;
        req_val   = 1;
        resp_rdy  = 0;
    end
    else
    begin
        req_val   = 0;
        resp_rdy  = 0;
    end
end

Bresenham_Solver
solver
(
    .clk(clk),
    .reset(reset),
    .req_rdy(req_rdy),
    .req_val(req_val),
    .req_point_1_x(point_1_x),
    .req_point_1_y(point_1_y),
    .req_point_2_x(point_2_x),
    .req_point_2_y(point_2_y),
    .change(0),
    .resp_rdy(resp_rdy),
    .resp_val(resp_val),
    .reduction(reduction)
);

endmodule