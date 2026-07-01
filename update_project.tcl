# update_project.tcl
# This script CORRECTS the project paths to use LOCAL files instead of the 2025 versions.

set project_name "fir_iir_23_03_2026"
set local_src_dir "./fir_iir_23_03_2026.srcs/sources_1/new"
set local_con_dir "./fir_iir_27_02_2025/fir_iir_27_02_2025.srcs/constrs_1/new" 
# Wait, even your local path has '27_02_2025' in the folder name inside your project! 
# I will just use absolute paths to be 100% sure.

puts "Step 1: Removing all external/broken file references..."
set all_files [get_files]
foreach f $all_files {
    if {[string match "*27_02_2025*" $f]} {
        puts "Removing outlier: $f"
        remove_files $f
    }
}

puts "Step 2: Adding LOCAL updated source files..."
# This forces Vivado to look at the files I just edited.
add_files C:/Users/skali/fir_iir_23_03_2026/fir_iir_23_03_2026.srcs/sources_1/new/top_static.v
add_files C:/Users/skali/fir_iir_23_03_2026/fir_iir_23_03_2026.srcs/sources_1/new/latency_tester.v
add_files C:/Users/skali/fir_iir_23_03_2026/fir_iir_23_03_2026.srcs/sources_1/new/pr_filter_slot.v
add_files C:/Users/skali/fir_iir_23_03_2026/fir_iir_23_03_2026.srcs/sources_1/new/rm_pr_fir64.v
add_files C:/Users/skali/fir_iir_23_03_2026/fir_iir_23_03_2026.srcs/sources_1/new/rm_pr_iir_chain.v
add_files C:/Users/skali/fir_iir_23_03_2026/fir_iir_23_03_2026.srcs/sources_1/new/uart_cmd_parser_4bank.v
add_files [glob C:/Users/skali/fir_iir_23_03_2026/fir_iir_23_03_2026.srcs/sources_1/new/*.v]

puts "Step 3: Adding LOCAL constraint file..."
add_files -fileset constrs_1 C:/Users/skali/fir_iir_27_02_2025/fir_iir_27_02_2025.srcs/constrs_1/new/const.xdc

puts "Step 4: Rebuilding Hierarchy..."
update_compile_order -fileset sources_1
set_property top top_static [current_fileset]

puts "=========================================================="
# Logic check:
if {[get_files latency_tester.v] ne ""} {
    puts "SUCCESS: Latency Tester is now in the project!"
} else {
    puts "WARNING: Latency Tester still missing. Check paths."
}
puts "=========================================================="
