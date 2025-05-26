lib :                                                 		
	vlib work                                     		
comp :	                                              		
	 vlog my_pkg.sv i2c_top.sv   
sim :	                                              		
	 vsim -vopt top -c -do "run -all; exit"  	
gui :	                                              		
	 vsim -voptargs=+acc work.top               		
clean :	                                              		
	rm -rf work transcript dump.vcd  
	
rungui : clean lib comp gui
runall : clean lib comp sim

#####################################################################################
#sim_cov:
#	vsim -classdebug -novopt -sva -coverage -l test.log i2c_top -cvgperinstance -c -do "coverage save -onexit -directive -cvg -codeall cov_ucdb.ucdb; run -all; exit"  
#comp_cov:
#	vlog -coveropt 3 +cover=sceft +acc i2c_interface.sv my_pkg.sv i2c_top.sv
#create_html:
#	vcover report -details -html cov_ucdb.ucdb
#	vcover report cov_ucdb.ucdb -file coverage.rpt
#####################################################################################

TOP_MODULE = top

TEST = ""

sim:
	vlog my_pkg.sv i2c_top.sv
	vsim -voptargs=+"acc" $(TOP_MODULE) -c -do "run -all; exit" +UVM_TESTNAME=$(TEST)

regress:
	vlog -coveropt 3 +cover +acc my_pkg.sv i2c_top.sv 

	vsim -coverage -voptargs=+"acc" $(TOP_MODULE) -c -do "coverage save -onexit -directive -cvg -codeall i2c_write_test.ucdb; run -all; exit" +UVM_TESTNAME=i2c_write_test +i2c_write_test
	vsim -coverage -voptargs=+"acc" $(TOP_MODULE) -c -do "coverage save -onexit -directive -cvg -codeall i2c_read_test.ucdb; run -all; exit" +UVM_TESTNAME=i2c_read_test +i2c_read_test
	vsim -coverage -voptargs=+"acc" $(TOP_MODULE) -c -do "coverage save -onexit -directive -cvg -codeall i2c_wr_rd_test.ucdb; run -all; exit" +UVM_TESTNAME=i2c_wr_rd_test +i2c_wr_rd_test
	vsim -coverage -voptargs=+"acc" $(TOP_MODULE) -c -do "coverage save -onexit -directive -cvg -codeall i2c_rd_wr_test.ucdb; run -all; exit" +UVM_TESTNAME=i2c_rd_wr_test +i2c_rd_wr_test
	vsim -coverage -voptargs=+"acc" $(TOP_MODULE) -c -do "coverage save -onexit -directive -cvg -codeall i2c_user_callback_test.ucdb; run -all; exit" +UVM_TESTNAME=i2c_user_callback_test +i2c_user_callback_test
	

	vcover merge i2c_full_cover.ucdb  i2c_write_test.ucdb i2c_read_test.ucdb i2c_wr_rd_test.ucdb i2c_rd_wr_test.ucdb i2c_user_callback_test.ucdb
	vcover report -html -details -htmldir I2C_COVERAGE i2c_full_cover.ucdb
