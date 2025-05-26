
`ifndef I2C_ACTUAL_CALLBACK_UVM
`define I2C_ACTUAL_CALLBACK_UVM

//callback class code 
class user_callback extends driver_callback;

    int error;

    //-----------------------------------------
    //factory registration
    //-----------------------------------------
    `uvm_object_utils(user_callback)
    //typedef uvm_object_registry#(user_callback,"user_callback")type_id;
    

    //-----------------------------------------
    //constructor
    //-----------------------------------------
    function new(string name = "user_callback");
        super.new(name);
    endfunction

    //-----------------------------------------
    //pre_drive()
    //-----------------------------------------
    function pre_drive(ref i2c_mseq_item req); //call to the dummy methods are called callback
        
        `uvm_info("USER_CALLBACK", "Inside pre_drive() method", UVM_NONE)
        
        //-------------------------------------
        //change slv_addr
        //-------------------------------------
        /*
        error = $urandom_range(0,6);
        req.slv_addr ^= (1<<error); //xor....to change/flip the random bit/byte
        `uvm_info("USER_CALLBACK", $sformatf("Callback--->error=%0d slv_addr = %0b", error, req.slv_addr), UVM_LOW)
        */
        
        //-------------------------------------
        //change wr condition into read condition
        //-------------------------------------
        /*
        req.rd_wr=1;  //to change the write condition into read condition
        req.size_while_read_write=5;
        `uvm_info("USER_CALLBACK", $sformatf("Callback--->rd_wr = %0b size_while_read_write=%0d", req.rd_wr, req.size_while_read_write), UVM_LOW)        
        */
        
        //--------------------------------------
        //changing the data on specific index
        //--------------------------------------
        /*
        int error_index;
        byte error_value;

        //generate the random index within queue range
        if(req.data.size() > 0)begin
            error_index = $urandom_range(0, req.data.size() - 1); //to select the random index
            error_value = $urandom_range(0, 255); //to generate the random byte value

            req.data[error_index] ^= error_value; //xor to inject error...changing the data 

            `uvm_info("USER_CALLBACK", "Inside the pre_drive() method", UVM_LOW)
            `uvm_info("USER_CALLBACK", $sformatf("Callback--->Injected error at the index=[%0d]::modified data=[%0h]", error_index, req.data[error_index]), UVM_LOW)
        end
        else begin
            `uvm_warning("USER_CALLBACK","****data queue is empty cannot inject the error****")
        end
        */
    endfunction

    //------------------------------------------
    //post_drive()
    //------------------------------------------
    function post_drive();
        `uvm_info("USER_CALLBACK", "Inside post_drive() method", UVM_NONE)
    endfunction

endclass: user_callback

`endif
