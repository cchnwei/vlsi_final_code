`timescale 1ns/10ps
`include "SRAM.v"

`ifdef syn
   `include "CPU_syn.v"
   `include "tsmc18.v"

`else
   `include "CPU.v"
`endif

`define CYCLE 10.0
`define MAX 1000000    // Max cycle number

`define mem_word(addr) {dm.mem[addr+3],dm.mem[addr+2],dm.mem[addr+1], dm.mem[addr]}

`define ANSWER_START 'h9000

module testbench;

//接線
reg clk;
reg rst;
wire [31:0] inst_F;
wire [31:0] ld_data_M;
wire [3:0] F_im_w_en;
wire [3:0] M_dm_w_en;
wire [15:0] pcaddress16;
wire [15:0] aluout16_M;
wire [31:0] rs2_data_M;
reg [31:0] GOLDEN [0:100];




//引入module
CPU cpu (.clk(clk),.rst(rst),.inst_F(inst_F),
	.ld_data_M(ld_data_M),
	.F_im_w_en(F_im_w_en),
	.M_dm_w_en(M_dm_w_en),
	.pcaddress16(pcaddress16),
	.aluout16_M(aluout16_M),
	.rs2_data_M(rs2_data_M)
  );
 SRAM im (.clk(clk),.rst(rst),
	.w_en(F_im_w_en), 
	.address(pcaddress16), 
	.write_data(), 
	.read_data(inst_F)
  );

 SRAM dm (.clk(clk),.rst(rst),
	.w_en(M_dm_w_en), 
	.address(aluout16_M), 
	.write_data(rs2_data_M), 
	.read_data(ld_data_M)
	);

//design clock
initial begin
    clk=1'b0;
end
always #(`CYCLE/2) clk = ~clk;


//模擬
integer i ;
integer num;              // total golden data
integer err;              // total number of errors compared to golden data


`ifdef syn
 
 initial  $sdf_annotate("CPU_syn.sdf",cpu);//no initial why????
   
`endif


initial begin

    #0 rst=0;
    #5 rst=1;
    #5 rst=0;
    /////////////////////////////測試everyins/////////////////////////////////////////////////////
    

  $readmemh("everyins.hex", im.mem);
  $readmemh("everyinsans.hex", GOLDEN);
  $readmemh("everyins.hex", dm.mem);
  

  // Begin Running !
  #(`CYCLE) rst = 0;

  // Wait until end of execution
  wait(dm.mem[16'hfffc] == 8'hff);
  $display("\n everyins.hex is Done\n");

    // Compare result with Golden Data
  err = 0;
  num=45;
  for (i = 0; i < num; i=i+1)
  begin
    if (`mem_word(`ANSWER_START + i*4) !== GOLDEN[i])
    begin
      $display("DM['h%4h] = %h, expect = %h", `ANSWER_START + i*4, `mem_word(`ANSWER_START + i*4), GOLDEN[i]);
      err = err + 1;
    end
    else
    begin
      $display("DM['h%4h] = %h, pass", `ANSWER_START + i*4, `mem_word(`ANSWER_START + i*4));
    end
  end
  result(err, num);//呼叫下方的task
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////測試sort///////////////////////////////////////////////////////////////////////////
    #5 rst=1;
    for(i=0;i<100;i=i+1) begin
      GOLDEN[i]=0 ;
    end
    #5 rst=0;
    

  $readmemh("sort.hex", im.mem);
  $readmemh("sortans.hex", GOLDEN);
  $readmemh("sort.hex", dm.mem);
  
  // Begin Running !
  #(`CYCLE) rst = 0;
  
