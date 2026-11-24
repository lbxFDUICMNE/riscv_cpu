`timescale 1ns/1ps
// Self-contained deterministic CPU regression. Add as Simulation Source; top=tb_all.
// ROM and data RAM are test fixtures. Architectural registers are NEVER initialized.
// Each case asserts external reset, loads instructions, runs, and checks results.
// Existing mem_inst readmemh may run at t=0; fixtures replace it after reset.
// These tests do not prove ISA compliance, FPGA timing, or exhaustive correctness.
module tb_all;
reg clk=0, reset=1;
wire [31:0] pc,addr,wdata;
wire we;
integer errors=0, checks=0, cases_run=0, before_errors, stalls=0, writes=0;
integer i,k;
reg running=0;
reg [8*80-1:0] test_name;
top #(.BOARD_INPUT(0)) dut(.clk(clk), .reset(reset), .sw(9'b0), .seg(), .an(), .seg_dp(), .led());
assign pc = dut.pc;
assign addr = dut.data_addr;
assign wdata = dut.writedata;
assign we = dut.ram_write_en;
always #5 clk=~clk;
always @(posedge clk) if(running && !reset) begin
 if(dut.dp.stallF===1'b1) stalls=stalls+1;
 if(we===1'b1) writes=writes+1;
 if((^pc)===1'bx) begin errors=errors+1; $display("FAIL %s unknown PC",test_name); end
end
task prepare;
input [8*80-1:0] name;
begin
 @(negedge clk); #1; reset=1; running=0; test_name=name; before_errors=errors;
 repeat(3) @(posedge clk); #1;
 if(pc!==0 || we!==0) begin errors=errors+1;$display("FAIL reset %s",name);end
 for(i=0;i<1024;i=i+1) begin dut.imem.RAM[i]=32'h00000013;dut.dmem.RAM[i]=32'ha5a5a5a5;end
 stalls=0; writes=0;
end endtask
task execute;
input integer last;
begin
 dut.imem.RAM[last]=32'h0000006f;
 @(negedge clk);#1;reset=0;running=1;
 repeat(120) @(posedge clk);
 @(negedge clk);#1;running=0;
 if((^pc)===1'bx || pc<last*4 || pc>last*4+8 || pc[1:0]!=0) begin errors=errors+1;$display("FAIL %s final PC=%h",test_name,pc);end
end endtask
task check_reg;
input integer n;input [31:0] expected;
begin checks=checks+1;
 if(dut.dp.regf.RAM[n]!==expected)begin errors=errors+1;$display("FAIL %s x%0d got=%h expected=%h",test_name,n,dut.dp.regf.RAM[n],expected);end
end endtask
task check_mem;
input integer n;input [31:0] expected;
begin checks=checks+1;
 if(dut.dmem.RAM[n]!==expected)begin errors=errors+1;$display("FAIL %s RAM[%0d] got=%h expected=%h",test_name,n,dut.dmem.RAM[n],expected);end
end endtask
initial begin

// Case 1: ADD
prepare("001 ADD");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h002081b3;
execute(5);
check_reg(3,32'h80000020);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 2: ADD
prepare("002 ADD");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h002081b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 3: ADD
prepare("003 ADD");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h002081b3;
execute(5);
check_reg(3,32'h9be02467);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 4: SUB
prepare("004 SUB");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h402081b3;
execute(5);
check_reg(3,32'h7fffffe2);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 5: SUB
prepare("005 SUB");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h402081b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 6: SUB
prepare("006 SUB");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h402081b3;
execute(5);
check_reg(3,32'h88888889);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 7: SLL
prepare("007 SLL");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h002091b3;
execute(5);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 8: SLL
prepare("008 SLL");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h002091b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 9: SLL
prepare("009 SLL");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h002091b3;
execute(5);
check_reg(3,32'h2b3c0000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 10: SLT
prepare("010 SLT");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h0020a1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 11: SLT
prepare("011 SLT");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0020a1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 12: SLT
prepare("012 SLT");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h0020a1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 13: SLTU
prepare("013 SLTU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h0020b1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 14: SLTU
prepare("014 SLTU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0020b1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 15: SLTU
prepare("015 SLTU");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h0020b1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 16: XOR
prepare("016 XOR");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h0020c1b3;
execute(5);
check_reg(3,32'h8000001e);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 17: XOR
prepare("017 XOR");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0020c1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 18: XOR
prepare("018 XOR");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h0020c1b3;
execute(5);
check_reg(3,32'h9b9f9b97);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 19: SRL
prepare("019 SRL");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h0020d1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 20: SRL
prepare("020 SRL");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0020d1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 21: SRL
prepare("021 SRL");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h0020d1b3;
execute(5);
check_reg(3,32'h00002468);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 22: SRA
prepare("022 SRA");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h4020d1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 23: SRA
prepare("023 SRA");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h4020d1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 24: SRA
prepare("024 SRA");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h4020d1b3;
execute(5);
check_reg(3,32'h00002468);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 25: OR
prepare("025 OR");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h0020e1b3;
execute(5);
check_reg(3,32'h8000001f);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 26: OR
prepare("026 OR");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0020e1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 27: OR
prepare("027 OR");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h0020e1b3;
execute(5);
check_reg(3,32'h9bbfdfff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 28: AND
prepare("028 AND");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h01f10113;
dut.imem.RAM[4]=32'h0020f1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 29: AND
prepare("029 AND");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0020f1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 30: AND
prepare("030 AND");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h89abd137;
dut.imem.RAM[3]=32'hdef10113;
dut.imem.RAM[4]=32'h0020f1b3;
execute(5);
check_reg(3,32'h00204468);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 31: ADDI
prepare("031 ADDI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'hfff08193;
execute(3);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 32: ADDI
prepare("032 ADDI");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h80008193;
execute(3);
check_reg(3,32'h12344e78);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 33: ADDI
prepare("033 ADDI");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h7ff08193;
execute(3);
check_reg(3,32'h000007fe);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 34: SLTI
prepare("034 SLTI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'hfff0a193;
execute(3);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 35: SLTI
prepare("035 SLTI");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h8000a193;
execute(3);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 36: SLTI
prepare("036 SLTI");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h7ff0a193;
execute(3);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 37: SLTIU
prepare("037 SLTIU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'hfff0b193;
execute(3);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 38: SLTIU
prepare("038 SLTIU");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h8000b193;
execute(3);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 39: SLTIU
prepare("039 SLTIU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h7ff0b193;
execute(3);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 40: XORI
prepare("040 XORI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'hfff0c193;
execute(3);
check_reg(3,32'h7ffffffe);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 41: XORI
prepare("041 XORI");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h8000c193;
execute(3);
check_reg(3,32'hedcbae78);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 42: XORI
prepare("042 XORI");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h7ff0c193;
execute(3);
check_reg(3,32'hfffff800);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 43: ORI
prepare("043 ORI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'hfff0e193;
execute(3);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 44: ORI
prepare("044 ORI");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h8000e193;
execute(3);
check_reg(3,32'hfffffe78);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 45: ORI
prepare("045 ORI");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h7ff0e193;
execute(3);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 46: ANDI
prepare("046 ANDI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'hfff0f193;
execute(3);
check_reg(3,32'h80000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 47: ANDI
prepare("047 ANDI");
dut.imem.RAM[0]=32'h123450b7;
dut.imem.RAM[1]=32'h67808093;
dut.imem.RAM[2]=32'h8000f193;
execute(3);
check_reg(3,32'h12345000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 48: ANDI
prepare("048 ANDI");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h7ff0f193;
execute(3);
check_reg(3,32'h000007ff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 49: SLLI
prepare("049 SLLI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00009193;
execute(3);
check_reg(3,32'h80000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 50: SLLI
prepare("050 SLLI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h00109193;
execute(3);
check_reg(3,32'h00000002);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 51: SLLI
prepare("051 SLLI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h01f09193;
execute(3);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 52: SRLI
prepare("052 SRLI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h0000d193;
execute(3);
check_reg(3,32'h80000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 53: SRLI
prepare("053 SRLI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h0010d193;
execute(3);
check_reg(3,32'h40000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 54: SRLI
prepare("054 SRLI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h01f0d193;
execute(3);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 55: SRAI
prepare("055 SRAI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h4000d193;
execute(3);
check_reg(3,32'h80000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 56: SRAI
prepare("056 SRAI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h4010d193;
execute(3);
check_reg(3,32'hc0000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 57: SRAI
prepare("057 SRAI");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00108093;
dut.imem.RAM[2]=32'h41f0d193;
execute(3);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 58: LUI_AUIPC
prepare("058 LUI_AUIPC");
dut.imem.RAM[0]=32'habcde0b7;
dut.imem.RAM[1]=32'h00108113;
dut.imem.RAM[2]=32'h00001197;
dut.imem.RAM[3]=32'h00118213;
execute(4);
check_reg(1,32'habcde000);
check_reg(2,32'habcde001);
check_reg(3,32'h00001008);
check_reg(4,32'h00001009);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 59: MUL
prepare("059 MUL");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h022081b3;
execute(5);
check_reg(3,32'hffffffeb);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 60: MUL
prepare("060 MUL");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h022081b3;
execute(5);
check_reg(3,32'hffffffeb);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 61: MUL
prepare("061 MUL");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h022081b3;
execute(5);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 62: MUL
prepare("062 MUL");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h022081b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 63: MUL
prepare("063 MUL");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h022081b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 64: MULH
prepare("064 MULH");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h022091b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 65: MULH
prepare("065 MULH");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h022091b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 66: MULH
prepare("066 MULH");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h022091b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 67: MULH
prepare("067 MULH");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h022091b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 68: MULH
prepare("068 MULH");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h022091b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 69: MULHSU
prepare("069 MULHSU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h0220a1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 70: MULHSU
prepare("070 MULHSU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h0220a1b3;
execute(5);
check_reg(3,32'h00000006);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 71: MULHSU
prepare("071 MULHSU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220a1b3;
execute(5);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 72: MULHSU
prepare("072 MULHSU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0220a1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 73: MULHSU
prepare("073 MULHSU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220a1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 74: MULHU
prepare("074 MULHU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h0220b1b3;
execute(5);
check_reg(3,32'h00000002);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 75: MULHU
prepare("075 MULHU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h0220b1b3;
execute(5);
check_reg(3,32'h00000006);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 76: MULHU
prepare("076 MULHU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220b1b3;
execute(5);
check_reg(3,32'h7fffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 77: MULHU
prepare("077 MULHU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0220b1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 78: MULHU
prepare("078 MULHU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220b1b3;
execute(5);
check_reg(3,32'hfffffffe);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 79: DIV
prepare("079 DIV");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h0220c1b3;
execute(5);
check_reg(3,32'hfffffffe);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 80: DIV
prepare("080 DIV");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h0220c1b3;
execute(5);
check_reg(3,32'hfffffffe);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 81: DIV
prepare("081 DIV");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220c1b3;
execute(5);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 82: DIV
prepare("082 DIV");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0220c1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 83: DIV
prepare("083 DIV");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220c1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 84: DIVU
prepare("084 DIVU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h0220d1b3;
execute(5);
check_reg(3,32'h55555553);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 85: DIVU
prepare("085 DIVU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h0220d1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 86: DIVU
prepare("086 DIVU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220d1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 87: DIVU
prepare("087 DIVU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0220d1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 88: DIVU
prepare("088 DIVU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220d1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 89: REM
prepare("089 REM");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h0220e1b3;
execute(5);
check_reg(3,32'hffffffff);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 90: REM
prepare("090 REM");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h0220e1b3;
execute(5);
check_reg(3,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 91: REM
prepare("091 REM");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220e1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 92: REM
prepare("092 REM");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0220e1b3;
execute(5);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 93: REM
prepare("093 REM");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220e1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 94: REMU
prepare("094 REMU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hff908093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00310113;
dut.imem.RAM[4]=32'h0220f1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 95: REMU
prepare("095 REMU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hffd10113;
dut.imem.RAM[4]=32'h0220f1b3;
execute(5);
check_reg(3,32'h00000007);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 96: REMU
prepare("096 REMU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220f1b3;
execute(5);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 97: REMU
prepare("097 REMU");
dut.imem.RAM[0]=32'h800000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h0220f1b3;
execute(5);
check_reg(3,32'h80000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 98: REMU
prepare("098 REMU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h0220f1b3;
execute(5);
check_reg(3,32'h00000000);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 99: LB
prepare("099 LB");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00000183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h00000001);
check_reg(4,32'h00000002);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 100: LB
prepare("100 LB");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00100183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h0000007f);
check_reg(4,32'h00000080);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 101: LB
prepare("101 LB");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00200183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'hffffffff);
check_reg(4,32'h00000000);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 102: LB
prepare("102 LB");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00300183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'hffffff80);
check_reg(4,32'hffffff81);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 103: LBU
prepare("103 LBU");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00004183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h00000001);
check_reg(4,32'h00000002);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 104: LBU
prepare("104 LBU");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00104183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h0000007f);
check_reg(4,32'h00000080);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 105: LBU
prepare("105 LBU");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00204183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h000000ff);
check_reg(4,32'h00000100);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 106: LBU
prepare("106 LBU");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00304183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h00000080);
check_reg(4,32'h00000081);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 107: LH
prepare("107 LH");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00001183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h00007f01);
check_reg(4,32'h00007f02);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 108: LH
prepare("108 LH");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00201183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'hffff80ff);
check_reg(4,32'hffff8100);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 109: LHU
prepare("109 LHU");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00005183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h00007f01);
check_reg(4,32'h00007f02);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 110: LHU
prepare("110 LHU");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00205183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h000080ff);
check_reg(4,32'h00008100);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 111: LW
prepare("111 LW");
dut.imem.RAM[0]=32'h80ff80b7;
dut.imem.RAM[1]=32'hf0108093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00002183;
dut.imem.RAM[4]=32'h00118213;
execute(5);
check_reg(3,32'h80ff7f01);
check_reg(4,32'h80ff7f02);
check_mem(0,32'h80ff7f01);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 112: SB
prepare("112 SB");
dut.imem.RAM[0]=32'hdeadc0b7;
dut.imem.RAM[1]=32'heef08093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h12345137;
dut.imem.RAM[4]=32'h6ab10113;
dut.imem.RAM[5]=32'h00200023;
dut.imem.RAM[6]=32'h00002183;
execute(7);
check_reg(3,32'hdeadbeab);
check_mem(0,32'hdeadbeab);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 113: SB
prepare("113 SB");
dut.imem.RAM[0]=32'hdeadc0b7;
dut.imem.RAM[1]=32'heef08093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h12345137;
dut.imem.RAM[4]=32'h6ab10113;
dut.imem.RAM[5]=32'h002000a3;
dut.imem.RAM[6]=32'h00002183;
execute(7);
check_reg(3,32'hdeadabef);
check_mem(0,32'hdeadabef);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 114: SB
prepare("114 SB");
dut.imem.RAM[0]=32'hdeadc0b7;
dut.imem.RAM[1]=32'heef08093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h12345137;
dut.imem.RAM[4]=32'h6ab10113;
dut.imem.RAM[5]=32'h00200123;
dut.imem.RAM[6]=32'h00002183;
execute(7);
check_reg(3,32'hdeabbeef);
check_mem(0,32'hdeabbeef);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 115: SB
prepare("115 SB");
dut.imem.RAM[0]=32'hdeadc0b7;
dut.imem.RAM[1]=32'heef08093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h12345137;
dut.imem.RAM[4]=32'h6ab10113;
dut.imem.RAM[5]=32'h002001a3;
dut.imem.RAM[6]=32'h00002183;
execute(7);
check_reg(3,32'habadbeef);
check_mem(0,32'habadbeef);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 116: SH
prepare("116 SH");
dut.imem.RAM[0]=32'hdeadc0b7;
dut.imem.RAM[1]=32'heef08093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h12345137;
dut.imem.RAM[4]=32'h6ab10113;
dut.imem.RAM[5]=32'h00201023;
dut.imem.RAM[6]=32'h00002183;
execute(7);
check_reg(3,32'hdead56ab);
check_mem(0,32'hdead56ab);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 117: SH
prepare("117 SH");
dut.imem.RAM[0]=32'hdeadc0b7;
dut.imem.RAM[1]=32'heef08093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h12345137;
dut.imem.RAM[4]=32'h6ab10113;
dut.imem.RAM[5]=32'h00201123;
dut.imem.RAM[6]=32'h00002183;
execute(7);
check_reg(3,32'h56abbeef);
check_mem(0,32'h56abbeef);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 118: SW
prepare("118 SW");
dut.imem.RAM[0]=32'hdeadc0b7;
dut.imem.RAM[1]=32'heef08093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h12345137;
dut.imem.RAM[4]=32'h6ab10113;
dut.imem.RAM[5]=32'h00202023;
dut.imem.RAM[6]=32'h00002183;
execute(7);
check_reg(3,32'h123456ab);
check_mem(0,32'h123456ab);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 119: BEQ
prepare("119 BEQ");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h00208663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 120: BEQ
prepare("120 BEQ");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00710113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h00208663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 121: BEQ
prepare("121 BEQ");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h00208663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 122: BNE
prepare("122 BNE");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h00209663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 123: BNE
prepare("123 BNE");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00710113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h00209663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 124: BNE
prepare("124 BNE");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h00209663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 125: BLT
prepare("125 BLT");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020c663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 126: BLT
prepare("126 BLT");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00710113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020c663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 127: BLT
prepare("127 BLT");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020c663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 128: BGE
prepare("128 BGE");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020d663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 129: BGE
prepare("129 BGE");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00710113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020d663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 130: BGE
prepare("130 BGE");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020d663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 131: BLTU
prepare("131 BLTU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020e663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 132: BLTU
prepare("132 BLTU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00710113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020e663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 133: BLTU
prepare("133 BLTU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020e663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 134: BGEU
prepare("134 BGEU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00010113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020f663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 135: BGEU
prepare("135 BGEU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00708093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'h00710113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020f663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000000);
check_reg(4,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 136: BGEU
prepare("136 BGEU");
dut.imem.RAM[0]=32'h000000b7;
dut.imem.RAM[1]=32'h00008093;
dut.imem.RAM[2]=32'h00000137;
dut.imem.RAM[3]=32'hfff10113;
dut.imem.RAM[4]=32'h00000193;
dut.imem.RAM[5]=32'h0020f663;
dut.imem.RAM[6]=32'h00100193;
dut.imem.RAM[7]=32'h00302023;
dut.imem.RAM[8]=32'h00900213;
execute(9);
check_reg(3,32'h00000001);
check_reg(4,32'h00000009);
check_mem(0,32'h00000001);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 137: BACKWARD_LOOP
prepare("137 BACKWARD_LOOP");
dut.imem.RAM[0]=32'h00300093;
dut.imem.RAM[1]=32'hfff08093;
dut.imem.RAM[2]=32'hfe009ee3;
dut.imem.RAM[3]=32'h00708113;
execute(4);
check_reg(1,32'h00000000);
check_reg(2,32'h00000007);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 138: JAL_FLUSH
prepare("138 JAL_FLUSH");
dut.imem.RAM[0]=32'h00c002ef;
dut.imem.RAM[1]=32'h00002023;
dut.imem.RAM[2]=32'h06300293;
dut.imem.RAM[3]=32'h00128313;
execute(4);
check_reg(5,32'h00000004);
check_reg(6,32'h00000005);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 139: JALR_FORWARD_BIT0
prepare("139 JALR_FORWARD_BIT0");
dut.imem.RAM[0]=32'h01100093;
dut.imem.RAM[1]=32'h000082e7;
dut.imem.RAM[2]=32'h00002023;
dut.imem.RAM[3]=32'h06300293;
dut.imem.RAM[4]=32'h00128313;
execute(5);
check_reg(5,32'h00000008);
check_reg(6,32'h00000009);
check_mem(0,32'ha5a5a5a5);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 140: LOAD_JALR
prepare("140 LOAD_JALR");
dut.imem.RAM[0]=32'h01800093;
dut.imem.RAM[1]=32'h00102023;
dut.imem.RAM[2]=32'h00002103;
dut.imem.RAM[3]=32'h000102e7;
dut.imem.RAM[4]=32'h00002223;
dut.imem.RAM[5]=32'h06300293;
dut.imem.RAM[6]=32'h00128313;
execute(7);
check_reg(5,32'h00000010);
check_reg(6,32'h00000011);
check_mem(1,32'ha5a5a5a5);
if(stalls!=1) begin errors=errors+1;$display("FAIL %s stalls=%0d expected=1",test_name,stalls);end
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 141: WB_ID
prepare("141 WB_ID");
dut.imem.RAM[0]=32'h00700093;
dut.imem.RAM[1]=32'h00000013;
dut.imem.RAM[2]=32'h00000013;
dut.imem.RAM[3]=32'h00108113;
execute(4);
check_reg(2,32'h00000008);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 142: FORWARD_PRIORITY
prepare("142 FORWARD_PRIORITY");
dut.imem.RAM[0]=32'h00100093;
dut.imem.RAM[1]=32'h00208093;
dut.imem.RAM[2]=32'h00408113;
dut.imem.RAM[3]=32'h00202023;
execute(4);
check_reg(1,32'h00000003);
check_reg(2,32'h00000007);
check_mem(0,32'h00000007);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
// Case 143: X0
prepare("143 X0");
dut.imem.RAM[0]=32'h07b00013;
dut.imem.RAM[1]=32'h00700093;
dut.imem.RAM[2]=32'h00102023;
dut.imem.RAM[3]=32'h00002003;
dut.imem.RAM[4]=32'h00900113;
execute(5);
check_reg(1,32'h00000007);
check_reg(2,32'h00000009);
cases_run=cases_run+1;if(errors==before_errors)$display("PASS %s",test_name);
$display("SUMMARY cases=%0d checks=%0d errors=%0d",cases_run,checks,errors);if(errors==0)$display("ALL TESTS PASSED");else $display("REGRESSION FAILED");$finish;end
initial begin #1000000;$display("FAIL global timeout");$finish;end
endmodule
