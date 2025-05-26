
`ifndef I2C_TEST_UVM
`define I2C_TEST_UVM

class i2c_test extends uvm_test;
    
    //-------------------------------------------
    //factory registration
    //-------------------------------------------
    `uvm_component_utils(i2c_test)
    //typedef uvm_component_registry#(i2c_test,"i2c_test")type_id;
    
    //handle to component and object
    i2c_environment env_h;
    i2c_base_sequence base_seq_h;
    i2c_read_sequence read_seq_h;
    i2c_write_sequence write_seq_h;
    i2c_wr_rd_sequence wr_rd_seq_h;
    i2c_rd_wr_sequence rd_wr_seq_h;  
    i2c_inv_addr_sequence inv_addr_seq_h;
    i2c_env_config env_config_h;

    //-------------------------------------------
    //externally defined task and function
    //-------------------------------------------
    extern function new(string name="i2c_test",uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
    extern function void end_of_elaboration_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass: i2c_test

    //-------------------------------------------
    //constructor
    //-------------------------------------------
    function i2c_test::new(string name="i2c_test",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    //-------------------------------------------
    //build phase
    //-------------------------------------------
    function void i2c_test::build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase",UVM_LOW)    
        
        env_h = i2c_environment::type_id::create("env_h",this);
        base_seq_h = i2c_base_sequence::type_id::create("base_seq_h");
        read_seq_h =i2c_read_sequence :: type_id :: create("read_seq_h");
        write_seq_h =i2c_write_sequence :: type_id :: create("write_seq_h");
        inv_addr_seq_h =i2c_inv_addr_sequence :: type_id :: create ("inv_addr_seq_h");
        wr_rd_seq_h = i2c_wr_rd_sequence :: type_id :: create ("wr_rd_seq_h");
        rd_wr_seq_h = i2c_rd_wr_sequence :: type_id :: create ("rd_wr_seq_h");
        env_config_h = i2c_env_config::type_id::create("env_config_h");

	    uvm_config_db#(i2c_env_config)::set(null,"*","env_config_h",env_config_h);
    endfunction

    //-------------------------------------------
    //end of elaboration
    //-------------------------------------------
    function void i2c_test::end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        `uvm_info(get_type_name(),"Inside end_of_elaboaration_phase()", UVM_LOW)
        
        uvm_top.print_topology();
    endfunction

    //-------------------------------------------
    //run phase
    //-------------------------------------------
    task i2c_test::run_phase(uvm_phase phase);
        //super.run_phase(phase);
        `uvm_info(get_type_name(),"Inside run_phase()", UVM_LOW)

        phase.raise_objection(this);
        `uvm_info(get_type_name(),"Base test after raise objection", UVM_LOW)
        //seq.start(env.magent.mseqr);
        `uvm_info(get_type_name(),"Base test before drop objection", UVM_LOW)
        phase.drop_objection(this);

    endtask

`endif

