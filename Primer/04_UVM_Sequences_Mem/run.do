if [file exists "work"] {vdel -all}
vlib work

vlog -f files.f
vopt tb_top -o tb_top_opt +acc

set NoQuitOnFinish 1
onbreak {resume}

vsim tb_top_opt +UVM_TESTNAME=write_read_test
run -all

vsim tb_top_opt +UVM_TESTNAME=random_test
run -all

quit -f
