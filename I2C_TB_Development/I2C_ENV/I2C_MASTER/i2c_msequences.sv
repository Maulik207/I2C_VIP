
`ifndef I2C_MSEQUENCES_UVM
`define I2C_MSEQUENCES_UVM

//-------------------------------------READ SEQUENCE-----------------------------------------//
class i2c_read_sequence extends i2c_base_sequence;

	`uvm_object_utils(i2c_read_sequence)
    //typedef uvm_object_registry#(i2c_read_sequence,"i2c_read_sequence")type_id;
	
	function new(string name = "i2c_read_sequence");
        super.new(name);
	endfunction
    
    task body();
        i2c_mseq_item trans;

        bit [2:0] rd_size;

        //assert(std::randomize(rd_size) inside {[1:5]});
        //$display("read_size : %0d", rd_size);

        trans = i2c_mseq_item::type_id::create("trans");

        /*
        begin
            $display("i2c_read_sequence");
            `uvm_do_with(req,{req.rd_wr==1'b1; req.slv_addr==7'h6f; req.size_while_read_write==5; req.repeated_start==1'b0;})    
        end
        */
      
        begin
            $display("Inside i2c_read_sequence");
            start_item(trans);  //will not work with the 'req'....will work in the uvm_do and etc, because does the task internally like create()
            assert(trans.randomize() with {rd_wr==1'b1; size_while_read_write==5; repeated_start==1'b0;});
            uvm_config_db#(bit)::set(null,"*","rpt_start_value",trans.repeated_start);      
            uvm_config_db#(bit [6:0])::set(null,"*","expected_slv_addr", trans.slv_addr);                 
            finish_item(trans);
        end
  
   endtask

endclass : i2c_read_sequence

//-------------------------------------WRITE SEQUENCE--------------------------------------//
class i2c_write_sequence extends i2c_base_sequence;

    `uvm_object_utils(i2c_write_sequence)
    //typedef uvm_object_registry#(i2c_write_sequence,"i2c_write_sequence")type_id;

    function new(string name= "i2c_write_sequence");
        super.new(name);
    endfunction

    task body();  
        i2c_mseq_item trans;
        trans = i2c_mseq_item::type_id::create("trans");           
        
        /*
        begin
            $display("Inside i2c_write_sequence");
            `uvm_do_with(req,{req.rd_wr==1'b0; req.slv_addr==7'h6F; req.data.size()==8'h3; req.data[0]==8'hEA; req.repeated_start==0;})       
        end
        */
      
        begin
            $display("Inside i2c_write_sequence");
            start_item(trans);  //will not wor with the 'req'....will work in the uvm_do and etc, because does the task internally like create()
            assert(trans.randomize() with {rd_wr==1'b0; data.size()==8'h5; repeated_start==1'b0;});
            uvm_config_db#(bit)::set(null,"*","rpt_start_value",trans.repeated_start); 
            uvm_config_db#(bit [6:0])::set(null,"*","expected_slv_addr", trans.slv_addr);     
            finish_item(trans);
        end
  
   endtask

endclass : i2c_write_sequence

//---------------------------------------INVALID ADDRESS------------------------------------//
class i2c_inv_addr_sequence extends i2c_base_sequence;

    `uvm_object_utils(i2c_inv_addr_sequence)
    //typedef uvm_object_registry#(i2c_inv_addr_sequence,"i2c_inv_addr_sequence")type_id;

    function new(string name= "i2c_inv_addr_sequence");
        super.new(name);
    endfunction

    task body();
        i2c_mseq_item trans;
        trans = i2c_mseq_item::type_id::create("trans");

        /*
        begin
            $display("Inside i2c_inv_add_sequence");
            `uvm_do_with(req,{req.slv_addr==7'h7F;})
        end
        */

        begin
            $display("Inside i2c_inv_addr_sequence");
            start_item(trans);  //will not wor with the 'req'....will work in the uvm_do and etc, because does the task internally like create()
            assert(trans.randomize() with {slv_addr==7'h7f;});
            uvm_config_db#(bit)::set(null,"*","rpt_start_value",trans.repeated_start); 
            uvm_config_db#(bit [6:0])::set(null,"*","expected_slv_addr", trans.slv_addr);                 
            finish_item(trans);
        end

    endtask

endclass : i2c_inv_addr_sequence

//-------------------------------------READ_THEN_WRITE--------------------------------------//
class i2c_rd_wr_sequence extends i2c_base_sequence;

    `uvm_object_utils(i2c_rd_wr_sequence)   
    //typedef uvm_object_registry#(i2c_rd_wr_sequence,"i2c_rd_wr_sequence")type_id;
        
    function new(string name="i2c_rd_wr_sequence");
        super.new(name);
    endfunction
        
    task body();
        i2c_mseq_item trans;

        //it will be used to store the randomized slv_addr
        bit [6:0] randomized_slv_addr;
        int wr_size, rd_size;

        assert(std::randomize(wr_size,rd_size) with {
            wr_size inside {[1:5]};
            rd_size inside {[1:5]};
            rd_size == wr_size;
        });

        $display("read size : %0d | write size : %0d", rd_size, wr_size);

        //randomize 'only' the slv_addr variable 
        assert(std::randomize(randomized_slv_addr));
        
        trans = i2c_mseq_item::type_id::create("trans");
        /*
        begin
            $display("Inside i2c_rd_wr_sequence");
            `uvm_do_with(req,{req.rd_wr==1'b1; req.slv_addr==7'h6F; req.size_while_read_write == 5; req.repeated_start==1;})
            `uvm_do_with(req,{req.rd_wr==1'b0; req.slv_addr==7'h6F; req.data.size()==8'h3; req.repeated_start==0;})
        end
        */
    
        //-----------------------------READ PHASE---------------------------------       
        begin
            $display("Inside i2c_read_sequence");
            start_item(trans);  //will not wor with the 'req'....will work in the uvm_do and etc, because does the task internally like create()
            assert(trans.randomize() with {rd_wr==1'b1; slv_addr==randomized_slv_addr; size_while_read_write==5; repeated_start==1'b1;});
            uvm_config_db#(bit)::set(null,"*","rpt_start_value",trans.repeated_start); 
            uvm_config_db#(bit [6:0])::set(null,"*","expected_slv_addr", trans.slv_addr);                 
            finish_item(trans);
        end
        //------------------------------------------------------------------------

        //------------------------------WRITE PHASE-------------------------------        
        begin
            $display("Inside i2c_write_sequence");
            start_item(trans);  //will not wor with the 'req'....will work in the uvm_do and etc, because does the task internally like create()
            assert(trans.randomize() with {rd_wr==1'b0; slv_addr==randomized_slv_addr; data.size()==8'h5; repeated_start==1'b0;});
            uvm_config_db#(bit)::set(null,"*","rpt_start_value",trans.repeated_start);    
            uvm_config_db#(bit [6:0])::set(null,"*","expected_slv_addr", trans.slv_addr);                 
            finish_item(trans);
        end
        //------------------------------------------------------------------------

    endtask

endclass : i2c_rd_wr_sequence

//-------------------------------------WRITE_THEN_READ----------------------------------------//

class i2c_wr_rd_sequence extends i2c_base_sequence;

    `uvm_object_utils(i2c_wr_rd_sequence)
    //typedef uvm_object_registry#(i2c_wr_rd_sequence,"i2c_wr_rd_sequence")type_id;

  
    function new(string name="i2c_wr_rd_sequence");
        super.new(name);
    endfunction
  
    task body();
        i2c_mseq_item trans;

        //it will be used to store the randomized slv_addr
        bit [6:0] randomized_slv_addr;
        int wr_size, rd_size;

        //Randomize such that wr_size > rd_size
        assert(std::randomize(wr_size,rd_size) with {
            wr_size inside {[1:5]};
            rd_size inside {[1:5]};
            wr_size == rd_size;
        });
        $display("write size : %0d | read size : %0d", wr_size, rd_size);

        //randomize 'only' the slv_addr variable 
        assert(std::randomize(randomized_slv_addr));
        $display("Generated slave address is %0h", randomized_slv_addr); 

        trans = i2c_mseq_item::type_id::create("trans");
        /*
        begin
            $display("Inside i2c_wr_rd_sequence");
            `uvm_do_with(req,{req.rd_wr==1'b0; req.slv_addr==7'h6F; req.data.size()==8'h5; req.data[0]==8'hEA; req.repeated_start==1'b1;})
            `uvm_do_with(req,{req.rd_wr==1'b1; req.slv_addr==7'h6F; req.size_while_read_write == 3; req.repeated_start==1'b0;})
        end*/
    
       //------------------------------WRITE PHASE--------------------------------
        begin
            $display("Inside i2c_write_sequence");
            start_item(trans);  //will not wor with the 'req'....will work in the uvm_do and etc, because does the task internally like create()
            assert(trans.randomize() with {rd_wr==1'b0; slv_addr==randomized_slv_addr; data.size()==8'h5; data[0]==8'hEA; repeated_start==1'b1;});
            uvm_config_db#(bit)::set(null,"*","rpt_start_value",trans.repeated_start);
            uvm_config_db#(bit [6:0])::set(null,"*","expected_slv_addr", trans.slv_addr);                 
            finish_item(trans);
        end
        //------------------------------------------------------------------------

        //-----------------------------READ PHASE---------------------------------
        begin
            $display("Inside i2c_read_sequence");
            start_item(trans);  //will not wor with the 'req'....will work in the uvm_do and etc, because does the task internally like create()
            assert(trans.randomize() with {rd_wr==1'b1; slv_addr==randomized_slv_addr; size_while_read_write==5; repeated_start==1'b0;});
            uvm_config_db#(bit)::set(null,"*","rpt_start_value",trans.repeated_start);  
            uvm_config_db#(bit [6:0])::set(null,"*","expected_slv_addr", trans.slv_addr);                 
            finish_item(trans);
        end
        //------------------------------------------------------------------------

    endtask

endclass : i2c_wr_rd_sequence

`endif



            


            
