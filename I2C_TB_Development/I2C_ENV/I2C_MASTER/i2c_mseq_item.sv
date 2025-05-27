
//Guard statements to avoid compilation of the same file multiple times
`ifndef I2C_MSEQ_ITEM_UVM
`define I2C_MSEQ_ITEM_UVM

//`define ADDR_WIDTH 7
//`define DATA_WIDTH 8

class i2c_mseq_item extends uvm_sequence_item;

    //-------------------------------------------
    //declare variables
    //-------------------------------------------
    rand bit [6:0]  slv_addr; 
    rand bit rd_wr;
    rand bit [7:0] data[$];
    rand bit repeated_start;
    rand int size_while_read_write;    

    //-------------------------------------------
    //constructor
    //-------------------------------------------
    function new(string name = "i2c_mseq_item");
        super.new(name);
    endfunction

    /*
    typedef uvm_object_registry#(i2c_mseq_item,"i2c_mseq_item")type_id;

    virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("slv_addr",slv_addr,$bits(slv_addr));
    printer.print_field("rd_wr",rd_wr,$bits(rd_wr));
    //printer.print_field("data",data,$bits(data));
    printer.print_array_header("data", data.size(), "bit[7:0]");
    foreach (data[i]) begin
        printer.print_field($sformatf("data[%0d]", i), data[i], $bits(data[i]));
    end
    printer.print_array_footer(); // optional, good for consistency
    
    printer.print_field("repeated_start",repeated_start,$bits(repeated_start));
    printer.print_field("size_while_read_write",size_while_read_write,$bits(size_while_read_write));
    endfunction
    */
    
    //--------------------------------------------------
    //factory registration
    //--------------------------------------------------
    `uvm_object_utils_begin(i2c_mseq_item)
    	`uvm_field_int(slv_addr,UVM_ALL_ON)
    	`uvm_field_int(rd_wr,UVM_ALL_ON)
    	`uvm_field_queue_int(data,UVM_ALL_ON) //queue
        `uvm_field_int(repeated_start,UVM_ALL_ON)
        `uvm_field_int(size_while_read_write,UVM_ALL_ON)
    `uvm_object_utils_end

    constraint slave_address { slv_addr > 0; }
    constraint data_size     { data.size() inside {[1:5]}; } 
    constraint read_size     { size_while_read_write inside {[1:5]}; }

    //constraint s_addr {slv_addr == 7'b110_1101;}
    //constraint w_data {data == 8'b1100_1010;}
    //constraint read_write {rd_wr == 1'b0;}
    
endclass : i2c_mseq_item

`endif
    