// Wait until end of execution
  wait(dm.mem[16'hfffc] == 8'hff);
  $display("\n sort.hex is Done\n");

    // Compare result with Golden Data
  err = 0;
  num=82;
  for (i = 0; i < num; i=i+1)
  begin
    if (`mem_word(`ANSWER_START + i*4) !== GOLDEN[i])
    begin
      $display("DM['h%4h] = %h, expect = %h", `ANSWER_START + i*4, `mem_word(`ANSWER_START + i*4), GOLDEN[i]);
      err = err + 1;
    end
    else
    begin
      $display("DM['h%4h] = %h, pass", `ANSWER_START + i*4, `mem_word(`ANSWER_START + i*4));
    end
  end
  result(err, num);//呼叫下方的task
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////測試fibo.prog///////////////////////////////////////////////////////////
  #10 rst=1;
  for(i=0;i<100;i=i+1) begin
    GOLDEN[i]=0 ;
  end
  #5 rst=0;
 

$readmemh("fibo.prog", im.mem);
$readmemh("fibo.golden.txt", GOLDEN);
$readmemh("fibo.prog", dm.mem);

// Begin Running !
#(`CYCLE) rst = 0;

// Wait until end of execution
wait(dm.mem[16'hfffc] == 8'hff);
$display("\n fibo.prog is Done\n");

  // Compare result with Golden Data
err = 0;
num=14;
for (i = 0; i < num; i=i+1)
  begin
    if (`mem_word(`ANSWER_START + i*4) !== GOLDEN[i])
    begin
      $display("DM['h%4h] = %h, expect = %h", `ANSWER_START + i*4, `mem_word(`ANSWER_START + i*4), GOLDEN[i]);
      err = err + 1;
    end
    else
    begin
      $display("DM['h%4h] = %h, pass", `ANSWER_START + i*4, `mem_word(`ANSWER_START + i*4));
    end
  end
  result(err, num);//呼叫下方的task
$finish;  ///模擬結束

end


