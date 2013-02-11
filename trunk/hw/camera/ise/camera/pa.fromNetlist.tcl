
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name camera -dir "D:/work/serio-pj/hw/camera/ise/camera/planAhead_run_1" -part xc3s200ft256-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "D:/work/serio-pj/hw/camera/ise/camera/top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/work/serio-pj/hw/camera/ise/camera} }
set_property target_constrs_file "top.ucf" [current_fileset -constrset]
add_files [list {top.ucf}] -fileset [get_property constrset [current_run]]
link_design
