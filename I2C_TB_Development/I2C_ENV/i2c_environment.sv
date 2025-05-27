
`ifndef I2C_ENVIRONMENT_UVM
`define I2C_ENVIRONMENT_UVM

class i2c_environment extends uvm_env;

    //handle
    i2c_magent magent_h;
    i2c_sagent sagent_h;
    i2c_scoreboard scb_h;
    i2c_cov covr;

    //-------------------------------------------
    //factory registration
    //-------------------------------------------
    `uvm_component_utils(i2c_environment)
    //typedef uvm_component_registry#(i2c_environment,"i2c_environment")type_id;

    //-------------------------------------------
    //externally defined task and function
    //-------------------------------------------
    extern function new(string name="i2c_environment", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass: i2c_environment

    //-------------------------------------------
    //constructor
    //-------------------------------------------
    function i2c_environment::new(string name="i2c_environment", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    //-------------------------------------------
    //build phase
    //-------------------------------------------
    function void i2c_environment::build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase",UVM_LOW)    
        
        covr = i2c_cov::type_id::create("covr",this);
        magent_h = i2c_magent::type_id::create("magent_h",this);
        sagent_h = i2c_sagent::type_id::create("sagent_h",this);
        scb_h = i2c_scoreboard::type_id::create("scb_h",this);

    endfunction

    //-------------------------------------------
    //connect phase
    //-------------------------------------------
    function void i2c_environment::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"Inside connect_phase()", UVM_LOW)
        
        magent_h.mmon_h.master_mon_send.connect(scb_h.master_mon_receive); //monitor port is connected with the scoreboard analysis imp
        magent_h.mmon_h.master_mon_send.connect(covr.analysis_export); 

        sagent_h.smon_h.slave_mon_send.connect(scb_h.slave_mon_receive);
        sagent_h.smon_h.slave_mon_send.connect(covr.analysis_export);
    endfunction

`endif

