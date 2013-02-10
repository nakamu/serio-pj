`timescale 1ns/1ps
`define D 1

module IBUFG(I,O);
input  I;
output O;
assign #`D O = I;
endmodule
module BUFG(I,O);
input  I;
output O;
assign #`D O = I;
endmodule
