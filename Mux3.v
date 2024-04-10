module Mux3 (
    input [1:0]sel,
    input [31:0] data00,
    input [31:0] data01,
    input [31:0] data10,

    output reg [31:0] out

);
always @(*) begin
    case(sel)
    //2'b00:
      //  out = data00;
    2'b01:
        out = data01;
    2'b10:
        out = data10;
    default://2'b00
        out = data00;
endcase
end




endmodule
