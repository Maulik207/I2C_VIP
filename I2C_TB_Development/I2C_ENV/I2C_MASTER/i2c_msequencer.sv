
`ifndef I2C_MSEQUENCER_UVM
`define I2C_MSEQUENCER_UVM

class i2c_msequencer extends uvm_sequencer#(i2c_mseq_item);

    
    //factory registration
    `uvm_component_utils(i2c_msequencer)
    //typedef uvm_component_registry#(i2c_msequencer,"i2c_msequencer")type_id;
    

    //constructor
    function new(string name="i2c_msequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction

endclass : i2c_msequencer

`endif

