module Reg_E (
    input clk,
    input rst,
    input stall,
    input jb,
    input [31:0] next_pc,
    input [31:0] next_rs1_data,
    input [31:0] next_rs2_data,
    input [31:0] next_sext_imm,
    output reg [31:0] current_pc,
    output reg [31:0] current_rs1_data,
    output reg [31:0] current_rs2_data,
    output reg [31:0] current_sext_imm
);

always @(posedge clk or posedge rst ) begin
    if(rst) begin
        current_pc <= 32'b0;
        current_rs1_data <= 32'b0;
        current_rs2_data <= 32'b0;
        current_sext_imm <= 32'b0;
    end
    else begin
	//standard
        if(stall == 0 && jb ==0)
	begin
            current_pc <= next_pc;
            current_rs1_data <= next_rs1_data;
            current_rs2_data <= next_rs2_data;
            current_sext_imm <= next_sext_imm;
        end        
	 //jb
        else if(stall == 0 && jb == 1)begin
            current_pc <= next_pc;    ///nop
            current_rs1_data <= 32'b0;///nop
            current_rs2_data <= 32'b0;///nop
            current_sext_imm <= 32'b0;///nop
        end	
	//stall
        else //(stall == 1 && jb == 0)
	begin
            current_pc <= next_pc;    /// nop
            current_rs1_data <= 32'b0;/// nop
            current_rs2_data <= 32'b0;/// nop 
            current_sext_imm <= 32'b0;/// nop
        end
        
        
        //else begin //基本上不會發生jb stall同時為1狀況 因為stall是在ex為load jb是在ex有branch 
          //  current_pc <= next_pc;
            //current_rs1_data <= next_rs1_data;
            //current_rs2_data <= next_rs2_data;
            //current_sext_imm <= next_sext_imm;
        //end
        end

end



endmodule
