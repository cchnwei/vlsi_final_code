module Mux2 (
    input sel,
    input [31:0] data1,
    input [31:0] data0,
    output [31:0] out

);

assign out = (sel) ? data1:data0; //1時選data1 0時選data0



endmodule