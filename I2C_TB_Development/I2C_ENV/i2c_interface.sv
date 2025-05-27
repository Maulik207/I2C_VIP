
`ifndef I2C_INTERFACE_UVM
`define I2C_INTERFACE_UVM

interface intf(tri1 sda);

    tri1 scl;
    bit reset;

    logic to_sda;
    assign sda = to_sda;

    event stop_detect;
    event flag_detect;
    event trigger;

    /////////////////////////////////////////////////////////////////////
    //ASSERTION--->Still Working
    /////////////////////////////////////////////////////////////////////
    /*
    property p1;
        @(posedge scl) disable iff(reset)
        ($past(sda) == 1 && sda == 0);
    endproperty
    assert property(p1)
        $display($time, "START condition assertion PASS");
    else
        $display($time, "START condition assertion FAIL");

    property p2;
        @(posedge scl) disable iff(reset)
        ($past(sda) == 0 && sda == 1);
    endproperty
    assert property(p2)
        $display($time, "STOP condition assertion PASS");
    else
        $display($time, "STOP condition assertion FAIL");
    */

endinterface

`endif

/*
interface intf(tri1 sda);

    //tri1 sda;
    //tri1 scl;
    //logic to_scl;
    tri1 scl;

    bit reset;

    logic to_sda;
    assign sda = to_sda;

    event stop_detect;
    event flag_detect;
    event trigger;
    
    //assign scl = to_scl;


    /*
    wire sda;
    wire scl;
    bit to_sda=1;  //logic to_sda=1;
    bit to_scl;    //logic to_scl=1;

    assign scl=(to_scl===1'bz) ? 1'bz: (to_scl ? 1'bz: 1'b0);
    assign (weak0,weak1)scl=1'b1;

    assign sda=(to_sda===1'bz) ? 1'bz: (to_sda ? 1'bz: 1'b0);
    assign (weak0,weak1)sda=1'b1;
    


    //Change--->SCL line is low. Data bit to be transferred is applied to the SDA line.
    //Data--->high or low bit of information on SDA line is valid during the high level of the SCL line.
    


    ////////////////////////////////////////////
    //clocking block
    ////////////////////////////////////////////
    clocking m_drv_ctrl@(posedge scl); //controls "when" to drive data
        //defualt input#1 output #0;
        output to_sda;
    endclocking

    clocking m_drv_data@(negedge scl); //controls "actual" data change
        //default input#1 output#0;
        output to_sda;
    endclocking

    clocking m_mon_cb@(posedge scl);
        //default input#1 output#0;
        input sda;
    endclocking

    clocking s_drv_cb@(posedge scl);
        //default input#1 output#0;
        inout sda;
        inout scl;
    endclocking

    clocking s_mon_cb@(posedge scl)
        //default input#1 output#0;
        input sda;
    endclocking

    /////////////////////////////////////////////
    //modport
    /////////////////////////////////////////////
    modport M_DRV(clocking m_drv_data);
    modport M_MON(clocking m_mon_cb);
    modport S_DRV(clocking s_drv_cb);
    modport S_MON(clocking s_mon_cb);
    
        
endinterface

`endif
*/
