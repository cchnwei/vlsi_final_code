module Controller (
    input clk,
    input rst,
    input [4:0] opcode,
    input [2:0] func3,
    input func7,
    input [4:0]rs1_index,
    input [4:0]rs2_index,
    input [4:0]rd_index,
    input alubranch,

    output reg next_pc_sel,
    output reg stall,

    output reg [3:0] F_im_w_en,
    
    output reg D_rs1_data_sel,
    output reg D_rs2_data_sel,

    output reg [1:0] E_rs1_data_sel,
    output reg [1:0] E_rs2_data_sel,
    output reg E_jb_op1_sel,
    output reg E_alu_op1_sel,
    output reg E_alu_op2_sel,

    output reg [4:0] E_op,
    output reg [2:0] E_f3,
    output reg E_f7,
   
    
    output reg [3:0] M_dm_w_en,

    output reg W_wb_en,
    output reg [4:0] W_rd_index,
    output reg [2:0] W_f3,
    output reg W_wb_data_sel


);


reg [4:0] E_rd;
reg [4:0] E_rs1;
reg [4:0] E_rs2;


reg [4:0] M_op;
reg [2:0] M_f3;
reg [4:0] M_rd;

reg [4:0] W_op;
reg [4:0] W_rd;

reg is_D_rs1_E_rd_overlap;
reg is_D_rs2_E_rd_overlap;
reg is_D_use_rs1;
reg is_D_use_rs2;
reg is_DE_overlap;

reg is_W_use_rd;
reg is_D_rs1_W_rd_overlap;
reg is_D_rs2_W_rd_overlap;

reg is_E_use_rs1;
reg is_E_use_rs2;
reg is_M_use_rd;
reg is_E_rs1_W_rd_overlap;
reg is_E_rs1_M_rd_overlap;
reg is_E_rs2_W_rd_overlap;
reg is_E_rs2_M_rd_overlap;

