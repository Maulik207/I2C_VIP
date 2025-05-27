
`ifndef I2C_COV_UVM
`define I2C_COV_UVM

class i2c_cov extends uvm_subscriber#(i2c_mseq_item);

    //transaction
    i2c_mseq_item trans;

    bit [7:0] sampled_data[5];

    //---------------------------------------
    //factory registration
    //---------------------------------------
    `uvm_component_utils(i2c_cov)
    //typedef uvm_component_registry#(i2c_cov,"i2c_cov")type_id;
    

    //---------------------------------------
    //covergroup--------covgrp
    //---------------------------------------
    covergroup covgrp;

        option.per_instance = 1;

        //cover slave address(7 bits:: 0 to 127)
        slv_addr_cp: coverpoint trans.slv_addr
        {
            //option.auto_bin_max = 16; 

            //bins slv_addr = {[104:111]};
            //illegal_bins ignore_slv_addr = {[0:103], [112:127]};

            bins range_1 = {[1:16]};
            bins range_2 = {[17:32]};
            bins range_3 = {[33:48]};
            bins range_4 = {[49:64]};
            bins range_5 = {[65:80]};
            bins range_6 = {[89:96]};
            bins range_7 = {[97:112]};
            bins range_8 = {[113:127]};
        }

        //cover rd/wr
        rd_wr_cp: coverpoint trans.rd_wr
        {
            bins write = {1'b0};
            bins read = {1'b1};
        }

        //cover repeated start
        rpt_start_cp: coverpoint trans.repeated_start
        {
            bins no_restart = {1'b0};
            bins restart = {1'b1};
        }

        //cover size of data being read/write
        /*
        size_cp: coverpoint trans.size_while_read_write{
            bins small_size = {[0:9]};
            //bins medium_size = {[4:7]};
            //bins large_size = {[8:15]};
            //ignore_bins size_ib = {[4:15]};
            illegal_bins size_ib = default;  //default can work with normal or illegal bins...not with ignore
        }*/

        //cover data values if queue is not empty
        /*
        data_cp: coverpoint trans.data.size(){
            //option.auto_bin_max = 2;
            bins in_range = {[1:10]};
            //illegal_bins others = default;
        }
        */

        //per-element coverage of 5-element queue
        /*
        data_0_cp: coverpoint sampled_data[0] { bins val[] = {[0:255]}; }
        data_1_cp: coverpoint sampled_data[1] { bins val[] = {[0:255]}; }
        data_2_cp: coverpoint sampled_data[1] { bins val[] = {[0:255]}; }
        data_3_cp: coverpoint sampled_data[1] { bins val[] = {[0:255]}; }
        data_4_cp: coverpoint sampled_data[1] { bins val[] = {[0:255]}; }
        */


        //CROSS COVERAGE
        cross_cp: cross slv_addr_cp, rd_wr_cp, rpt_start_cp;

    endgroup

    //----------------------------------------
    //constructor
    //----------------------------------------
    function new(string name = "i2c_cov", uvm_component parent = null);
        super.new(name,parent);
        trans = i2c_mseq_item::type_id::create("trans");
        covgrp = new();
    endfunction

    //-----------------------------------------
    //write()
    //-----------------------------------------
    virtual function void write(input i2c_mseq_item t);
        $display("Printing the coverage packet");
        t.print();
        trans = t;

        //data queue elements
        /*
        foreach(t.data[i])begin
            if(i<5)
                sampled_data[i] = t.data[i];
        end
        */
       
        covgrp.sample();
        `uvm_info(get_type_name(),$sformatf("---cvg---%0f", covgrp.get_coverage()), UVM_LOW)
    endfunction

endclass: i2c_cov

`endif
