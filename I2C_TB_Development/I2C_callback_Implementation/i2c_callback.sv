
`ifndef I2C_CALLBACK_UVM
`define I2C_CALLBACK_UVM

//user defined callback class
class driver_callback extends uvm_callback;

    //-----------------------------------------
    //factory registration
    //-----------------------------------------
    `uvm_object_utils(driver_callback)
    //typedef uvm_object_registry#(driver_callback,"driver_callback")type_id;
    

    //-----------------------------------------
    //constructor
    //-----------------------------------------
    function new(string name = "driver_callback");
        super.new(name);
    endfunction

    //-----------------------------------------
    //callback methods
    //-----------------------------------------
    virtual function pre_drive(ref i2c_mseq_item req);
    endfunction

    virtual function post_drive();
    endfunction

endclass: driver_callback

`endif
