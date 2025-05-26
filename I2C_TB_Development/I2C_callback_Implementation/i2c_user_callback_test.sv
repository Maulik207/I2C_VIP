
`ifndef I2C_USER_CALLBACK_TEST_UVM
`define I2C_USER_CALLBACK_TEST_UVM

class i2c_user_callback_test extends i2c_test;

    //declare the callback
    user_callback callback_1;

    //-------------------------------------------
    //factory registration
    //-------------------------------------------
    `uvm_component_utils(i2c_user_callback_test)
    //typedef uvm_component_registry#(i2c_user_callback_test,"i2c_user_callback_test")type_id;
    

    //-------------------------------------------
    //constructor
    //-------------------------------------------
    function new(string name = "i2c_user_callback_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    //-------------------------------------------
    //build phase
    //-------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //create the callback 
        callback_1 = user_callback::type_id::create("callback_1",this);

        //To execute callback method...register the callback object to the driver using 'add' method
        //uvm_callbacks#(i2c_mdriver,driver_callback)::add(env_h.magent_h.mdrv_h,callback_1);
    endfunction

    //-------------------------------------------
    //run phase()
    //-------------------------------------------
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);

        `uvm_info(get_type_name(),"Inside the run_phase of user_callback_test", UVM_LOW)
	      //write_seq_h.start(env_h.magent_h.mseqr_h);  //sequence pati gai pchi callback execute-or-call karine su phaydo etle ee pchi sequence start kari    
      
        //uvm_callbacks#(i2c_smonitor,driver_callback)::add(env_h.sagent_h.smon_h,callback_1);  //khali hierarchy print thase
        `uvm_callback#(i2c_mdriver,driver_callback)::add(env_h.magent_h.mdrv_h,callback_1); //khali hierarchy print karse
        write_seq_h.start(env_h.magent_h.mseqr_h);        
        
        phase.drop_objection(this);
    endtask

endclass: i2c_user_callback_test

`endif
