
`include "RegFile.v"
`include "Reg_PC.v"
`include "Decoder.v"
`include "Imm_Ext.v"
`include "ALU.v"
`include "JB_Unit.v"
`include "LD_Filter.v"
`include "Controller.v"
`include "Mux2.v"
`include "Mux3.v"
`include "Reg_D.v"
`include "Reg_E.v"
`include "Reg_M.v"
`include "Reg_W.v"



module CPU (
    input clk,
    input rst,
	input [31:0] inst_F,
	input [31:0] ld_data_M,
	output [3:0] F_im_w_en,
	output [3:0] M_dm_w_en,
	output [15:0] pcaddress16,
	output [15:0] aluout16_M,
	output [31:0] rs2_data_M
);

//controller output
wire stall;
wire next_pc_sel;
wire D_rs1_data_sel,D_rs2_data_sel;
wire [1:0] E_rs1_data_sel,E_rs2_data_sel;
wire E_jb_op1_sel,E_alu_op1_sel,E_alu_op2_sel;
wire [4:0] E_op;
wire [2:0] E_f3;
wire E_f7;

wire W_wb_en;
wire [4:0] W_rd_index;
wire [2:0] W_f3;
wire W_wb_data_sel;


//controller input
wire [4:0] D_opcode;
wire [2:0] D_func3;
wire D_func7;
wire alubranch;


//other wires
wire [31:0] nextpcaddress;
wire [31:0] jb_pc;

wire [31:0] inst_D;
wire [4:0] rs1_index,rs2_index,rd_index;
wire [31:0] rs1_data_D,rs2_data_D;
wire [31:0] newest_rs1_data_D,newest_rs2_data_D;
wire [31:0] rs1_data_E,rs2_data_E;
wire [31:0] sext_imme_D,sext_imme_E;
wire [31:0] pcaddress32_D,pcaddress32_E;
wire [31:0] wb_data_W;
wire [31:0] newest_rs1_data_E,newest_rs2_data_E;


wire [31:0] ld_data_W;
wire [31:0] ld_data_f;

wire [31:0] op1,op2;
wire [31:0] jbin;

wire [31:0] pcaddress32_F;

wire [31:0] aluout32_E;
wire [31:0] aluout32_M;
wire [31:0] aluout32_W;

wire [31:0] pcplus4;



assign pcplus4 = pcaddress32_F + 32'd4;
assign pcaddress16 = pcaddress32_F [15:0];
assign aluout16_M = aluout32_M [15:0];


//SRAM im ( .clk(clk), .w_en(F_im_w_en), .address(pcaddress16), .write_data(), .read_data(inst_F));MEM don't synopsys,so it should take outside and its I/O

//SRAM dm ( .clk(clk), .w_en(M_dm_w_en), .address(aluout16_M), .write_data(rs2_data_M), .read_data(ld_data_M));should appear at module CPU in/out ports


RegFile regfile ( .clk(clk), .wb_en(W_wb_en), .wb_data(wb_data_W), .rs1_index(rs1_index), .rs2_index(rs2_index), .rd_index(W_rd_index), .rs1_data_out(rs1_data_D), .rs2_data_out(rs2_data_D));

Reg_PC pc ( .clk(clk), .rst(rst), .stall(stall), .next_pc(nextpcaddress), .current_pc(pcaddress32_F));

Decoder dc ( .inst(inst_D), .dc_out_opcode(D_opcode), .dc_out_func3(D_func3), .dc_out_func7(D_func7), .dc_out_rs1_index(rs1_index), .dc_out_rs2_index(rs2_index), .dc_out_rd_index(rd_index));

Imm_Ext imext ( .inst(inst_D), .imm_ext_out(sext_imme_D));

ALU alu ( .opcode(E_op), .func3(E_f3), .func7(E_f7), .operand1(op1), .operand2(op2), .alu_out(aluout32_E), .alubranch(alubranch));

JB_Unit jb ( .operand1(jbin), .operand2(sext_imme_E), .jb_out(jb_pc));

