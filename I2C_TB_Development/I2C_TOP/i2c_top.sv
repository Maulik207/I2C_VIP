
`include "uvm_macros.svh"
`include "i2c_interface.sv"

`include "my_pkg.sv"

//`define STD_CLK           10         //us
//`define FAST_CLK          2.5us      //us
//`define FAST_PLUS_CLK     1us        //us
//`define HIGH_CLK          294ns      //ns
//`define ULTRA_F_CLK       200ns      //ns

//`timescale 1us/1ps
module top;

    import uvm_pkg::*;
    import my_pkg::*;

   
    tri1 scl;
    tri1 sda;

    logic clock=0;
    //clock generation
    always #5us clock = ~clock; //standard mode..10us
    /* 
    forever begin
        clock = ~clock;
        #(`STD_CLK*1ns)/2);
    end*/

    //interface handle
    intf vif(.sda(sda));
    assign vif.scl = clock;
   

    //set interface
    initial begin
        uvm_config_db#(virtual intf)::set(null,"*","vif",vif);
        `uvm_info("top", "uvm_config_db set for uvm_test", UVM_LOW)
    end

    //run test
    initial begin
        //run_test("");
        run_test("i2c_write_test");
        //run_test("user_callback_test");
        //run_test("i2c_read_test");
        //run_test("i2c_rd_wr_test");
        //run_test("i2c_wr_rd_test");
        //run_test("i2c_inv_addr_test");
        $finish();
    end

endmodule
