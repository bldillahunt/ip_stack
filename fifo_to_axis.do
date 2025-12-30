onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/clock
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/reset
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_write_enable
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /fifo_to_axis_testbench/fifo_data_in
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_read_enable
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /fifo_to_axis_testbench/fifo_data_out
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_data_valid
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_data_empty
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_data_full
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_control_in
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_control_out
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_control_valid
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_control_empty
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/fifo_control_full
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/data_valid_reg
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /fifo_to_axis_testbench/data_reg
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/last_reg
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/keep_reg
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/control_valid_reg
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/control_data_reg
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/control_last_reg
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/control_keep_reg
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /fifo_to_axis_testbench/prbs_register
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /fifo_to_axis_testbench/prbs_shift_register
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/byte_counter
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /fifo_to_axis_testbench/ip_to_axis_state
add wave -noupdate -color Gold -itemcolor Gold /fifo_to_axis_testbench/tready_in
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/reset
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/clock
add wave -noupdate -color Red -itemcolor Red /fifo_to_axis_testbench/tdata_interface/fifo_read_enable
add wave -noupdate -color Cyan -itemcolor Cyan /fifo_to_axis_testbench/tdata_interface/fifo_empty
add wave -noupdate -color Cyan -itemcolor Cyan /fifo_to_axis_testbench/tdata_interface/fifo_full
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /fifo_to_axis_testbench/tdata_interface/fifo_data_out
add wave -noupdate -color Cyan -itemcolor Cyan /fifo_to_axis_testbench/tdata_interface/fifo_data_valid
add wave -noupdate -color Cyan -itemcolor Cyan /fifo_to_axis_testbench/tdata_interface/tready_in
add wave -noupdate -color Red -itemcolor Red /fifo_to_axis_testbench/tdata_interface/tvalid_out
add wave -noupdate -color Red -itemcolor Red -radix hexadecimal /fifo_to_axis_testbench/tdata_interface/tdata_out
add wave -noupdate -color Red -itemcolor Red /fifo_to_axis_testbench/tdata_interface/tlast_out
add wave -noupdate -color Red -itemcolor Red /fifo_to_axis_testbench/tdata_interface/tkeep_out
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/i
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /fifo_to_axis_testbench/tdata_interface/fifo_to_axis_state
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/end_of_frame
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/valid_queue
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/queue_counter
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/reset_pointer
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/flush_pipeline
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/ready_to_send
add wave -noupdate -radix hexadecimal -childformat {{{/fifo_to_axis_testbench/tdata_interface/data_queue[0]} -radix hexadecimal} {{/fifo_to_axis_testbench/tdata_interface/data_queue[1]} -radix hexadecimal} {{/fifo_to_axis_testbench/tdata_interface/data_queue[2]} -radix hexadecimal} {{/fifo_to_axis_testbench/tdata_interface/data_queue[3]} -radix hexadecimal}} -expand -subitemconfig {{/fifo_to_axis_testbench/tdata_interface/data_queue[0]} {-height 15 -radix hexadecimal} {/fifo_to_axis_testbench/tdata_interface/data_queue[1]} {-height 15 -radix hexadecimal} {/fifo_to_axis_testbench/tdata_interface/data_queue[2]} {-height 15 -radix hexadecimal} {/fifo_to_axis_testbench/tdata_interface/data_queue[3]} {-height 15 -radix hexadecimal}} /fifo_to_axis_testbench/tdata_interface/data_queue
add wave -noupdate /fifo_to_axis_testbench/tdata_interface/output_pointer
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/reset
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/clock
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/fifo_read_enable
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/fifo_empty
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/fifo_full
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/fifo_data_out
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/fifo_data_valid
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/tready_in
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/tvalid_out
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/tdata_out
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/tlast_out
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/tkeep_out
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/i
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/fifo_to_axis_state
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/queue_counter
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/reset_pointer
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/flush_pipeline
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/ready_to_send
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/data_queue
add wave -noupdate /fifo_to_axis_testbench/control_signal_interface/output_pointer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1142834 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 238
configure wave -valuecolwidth 188
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {997914 ps} {1013132 ps}
