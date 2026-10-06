vlib work
vlog baud_generation.v tx.v rx.v top.v tb.v synchronizer.v
vsim -voptargs=+acc work.tb
add wave *
run -all
