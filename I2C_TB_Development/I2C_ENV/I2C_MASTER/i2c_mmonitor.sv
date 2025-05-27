
`ifndef I2C_MMONITOR_UVM
`define I2C_MMONITOR_UVM

class i2c_mmonitor extends uvm_monitor;
    
    //----------------------------------------------
    //factory registration
    //----------------------------------------------
    `uvm_component_utils(i2c_mmonitor)
    //typedef uvm_component_registry#(i2c_mmonitor,"i2c_mmonitor")type_id;
    
    //----------------------------------------------
    //interface handle
    //----------------------------------------------
    virtual intf vif;

    //packet instance
    i2c_mseq_item item;

    //----------------------------------------------
    //env config
    //----------------------------------------------
    i2c_env_config env_config_h;

    //----------------------------------------------
    //analysis port
    //----------------------------------------------
    uvm_analysis_port#(i2c_mseq_item) master_mon_send;

    //properties
    bit ack=0;
    bit start=0;
    bit stop=0;
    bit repeat_start=0;
    bit temp_start=0;
    bit [6:0] slv_addr_temp;
    bit [7:0] temp_data;

    bit repeated_start_value;
    bit [6:0] expected_slv_addr;

    //----------------------------------------------
    //constructor
    //----------------------------------------------
    function new(string name="i2c_mmonitor", uvm_component parent=null);
        super.new(name,parent);
        master_mon_send = new("master_mon_send",this);
    endfunction

    //----------------------------------------------
    //build phase
    //----------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase",UVM_LOW)            

        //get interface handle
        if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif ))
            `uvm_fatal("M_MON","No virtual interface specified for i2c_master_monitor")

        //env config
        if(!uvm_config_db#(i2c_env_config)::get(this,"","env_config_h",env_config_h))
            `uvm_fatal(get_type_name()," MASTER-DRV:: ERROR--->Environment Configuration is not Set ")

    endfunction : build_phase

    //-----------------------------------------------
    //run phase
    //-----------------------------------------------
    task run_phase(uvm_phase phase);
        //@(negedge vif.reset);
        forever begin
            wait(vif.trigger.triggered);
            `uvm_info(get_type_name(),"Inside run_phase()", UVM_LOW)   
            item = i2c_mseq_item::type_id::create("item");
            monitor_start(); //task--->start condition
            `uvm_info(get_type_name(),$sformatf("run_phase():: Received START condition [%0d]", start), UVM_LOW)            
            start=0;   //0--->No START.......1--->START detected            
            collecting_data(item); //task--->collect the data (rd/wr)
        end
    endtask : run_phase

    //------------------------------------------------
    //start condition
    //------------------------------------------------
    task monitor_start();
        forever begin
            @(negedge vif.sda);
            if(vif.scl==1)begin
                start=1;
                `uvm_info(get_type_name(), $sformatf("monitor_start()::Driving Started"), UVM_LOW)                
                break;  //if not use then it will be stuck inside forever loop only
            end
        end
    endtask : monitor_start

    //-----------------------------------------------
    //collecting data
    //-----------------------------------------------
    task collecting_data(input i2c_mseq_item item);
        bit rd_wr_flag = 0;
        get_slv_addr(); //collecting 7bit slave addr from master driver

        `uvm_info(get_type_name(),$sformatf("collecting_data():: Received address = %0h",item.slv_addr),UVM_LOW)
        @(posedge vif.scl);
        item.rd_wr = vif.to_sda; //collecting rd/wr bit from master driver
        `uvm_info(get_type_name(),$sformatf("collecting_data():: Received rd/wr bit = %0b",item.rd_wr),UVM_LOW)

        `uvm_info(get_type_name(),"collecting_data():: Waiting for ACK", UVM_LOW)
        @(posedge vif.scl); //collecting ACK from Slave
        #3us;
        ack=vif.to_sda;
        `uvm_info(get_type_name(),$sformatf("collecting_data():: Received ack/nack bit = %0b",ack),UVM_LOW) 

        //address matching...This is used to run the inv_addr_sequence
        /*
        if(item.slv_addr == env_config_h.slv_addr)begin
            if(ack==0)begin
                `uvm_info(get_type_name(),"collecting_data()::Address matching is successful", UVM_LOW)
            end
            else begin
                `uvm_info(get_type_name(),"collecting_data()::Address is matched but slave is sending NACK", UVM_LOW)
            end
        end
        */
        
        if(uvm_config_db#(bit[6:0])::get(this,"","expected_slv_addr",expected_slv_addr))begin
            if(item.slv_addr == expected_slv_addr)begin
                `uvm_info(get_type_name(), "Collecting_data():: Slave Address Matched", UVM_LOW)
                if(ack==0)begin
                    `uvm_info(get_type_name(),"Collecting_data():: Address is matched and send ACK", UVM_LOW)
                end
                else begin
                    `uvm_info(get_type_name(),"Collecting_data():: Address is matched but slave is sending NACK", UVM_LOW)
                end
            end
            else begin
                `uvm_fatal(get_type_name(),"Slave address did not matched")
            end
        end
        else begin
            `uvm_warning(get_type_name(), "No expected slave address ha been found in config_db")
        end

        //rd_wr condition
        if(!ack)begin
            if(item.rd_wr==1)begin
                `uvm_info(get_type_name(),"collecting_data():: Starting READ task", UVM_LOW)
                get_data_rd(); //task--->8-bit read transaction
                rd_wr_flag = 1;
            end
            if(item.rd_wr==0 && rd_wr_flag==0)begin //if(item.rd_wr==0 && rd_wr_flag==0)
                `uvm_info(get_type_name(),"collecting_data():: Starting WRITE task", UVM_LOW)
                @(posedge vif.scl);   
                temp_data[7]= vif.to_sda;
                `uvm_info(get_type_name(),$sformatf("****temp_data[7] = %0d", temp_data[7]), UVM_LOW)
                get_data_wr(temp_data);  //task--->8-bit write transaction
            end
        end
        else begin
            `uvm_info(get_type_name(),"collecting_data():: Received NACK--->STOP condition", UVM_LOW)
            monitor_check_stop();
        end
    endtask : collecting_data

    //----------------------------------------------------
    //get_data_rd
    //----------------------------------------------------
    task get_data_rd();
        bit [7:0] temp_read; 
       `uvm_info(get_type_name(),"get_data_rd():: Inside READ task", UVM_LOW)             
  
        @(posedge vif.scl);
        temp_read[7] = vif.to_sda;
        `uvm_info(get_type_name(),$sformatf("get_data_rd()****temp_read[7] = %0d", temp_read[7]), UVM_LOW)
        
        do begin

            for(int i=6; i>=0; i--)begin   //collecting 8bit data
                @(posedge vif.scl);
                temp_read[i] = vif.to_sda;
                `uvm_info(get_type_name(),$sformatf("get_data_rd()::Inside READ sequence--->Received data bit [%0d] = %0b", i, temp_read[i]), UVM_LOW)
            end

            `uvm_info(get_type_name(),$sformatf("get_data_rd():: ****READ sequence****Received data byte = %0h", temp_read), UVM_LOW)
            item.data.push_back(temp_read);   //push 8bit data into queue

            @(negedge vif.scl);  //receive ack from slave
            #3us;
            ack = vif.to_sda;  //koi jarur nthi ane @(posedge) ni niche pn lakhaay
            @(posedge vif.scl);
            `uvm_info(get_type_name(),$sformatf("get_data_rd():: READ sequence---->Received ACK/NACK bit = %0b", ack), UVM_LOW)

            monitor_check_stop();  //check for STOP condition
            temp_read[7] = vif.sda;
            `uvm_info(get_type_name(),$sformatf("get_data_rd():: READ sequence---->temp_read[7] = %0d", temp_read[7]), UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("get_data_rd():: READ sequence---->RECEIVED stop bit = %0b", stop), UVM_LOW)
            `uvm_info(get_type_name(),"get_data_rd():: READ sequence*****Writing to Scoreboard*****", UVM_LOW)

            if(!uvm_config_db#(bit)::get(this,"","rpt_start_value",repeated_start_value))begin  //item.repeated_start
                `uvm_fatal("M_MON","No repeated_start_value found in config db")
            end
            item.repeated_start = repeated_start_value;
            item.print(); //printing the transaction with the proper value of repeated_start condition 
            
            master_mon_send.write(item); //giving to scoreboard

            //check for repeated start condition
            if(repeat_start)begin
                collecting_data(item);
                break;
            end

            if(stop) begin
                `uvm_info(get_type_name(),"get_data_rd()::WRITE sequence--->STOP condition",UVM_LOW)
            end

            /*
            if(stop == 0 && ack == 1) begin
                `uvm_fatal(get_type_name(),"get_data_wr()::found NACK in write seq, stop must be there after NAK")
            end
           */ 

        end
        while((!stop) && (ack==0)); 

    endtask : get_data_rd

    //-------------------------------------------------
    //get 8-bit data wr
    //-------------------------------------------------
    task get_data_wr(input bit[7:0] temp_data);  //task for write function
        `uvm_info(get_type_name(),"get_data_wr():: Inside WRITE task", UVM_LOW)
        do begin

            for(int i=6;i>=0;i--)begin  //collecting 8bit data
                @(posedge vif.scl);
                temp_data[i]=vif.to_sda;
                `uvm_info(get_type_name(),$sformatf("get_data_wr()::Inside write sequence--->Received data bit [%0d] =%0d",i,temp_data[i]), UVM_HIGH)
            end

            `uvm_info(get_type_name(),$sformatf("get_data_wr():: ****WRITE sequence****Received Data = %0h",temp_data), UVM_LOW)
            item.data.push_back(temp_data);  //push 8bit data into queue

            @(posedge vif.scl); //receive ack from slave
            ack = vif.to_sda;
            `uvm_info(get_type_name(),$sformatf("get_data_wr():: WRITE sequence--->Received ACK/NACK bit=%0b",ack),UVM_LOW) 

            monitor_check_stop();  //check for STOP condition...completed at 200us for first data byte, so we have to store bit[7] explicitly
            temp_data[7] = vif.sda; 
            `uvm_info(get_type_name(),$sformatf("get_data_wr():: WRITE sequence--->temp_data[7] = %0d", temp_data[7]), UVM_LOW)            
            `uvm_info(get_type_name(),$sformatf("get_data_wr():: WRITE sequence--->Received STOP bit=%0b", stop), UVM_LOW)
            `uvm_info(get_type_name(),"get_data_wr():: WRITE sequence*****Writing to Scoreboard*****", UVM_LOW)
            
            if(!uvm_config_db#(bit)::get(this,"","rpt_start_value",repeated_start_value))begin
                `uvm_fatal("M_MON","No repeated_start_value found in config db")
            end
            item.repeated_start = repeated_start_value;
            item.print();  //printing the transaction with the proper repeated_start condition

            master_mon_send.write(item); //giving to scoreboard
            
            //check for repeated start condition
            if(repeat_start)begin
                collecting_data(item);
                break;
            end

            if(stop) begin
                `uvm_info(get_type_name(),"get_data_wr()::WRITE sequence--->STOP condition",UVM_LOW)
            end
        
            /*
            if(stop == 0 && ack == 1) begin
                `uvm_fatal(get_type_name(),"get_data_wr()::found NACK in write seq, stop must be there after NAK")
            end 
            */
            
        end
        while((!stop) && (ack == 0));

    endtask : get_data_wr

    //------------------------------------------------
    //Monitor STOP condition
    //-----------------------------------------------
    task monitor_check_stop();
        `uvm_info(get_type_name(),"monitor_check_stop():: Inside monitor_check_stop()", UVM_LOW)

        fork
            //process 1----->Check for STOP condition
            begin
                `uvm_info(get_type_name(),"monitor_check_stop():: Checking if STOP Detected ",UVM_LOW)                                
                @(posedge vif.scl);
                @(posedge vif.sda);
                stop = 1;
                `uvm_info(get_type_name(),"monitor_check_stop():: STOP detected", UVM_LOW)
            end

            //process 2
            begin
                `uvm_info(get_type_name(),"monitor_check_stop():: Checking the usual condition ",UVM_LOW)                                
                @(posedge vif.scl);
                @(negedge vif.scl);
                stop = 0;
                repeat_start = 0;
                `uvm_info(get_type_name(),"monitor_check_stop():: NO START/STOP detected ",UVM_LOW)                              
            end

            //process 3------> Check for repeated START condition
            begin
                `uvm_info(get_type_name(),"monitor_check_stop():: Checking if repeated START Detected ",UVM_LOW)                                
                @(posedge vif.scl);  
                @(negedge vif.sda);
                repeat_start = 1;
                `uvm_info(get_type_name(),"monitor_check_stop():: Repeated START detected", UVM_LOW)
            end

        join_any
        disable fork;
    endtask : monitor_check_stop


    //---------------------------------------------
    //get slave addr
    //---------------------------------------------
    task get_slv_addr();
        for(int i=6; i>=0; i--)begin
            @(posedge vif.scl);
            item.slv_addr[i] = vif.to_sda; //7bit address...bit-by-bit
            `uvm_info(get_type_name(), $sformatf("get_slv_addr():: Received slave address bit[%0d] = [%0b]", i, vif.sda), UVM_LOW)
        end
    endtask : get_slv_addr

endclass : i2c_mmonitor

`endif
