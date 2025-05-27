
`ifndef I2C_SCOREBOARD_UVM
`define I2C_SCOREBOARD_UVM

//TLM...define analysis port 
`uvm_analysis_imp_decl(_actual_data) //port identifier
`uvm_analysis_imp_decl(_expected_data)

class i2c_scoreboard extends uvm_scoreboard;

    //-----------------------------------------------------------
    //factory registration
    //-----------------------------------------------------------
    `uvm_component_utils(i2c_scoreboard)
    //typedef uvm_component_registry#(i2c_scoreboard,"i2c_scoreboard")type_id;
    
    //-----------------------------------------------------------
    //transaction handle.....for comparing expected data and actual data
    //-----------------------------------------------------------
    i2c_mseq_item actual_data_h;
    i2c_mseq_item expected_data_h;

    //-----------------------------------------------------------
    //declaring queue.....for storing expected and actual data
    //-----------------------------------------------------------
    i2c_mseq_item actual_data_queue[$], expected_data_queue[$];

    //-----------------------------------------------------------
    //analysis port
    //-----------------------------------------------------------
    uvm_analysis_imp_expected_data#(i2c_mseq_item,i2c_scoreboard) master_mon_receive;  //analysis port for master monitor
    uvm_analysis_imp_actual_data#(i2c_mseq_item,i2c_scoreboard) slave_mon_receive; //analysis port for slave monitor 
    
    //-----------------------------------------------------------
    //constructor
    //-----------------------------------------------------------
    function new(string name="i2c_scoreboard", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    //------------------------------------------------------------
    //build phase
    //------------------------------------------------------------
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
	    `uvm_info(get_type_name(),"Inside build_phase",UVM_LOW)            

        master_mon_receive = new("master_mon_receive",this);
        slave_mon_receive = new("slave_mon_receive",this);
        
        actual_data_h = i2c_mseq_item::type_id::create("actual_data_h");
        expected_data_h = i2c_mseq_item::type_id::create("expected_data_h");
    endfunction

    //------------------------------------------------------------
    //write_actual_data------>packet received from the slave monitor and pushed into actual_data_queue
    //------------------------------------------------------------
    function void write_actual_data(input i2c_mseq_item actual_data);
      actual_data_queue.push_back(actual_data); //pushing into queue  
      `uvm_info(get_type_name(),"Currently inside write analysis method***write_actual_data", UVM_LOW)
    endfunction

    //------------------------------------------------------------
    //write_expected_data---->packet received from master monitor and pushed into expected_data_queue
    //------------------------------------------------------------
    function void write_expected_data(input i2c_mseq_item expected_data);
        expected_data_queue.push_back(expected_data); //pushing into queue
        `uvm_info(get_type_name(), "Currently inside write analysis method***write_expected_data", UVM_LOW)
    endfunction

    //-----------------------------------------------------------
    //task()--->run phase
    //-----------------------------------------------------------
    task run_phase(uvm_phase phase);
        forever begin
            `uvm_info(get_type_name(),"Inside run_phase()", UVM_LOW)            

            //waiting for the queue to get the data from master and/or slave data
            wait(actual_data_queue.size() !=0  &&  expected_data_queue.size() !=0);

            //pop data out from queue to local handles for comparison
            actual_data_h   = actual_data_queue.pop_front();
            expected_data_h = expected_data_queue.pop_front();


            if(actual_data_h.compare(expected_data_h))begin
                pass(); //pass()--->function called
            end
            else begin
                fail(); //fail()--->function called
            end

        end
    endtask

    //------------------------------------------------------------
    //function()---->Pass
    //------------------------------------------------------------
    function void pass();
        //packet comparison

        if(!actual_data_h.rd_wr && !expected_data_h.rd_wr)begin //for write data
            `uvm_info("i2c_scoreboard", "PASS*****************WRITE SUCCESS*****************", UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("PASS***Comparing--->actual_write_data = %0h and expected_write_data = %0h", actual_data_h.data.pop_front(), expected_data_h.data.pop_front()), UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("Compared Packet information: \t%s \t%s", actual_data_h.sprint(), expected_data_h.sprint()), UVM_LOW)
        end
        else if(actual_data_h.rd_wr && expected_data_h.rd_wr)begin //for read data
            `uvm_info("i2c_scoreboard", "PASS*****************READ SUCCESS*****************", UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("PASS***Comparing--->actual_read_data = %0h and expected_read_data = %0h", actual_data_h.data.pop_front(), expected_data_h.data.pop_front()), UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("Compared Packet information: \t%s \t%s", actual_data_h.sprint(), expected_data_h.sprint()), UVM_LOW)
        end
    endfunction

    ///////////////////////////////////////////////////////////
    //function()---->Fail
    ///////////////////////////////////////////////////////////
    function void fail();
        //invalid address
        if(actual_data_h.slv_addr != expected_data_h.slv_addr)
            `uvm_fatal("ERROR", $sformatf("Address mismatched: SLAVE received address = %0h and MASTER sent address = %0h", actual_data_h.slv_addr, expected_data_h.slv_addr))

        
        if(!actual_data_h.rd_wr && !expected_data_h.rd_wr)begin //for write data
            `uvm_info("i2c_scoreboard", "FAIL*****************WRITE FAILED*****************", UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("FAIL***Comparing info--->actual_write_data = %0h and expected_write_data = %0h", actual_data_h.data.pop_front(), expected_data_h.data.pop_front()), UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("Compared Packet information: \t%s \t%s", actual_data_h.sprint(), expected_data_h.sprint), UVM_LOW)
        end
        else if(actual_data_h.rd_wr && expected_data_h.rd_wr)begin //for read data
            `uvm_info("i2c_scoreboard", "FAIL*****************READ FAILED******************", UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("FAIL***Comparing info--->actual read_data = %0h and expected_read_data = %0h", actual_data_h.data.pop_front(), expected_data_h.data.pop_front()), UVM_LOW)
            `uvm_info("i2c_scoreboard", $sformatf("Compared Packet information: \t%s \t%s", actual_data_h.sprint(), expected_data_h.sprint), UVM_LOW)
        end
        else begin //mismatched rd_wr bit
            `uvm_fatal("ERROR", $sformatf("rd_wr bit is mismatched....actual rd_wr = %0b and expected rd_wr = %0b", actual_data_h.rd_wr, expected_data_h.rd_wr))
        end
        
    endfunction


endclass : i2c_scoreboard

`endif


        
    
