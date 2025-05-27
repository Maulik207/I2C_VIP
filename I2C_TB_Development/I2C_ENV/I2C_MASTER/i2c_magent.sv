
`ifndef I2C_MAGENT_UVM
`define I2C_MAGENT_UVM

class i2c_magent extends uvm_agent;

    //component
    i2c_msequencer mseqr_h;
    i2c_mdriver mdrv_h;
    i2c_mmonitor mmon_h;

    //-------------------------------------------------
    //env configuration handle
    //-------------------------------------------------
    //i2c_env_config env_config_h;
    uvm_active_passive_enum is_active=UVM_ACTIVE;
    
    //-------------------------------------------------
    //factory registration
    //-------------------------------------------------
    `uvm_component_utils(i2c_magent)
    //typedef uvm_component_registry#(i2c_magent,"i2c_magent")type_id;
    

    //-------------------------------------------------
    //externally defined task and function
    //-------------------------------------------------
    extern function new(string name="i2c_magent",uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass : i2c_magent

    //-------------------------------------------------
    //constructor
    //-------------------------------------------------
    function i2c_magent::new(string name="i2c_magent",uvm_component parent=null);
        super.new(name,parent);
    endfunction

    //-----------------------------------------------
    //build phase
    //-----------------------------------------------
    function void i2c_magent::build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase",UVM_LOW)                    

        if(is_active == UVM_ACTIVE)begin   //if(get_is_active()==UVM_ACTIVE)
            mseqr_h = i2c_msequencer::type_id::create("mseqr_h",this);
            mdrv_h = i2c_mdriver::type_id::create("mdrv_h",this);
        end
        mmon_h = i2c_mmonitor::type_id::create("mmon_h",this);
    endfunction

    //-----------------------------------------------
    //connect phase
    //-----------------------------------------------
    function void i2c_magent::connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"Inside connect_phase()", UVM_LOW)

        if(is_active == UVM_ACTIVE) //if(get_is_active()==UVM_ACTIVE)
            mdrv_h.seq_item_port.connect(mseqr_h.seq_item_export); //communication between the driver and sequencer
    endfunction

`endif