//stall
always @(*) begin
    if(opcode == 5'b01100 || opcode == 5'b00100 || opcode == 5'b00000 || opcode == 5'b11001 || opcode == 5'b01000 || opcode == 5'b11000)begin
        if(opcode == 5'b00100 || opcode == 5'b00000 || opcode == 5'b11001)begin
            is_D_use_rs1 = 1'b1;
            is_D_use_rs2 = 1'b0;
        end
        else begin
            is_D_use_rs1 = 1'b1;
            is_D_use_rs2 = 1'b1;
        end
        
    end
    else begin
        is_D_use_rs1 = 1'b0;
        is_D_use_rs2 = 1'b0;
    end

    is_D_rs1_E_rd_overlap = is_D_use_rs1 & (rs1_index == E_rd) & (E_rd != 5'b0);
    is_D_rs2_E_rd_overlap = is_D_use_rs2 & (rs2_index == E_rd) & (E_rd != 5'b0);
    is_DE_overlap = (is_D_rs1_E_rd_overlap | is_D_rs2_E_rd_overlap);
    stall = (E_op == 5'b00000) & is_DE_overlap;
end

//D_rs1_data_sel & D_rs2_data_sel
always @(*) begin
    if(W_op == 5'b01100 || W_op == 5'b00100 || W_op == 5'b00000 || W_op == 5'b11001 || W_op == 5'b01101 || W_op == 5'b00101 || W_op == 5'b11011)begin
        is_W_use_rd = 1'b1;
    end
    else begin
        is_W_use_rd = 1'b0;
    end
    is_D_rs1_W_rd_overlap = is_D_use_rs1 & is_W_use_rd & (rs1_index == W_rd) & (W_rd != 5'b0);
    is_D_rs2_W_rd_overlap = is_D_use_rs2 & is_W_use_rd & (rs2_index == W_rd) & (W_rd != 5'b0);

    D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
    D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;

end

//E_rs1_data_sel & E_rs2_data_sel
always @(*) begin
    if(E_op == 5'b01100 || E_op == 5'b00100 || E_op == 5'b00000 || E_op == 5'b11001 || E_op == 5'b01000 || E_op == 5'b11000)begin
        if(E_op == 5'b00100 || E_op == 5'b00000 || E_op == 5'b11001)begin
            is_E_use_rs1 = 1'b1;
            is_E_use_rs2 = 1'b0;
        end
        else begin
            is_E_use_rs1 = 1'b1;
            is_E_use_rs2 = 1'b1;
        end
        
    end
    else begin
        is_E_use_rs1 = 1'b0;
        is_E_use_rs2 = 1'b0;
    end

    if(M_op == 5'b01100 || M_op == 5'b00100 || M_op == 5'b00000 || M_op == 5'b11001 || M_op == 5'b01101 || M_op == 5'b00101 || M_op == 5'b11011)begin
        is_M_use_rd = 1'b1;
    end
    else begin
        is_M_use_rd = 1'b0;
    end
    is_E_rs1_W_rd_overlap = is_E_use_rs1 & is_W_use_rd & (E_rs1 == W_rd) & (W_rd != 5'b0);
    is_E_rs1_M_rd_overlap = is_E_use_rs1 & is_M_use_rd & (E_rs1 == M_rd) & (M_rd != 5'b0);
    is_E_rs2_W_rd_overlap = is_E_use_rs2 & is_W_use_rd & (E_rs2 == W_rd) & (W_rd != 5'b0);
    is_E_rs2_M_rd_overlap = is_E_use_rs2 & is_M_use_rd & (E_rs2 == M_rd) & (M_rd != 5'b0);
    E_rs1_data_sel = is_E_rs1_M_rd_overlap ? 2'b01 : is_E_rs1_W_rd_overlap ? 2'b00 : 2'b10;
    E_rs2_data_sel = is_E_rs2_M_rd_overlap ? 2'b01 : is_E_rs2_W_rd_overlap ? 2'b00 : 2'b10;
end


//next_pc_sel
always@(*)
 begin
 next_pc_sel <= (alubranch) ? 1:0;

 F_im_w_en <= 4'b0;

 W_rd_index <= W_rd;
 end

always @(posedge clk or posedge rst) begin
    if(rst)begin
        E_op <= 5'b0;
        E_f3 <= 3'b0;
        E_rd <= 5'b0;
        E_rs1 <= 5'b0;
        E_rs2 <= 5'b0;
        E_f7 <= 1'b0;
        M_op <= 5'b0;
        M_f3 <= 3'b0;
        M_rd <= 5'b0;
        W_op <= 5'b0;
        W_f3 <= 3'b0;
        W_rd <= 5'b0;
    end
    else begin
        if(((E_op == 5'b00000) & is_DE_overlap) || alubranch )begin
            E_op <= 5'b00100;
            E_f3 <= 3'b0;
            E_rd <= 5'b0;
            E_rs1 <= 5'b0;
            E_rs2 <= 5'b0;
            E_f7 <= 1'b0;
            M_op <= E_op;
            M_f3 <= E_f3;
            M_rd <= E_rd;
            W_op <= M_op;
            W_f3 <= M_f3;
            W_rd <= M_rd;
        end
        else begin
            E_op <= opcode;
            E_f3 <= func3;
            E_rd <= rd_index;
            E_rs1 <= rs1_index;
            E_rs2 <= rs2_index;
            E_f7 <= func7;
            M_op <= E_op;
            M_f3 <= E_f3;
            M_rd <= E_rd;
            W_op <= M_op;
            W_f3 <= M_f3;
            W_rd <= M_rd;
        end
        
    end
end


always @(*) begin
    case(E_op)
        //R type    
        5'b01100:begin
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b1;
            E_alu_op2_sel = 1'b1;
        end

        //I type
        5'b00100:begin
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b1;
            E_alu_op2_sel = 1'b0;
        end

        5'b00000:begin
            //load
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b1;
            E_alu_op2_sel = 1'b0;
        end

        5'b11001:begin
            //jalr
            E_jb_op1_sel = 1'b1;
            E_alu_op1_sel = 1'b0;
            E_alu_op2_sel = 1'b0;
        end

        // S type
        5'b01000:begin
            //store
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b1;
            E_alu_op2_sel = 1'b0;
        end

        // B type
        5'b11000:begin
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b1;
            E_alu_op2_sel = 1'b1;
        end

        // U type
        5'b00101:begin
            //auipc
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b0;
            E_alu_op2_sel = 1'b0;
        end
        5'b01101:begin
            //lui
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b1;
            E_alu_op2_sel = 1'b0;
        end

        // J type
        5'b11011:begin
            //jal
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b0;
            E_alu_op2_sel = 1'b0;
        end

        default: begin
            E_jb_op1_sel = 1'b0;
            E_alu_op1_sel = 1'b0;
            E_alu_op2_sel = 1'b0;
        end

    endcase
    
    
end

always @(*) begin
    case(M_op)
        //R type    
        5'b01100:begin
            M_dm_w_en = 4'b0000;
        end

        //I type
        5'b00100:begin
            M_dm_w_en = 4'b0000;
        end

        5'b00000:begin
            //load
            M_dm_w_en = 4'b0000;
        end

        5'b11001:begin
            //jalr
            M_dm_w_en = 4'b0000;
        end

        // S type
        5'b01000:begin
            //store
            //sb
            if(M_f3 == 3'b000)begin
                M_dm_w_en = 4'b0001;
            end
            //sh
            else if(M_f3 == 3'b001)begin
                M_dm_w_en = 4'b0011;
            end
            //sw
            else if(M_f3 == 3'b010)begin
                M_dm_w_en = 4'b1111;
            end
            else begin
                M_dm_w_en = 4'b1111;
            end
        end

        // B type
        5'b11000:begin
            M_dm_w_en = 4'b0000;
        end

        // U type
        5'b00101:begin
            //auipc
            M_dm_w_en = 4'b0000;
        end
        5'b01101:begin
            //lui
            M_dm_w_en = 4'b0000;
        end

        // J type
        5'b11011:begin
            //jal
            M_dm_w_en = 4'b0000;
        end

        default: begin
            M_dm_w_en = 4'b0000;
        end

    endcase
    
    
end

always @(*) begin
    case(W_op)
        //R type    
        5'b01100:begin
            W_wb_en = 1'b1;
            W_wb_data_sel = 1'b1;
        end

        //I type
        5'b00100:begin
            W_wb_en = 1'b1;
            W_wb_data_sel = 1'b1;
        end

        5'b00000:begin
            //load
            W_wb_en = 1'b1;
            W_wb_data_sel = 1'b0;
        end

        5'b11001:begin
            //jalr
            W_wb_en = 1'b1;
            W_wb_data_sel = 1'b1;
        end

        // S type
        5'b01000:begin
            //store
            W_wb_en = 1'b0;
            W_wb_data_sel = 1'b1;
        end

        // B type
        5'b11000:begin
            W_wb_en = 1'b0;
            W_wb_data_sel = 1'b1;
        end

        // U type
        5'b00101:begin
            //auipc
            W_wb_en = 1'b1;
            W_wb_data_sel = 1'b1;
        end
        5'b01101:begin
            //lui
            W_wb_en = 1'b1;
            W_wb_data_sel = 1'b1;
        end

        // J type
        5'b11011:begin
            //jal
            W_wb_en = 1'b1;
            W_wb_data_sel = 1'b1;
        end

        default: begin
            W_wb_en = 1'b0;
            W_wb_data_sel = 1'b1;
        end

    endcase
    
    
end


endmodule
