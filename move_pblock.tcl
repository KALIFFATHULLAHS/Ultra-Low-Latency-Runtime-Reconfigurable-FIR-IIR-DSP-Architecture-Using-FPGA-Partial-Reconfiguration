# Move the PR Pblock to the empty region of the chip!
set pblock [get_pblocks pblock_U_PR_SLOT]

# Remove the old massive overlapping clock regions
resize_pblock $pblock -remove {CLOCKREGION_X1Y1:CLOCKREGION_X1Y2}

# Add just the completely empty bottom-right clock region
resize_pblock $pblock -add {CLOCKREGION_X1Y0:CLOCKREGION_X1Y0}

# Enforce hardware reset during reconfiguration and save
set_property RESET_AFTER_RECONFIG true $pblock
set_property SNAPPING_MODE ON $pblock

save_constraints -force
puts "PBLOCK SAFELY RELOCATED TO X1Y0!"
