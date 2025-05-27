
package my_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "i2c_mseq_item.sv"
    `include "i2c_base_sequence.sv"
    `include "i2c_msequences.sv"
    `include "i2c_msequencer.sv"
    `include "i2c_env_config.sv"
   
    `include "i2c_callback.sv"
    
    `include "i2c_mdriver.sv"
    `include "i2c_sdriver.sv"
    `include "i2c_ssequencer.sv"
    `include "i2c_mmonitor.sv"
    `include "i2c_smonitor.sv"
    `include "i2c_magent.sv"
    `include "i2c_sagent.sv"

   `include "i2c_scoreboard.sv"
   
   `include "i2c_cov.sv"
   `include "i2c_environment.sv"
   `include "i2c_test.sv"
   `include "i2c_read_test.sv"
   `include "i2c_write_test.sv"
   
   `include "i2c_actual_callback.sv"
   `include "i2c_user_callback_test.sv"
   
   `include "i2c_wr_rd_test.sv"
   `include "i2c_rd_wr_test.sv"
   `include "i2c_inv_addr_test.sv"
endpackage
