module Add_Remove_Search
 (
    input  logic clk,
    input  logic reset,

    input  logic req_val,
     
    input  logic resp_rdy,
    output logic resp_val,

    output logic [7:0] pin_1_index,
    output logic [7:0] pin_2_index,
    output logic add_or_remove,
	output logic done
 );

 logic [17:0] pin_1_pos;
 logic [17:0] pin_2_pos;

 logic [8:0]  pin_x_sub;
 logic [8:0]  pin_y_sub;

 logic [8:0]  pin_1_pos_x;
 logic [8:0]  pin_1_pos_y;
 logic [8:0]  pin_2_pos_x;
 logic [8:0]  pin_2_pos_y;
 logic change_temp;
 logic change;

 logic [7:0]  x1_counter;
 logic [7:0]  x2_counter;

 logic solver_req_val;
 logic solver_req_rdy;
 logic solver_resp_rdy;
 logic solver_resp_val;

 logic [1:0]  cal_mode;

 logic [1:0]  add_cycle_counter;
 logic [2:0]  remove_cycle_counter;


 logic signed [18:0] reduction;
 logic signed [18:0] max_reduction;
 logic [8:0] optimal_pos_1_x;
 logic [8:0] optimal_pos_1_y;
 logic [8:0] optimal_pos_2_x;
 logic [8:0] optimal_pos_2_y;
 logic [7:0] optimal_pin_1_index;
 logic [7:0] optimal_pin_2_index;
 logic [10:0] optimal_edge_index;
 logic optimal_change;

 logic add_has_update;
 logic remove_has_update;
 
 logic add_ever_update;
 logic remove_ever_update;
 logic add_ever_update_next;
 logic remove_ever_update_next;
 logic add_or_remove_next;
 
 logic add_finish;
 logic remove_finish;
 logic update_finish;
 
 logic [11:0] edge_count;
 logic [11:0] edge_count_next;
 
 logic edge_mem_write_en;
 logic [15:0] edge_write_data;
 logic [15:0] edge_read_data;
 logic [11:0] edge_mem_address;
 

 assign pin_x_sub   = (pin_1_pos[8:0] > pin_2_pos[8:0]) ? (pin_1_pos[8:0] - pin_2_pos[8:0]) : (pin_2_pos[8:0] - pin_1_pos[8:0]);
 assign pin_y_sub   = (pin_1_pos[17:9] > pin_2_pos[17:9]) ? (pin_1_pos[17:9] - pin_2_pos[17:9]) : (pin_2_pos[17:9] - pin_1_pos[17:9]);  
 assign change_temp = pin_x_sub < pin_y_sub;
 assign pin_1_index = optimal_pin_1_index;
 assign pin_2_index = optimal_pin_2_index;
 
 typedef enum logic [2:0] {
     STATE_RESET,
     STATE_ADD,
     STATE_UPDATE,
     STATE_REMOVE,
     STATE_OUTPUT,
	 STATE_DONE
 } state_def;

state_def ps, ns;

always_ff @(posedge clk)
begin
    if( reset == 0)
        ps <= STATE_RESET;
    else
        ps <= ns;
end

always_ff @(posedge clk)
begin
	if( reset == 0)
	begin
		add_ever_update    <= 0;
		remove_ever_update <= 0;
		add_or_remove      <= 0;
		edge_count         <= 0;
	end
	else
	begin
		add_ever_update    <= add_ever_update_next;
		remove_ever_update <= remove_ever_update_next;
		add_or_remove      <= add_or_remove_next;
		edge_count         <= edge_count_next;
	end
end
		

