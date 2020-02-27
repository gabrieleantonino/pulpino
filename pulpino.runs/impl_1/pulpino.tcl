proc start_step { step } {
  set stopFile ".stop.rst"
  if {[file isfile .stop.rst]} {
    puts ""
    puts "*** Halting run - EA reset detected ***"
    puts ""
    puts ""
    return -code error
  }
  set beginFile ".$step.begin.rst"
  set platform "$::tcl_platform(platform)"
  set user "$::tcl_platform(user)"
  set pid [pid]
  set host ""
  if { [string equal $platform unix] } {
    if { [info exist ::env(HOSTNAME)] } {
      set host $::env(HOSTNAME)
    }
  } else {
    if { [info exist ::env(COMPUTERNAME)] } {
      set host $::env(COMPUTERNAME)
    }
  }
  set ch [open $beginFile w]
  puts $ch "<?xml version=\"1.0\"?>"
  puts $ch "<ProcessHandle Version=\"1\" Minor=\"0\">"
  puts $ch "    <Process Command=\".planAhead.\" Owner=\"$user\" Host=\"$host\" Pid=\"$pid\">"
  puts $ch "    </Process>"
  puts $ch "</ProcessHandle>"
  close $ch
}

proc end_step { step } {
  set endFile ".$step.end.rst"
  set ch [open $endFile w]
  close $ch
}

proc step_failed { step } {
  set endFile ".$step.error.rst"
  set ch [open $endFile w]
  close $ch
}

set_msg_config -id {HDL 9-1061} -limit 100000
set_msg_config -id {HDL 9-1654} -limit 100000
set_msg_config  -id {[Synth 8-3352]}  -new_severity {CRITICAL WARNING} 
set_msg_config  -id {[Opt 31-35]}  -new_severity {INFO} 
set_msg_config  -id {[Opt 31-32]}  -new_severity {INFO} 
set_msg_config  -id {[Shape Builder 18-119]}  -new_severity {WARNING} 
set_msg_config  -id {[Filemgmt 20-742]}  -new_severity {ERROR} 
set_msg_config  -id {[Synth 8-350]}  -new_severity {CRITICAL WARNING} 
set_msg_config  -id {[Synth 8-2490]}  -new_severity {WARNING} 
set_msg_config  -id {[Synth 8-2306]}  -new_severity {INFO} 
set_msg_config  -id {[Synth 8-3331]}  -new_severity {CRITICAL WARNING} 
set_msg_config  -id {[Synth 8-3332]}  -new_severity {INFO} 
set_msg_config  -id {[Synth 8-2715]}  -new_severity {ERROR} 

start_step write_bitstream
set rc [catch {
  create_msg_db write_bitstream.pb
  debug::add_scope template.lib 1
  open_checkpoint pulpino_routed.dcp
  set_property webtalk.parent_dir /home/gab/Desktop/FPU_PULP/pulpino/fpga/pulpino/pulpino.cache/wt [current_project]
  write_bitstream -force pulpino.bit 
  catch { write_sysdef -hwdef pulpino.hwdef -bitfile pulpino.bit -meminfo pulpino.mmi -ltxfile debug_nets.ltx -file pulpino.sysdef }
  close_msg_db -file write_bitstream.pb
} RESULT]
if {$rc} {
  step_failed write_bitstream
  return -code error $RESULT
} else {
  end_step write_bitstream
}