task result;
    input integer err;
    input integer num;
    begin
      if (err === 0)
      begin 
        $display("                                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣶⣶⣾⣷⣶⣿⣿⣿⣿⣿⣿⣿⣦");
        $display("                                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⣿⣿⣿⣿⣿⣧⡀");
        $display("                                      ⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠀⠀⠀⠀⠀⣻⣿⣿⣿⣧");
        $display("                                      ⠀⠀⠀⠀⠀⠀ ⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠥⠤⣤⣤⡀⠀⠈⣹⣿⣿⣿");
        $display("                                              ⣸⣿⣿⣿⣿⣿⡟⠁⠙⠛⠥⠤⠤⣶⠎⠀⠰⢋⣭⣅⢹⡿");
        $display("                                      ⠀⠀⠀⠀⠀⠀⣿⣿⠛⢿⣿⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠁");
        $display("                                      ⠀⠀⠀⠀⠀⠀⠹⣿⣶⠞⢉⣁⠀⠀⠀⠀⠀⠀⠀⠀⠒⠒⠲⠶⠂");
        $display("                                      ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠒⣒⣒⣒⠶");
        $display("                                      ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣶⣶⣤⣦⣀⣀⠀⠾⠶⣶⣶⣀⡀⠉⣉⣉⡴");
        $display("                                      ⠀⠀⠀⠀⢀⣀⣲⣿⣿⣿⣯⣿⣿⣿⣿⣿⣷⣶⣤⣤⣭⣿⣿⣿⣿⠛");
        $display("                                      ⠀⢀⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣶⣦⣤⣀");
        $display("                                      ⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣄");
        $display("                                      ⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣌⣙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⡀");
        $display("                                      ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣻⣿⣿⣿⣿⣿⣿⣿⣶⣄⣀");
        $display("                                      ⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠛⠛⠛⠫⠙⣿⣿⣿⣿⣿⣿⣿⣿⣧⣀");
        $display("                                      ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠻⣿⣿⣿⡷⠦");
        $display("                                      ⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟⣻⢿⣿⣿⣿⣿⣿⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡨⠏");
        $display("                                      ⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣄⣀⡀⠀⠀⠀⠀⠀⠀⠀⢀⣸⠇⠀⠀⠀⠀⣰⠿⠃");
        $display("                                      ⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⣻⣿⣿⣶⣶⣶⣶⣾⣿⣿⣷⣶⡶⠶⠖⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⠄");
        $display("                                      ⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠁⢠⣿⠉⣡⡴⣶⣤⣄⣀⣀⣀⣤⣤⣤⣤⣤⣤⣤⣤⠤⠚");
        $display("                                      ⠀  ⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡁");
        $display("                                         ⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀");
        $display("                                      ⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧");
        $display("                                      ⠀⠀  ⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⡆");
        $display("                                           ⠘⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⠇");
        //$display("                                      ");
        //$display("                                      ");
        //$display("                                      ");
        $display("    **************************** ");
        $display("    **                        ** ");
        $display("    **  yeah hua chi lai !!   ** ");
        $display("    **                        ** ");
        $display("    **  you PASS !!           ** ");
        $display("    **                        ** ");
        $display("    **************************** ");
        $display("                                 ");
      end
      else
      begin
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⠄⠄⢀⡤⠒⢁⣨⣴⣶⣿⣿⣿⣷⣦⣥⡂⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄ ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⢀⠜⠁⠄⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠠⠄⠄⠄⠄⠄⠄⠄⠄");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⡈⠄⠄⠄⢺⣿⣿⣿⣿⣛⢛⣛⣽⣿⣿⣿⣿⠇⠁⠄⠄⠄⠄⠄⠄⠄ ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⡇⠄⠄⠄⣽⣿⣿⣿⣿⣿⡿⠿⢿⣻⣿⣿⣧⣦⡄⡀⠄⠄⠄⠄⠄⠄ ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⡧⠄⣀⠄⣸⣿⣿⣿⣿⣶⣶⣲⣾⣿⣿⣿⣤⣤⣘⡇⠄⠄⠄⠄⠄⠄  ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠸⣾⡗⠛⣷⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⠿⣿⣿⣿⣿⡇⠄⠄⠄⠄⠄⠄ ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣶⣤⣌⣿⣿⡇⠄⠄⠄⠄⠄⠄ ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⠄⠙⡟⠛⢻⣿⣿⣿⣿⣿⣿⠋⠉⠄⠄⠄⠄⢸⣿⠁⠄⠄⠄⠄⠄⠄ ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⠄⠄⠄⢸⣴⠄⠉⢿⣿⣿⣿⣿⣿⣆⠙⠛⠄⣰⣿⠇⠄⠄⠄⠄⠄⠄⠄  ");
        $display("                                    ⠄⠄⠄⠄⠄⠄⢀⠠⠊⠰⠿⠦⠄⠄⠈⠛⠻⠿⢿⣿⢿⣷⣾⣟⠋⠄⠄⠄⠄⠄⠄⠄⠄ ");
        $display("                                    ⠄⠄⠿⠿⠿⠿⠿⠿⣿⠿⠄⠄⠄⢸⣇⣀⣶⣼⣟⣴⣂⠄⠄⢱⡶⣶⠻⡟⣿⢸⡟⣷⠄ ");
        $display("                                    ⠄⠄⢰⡶⠶⢶⡆⠄⣿⠄⠄⠄⢰⣿⡏⢫⡽⢿⡿⠿⣭⠄⠄⢸⡇⣿⢸⡿⣿⢸⣧⡏⠄ ");
        $display("                                    ⠄⠄⢸⣧⣤⣼⡇⠄⣿⠄⠄⠄⠈⢸⡇⣰⡿⣶⣷⢾⡷⠄⠄⢸⣧⣿⢾⡷⣿⢸⡇⣿⠄ ");
        $display("                                    ⠄⠄⠘⠃⠄⠄⣤⣤⣿⠄⠄⠄⠄⢸⡇⣩⡿⠓⠿⢾⡷⠄⠄⠘⠃⢀⡾⢁⣿⢸⡟⠋⠄ ");
        $display("                                     ");
        $display("                                     ");
        $display("                                     ");
        $display("                                     ");
        $display("                                     ");
        $display("    ****************************     ");
        $display("    **                        **     ");
        $display("    **  caliana !!            **     ");
        $display("    **                        **     ");
        $display("    **  you Failed !!         **     ");
        $display("    **                        **     ");
        $display("    ****************************     ");
        $display("                                     ");
        $display("                                     ");
        $display("                                     ");
        $display("         Totally has %d errors"                     , err);
        $display("\n");
      end
    end
  endtask