always_ff @(posedge clk)
begin
	resp_val = 0;
    add_finish = 0;
    remove_finish = 0;
    update_finish = 0;
    solver_req_val = 0;
    solver_resp_rdy = 0;
    edge_mem_write_en = 0;

    case(ps)

        STATE_RESET:
        begin
            x1_counter = 0;
            x2_counter = 0;
			edge_mem_address = 0;
            cal_mode = 0;
            add_cycle_counter = 0;
			remove_cycle_counter = 0;
            add_has_update = 0;
            remove_has_update = 0;
            optimal_pos_1_x = 0;
            optimal_pos_1_y = 0;
            optimal_pos_2_x = 0;
            optimal_pos_2_y = 0;
			optimal_edge_index = 0;
            optimal_pin_1_index = 0;
            optimal_pin_2_index = 0;
            max_reduction = 0;
        end

        STATE_ADD:
        begin
            cal_mode = 0;
				edge_mem_address = 0;
            case (add_cycle_counter)
                0:
                begin
                    if(x1_counter < 254)
                    begin
                        if(x2_counter == 255)
                        begin
                            x1_counter = x1_counter + 1;
                            x2_counter = x1_counter + 1;
                        end
                        else
                        begin
                            x2_counter = x2_counter + 1;
                        end
                        add_cycle_counter = add_cycle_counter + 1;
                    end
                    else
                    begin
                        add_finish = 1;
                    end
       
                end

                1:
                begin
                    add_cycle_counter = add_cycle_counter + 1;
                end

                2:
                begin
                    if(solver_req_rdy)
                    begin
                        change      = change_temp;
                        pin_1_pos_x = change_temp ? pin_1_pos[17:9] : pin_1_pos[8:0];
                        pin_1_pos_y = change_temp ? pin_1_pos[8:0]  : pin_1_pos[17:9];
                        pin_2_pos_x = change_temp ? pin_2_pos[17:9] : pin_2_pos[8:0];
                        pin_2_pos_y = change_temp ? pin_2_pos[8:0]  : pin_2_pos[17:9];                
                        solver_req_val = 1;
                        add_cycle_counter = add_cycle_counter + 1;
                    end
                end

                3:
                begin
                    if(solver_resp_val)
                    begin
                        if(reduction > max_reduction)
                        begin
                            max_reduction = reduction;
                            optimal_pos_1_x = pin_1_pos_x;
                            optimal_pos_1_y = pin_1_pos_y;
                            optimal_pos_2_x = pin_2_pos_x;
                            optimal_pos_2_y = pin_2_pos_y;
                            optimal_change  = change;
									optimal_pin_1_index = x1_counter;
									optimal_pin_2_index = x2_counter;
                            add_has_update  = 1;
                        end
                        solver_resp_rdy = 1;
                        add_cycle_counter = add_cycle_counter + 1;
                    end
                end
            endcase
        end
		
		STATE_REMOVE:
		begin
			cal_mode = 2;
            case (remove_cycle_counter)

                0:
                begin
                    if(edge_mem_address == edge_count)
						remove_finish = 1;
					else
					begin
						remove_cycle_counter = remove_cycle_counter + 1;
					end
                end

                1:
                begin
					x1_counter  = edge_read_data[15:8];
					x2_counter  = edge_read_data[7:0];
					if(x1_counter == 0 && x2_counter == 0)
					begin
						edge_mem_address = edge_mem_address + 1;
						remove_cycle_counter = 0;
					end
					else
					begin
						remove_cycle_counter = remove_cycle_counter + 1;
					end
				end
				
				2:
				begin
					remove_cycle_counter =  remove_cycle_counter + 1;
				end
				
				3:
				begin
                    if(solver_req_rdy)
                    begin
                        change      = change_temp;
                        pin_1_pos_x = change_temp ? pin_1_pos[17:9] : pin_1_pos[8:0];
                        pin_1_pos_y = change_temp ? pin_1_pos[8:0]  : pin_1_pos[17:9];
                        pin_2_pos_x = change_temp ? pin_2_pos[17:9] : pin_2_pos[8:0];
                        pin_2_pos_y = change_temp ? pin_2_pos[8:0]  : pin_2_pos[17:9];
                        solver_req_val = 1;
                        remove_cycle_counter = remove_cycle_counter + 1;
                    end
                end

                4:
                begin
                    if(solver_resp_val)
                    begin
                        if(reduction > max_reduction)
                        begin
                            max_reduction = reduction;
                            optimal_pos_1_x = pin_1_pos_x;
                            optimal_pos_1_y = pin_1_pos_y;
                            optimal_pos_2_x = pin_2_pos_x;
                            optimal_pos_2_y = pin_2_pos_y;
                            optimal_change  = change;
									 optimal_pin_1_index = x1_counter;
									 optimal_pin_2_index = x2_counter;
									 optimal_edge_index = edge_mem_address;
                            remove_has_update  = 1;    
                        end
                        solver_resp_rdy = 1;
						edge_mem_address = edge_mem_address + 1;
                        remove_cycle_counter = 0;
                    end
                end
            endcase
		end

        STATE_UPDATE:
        begin
            
            add_has_update = 0;
			remove_has_update = 0;
			x1_counter = 0;
			x2_counter = 0;
			edge_mem_address = 0;
            max_reduction = 0;
            if(add_or_remove == 0)
			begin
                cal_mode = 1;
			end
            else
			begin
                cal_mode = 3;
			end
            if(solver_req_rdy)
            begin
                pin_1_pos_x = optimal_pos_1_x;
                pin_1_pos_y = optimal_pos_1_y;
                pin_2_pos_x = optimal_pos_2_x;
                pin_2_pos_y = optimal_pos_2_y;
                change      = optimal_change;
                solver_req_val = 1;
            end
            if(solver_resp_val)
            begin
                solver_resp_rdy = 1;
                update_finish = 1;
            end
        end
		
		STATE_OUTPUT:
		begin
			edge_mem_write_en = 1;
			resp_val = 1;
			if(add_or_remove == 0)
			begin
				edge_mem_address = edge_count;
				edge_write_data = {optimal_pin_1_index, optimal_pin_2_index};
			end
			else
			begin
				edge_mem_address = optimal_edge_index;
				edge_write_data = 16'h0000;
			end
		end
    endcase
