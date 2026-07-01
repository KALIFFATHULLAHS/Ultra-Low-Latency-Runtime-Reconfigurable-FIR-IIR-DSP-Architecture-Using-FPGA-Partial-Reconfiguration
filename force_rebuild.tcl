puts "Fixing run relationships..."
source fix_runs.tcl

puts "Resetting all cached runs to guarantee the new code is used..."
reset_run synth_1
reset_run pr_filter_slot_synth_1
reset_run impl_1
reset_run impl_2
reset_run impl_3

puts "Step 1: Launching Parent implementation (impl_1)..."
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

puts "Step 2: Launching Child implementations (impl_2, impl_3)..."
launch_runs impl_2 impl_3 -to_step write_bitstream -jobs 8
wait_on_run impl_2
wait_on_run impl_3

puts "================================================="
puts "ALL NEW FIR AND IIR BITSTREAMS HAVE BEEN CREATED!"
puts "================================================="
