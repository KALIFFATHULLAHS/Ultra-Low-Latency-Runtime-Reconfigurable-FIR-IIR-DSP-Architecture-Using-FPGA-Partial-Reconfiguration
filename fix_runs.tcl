# fix_runs.tcl
# This script re-creates implementations as Child Runs to ensure static compatibility.

puts "Checking DFX Run Relationships..."

# 1. Define Parent
set parent_run "impl_1"

# 2. Check and Re-create Child Runs if necessary
foreach {run_name cfg} {impl_2 config_2 impl_3 config_3} {
    set run_obj [get_runs -quiet $run_name]
    
    set needs_recreate 0
    if {$run_obj == ""} {
        set needs_recreate 1
    } else {
        # Check if the parent is correct. The 'PARENT' property is read-only.
        # If it's empty or wrong, we must recreate.
        set current_parent [get_property PARENT $run_obj]
        if {$current_parent != $parent_run} {
            puts "Run $run_name is not a child of $parent_run. Deleting and re-creating..."
            delete_runs $run_name
            set needs_recreate 1
        }
    }

    if {$needs_recreate} {
        puts "Creating child run $run_name with parent $parent_run and config $cfg..."
        # Create as a child run (this ensures it reuses the static layout)
        create_run $run_name -parent_run $parent_run -flow {Vivado Implementation 2025} -pr_config $cfg
        
        # Match settings
        set_property part [get_property part [get_runs $parent_run]] [get_runs $run_name]
        set_property strategy [get_property strategy [get_runs $parent_run]] [get_runs $run_name]
    } else {
        puts "Run $run_name is already correctly configured."
    }
}

# 3. Success message
puts "Successfully configured DFX run hierarchy."
