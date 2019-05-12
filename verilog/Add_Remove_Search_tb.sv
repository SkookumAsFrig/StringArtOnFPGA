`timescale 1ps/1ps
module Add_or_Remove_Search_tb;

logic clk;
logic reset;
logic req_val;
logic resp_rdy;
logic resp_val;

logic [7:0] pin_1_index;
logic [7:0] pin_2_index;
logic add_or_remove;
logic done;

initial
begin
    clk = 0;
    reset = 0;
    #1500
    reset = 1;
end

always #500 clk = ~clk;

assign resp_rdy = resp_val;

always_ff @( posedge clk)
begin
    if(reset == 1)
    begin
        req_val   = 1;
    end
    else
    begin
        req_val   = 0;
    end
end


Add_Remove_Search
search
(
    .clk(clk),
    .reset(reset),
    .req_val(req_val),
    .resp_rdy(resp_rdy),
    .resp_val(resp_val),
    .pin_1_index(pin_1_index),
    .pin_2_index(pin_2_index),
    .add_or_remove(add_or_remove),
    .done(done)
);

endmodule