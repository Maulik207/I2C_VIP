
`ifndef I2C_MDRIVER_UVM
`define I2C_MDRIVER_UVM

class i2c_mdriver extends uvm_driver#(i2c_mseq_item);
    
    //--------------------------------------------
    //factory registration
    //--------------------------------------------
    `uvm_component_utils(i2c_mdriver)
    //typedef uvm_component_registry#(i2c_mdriver,"i2c_mdriver")type_id;
    
    //--------------------------------------------
    //interface handle
    //--------------------------------------------
    virtual intf vif;

    //write packets
    bit [3:0] last_wr_size;

    //---------------------------------------------
    //environment configuration instance
    //---------------------------------------------
    i2c_env_config env_config_h;

    //---------------------------------------------
    //register callback
    //---------------------------------------------
    `uvm_register_cb(i2c_mdriver,driver_callback)

    //---------------------------------------------
    //constructor
    //---------------------------------------------
    function new(string name="i2c_mdriver", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    //---------------------------------------------
    //build_phase
    //---------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase",UVM_LOW)            

        //get interface handle
        if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(), "No virtual interface specified for i2c_master_driver")

        //env config
        if(!uvm_config_db #(i2c_env_config)::get(this,"","env_config_h",env_config_h))
            `uvm_fatal(get_type_name()," MASTER-DRV:: env configuration is not set")
        
    endfunction : build_phase
    

    //-------------------------------------------
    //run phase
    //-------------------------------------------
    task run_phase(uvm_phase phase);
      //reset();  //still working
        forever begin
            `uvm_info(get_type_name(),"Inside run_phase()", UVM_LOW)
            //reset();
            seq_item_port.get_next_item(req);
            -> vif.trigger;

            //----------------------------------------------------------
            //injecting the error and changing the write opeartion into read operation
            //----------------------------------------------------------
            //`uvm_info("DRV-CALLBACK", $sformatf("Before callback req.rd_wr--->%0b", req.rd_wr), UVM_LOW)

            //----------------------------------------------------------
            //injecting the error and changing the slv_addr
            //----------------------------------------------------------
            //`uvm_info("DRV-CALLBACK", $sformatf("Before callback req.slv_addr---->%0b", req.slv_addr), UVM_LOW)

            //----------------------------------------------------------
            //injecting the error and changing the data onto specific index
            //---------------------------------------------------------- 
            /*
            foreach(req.data[i])begin
                `uvm_info("DRV-CALLBACK", $sformatf("Before callback req.data[%0d] = %0h", i, req.data[i]), UVM_LOW)
            end
            */
            
            //----------------------------------------------------------
            //call the callback methods......callback hook
            //----------------------------------------------------------
            //`uvm_do_callbacks(i2c_mdriver,driver_callback,pre_drive(req));
           
            //////////////////////////////////////////////////////////////////
                                        //drive()
            drive_start(req);
            rd_wr_ack_nack_operation(req);
            ///////////////////////////////////////////////////////////////////

            //---------------------------------------------------------
            //call the callback methods......callback hook
            //---------------------------------------------------------
            //`uvm_do_callbacks(i2c_mdriver,driver_callback,post_drive());

            seq_item_port.item_done();
        end
    endtask : run_phase

    //---------------------------------------------
    //reset task
    //---------------------------------------------
    task reset();
        `uvm_info("MDRIVER","Inside Reset", UVM_LOW)
        vif.reset = 1;
        vif.to_sda = 1;
        
        repeat(2)@(posedge vif.scl);
        vif.reset = 0;
        `uvm_info("MDRIVER", "Reset Done", UVM_LOW)
    endtask : reset

    //---------------------------------------------
    //drive start--->send start bit
    //---------------------------------------------
    task drive_start(input i2c_mseq_item req);
        //vif.sda ='b1;  //default '1' che
        @(posedge vif.scl);
        #2us;
        vif.to_sda <= 0;
        `uvm_info(get_type_name(), $sformatf("drive_start():: Driven START condition"), UVM_LOW)
    endtask: drive_start

    //---------------------------------------------
    //         rd/wr and ACK/NACK
    //---------------------------------------------
    task rd_wr_ack_nack_operation(input i2c_mseq_item req);  //input argument
        bit ack;//local variable
        send_7bit_addr(req.slv_addr); //task--->send slv addr

        @(negedge vif.scl);
        #2us;
        vif.to_sda <= req.rd_wr; //rd_wr bit
        `uvm_info(get_type_name(), $sformatf("rd_wr_ack_nack_operation():: Drive Read/Write Bit = %0b", req.rd_wr), UVM_LOW)

        //ACK NACK condition
        @(negedge vif.scl);
        #1us;
        vif.to_sda <= 1'bz;
        `uvm_info(get_type_name(),"rd_wr_ack_nack_operation():: Master Releasing the bus and Waiting for ACK from Slave ", UVM_LOW)
    
        @(posedge vif.scl);  //ana mate vicharvu padse
        ack = vif.to_sda; //ack bit
        `uvm_info(get_type_name(),$sformatf("rd_wr_ack_nack_operation():: Master Receives ACK-->[%0b] from Slave ",ack), UVM_LOW)
    
        if(ack) begin
            `uvm_info(get_type_name(),$sformatf("rd_wr_ack_nack_operation():: Master Receives NACK from Slave = [%0b] ", ack), UVM_LOW)
            `uvm_info(get_type_name(),"rd_wr_ack_nack_operation():: Initiates Stop ", UVM_LOW) 
            drive_stop();
            $finish();
        end
    
        if ( !ack && (req.rd_wr == 0)) begin
            `uvm_info(get_type_name(),$sformatf("rd_wr_ack_nack_operation():: Write Operation "), UVM_LOW)
            drive_write_data(req.data); //write task called
        end
    
        if ( !ack && (req.rd_wr == 1)) begin
            `uvm_info(get_type_name(),$sformatf("rd_wr_ack_nack_operation():: Read Operation "), UVM_LOW)
            get_read_data(); //read task called
        end
        
    endtask : rd_wr_ack_nack_operation

    //------------------------------------------
    //slave address
    //------------------------------------------
    task send_7bit_addr(input bit[6:0] addr);
        `uvm_info(get_type_name(),$sformatf("send_7bit_addr()::Slave address going to send=%0h",addr), UVM_LOW)

        for(int i=6; i>=0; i--)begin
            //#3us;  //useless bcoz it is waiting for negedge only
            @(negedge vif.scl);
            #2us;
            vif.to_sda <= addr[i];
            `uvm_info(get_type_name(),$sformatf("send_7bit_addr():: Driven Slave Address bit[%0d] = %0b ", i, addr[i]),UVM_LOW)
        end
        `uvm_info(get_type_name(),$sformatf("send_7bit_addr():: Driven Slave Address = %0h ",addr),UVM_LOW)

    endtask : send_7bit_addr       

    //-------------------------------------------
    //Master writing data to slave
    //-------------------------------------------
    task drive_write_data(input bit [7:0] data[$]);
        logic ack;
        bit [7:0] temp_data;
        last_wr_size = data.size();
        req.print();

        for (int i=0; i<data.size(); i++) begin 
            `uvm_info(get_type_name(), $sformatf("drive_write_data():: 'Driving' Write Data [%0d] = %0h ", i, data[i]), UVM_LOW)
        end
    
        while (data.size() > 0) begin   //size=2 che.....index--->0,1 che 
            temp_data = data.pop_front();  //pehla--->data[0]...pchi--->data[1].....data[n]
      
            for(int i=7; i>=0; i--) begin //msb first
                @(negedge vif.scl);
                #2us;
                vif.to_sda <= temp_data[i];
                `uvm_info(get_type_name(),$sformatf("drive_write_data():: Driving Bits of Write Data [%0d] = %0b ",i , temp_data[i]),UVM_LOW)
            end
      
            `uvm_info(get_type_name(),$sformatf("drive_write_data():: 'Driven' Write data successfully = %0h ", temp_data),UVM_LOW)
      
            @(negedge vif.scl);  //waiting for ack
            #1us;
            vif.to_sda <= 1'bz;
            `uvm_info(get_type_name(),"drive_write_data():: Master Releasing the bus and Waiting/Sampling ACK from Slave", UVM_LOW)
            
            @(posedge vif.scl);  //received ack from slave 
            ack = vif.to_sda;
            `uvm_info(get_type_name(), $sformatf("drive_write_data():: Received ACK/NACK bit = %0b", ack), UVM_LOW)
      
            if(ack) begin
                `uvm_info(get_type_name(),"drive_write_data():: Receives NACK from Slave ", UVM_LOW)
                `uvm_info(get_type_name(),"drive_write_data():: Initiates Stop ", UVM_LOW)
                drive_stop();
                $finish();
            end
            
        end
   
        if(req.repeated_start == 0 ) begin //check--->answer: No repeated start then generate STOP condition
            `uvm_info(get_type_name(),"drive_write_data(): Write Sequencce - Sent All The Data And Driving Stop ", UVM_LOW)
            drive_stop();
            //$finish();
        end 

        if(req.repeated_start == 1) begin
            `uvm_info(get_type_name(), "drive_write_data(): REPEATED_START condition found", UVM_LOW)
        end
        

    endtask : drive_write_data

    //--------------------------------------------
    //get read data
    //--------------------------------------------
    
    task get_read_data();
        logic [7:0] data;
        last_wr_size = req.size_while_read_write;
        req.print();
        
        `uvm_info(get_type_name(),"get_read_data():: Master will read data from slave", UVM_LOW)

        for(int i=0; i<last_wr_size; i++)begin
            for(int j=7; j>=0; j--)begin
                @(posedge vif.scl);
                data[j] = vif.to_sda;
                `uvm_info(get_type_name(),$sformatf("get_read_data():: sampling read data bit[%0d] = %0b",j, data[j]), UVM_LOW)
            end

            `uvm_info(get_type_name(), $sformatf("get_read_data():: received read byte data = %0h", data), UVM_LOW)            

            @(negedge vif.scl);
            if(i == (last_wr_size - 1))begin
                `uvm_info(get_type_name(),$sformatf("get_read_data():: Number of read byte from slave = %0d", last_wr_size), UVM_LOW)
                if(req.repeated_start == 0)begin
                    #2us;
                    vif.to_sda = 1'b1; //NACK for the last byte
                    `uvm_info(get_type_name(),"get_read_data():: Read sequence...last data byte so drive NACK and then driving STOP", UVM_LOW)
                    drive_stop();
                    //$finish();
                end
                else begin
                    #2us;
                    vif.to_sda = 1'b1;  //NACK for the last byte
                    `uvm_info(get_type_name(), "get_read_data():: Read sequence...last data byte so drive NACK and then REPEAT_START", UVM_LOW)
                    #3us;
                    //@(posedge vif.scl);
                end
            end
            else begin
                #2us;
                `uvm_info(get_type_name(),"get_read_data():: driving ACK from MASTER", UVM_LOW)
                vif.to_sda = 1'b0;
                @(negedge vif.scl);
                `uvm_info(get_type_name(),"get_read_data():: Master is realising the bus ", UVM_LOW)
                vif.to_sda = 1'bz;
            end
        end

    endtask : get_read_data 

    //------------------------------------------
    //send stop bit
    //------------------------------------------
    task drive_stop();
        `uvm_info(get_type_name(),"drive_stop()---->MASTER-DRV initiating STOP condition", UVM_LOW)
        @(negedge vif.scl);
        #2us;
        vif.to_sda <= 0;
        `uvm_info(get_type_name(), "drive_stop():: making sda zero", UVM_LOW)        
        @(posedge vif.scl);
        #2us;
        vif.to_sda <= 1'bz; //check--->answer: it will automatically pulled up(1)
        `uvm_info(get_type_name(), "drive_stop():: driver releasing bus", UVM_LOW)       
        @(posedge vif.scl); //just to make sure that if any process is remaining then it must be completed....bcoz $finish is called later on
        `uvm_info(get_type_name(), "drive_stop():: STOP completed", UVM_LOW)

    endtask : drive_stop

endclass : i2c_mdriver

`endif    
