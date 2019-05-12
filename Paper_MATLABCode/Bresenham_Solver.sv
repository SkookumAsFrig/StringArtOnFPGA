module Bresenham_Solver
(
    input  logic clk,
    input  logic reset,

    output logic req_rdy,
    input  logic req_val,
    input  logic [8:0] req_point_1_x,
    input  logic [8:0] req_point_1_y,
    input  logic [8:0] req_point_2_x,
    input  logic [8:0] req_point_2_y,
    input  logic change,
    input  logic mode,

    input  logic resp_rdy,
    output logic resp_val,
    output logic signed [18:0] reduction
);

logic [8:0] point_1_x;
logic [8:0] point_1_y;
logic [8:0] point_2_x;
logic [8:0] point_2_y;
logic [8:0] point_x_interval;
logic [8:0] point_y_interval;

logic [8:0] point_draw_x;
logic [8:0] point_draw_y;
logic signed [12:0] point_x_interval_extend;
logic signed [12:0] point_y_interval_extend;
logic signed [12:0] p;

logic [1:0]  wait_count;
logic [17:0] image_address;
logic [7:0]  image_data;
logic signed [18:0] image_data_extend;

logic initial_done;
logic cal_done;

localparam signed [18:0] black = 255;


typedef enum logic [1:0] {
    STATE_READY,
    STATE_WORK,
    STATE_OUTPUT
} state_def;

state_def ps, ns;

always_ff @(posedge clk)
begin
    if( reset == 0)
        ps <= STATE_READY;
    else
        ps <= ns;
end

assign req_rdy = (ps == STATE_READY);
assign resp_val = (ps == STATE_OUTPUT);
assign resp_point_x = point_draw_x;
assign resp_point_y = point_draw_y;
assign image_address = change ? (point_draw_y * 256 + point_draw_x) : (point_draw_x * 256 + point_draw_y); 
assign image_data_extend = {{11{1'b0}}, image_data};

always_ff @(posedge clk)
begin

    case( ps )

        STATE_READY:
        begin
            cal_done    = 0;
            reduction   = 0;
            wait_count  = 0;
            if(req_val)
            begin
                point_1_x = req_point_1_x < req_point_2_x ? req_point_1_x : req_point_2_x;
                point_1_y = req_point_1_y < req_point_2_y ? req_point_1_y : req_point_2_y;
                point_2_x = req_point_1_x < req_point_2_x ? req_point_2_x : req_point_1_x;
                point_2_y = req_point_1_y < req_point_2_y ? req_point_2_y : req_point_1_y;
                point_x_interval = req_point_1_x < req_point_2_x ? req_point_2_x - req_point_1_x : req_point_1_x - req_point_2_x;
                point_y_interval = req_point_1_y < req_point_2_y ? req_point_2_y - req_point_1_y : req_point_1_y - req_point_2_y;
                point_x_interval_extend =  {4'h0, point_x_interval};
                point_y_interval_extend =  {4'h0, point_y_interval};
                p = (point_y_interval_extend <<< 1) - point_x_interval_extend;
                initial_done = 1;
            end
        end

        STATE_WORK:
        begin
            initial_done = 0;
            if(point_1_x <= point_2_x)
            begin
                point_draw_x = point_1_x;
                point_draw_y = point_1_y;
                point_1_x    = point_1_x + 1 ;
                if( p >= 0)
                begin
                    point_1_y = point_1_y + 1 ;
                    p = p + (point_y_interval_extend <<< 1) - (point_x_interval_extend <<< 1);
                end
                else
                begin
                    p = p + (point_y_interval_extend <<< 1);
                end
            end
            else
            begin
                cal_done = 1;
            end

            if(wait_count < 2)
                wait_count = wait_count + 1;
            else
                reduction = reduction + (image_data_extend <<< 1) - black;
        end

        STATE_OUTPUT:
        begin
            cal_done    = 0;
            wait_count  = 0;
        end
    endcase
end


always_comb
begin

    ns = ps;

    case( ps )

        STATE_READY:

            if( initial_done )
                ns = STATE_WORK;
        
        STATE_WORK:

            if( cal_done )
                ns = STATE_OUTPUT;
        
        STATE_OUTPUT:
            
            if( resp_val && resp_rdy)
                ns = STATE_READY;
        
        default:
            ns = STATE_READY;
    
    endcase
end

single_port_ram_with_init
#(.DATA_WIDTH(8),
.ADDR_WIDTH(18)
)
image_memory
(
    .data(),
    .addr(image_address),
    .we(1'b0),
    .clk(clk),
    .q(image_data)
);

single_port_ram_with_init
#(.DATA_WIDTH(8),
.ADDR_WIDTH(18)
)
count_memory
(
    .data(),
    .addr(image_address),
    .we(mode),
    .clk(clk),
    .q(image_data)
);


endmodule