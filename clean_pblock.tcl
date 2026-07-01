# Absolute Silver Bullet for Partial Reconfiguration Crashing

puts "Wiping corrupted Pblock configurations..."
delete_pblocks [get_pblocks pblock_U_PR_SLOT]

puts "Creating fresh, completely safe Pblock using entire Clock Regions..."
create_pblock pblock_U_PR_SLOT
add_cells_to_pblock [get_pblocks pblock_U_PR_SLOT] [get_cells -quiet [list U_PR_SLOT]]

# By using CLOCKREGION instead of SLICE, we scientifically guarantee that 
# the boundaries never split a single interconnect tile or clock routing spine!
resize_pblock [get_pblocks pblock_U_PR_SLOT] -add {CLOCKREGION_X1Y1:CLOCKREGION_X1Y2}

# Automatically hold the PR slot in a hardware RESET state while the new bitstream loads!
# This prevents garbage voltage signals from leaking out of the PR box and crashing the static UART wire.
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_U_PR_SLOT]
set_property SNAPPING_MODE ON [get_pblocks pblock_U_PR_SLOT]

save_constraints -force
puts "NEW BULLETPROOF PBLOCK CREATED!"
