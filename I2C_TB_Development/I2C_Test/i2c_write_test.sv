
`ifndef I2C_WRITE_TEST_UVM
`define I2C_WRITE_TEST_UVM

class i2c_write_test extends i2c_test;
  
  //----------------------------------------------
  //factory registration
  //----------------------------------------------
  `uvm_component_utils(i2c_write_test)
  //typedef uvm_component_registry#(i2c_write_test,"i2c_write_test")type_id;
  
  //----------------------------------------------
  //constructor
  //----------------------------------------------
  function new(string name="i2c_write_test",uvm_component parent=null);
	super.new(name,parent);
  endfunction 

  //----------------------------------------------
  //build phase
  //----------------------------------------------
  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(),"Inside build_phase",UVM_LOW)    
  endfunction 
  
  //----------------------------------------------
  //run phase()
  //----------------------------------------------
  task run_phase(uvm_phase phase);
	//super.run_phase(phase);
    repeat(2)begin
	    phase.raise_objection(this);
        //#10us;
	    `uvm_info(get_type_name(),"i2c_write_test raise objection",UVM_LOW)
	    write_seq_h.start(env_h.magent_h.mseqr_h);
        `uvm_info(get_type_name(),"i2c_write_test drop objection",UVM_LOW)
        //#10us;
	    phase.drop_objection(this);
    end
  endtask
  
endclass  : i2c_write_test

`endif
