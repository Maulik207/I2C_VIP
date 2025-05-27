
`ifndef I2C_ENV_CONFIG_UVM
`define I2C_ENV_CONFIG_UVM

class i2c_env_config extends uvm_object;

    //------------------------------------------------
    //factory registration
    //------------------------------------------------
    `uvm_object_utils(i2c_env_config)
    //typedef uvm_object_registry#(i2c_env_config,"i2c_env_config")type_id;
    

     bit [6:0] slv_addr = 7'h6F;
    
     uvm_active_passive_enum is_active=UVM_ACTIVE;

    //-------------------------------------------------
    //externally defined function
    //-------------------------------------------------
    extern function new(string name="i2c_env_config");

endclass : i2c_env_config

    //-------------------------------------------------
    //constructor
    //-------------------------------------------------
    function i2c_env_config::new(string name="i2c_env_config");
        super.new(name);
    endfunction

`endif
