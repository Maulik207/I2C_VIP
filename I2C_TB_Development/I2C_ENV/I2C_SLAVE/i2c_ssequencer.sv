
`ifndef I2C_SSEQUENCER_UVM
`define I2C_SSEQUENCER_UVM

class i2c_ssequencer extends uvm_sequencer#(i2c_mseq_item);

    //------------------------------------------
    //factory registration
    //------------------------------------------
    `uvm_component_utils(i2c_ssequencer)
    //typedef uvm_component_registry#(i2c_ssequencer,"i2c_ssequencer")type_id;
    

    //------------------------------------------
    //constructor
    //------------------------------------------
    function new(string name="i2c_ssequencer", uvm_component parent =null);
        super.new(name,parent);
    endfunction

endclass: i2c_ssequencer

`endif
