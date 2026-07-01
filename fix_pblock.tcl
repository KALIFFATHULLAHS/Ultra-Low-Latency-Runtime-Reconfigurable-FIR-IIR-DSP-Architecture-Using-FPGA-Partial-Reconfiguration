# Auto-Snap the PR Box to Legal Boundaries
# This script grabs your purple PR box and forces it to strictly obey
# Xilinx's 7-series interconnect column laws!

# Set snapping mode permanently
set_property SNAPPING_MODE ON [get_pblocks pblock_U_PR_SLOT]

# Forcefully re-evaluate the geometry in memory
set pblock [get_pblocks pblock_U_PR_SLOT]
resize_pblock $pblock -add {SLICE_X52Y5:SLICE_X79Y199} -remove {SLICE_X80Y5:SLICE_X81Y199}
resize_pblock $pblock -add {SLICE_X82Y50:SLICE_X85Y149}

puts "PBLOCK SNAPPING MODE FORCED ON!"
puts "Please save your project and RE-RUN IMPLEMENTATION!"
