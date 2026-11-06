if [file exists "work"] {vdel -all}
vlib work

vlog -f dut.f
vlog -f tb.f
vopt top -o top_optimized +acc

set NoQuitOnFinish 1
onbreak {resume}

vsim top_optimized +UVM_TESTNAME=random_test
run -all

quit -f
