module SRAM (
    input clk,rst,
    input [3:0] w_en,
    input [15:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);

reg [7:0] mem [0:65535];
integer i;

always @(posedge clk or posedge rst) begin
    if(rst) begin
        for(i=0;i<65535;i=i+1)
            mem[i]<=8'd0;
    end
    else begin
        mem[address] <= (w_en[0]) ? write_data[7:0]:mem[address];  //modelsim測試時小心這邊過不了
        mem[address+1] <= (w_en[1]) ? write_data[15:8]:mem[address+1];
        mem[address+2] <= (w_en[2]) ? write_data[23:16]:mem[address+2];
        mem[address+3] <= (w_en[3]) ? write_data[31:24]:mem[address+3];
    end
end
assign read_data[31:0] = {mem[address+3],mem[address+2],mem[address+1],mem[address]};


endmodule