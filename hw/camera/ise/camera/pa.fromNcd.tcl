
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name camera -dir "D:/work/serio-pj/hw/camera/ise/camera/planAhead_run_1" -part xc3s200ft256-4
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "D:/work/serio-pj/hw/camera/ise/camera/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/work/serio-pj/hw/camera/ise/camera} }
set_property target_constrs_file "top.ucf" [current_fileset -constrset]
add_files [list {top.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "D:/work/serio-pj/hw/camera/ise/camera/top.ncd"
if {[catch {read_twx -name results_1 -file "D:/work/serio-pj/hw/camera/ise/camera/top.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"D:/work/serio-pj/hw/camera/ise/camera/top.twx\": $eInfo"
}
