`timescale 1ns/1ps

module frame_driver(reset_n, PCLK, VSYNC, HREF, DATA);
input reset_n;
output PCLK;
output VSYNC;
output HREF;
output [7:0] DATA;

// assume pixel clock frequency is 23.99MHz
reg pclk;
initial pclk = 0;
always #20.842 begin
	pclk = ~pclk;
end
assign PCLK = pclk;

integer v_count;
integer h_count;

assign VSYNC = (v_count < 3)   ? reset_n : 1'b0;
assign HREF  = (h_count < 640) && (v_count > 19) && (v_count < 500) ? 1'b1 : 1'b0;

integer even;

always @ (posedge pclk or negedge reset_n) begin
	if(~reset_n) begin
		even    = 0;
		h_count = 0;
		v_count = 0;
	end else begin
		if(even == 1) begin
			even = 0;
			if(h_count == 783) begin
				h_count = 0;
				if(v_count == 509) begin
					v_count = 0;
				end else begin
					v_count = v_count + 1;
				end
			end else begin
				h_count = h_count + 1;
			end
		end else begin
			even = 1;
		end
	end
end

wire [18:0] pointer;
assign pointer = v_count < 20 ? 19'h0 : h_count + (v_count-20)*640;

reg [23:0] picture [0:307199];
initial $readmemh("picture.hex", picture);
assign DATA = HREF ? (even == 0 ? 
	{ picture[pointer][23:19] , picture[pointer][15:13] } : 
	{ picture[pointer][12:10] , picture[pointer][7:3]   } ) : 8'hxx ;

endmodule


