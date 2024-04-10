module Reg_D (
    input clk,
    input rst,
    input stall, 
    input jb,//即next_pc_sel 1時代表跳轉成立
    input [31:0] next_pc,
    input [31:0] next_inst,
    output reg [31:0] current_pc,
    output reg [31:0] current_inst

);

always @(posedge clk or posedge rst ) begin
    if(rst) begin
        current_pc <= 32'b0;
        current_inst <= 32'b0;
    end
    else begin
  	
	//standard
        if(stall == 0 && jb ==0)
	begin
            current_pc <= next_pc;
            current_inst <= next_inst;
        end
        //jb
        else if(stall == 0 && jb == 1)begin
            current_pc <= next_pc;
            current_inst <= {12'b0,5'b0,3'b0,5'b0,7'b0010011}; //opcode0010011 func3000是跟imm有關的算數 但因為rs1 rd imm 都是0 所以等於nop
        end
        
	      //stall
        else //(stall == 1 && jb == 0)
	begin
            current_pc <= current_pc;
            current_inst <= current_inst;
        end
        //else begin //基本上不會發生jb stall同時為1狀況 因為stall是在ex為load jb是在ex有branch 
          //  current_pc <= next_pc;
            //current_inst <= next_inst;
        //end
    end
    
end



endmodule
