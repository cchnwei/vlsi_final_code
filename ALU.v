module ALU (
    input [4:0] opcode,
    input [2:0] func3,
    input func7,
    input signed [31:0] operand1,
    input signed [31:0] operand2,
    output reg [31:0] alu_out,
    output reg alubranch
);



always @(*)begin
    
    case(opcode) 
        // R type
        5'b01100:begin
            alubranch = 1'b0;
            if(func7 == 1'b0)begin
                case(func3)
                    //add
                    //3'b000:
                    //    alu_out = operand1 + operand2;
                    //sll
                    3'b001:
                        alu_out = operand1 << operand2[4:0];
                    //slt
                    3'b010:
                        alu_out = (operand1 < operand2) ? 32'b1:32'b0;
                    //sltu
                    3'b011:
                        alu_out = ($unsigned(operand1) < $unsigned(operand2)) ? 32'b1:32'b0; //$unsigned網路說可合成
                    //xor
                    3'b100:
                        alu_out = operand1 ^ operand2;
                    //srl
                    3'b101:
                        alu_out = operand1 >> operand2[4:0];
                    //or
                    3'b110:
                        alu_out = operand1 | operand2;
                    //and
                    3'b111:
                        alu_out = operand1 & operand2;
                    default://ADD
                        alu_out = operand1 + operand2;
                endcase
            end
            else begin
                //sub
                if(func3 == 3'b000)begin
                    alu_out = operand1 - operand2;
                end
                //sra
                else begin
                    alu_out = operand1 >>> operand2[4:0];
                end
            end
        end
        // I type
        5'b00100:begin
            alubranch = 1'b0;

            case(func3)
                //addi
                //3'b000:
                    //alu_out = operand1 + operand2;
                //slti
                3'b010:
                    alu_out = (operand1 < operand2) ? 32'b1:32'b0;
                //sltiu
                3'b011:
                    alu_out = ($unsigned(operand1) < $unsigned(operand2)) ? 32'b1:32'b0;
                //xori
                3'b100:
                    alu_out = operand1 ^ operand2;
                //ori
                3'b110:
                    alu_out = operand1 | operand2;
                //andi
                3'b111:
                    alu_out = operand1 & operand2;
                //slli
                3'b001:
                    alu_out = operand1 << $unsigned(operand2[4:0]);
                3'b101:begin
                    //srai
                    if(func7)begin
                        alu_out = operand1 >>> $unsigned(operand2[4:0]);
                    end
                    //srli
                    else begin
                        alu_out = operand1 >> $unsigned(operand2[4:0]);
                    end
                end
                default://addi
                    alu_out = operand1 + operand2;
            endcase
        end
        5'b00000:begin
            //load
            alu_out = operand1 + operand2;  //算出要讀出的address
            alubranch = 1'b0;
        end
        5'b11001:begin
            //jalr
            alu_out = operand1 + 32'd4; //因為無條件跳轉需紀錄跳轉回來的地址即pc+4 需wb回regfile
            alubranch = 1'b1;
        end

        // S type
        5'b01000:begin
            //store
            alu_out = operand1 + operand2; //算出要寫進的address
            alubranch = 1'b0;
        end
            

        // B type
        5'b11000:begin
            alu_out = operand1 + operand2; //這個alu_out之後也不需writeback 所以亂給個運算
            case(func3)
                //beq
                //3'b000:
                   // alubranch = (operand1 == operand2) ? 1'b1:1'b0;
                //bne
                3'b001:
                    alubranch = (operand1 != operand2) ? 1'b1:1'b0;
                //blt
                3'b100:
                    alubranch = (operand1 < operand2) ? 1'b1:1'b0;
                //bge
                3'b101:
                    alubranch = (operand1 >= operand2) ? 1'b1:1'b0;
                //bltu
                3'b110:
                    alubranch = ($unsigned(operand1) < $unsigned(operand2)) ? 1'b1:1'b0;
                //bgeu
                3'b111:
                    alubranch = ($unsigned(operand1) >= $unsigned(operand2)) ? 1'b1:1'b0;
                default://beq
                    alubranch = (operand1 == operand2) ? 1'b1:1'b0;
            endcase
        end
            

        // U type
        5'b00101:begin
            //auipc
            alu_out = operand1 + operand2; //op1為pc op2為imm
            alubranch = 1'b0;
        end
            
        5'b01101:begin
            //lui
            alu_out = operand2; //op2為unsigned imm
            alubranch = 1'b0;
        end
            

        // J type
        5'b11011:begin
            //jal
            alu_out = operand1 + 32'd4;//因為無條件跳轉需紀錄跳轉回來的地址即pc+4 需wb回regfile
            alubranch = 1'b1;
        end

        default:begin
            alu_out = operand1 + operand2;
            alubranch = 1'b0;
        end
    endcase


end


endmodule
