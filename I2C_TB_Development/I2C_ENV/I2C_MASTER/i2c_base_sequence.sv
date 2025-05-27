
`ifndef I2C_BASE_SEQUENCE_UVM
`define I2C_BASE_SEQUENCE_UVM

class i2c_base_sequence extends uvm_sequence#(i2c_mseq_item);

    //---------------------------------
    //factory registration
    //---------------------------------
    `uvm_object_utils(i2c_base_sequence)
    //typedef uvm_object_registry#(i2c_base_sequence,"i2c_base_sequence")type_id;

    //---------------------------------
    //constructor
    //---------------------------------
    function new(string name = "i2c_base_sequence");
        super.new(name);
    endfunction

endclass : i2c_base_sequence

`endif