`ifdef syn
   initial begin
	$dumpfile("pipelined CPU_syn.fsdb");
	$dumpvars;
   end
`else
   initial begin
	$dumpfile("pipelined CPU.fsdb");
	$dumpvars;
   end
`endif

initial begin
    #(`CYCLE*`MAX)
    $display("                                     ");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⢿⣿⡆⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⠘⣿⣷⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣿⣿⣧⣀⣠⣴⣦⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠿⠟⠋⠀⠀⠀⠀⠀⣰⣶⣶⣶⣶⣶⣦⣤⣤⣤⡀⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⣴⡄⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⢰⣿⡆⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠈⠛⠛⠛⠛⠛⠛⠛⣿⣿⡿⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⢸⣿⡇⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⣿⣿⠃⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⣿⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⢸⣿⡇⠀⠀⢀⣀⣿⣇⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⡿⠃⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣸⣿⣿⣿⣿⣿⣧⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠟⠀");
    $display("                                     ⠀⠀⠀⠀⠀⢠⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⢹⣿⣿⣿⣿⣿⡟⢿⣿⣿⣿⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣇⠀");
    $display("                                     ⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀⠀⢸⣿⡇⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀");
    $display("                                     ⠀⠀⠀⠀⠀⣼⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⢀⡀⢸⣿⣇⣤⢀⣤⠀⣿⣇⣤⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⡇⠀");
    $display("                                     ⠀⠀⠀⠀⠀⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣼⣿⢸⣿⣿⣿⣿⣿⡇⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣿⣧⠀");
    $display("                                     ⠀⠀⠀⠀⢸⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⡇⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀");
    $display("                                     ⠀⠀⠀⠀⣾⣿⠃⢿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡟⣿⣿⢸⣿⣿⣿⣿⣿⡇⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⠀");
    $display("                                     ⠀⠀⠀⣸⣿⡟⠀⠘⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⣿⣿⢸⣿⣿⣿⣿⣿⡇⣿⣿⣿⡇⠀⠀⠀⠀⠀⢰⣦⠀⠀⠀⢸⣿⠀");
    $display("                                     ⠀⠀⣰⣿⣿⠁⠀⠀⠘⣿⣿⣆⠀⠀⠀⠀⠀⠀⣾⣿⠃⠙⠃⢸⣿⣿⣿⣿⣿⡇⣿⣿⣿⡇⠀⠀⠀⠀⠀⢻⣿⡆⠀⠀⢸⣿⠀");
    $display("                                    ⢀⣠⣾⣿⣿⠏⠀⠀⠀⠀⠹⣿⣿⣦⡀⠀⠀⠀⢸⣿⡟⠀⠀⠀⢸⣿⡇⠛⠘⣿⠃⣿⣿⣿⡇⠀⠀⠀⠀⠀⠘⣿⣿⡀⠀⢸⣿⠀");
    $display("                                    ⣾⣿⣿⣿⠋⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣦⡀⠀⠈⠿⠁⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⣿⡏⠿⠃⠀⠀⠀⠀⠀⠀⢹⣿⣇⠀⢸⣿⠀");
    $display("                                    ⢻⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⢸⣿⠇⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡆⣼⣿⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠻⣿⠃⠀⠀⠀⠀⠀⠀⠈⠋⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ⢿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⠀");
    $display("                                     ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⡿⠃⠀");
    $display("    ****************************      ");
    $display("    **                        **      ");
    $display("    **  Time Out !!           **      ");
    $display("    **                        **     ⠀");
    $display("    **  It's too long !!      **     ⠀");
    $display("    **                        **     ⠀");
    $display("    ****************************     ⠀");
    $display("                                     ⠀");
    $display("                                      ");
    $display("                                     ⠀");
    $display("         Totally has %d errors"                     , err);
    $display("\n");
    $finish;
  end



    
endmodule


