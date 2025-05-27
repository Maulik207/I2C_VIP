
`ifndef I2C_SAGENT_UVM
`define I2C_SAGENT_UVM

class i2c_sagent extends uvm_agent;

    //component handle
    i2c_ssequencer sseqr_h;
    i2c_sdriver sdrv_h;
    i2c_smonitor smon_h;

    uvm_active_passive_enum is_active= UVM_ACTIVE;

    //----------------------------------------------
    //factory registration
    //----------------------------------------------
    `uvm_component_utils(i2c_sagent)
    //typedef uvm_component_registry#(i2c_sagent,"i2c_sagent")type_id;
    
    //----------------------------------------------
    //constructor
    //----------------------------------------------
    function new(string name= "i2c_sagent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    //----------------------------------------------
    //build phase
    //----------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase()",UVM_LOW)            

        if(is_active == UVM_ACTIVE)begin //OR if(get_is_active==UVM_ACTIVE)
            sseqr_h = i2c_ssequencer::type_id::create("sseqr",this);
            sdrv_h = i2c_sdriver::type_id::create("sdrv_h",this);
        end
        smon_h = i2c_smonitor::type_id::create("smon_h",this);
    endfunction

    //----------------------------------------------
    //connect phase
    //----------------------------------------------
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(),"Inside connect_phase()", UVM_LOW)

        if(is_active == UVM_ACTIVE)
            sdrv_h.seq_item_port.connect(sseqr_h.seq_item_export);

    endfunction

endclass : i2c_sagent

`endif