LD_Filter ldfilter ( .func3(W_f3), .ld_data(ld_data_W), .ld_data_f(ld_data_f));

Controller control ( .clk(clk), .rst(rst), .opcode(D_opcode), .func3(D_func3), .func7(D_func7), .rs1_index(rs1_index), .rs2_index(rs2_index), .rd_index(rd_index), .alubranch(alubranch), .next_pc_sel(next_pc_sel), .stall(stall), .F_im_w_en(F_im_w_en), .D_rs1_data_sel(D_rs1_data_sel), .D_rs2_data_sel(D_rs2_data_sel), .E_rs1_data_sel(E_rs1_data_sel), .E_rs2_data_sel(E_rs2_data_sel), .E_jb_op1_sel(E_jb_op1_sel), .E_alu_op1_sel(E_alu_op1_sel), .E_alu_op2_sel(E_alu_op2_sel), .E_op(E_op), .E_f3(E_f3), .E_f7(E_f7), .M_dm_w_en(M_dm_w_en), .W_wb_en(W_wb_en), .W_rd_index(W_rd_index), .W_f3(W_f3), .W_wb_data_sel(W_wb_data_sel));

Reg_D regd ( .clk(clk), .rst(rst), .stall(stall), .jb(next_pc_sel), .next_pc(pcaddress32_F), .next_inst(inst_F), .current_pc(pcaddress32_D),.current_inst(inst_D));

Reg_E rege ( .clk(clk), .rst(rst), .stall(stall), .jb(next_pc_sel), .next_pc(pcaddress32_D), .next_rs1_data(newest_rs1_data_D), .next_rs2_data(newest_rs2_data_D), .next_sext_imm(sext_imme_D), .current_pc(pcaddress32_E), .current_rs1_data(rs1_data_E), .current_rs2_data(rs2_data_E), .current_sext_imm(sext_imme_E));

Reg_M regm ( .clk(clk), .rst(rst), .next_alu_out(aluout32_E), .next_rs2_data(newest_rs2_data_E), .current_alu_out(aluout32_M), .current_rs2_data(rs2_data_M));

Reg_W regw ( .clk(clk), .rst(rst), .next_alu_out(aluout32_M), .next_ld_data(ld_data_M), .current_alu_out(aluout32_W), .current_ld_data(ld_data_W));

Mux2 m1 ( .sel(next_pc_sel), .data1(jb_pc), .data0(pcplus4), .out(nextpcaddress)); //reg_pc前那個 1時選jb_pc 0時選pcplus4

Mux2 m2 ( .sel(D_rs1_data_sel), .data1(wb_data_W), .data0(rs1_data_D), .out(newest_rs1_data_D));//regfile後那2個 1時選wb_data_W 0時選rs1_data_D

Mux2 m3 ( .sel(D_rs2_data_sel), .data1(wb_data_W), .data0(rs2_data_D), .out(newest_rs2_data_D));//regfile後那2個 1時選wb_data_W 0時選rs2_data_D

Mux2 m4 ( .sel(E_alu_op1_sel), .data1(newest_rs1_data_E), .data0(pcaddress32_E), .out(op1)); //alu前那2個 

Mux2 m5 ( .sel(E_alu_op2_sel), .data1(newest_rs2_data_E), .data0(sext_imme_E), .out(op2));//alu前那2個

Mux2 m6 ( .sel(E_jb_op1_sel), .data1(newest_rs1_data_E), .data0(pcaddress32_E), .out(jbin));//jb unit前那2個

Mux2 m7 ( .sel(W_wb_data_sel), .data1(aluout32_W), .data0(ld_data_f), .out(wb_data_W)); //ld filter後那個

Mux3 m8 ( .sel(E_rs1_data_sel), .data00(wb_data_W), .data01(aluout32_M), .data10(rs1_data_E), .out(newest_rs1_data_E));//Reg_E後那2個

Mux3 m9 ( .sel(E_rs2_data_sel), .data00(wb_data_W), .data01(aluout32_M), .data10(rs2_data_E), .out(newest_rs2_data_E));//Reg_E後那2個



endmodule
