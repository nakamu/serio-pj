
# sample commands for sequencer test
set_tick 50ms
tick 20
set_mode ch0, normal
set_mode ch1, mute
set_mode ch2, mute
set_mode ch3, mute
set_duty ch0, 7
set_duty ch1, 8
set_duty ch2, 9
set_duty ch3, 10
set_note ch0, 2, C
tick 4
set_note ch0, 2, D
tick 4
set_note ch0, 2, E
tick 4
set_note ch0, 2, F
tick 4
set_note ch0, 2, G
tick 4
set_note ch0, 2, A
tick 4
set_note ch0, 2, B
tick 4
set_note ch0, 3, C
tick 4
halt