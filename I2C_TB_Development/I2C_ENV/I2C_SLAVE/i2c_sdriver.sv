
`ifndef I2C_SDRIVER_UVM
`define I2C_SDRIVER_UVM

class i2c_sdriver extends uvm_driver#(i2c_mseq_item);

    //----------------------------------------------
    //factory registration
    //----------------------------------------------
    `uvm_component_utils(i2c_sdriver)
    //typedef uvm_component_registry#(i2c_sdriver,"i2c_sdriver")type_id;
    
    //----------------------------------------------
    //interface handle
    //----------------------------------------------
    virtual intf vif;
    
    //----------------------------------------------
    //env configuration
    //----------------------------------------------
    i2c_env_config env_config_h;
 

    //properties
    bit [7:0] data=0;
    bit [6:0] slv_addr=0;
    bit repeat_start=0;
    bit start_detection=0;
    bit rd_wr;
    bit trigger=0;
    bit stop_detection=0;
    bit [7:0] data_queue[$];
    //bit [7:0] default_queue[$] = {11,22,33,44,55}; //when read operation
    bit flag = 0; //read opeartion

    bit [6:0] exp_slv_addr;

    //-----------------------------------------------
    //constructor
    //-----------------------------------------------
    function new(string name="i2c_sdriver", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    //----------------------------------------------
    //build phase
    //----------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(),"Inside build_phase", UVM_LOW)

        if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
            `uvm_fatal(get_type_name(),"No virtual interface for i2c_slave_driver")

        if(!uvm_config_db#(i2c_env_config)::get(this,"","env_config_h", env_config_h))
            `uvm_fatal(get_type_name(),"SLAVE-DRV:: env configuration is not set")

    endfunction: build_phase

    //---------------------------------------------
    //run phase
    //---------------------------------------------
    task run_phase(uvm_phase phase);
        //@(negedge vif.reset);
        forever begin

            stop_detection = 0;
            repeat_start = 0;
            wait(vif.trigger.triggered);
            //`uvm_info(get_type_name(),"Inside run_phase", UVM_LOW)
            fork

            begin
                wait(vif.flag_detect.triggered);  
                `uvm_info(get_type_name(),"Exiting the 'thread1' of run_phase()", UVM_LOW)  //...comes back inside the forever loop and start printing this statement and will stuck with this thread because this thread is triggered prior and now value will be always 1 so it will exit the fork join_any and will print last staement and the process starts again and the simulation will be hanged
            end

            begin
                `uvm_info(get_type_name(),"Inside run_phase", UVM_LOW)
                check_start();
                collecting_data();
            end

            join_any;
            disable fork;
  
        end
    endtask: run_phase

    //----------------------------------------------
    //collecting data
    //----------------------------------------------
    task collecting_data();
        trigger=0;
        slave_address();
        @(posedge vif.scl);
        rd_wr = vif.to_sda;
        `uvm_info(get_type_name(), $sformatf("run_phase():: Received rd/wr bit = %0b", rd_wr), UVM_LOW)

       
        //address matching
        /*
        if(slv_addr==env_config_h.slv_addr)begin
            trigger=1;
        end
        */
       
        if(uvm_config_db#(bit[6:0])::get(this,"","expected_slv_addr",exp_slv_addr))begin
            if(slv_addr==exp_slv_addr)begin
                `uvm_info("ADDR_CHECK","Slave address matched", UVM_LOW)
                trigger=1;
            end
            else begin
                trigger=0;
                `uvm_warning("ADDR_MISMATCH", $sformatf("Slave address did not match...actual slv_addr : %0h | expected_slv_addr : %0h", slv_addr, exp_slv_addr))
            end
        end
        else begin
            `uvm_fatal(get_type_name(), "NO Expected Slave address has been found in config_db")
        end
        
         
        if(trigger==1)begin //trigger ==1;
             `uvm_info(get_type_name(),"run_phase():: Slave address matched--->Sending ACK", UVM_LOW)
             send_ack();
        end
        else begin
             `uvm_info(get_type_name(),"run_phase():: Slave address mismatched---->Sending NACK", UVM_LOW)
             send_nack();
             check_stop();
        end

        //rd_wr condition
        if(rd_wr==0)begin
             write_data();
        end

        if(rd_wr==1)begin
             read_data();
        end

    endtask: collecting_data

    //-----------------------------------------------
    //write data
    //-----------------------------------------------
    task write_data();
        `uvm_info(get_type_name(),"write_data():: Slave is allowing master to write data", UVM_LOW)
        fork
            begin
                wait(vif.stop_detect.triggered);
                `uvm_info(get_type_name(), $sformatf("Time=[%0t] Exiting the 'thread1' of write_data()",$realtime), UVM_LOW)
            end

            forever begin
            //do begin
            data =0;

            //wait(vif.stop_detect.triggered);
            for(int i=7; i>=0; i--)begin
                @(posedge vif.scl);
                #3us;
                if(repeat_start==1)begin
                    `uvm_info(get_type_name(),"write_data():: Repeated START detected while writing", UVM_LOW)
                    break;
                end

                data = {data[6:0], vif.to_sda};
               `uvm_info(get_type_name(),$sformatf("write_data():: Sampling bits of WRITE data[%0d]=%0b", i, vif.sda), UVM_LOW) 
            end

            if(repeat_start==1)begin
                `uvm_info(get_type_name(), "write_data():: After repeat_start detected calling collecting_data() task", UVM_LOW)
                repeat_start=0;
                collecting_data();
                `uvm_info(get_type_name(),"Call", UVM_LOW)
                break;
            end
           
            if(stop_detection==1)begin
                `uvm_info(get_type_name(), $sformatf("write_data():: STOP detected while writing"), UVM_LOW)
                break;
            end

            `uvm_info(get_type_name(), $sformatf("write_data():: Received WRITE data = %0h", data), UVM_LOW)
            data_queue.push_back(data);

           send_ack();
           fork
               check_stop();
               `uvm_info(get_type_name(), $sformatf("Time[check_stop]=%0t.........................",$realtime), UVM_LOW)
           join_none
           end

       join_any;
       disable fork;
       -> vif.flag_detect;
       `uvm_info(get_type_name(), $sformatf("write task() completed and exiting at [%0t].........................",$realtime), UVM_LOW)
       //end
       //while((!stop_detection));

    endtask : write_data

    //------------------------------------------------
    // read data
    //------------------------------------------------
    task read_data();
        bit [7:0] default_queue[$] = {11,22,33,44,55,66,77,88,99,98}; //when read operation...HEX: {b,16,21,2c,37,42,4d,58,63,62}
        `uvm_info(get_type_name(),"read_data():: Slave is allowing master to READ data", UVM_LOW)
        
            if(data_queue.size == 0)begin  //write pchi read karisu tyare bharelu hse
                `uvm_info(get_type_name(),"read_data():: data_queue is empty***Master is reading from default queue", UVM_LOW)
            
                while(default_queue.size() > 0)begin
                    data = default_queue.pop_front();
                    `uvm_info(get_type_name(), $sformatf("read_data()::[Default] Driven read byte will be = %0d", data), UVM_LOW)

                    for(int i=7; i>=0; i--)begin
                        @(negedge vif.scl);
                        #2us;
                        vif.to_sda = data[i];
                        `uvm_info(get_type_name(), $sformatf("read_data()::[Default] Driving bit of read data [%0d] = %0b", i, vif.to_sda), UVM_LOW)
                    end

                    @(negedge vif.scl);
                    #1us;
                    vif.to_sda = 1'bz;
                    `uvm_info(get_type_name(), "read_data()::[Default] Slave releasing the bus and waiting for ACK", UVM_LOW)

                    wait_for_master_ack();  //wait for the master acknowledgement to slave

                    if(flag==1)begin
                        `uvm_info(get_type_name(), "read_data()::[Default] Checking for STOP condition", UVM_LOW)   
                        check_stop();
                        if(stop_detection==1)begin
                            `uvm_info(get_type_name(), "read_data()::[Default] STOP condition detected", UVM_LOW)     
                            break;
                        end
                        $display("Checking purpose******");
                        
                        if(repeat_start==1)begin
                            `uvm_info(get_type_name(), "read_data()::[Default] REPEATED_START condition detected", UVM_LOW)
                            repeat_start=0;
                            collecting_data();
                            break;
                        end
                    end

                end  //while...begin end

            end  //if...begin end
            else begin
                `uvm_info(get_type_name(),"read_data():: ***Master is reading from data queue", UVM_LOW)
            
            while(data_queue.size() > 0)begin
                data = data_queue.pop_front();
                `uvm_info(get_type_name(), $sformatf("read_data()::[Data] Driven read byte will be = %0h", data), UVM_LOW)

                for(int i=7; i>=0; i--)begin
                    @(negedge vif.scl);
                    #2us;
                    vif.to_sda = data[i];
                    `uvm_info(get_type_name(),$sformatf("read_data()::[Data] Driving bit of read data [%0d] = %0b",i, vif.to_sda), UVM_LOW)
                end
               
                @(negedge vif.scl);
                #1us;
                vif.to_sda = 1'bz;
                `uvm_info(get_type_name(), "read_data()::[Data] Slave realeasing the bus and waiting for ACK", UVM_LOW)
                
                wait_for_master_ack();

                if(flag==1)begin
                    `uvm_info(get_type_name(), "read_data()::[Data] Checking for START/STOP condition", UVM_LOW)   
                    check_stop();
                    if(stop_detection==1)begin
                        `uvm_info(get_type_name(), "read_data()::[Data] STOP condition detected", UVM_LOW)     
                        break;
                    end
           
                    if(repeat_start==1)begin
                        `uvm_info(get_type_name(), "read_data()::[Data] REPEAT_START condition detected", UVM_LOW)
                        repeat_start=0;
                        collecting_data();
                        break;
                    end
                end
                
            end
            end  //else...begin end

        `uvm_info(get_type_name(), $sformatf("read task() completed and exiting at [%0t].........................",$realtime), UVM_LOW)
    endtask : read_data 
    
    //------------------------------------------------
    //wait for master ack
    //------------------------------------------------
    task wait_for_master_ack();
        `uvm_info(get_type_name(), "wait_for_master_ack():: Inside task--->waiting for master ack", UVM_LOW)
        @(posedge vif.scl);
        if(vif.to_sda==0)begin
            flag=0;
            `uvm_info(get_type_name(),"wait_for_master_ack():: Inside task--->Received ACK", UVM_LOW)
        end
        else begin
            flag=1;
            `uvm_info(get_type_name(),"wait_for_master_ack():: Inside task--->Received NACK", UVM_LOW)
        end
    endtask: wait_for_master_ack
    
    
    //-------------------------------------------------
    //send ack
    //-------------------------------------------------
    task send_ack(); 
        `uvm_info(get_type_name(),"send_ack():: Waiting for negedge #2us to drive ACK ",UVM_LOW)
        @(negedge vif.scl);
        #2us;
        `uvm_info(get_type_name(),"send_ack():: ACK from Slave To Master ", UVM_LOW)
        vif.to_sda = 0;
        @(posedge vif.scl);
        #4.5us;
        `uvm_info(get_type_name(),"send_ack():: Slave Realising the Bus ", UVM_LOW)
        vif.to_sda = 1'bz;
    endtask: send_ack

    //--------------------------------------------------
    //send nack
    //--------------------------------------------------
    task send_nack();
        `uvm_info(get_type_name(),"send_nack():: Waiting for negedge #2us to drive NACK ", UVM_LOW)
        @(negedge vif.scl);
        #2us;
        `uvm_info(get_type_name(),"send_nack():: NACK from Slave To Master ", UVM_LOW)
        vif.to_sda = 1;
        @(posedge vif.scl);
        #4.5us;
        `uvm_info(get_type_name(),"send_nack():: Slave Realising the Bus ", UVM_LOW)
        vif.to_sda = 1'bz;
    endtask : send_nack


    //--------------------------------------------------
    //slave addr
    //--------------------------------------------------
    task slave_address();
        for(int i=6; i>=0; i--)begin
            @(posedge vif.scl );
            slv_addr[i] = vif.to_sda;
            `uvm_info(get_type_name(),$sformatf("slave_address():: Sampling Received Slave Address bit[%0d] : %0b ",i ,vif.to_sda),UVM_LOW) 
        end
        `uvm_info(get_type_name(),$sformatf("slave_address():: Received Slave Address : %0h ",slv_addr),UVM_LOW)
        //`uvm_info(get_type_name(),$sformatf("slave_address():: Actual Slave Address : %0h ",env_config_h.slv_addr),UVM_LOW)
    endtask : slave_address


    //-------------------------------------------------
    //check start
    //-------------------------------------------------
    task check_start();
        forever begin
            @(negedge vif.sda);
            if (vif.scl == 1'b1) begin
                `uvm_info(get_type_name(),"check_start()::Detected Start ",UVM_LOW)
                break;
            end
        end
    endtask : check_start

    //------------------------------------------------
    //check stop
    //------------------------------------------------
    task check_stop();
        fork
            //process 1----->Check for STOP condition            
            begin
                `uvm_info(get_type_name(),"check_stop():: Checking if STOP Detected ",UVM_LOW)                
                @(posedge vif.scl);
                @(posedge vif.sda);
                stop_detection=1'b1;
                `uvm_info(get_type_name(),"check_stop():: STOP Detected ",UVM_LOW)
                -> vif.stop_detect;
                $display("event triggered ");
            end
            
            //process 2
            begin
                `uvm_info(get_type_name(),"check_stop():: CHecking the usual condition ",UVM_LOW)                
                @(posedge vif.scl);
                @(negedge vif.scl);
                stop_detection=1'b0; 
                repeat_start = 1'b0;
                `uvm_info(get_type_name(),"check_stop():: NO START/STOP detected ",UVM_LOW)              
            end
      
            //process 3------> Check for repeated START condition            
            begin
                `uvm_info(get_type_name(),"check_stop():: Checking if repeated START Detected ",UVM_LOW)                
                @(posedge vif.scl);
                @(negedge vif.sda);
                repeat_start = 1;
                `uvm_info(get_type_name(),"check_stop():: Repeated START Detected ",UVM_LOW)
            end

        join_any 
        disable fork;
    endtask : check_stop

endclass: i2c_sdriver

`endif