end

always_comb
begin
   ns = ps;
	remove_ever_update_next = remove_ever_update;
	add_ever_update_next = add_ever_update;
	add_or_remove_next = add_or_remove;
	edge_count_next = edge_count;
	done = 0;

    case( ps )

        STATE_RESET:
		begin
		   add_ever_update_next    = 0;
			remove_ever_update_next = 0;
			add_or_remove_next      = 0;
			edge_count_next         = 0;
            if( req_val )
                ns = STATE_ADD;
		end
        
        STATE_ADD:
        begin
			add_or_remove_next = 0;
            if( add_finish )
            begin
                if( add_has_update )
					begin
					add_ever_update_next = 1;					
                    ns = STATE_UPDATE;
					end
                else
					begin
					if( add_ever_update )
					begin
						ns = STATE_REMOVE;
						add_ever_update_next = 0;
					end
					else
					begin
						ns = STATE_DONE;
					end
				end
            end
        end

        STATE_REMOVE:
        begin
			add_or_remove_next = 1;
			if( remove_finish )
			begin
				if( remove_has_update )
				begin
					remove_ever_update_next = 1;
					ns = STATE_UPDATE;
				end
				else
				begin
					if( remove_ever_update )
					begin
						ns = STATE_ADD;
						remove_ever_update_next = 0;
					end
					else
					begin
						ns = STATE_DONE;
					end
				end
			end
        end
                

        STATE_UPDATE:
		begin
			if(update_finish)
			begin
				ns = STATE_OUTPUT;
			end
		end
		
        STATE_OUTPUT:
            if( resp_val && resp_rdy )
				begin
				if(add_or_remove == 0)
				begin
					edge_count_next = edge_count_next + 1;
					ns = STATE_ADD;
				end
				else
				begin
					ns = STATE_REMOVE;
				end
				end
					
		STATE_DONE:
			done = 1;
        
        default:
            ns = STATE_RESET;
    
    endcase
end

Bresenham_Solver
solver
(
    .clk(clk),
    .reset(reset),
    .req_rdy(solver_req_rdy),
    .req_val(solver_req_val),
    .req_point_1_x(pin_1_pos_x),
    .req_point_1_y(pin_1_pos_y),
    .req_point_2_x(pin_2_pos_x),
    .req_point_2_y(pin_2_pos_y),
    .change(change),
    .mode(cal_mode),
    .resp_rdy(solver_resp_rdy),
    .resp_val(solver_resp_val),
    .reduction(reduction)
);


Pin_pos_memory
#(.DATA_WIDTH(18),
.ADDR_WIDTH(8)
)
pin_1_pos_memory
(
    .addr(x1_counter),
    .clk(clk),
    .q(pin_1_pos)
);

Pin_pos_memory
#(.DATA_WIDTH(18),
.ADDR_WIDTH(8)
)
pin_2_pos_memory
(
    .addr(x2_counter),
    .clk(clk),
    .q(pin_2_pos)
);

Edge_memory
#(.DATA_WIDTH(16),
.ADDR_WIDTH(12)
)
edge_pin_pair_memory
(
    .data(edge_write_data),
    .addr(edge_mem_address),
    .we(edge_mem_write_en),
    .clk(clk),
    .q(edge_read_data)
);



endmodule