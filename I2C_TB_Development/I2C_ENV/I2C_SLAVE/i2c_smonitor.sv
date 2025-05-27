
`ifndef I2C_SMONITOR_UVM
`define I2C_SMONITOR_UVM

class i2c_smonitor extends uvm_monitor;

    //------------------------------------------------
    //factory registration
    //------------------------------------------------
    `uvm_component_utils(i2c_smonitor)
    //typedef uvm_component_registry#(i2c_smonitor,"i2c_smonitor")type_id;

    //------------------------------------------------
    //interface handle
    //------------------------------------------------
    virtual intf vif;

    //------------------------------------------------
    //transaction handle
    //------------------------------------------------
    i2c_mseq_item item;
    `uvm_register_cb(i2c_smonitor,driver_callback)

    //------------------------------------------------
    //env config
    //------------------------------------------------
    i2c_env_config env_config_h;

    //------------------------------------------------
    //analysis port
    //------------------------------------------------
    uvm_analysis_port#(i2c_mseq_item) slave_mon_send;

    bit ack=0;
    bit start=0;
    bit stop=0;
    bit [7:0] temp_data;
    bit repeat_start=0;

    bit repeated_start_value;
    bit [6:0] exp_slv_addr;


    //-------------------------------------------------
    //constructor
    //-------------------------------------------------
    function new(string name = "i2c_smonitor", uvm_component parent = null);
        super.new(name,parent);
        slave_mon_send = new("slave_mon_send", this);
    endfunction

    //-------------------------------------------------
    //build phase
    //-------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase()",UVM_LOW)            

        if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif))
            `uvm_fatal("S_MON","No virtual interface specified for i2c_slave_monitor")

        if(!uvm_config_db#(i2c_env_config)::get(this,"","env_config_h",env_config_h))
            `uvm_fatal(get_type_name(),"SLAVE-MON:: ERROR---->Environment Configuration is not set")
        
    endfunction

    //-------------------------------------------------
    //run phase
    //-------------------------------------------------
    task run_phase(uvm_phase phase);
        //@(negedge vif.reset);        
        forever begin
            wait(vif.trigger.triggered);
            `uvm_info(get_type_name(),"Inside run_phase()", UVM_LOW)            
            item = i2c_mseq_item::type_id::create("item");
            monitor_start();      	 		                                                   
            start=0; 
            collecting_data(item);
        end
    endtask : run_phase

    //-------------------------------------------------
    //collecting data
    //-------------------------------------------------
    task collecting_data(input i2c_mseq_item item);
        bit rd_wr_flag=0;
        monitor_addr(); 
        `uvm_info(get_type_name(),$sformatf("collecting_data():: Received address = %0h", item.slv_addr), UVM_LOW)
        @(posedge vif.scl);
        item.rd_wr = vif.to_sda;
        `uvm_info(get_type_name(),$sformatf("collecting_data():: Received rd/wr bit = %0b", item.rd_wr), UVM_LOW)

        `uvm_info(get_type_name(),"collecting_data():: Waiting for ACK", UVM_LOW)
        @(posedge vif.scl);
        #3us;
        ack = vif.to_sda;
        `uvm_info(get_type_name(),$sformatf("collecting_data():: Received ack/nack bit = %0b", ack), UVM_LOW)

        //address matching
        /*
        if(item.slv_addr == env_config_h.slv_addr)begin
            if(ack==0)begin
                `uvm_info(get_type_name(),"collecting_data():: Address matching is successful", UVM_LOW)
            end
            else begin
                `uvm_info(get_type_name(),"collecting_data():: Address is matched but slave is sending NACK", UVM_LOW)
            end
        end
        */
        
        if(uvm_config_db#(bit[6:0])::get(this,"","expected_slv_addr",exp_slv_addr))begin
            if(item.slv_addr == exp_slv_addr)begin
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


        //rd_wr_condition
        if(!ack)begin
            if(item.rd_wr==1)begin
                `uvm_info(get_type_name(),"collecting_data():: Starting READ task", UVM_LOW)
                get_data_rd();
                rd_wr_flag = 1;
            end
            if(item.rd_wr==0 && rd_wr_flag==0)begin //if(item.rd_wr ==0 && rd_wr_flag==0)
                `uvm_info(get_type_name(),"collecting_data():: Starting WRITE task", UVM_LOW)
                @(posedge vif.scl);
                temp_data[7] = vif.to_sda;
                `uvm_info(get_type_name(),$sformatf("****temp_data[7] = %0d", temp_data[7]), UVM_LOW)                
                get_data_wr(temp_data);
            end
        end
        else begin
            `uvm_info(get_type_name(),"collecting_data():: Received NACK--->STOP condition", UVM_LOW)
            check_stop();
        end

    endtask : collecting_data

    //--------------------------------------------------
    //get data rd
    //--------------------------------------------------
    task get_data_rd;
        `uvm_info(get_type_name(),"get_data_rd():: Inside READ task", UVM_LOW)

        @(posedge vif.scl);
        temp_data[7] = vif.to_sda;
        `uvm_info(get_type_name(),$sformatf("****temp_read[7] = %0d", temp_data[7]), UVM_LOW)        

        do begin

            for(int i=6; i>=0; i--)begin
                @(posedge vif.scl);
                temp_data[i] = vif.to_sda;
                `uvm_info(get_type_name(),$sformatf("get_data_rd()::Inside READ sequence--->Received data bit [%0d] =%0d",i,temp_data[i]), UVM_LOW)                
            end
            
            `uvm_info(get_type_name(),$sformatf("get_data_rd():: ****READ sequence****Received Data byte = %0h",temp_data), UVM_LOW)
            item.data.push_back(temp_data);  //push 8bit data into queue

            @(negedge vif.scl);
            #3us;
            ack = vif.to_sda; //koi jarur nthi ane @(posedge) ni niche pn lakhaay
            @(posedge vif.scl); //receive ack from slave
            `uvm_info(get_type_name(),$sformatf("get_data_rd():: READ sequence--->Received ACK/NACK bit=%0b",ack), UVM_LOW) 

            check_stop(); //check stop condition
            temp_data[7] = vif.sda;
            `uvm_info(get_type_name(),$sformatf("get_data_rd():: READ sequence--->temp_data[7] = %0d", temp_data[7]), UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("get_data_rd():: READ sequence--->Received STOP bit=%0b", stop), UVM_LOW)
            `uvm_info(get_type_name(),"get_data_rd():: READ sequence*****Writing to Scoreboard*****", UVM_LOW)

            if(!uvm_config_db#(bit)::get(this,"","rpt_start_value",repeated_start_value))begin
                `uvm_fatal("S_MON","No repeated_start_value found in config_db")
            end
            item.repeated_start = repeated_start_value;
            item.print();
            
            slave_mon_send.write(item); //giving to scoreboard

            //check for repeated START condition
            if(repeat_start)begin
                collecting_data(item);
                break;
            end

            if(stop) begin
                `uvm_info(get_type_name(),"get_data_rd()::READ sequence--->STOP condition",UVM_LOW)
            end
            
            /*
            if(stop == 0 && ack == 1) begin 
                `uvm_fatal(get_type_name(),"get_data_rd()::found NACK in write seq, stop must be there after NACK")
            end
           */ 

        end
        while((!stop) && (ack==0));

    endtask : get_data_rd

    //----------------------------------------------------
    //get data wr
    //----------------------------------------------------
    task get_data_wr(input bit[7:0] temp_data);
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

            check_stop();  //check for STOP condition
            temp_data[7] = vif.sda; 
            `uvm_info(get_type_name(),$sformatf("get_data_wr():: WRITE sequence--->temp_data[7] = %0d", temp_data[7]), UVM_LOW)
            `uvm_info(get_type_name(),$sformatf("get_data_wr():: WRITE sequence--->Received STOP bit=%0b", stop), UVM_LOW)
            `uvm_info(get_type_name(),"get_data_wr():: WRITE sequence*****Writing to Scoreboard*****", UVM_LOW)

            if(!uvm_config_db#(bit)::get(this,"","rpt_start_value",repeated_start_value))begin
                `uvm_fatal("S_MON","No repeated_start_value found in config_db")
            end
            item.repeated_start = repeated_start_value;
    
            //`uvm_do_callbacks(i2c_smonitor,driver_callback,pre_drive(item));
            //`uvm_info("SMON-CALLBACK", $sformatf("After callback item.slv_addr---->%0b", item.slv_addr), UVM_LOW)
            //`uvm_info("DRV-CALLBACK", $sformatf("After callback item.rd_wr--->%0b", item.rd_wr), UVM_LOW)
            /*
            foreach(item.data[i])begin
                `uvm_info("DRV-CALLBACK", $sformatf("After callback item.data[%0d] = %0h", i, item.data[i]), UVM_LOW)
            end*/
            
            item.print();
            
            slave_mon_send.write(item); //giving to scoreboard
            
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
        while((!stop)&&(ack == 0));

    endtask : get_data_wr

    //---------------------------------------------------
    //check stop
    //---------------------------------------------------
    task check_stop();
        `uvm_info(get_type_name(),"check_stop():: Inside check_stop()", UVM_LOW)
        
        fork
            //process 1----->Check for STOP condition
            begin
                `uvm_info(get_type_name(),"check_stop():: Checking if STOP Detected ",UVM_LOW)                                
                @(posedge vif.scl);
                @(posedge vif.sda);
                stop = 1;
                `uvm_info(get_type_name(),"check_stop():: STOP detected", UVM_LOW)
            end

            //process 2
            begin
                `uvm_info(get_type_name(),"check_stop():: CHecking the usual condition ",UVM_LOW)                                
                @(posedge vif.scl);
                @(negedge vif.scl);
                stop = 0;
                repeat_start = 0;
                `uvm_info(get_type_name(),"check_stop():: NO START/STOP detected ",UVM_LOW)                              
            end

            //process 3------> Check for repeated START condition
            begin
                `uvm_info(get_type_name(),"check_stop():: Checking if repeated START Detected ",UVM_LOW)                                
                @(posedge vif.scl);  
                @(negedge vif.sda);
                repeat_start = 1;
                `uvm_info(get_type_name(),"check_stop():: Repeated START detected", UVM_LOW)
            end

        join_any
        disable fork;
    endtask : check_stop


    //-----------------------------------------------------
    //monitor addr
    //-----------------------------------------------------
    task monitor_addr();
        for(int i=6; i>=0; i--)begin
            @(posedge vif.scl);
            item.slv_addr[i] = vif.to_sda; //7bit address....bit-by-bit
            `uvm_info(get_type_name(),$sformatf("monitor_addr():: Sampling Received Slave Address bit[%0d] : %0b ",i ,vif.to_sda),UVM_LOW)             
        end     
    endtask
    

    //-----------------------------------------------------
    //monitor start
    //-----------------------------------------------------
    task monitor_start();                                                                      
        forever begin
            @(negedge vif.sda);
            if(vif.scl==1'b1)begin
                `uvm_info(get_type_name(),"monitor_start()::Detected Start ",UVM_LOW)                
                start=1;
                break;
            end
        end
    endtask : monitor_start

endclass : i2c_smonitor

`endif
