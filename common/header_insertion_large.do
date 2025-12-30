onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tready_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tvalid_in
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tdata_in
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tlast_in
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tkeep_in
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tready_in
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tvalid_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tdata_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tlast_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tkeep_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/header_data
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/source_mac_address
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/destination_mac_address
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/ethernet_type
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/header_data_112bit
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/header_data_64bit
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/header_data_32bit
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/beat_counter
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/prbs_register
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/prbs_verifier
add wave -noupdate -radix hexadecimal /header_capture_testbench/verification_state
add wave -noupdate -radix hexadecimal /header_capture_testbench/large_beat_size/verifier_shift_register
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/data_valid
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/header_capture_state
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/i
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tdata_shift_register
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/packet_byte_counter
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/header_byte_counter
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/header_shift_register
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/udp_checksum
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/udp_payload_data
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/checksum_data_input
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/udp_checksum_swapped
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/udp_length_swapped
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/udp_destination_swapped
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/udp_source_swapped
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/enable_verification
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tready_tx_in
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tvalid_tx_out
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/tdata_tx_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tlast_tx_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/tkeep_tx_out
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/clock
add wave -noupdate -color Gold -itemcolor Gold /header_capture_testbench/reset
add wave -noupdate -color Gold -itemcolor Gold -radix hexadecimal /header_capture_testbench/datagram_header
add wave -noupdate /header_capture_testbench/large_beat_size/tdata_leftover
add wave -noupdate /header_capture_testbench/large_beat_size/tkeep_leftover
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/clock
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/reset
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_rx/tready_out
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_rx/tvalid_in
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /header_capture_testbench/dut_rx/tdata_in
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_rx/tlast_in
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_rx/tkeep_in
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_rx/tready_in
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_rx/tvalid_out
add wave -noupdate -color Red -itemcolor Red -radix hexadecimal /header_capture_testbench/dut_rx/tdata_out
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_rx/tlast_out
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_rx/tkeep_out
add wave -noupdate -color Red -itemcolor Red -radix hexadecimal /header_capture_testbench/dut_rx/header_data
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /header_capture_testbench/dut_rx/header_state
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /header_capture_testbench/dut_rx/capture_output_state
add wave -noupdate -radix hexadecimal /header_capture_testbench/dut_rx/data_shift_register
add wave -noupdate /header_capture_testbench/dut_rx/control_shift_register
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_write_enable
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_read_enable
add wave -noupdate -color Brown -itemcolor Brown -radix hexadecimal /header_capture_testbench/dut_rx/fifo_data_in
add wave -noupdate -color Brown -itemcolor Brown -radix hexadecimal /header_capture_testbench/dut_rx/fifo_data_out
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_data_valid
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_data_empty
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_data_full
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_control_in
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_control_out
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_control_valid
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_control_empty
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/fifo_control_full
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/byte_counter
add wave -noupdate -color Brown -itemcolor Brown /header_capture_testbench/dut_rx/header_byte_counter
add wave -noupdate -color Brown -itemcolor Brown -radix hexadecimal /header_capture_testbench/dut_rx/header_shift_register
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/clock
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/reset
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_tx/tready_out
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_tx/tvalid_in
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /header_capture_testbench/dut_tx/tdata_in
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_tx/tlast_in
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_tx/tkeep_in
add wave -noupdate -color Cyan -itemcolor Cyan /header_capture_testbench/dut_tx/tready_in
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_tx/tvalid_out
add wave -noupdate -color Red -itemcolor Red -radix hexadecimal /header_capture_testbench/dut_tx/tdata_out
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_tx/tlast_out
add wave -noupdate -color Red -itemcolor Red /header_capture_testbench/dut_tx/tkeep_out
add wave -noupdate -color Cyan -itemcolor Cyan -radix hexadecimal /header_capture_testbench/dut_tx/header_data
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_write_enable
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_read_enable
add wave -noupdate -color Green -itemcolor Green -radix hexadecimal /header_capture_testbench/dut_tx/fifo_data_in
add wave -noupdate -color Green -itemcolor Green -radix hexadecimal /header_capture_testbench/dut_tx/fifo_data_out
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_data_valid
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_data_empty
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_data_full
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_control_in
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_control_out
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_control_valid
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_control_empty
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/fifo_control_full
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /header_capture_testbench/dut_tx/header_insertion_state
add wave -noupdate -color Green -itemcolor Green -radix hexadecimal /header_capture_testbench/dut_tx/tdata_leftover
add wave -noupdate -color Green -itemcolor Green /header_capture_testbench/dut_tx/tkeep_leftover
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/clock
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/reset
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/write_enable
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/data_in
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/read_enable
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/data_out
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/data_valid
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/empty
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/full
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/data_array
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/input_counter
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/output_pointer
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/current_size
add wave -noupdate /header_capture_testbench/dut_tx/data_memory/i
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/clock
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/reset
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/write_enable
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/data_in
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/read_enable
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/data_out
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/data_valid
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/empty
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/full
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/data_array
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/input_counter
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/output_pointer
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/current_size
add wave -noupdate /header_capture_testbench/dut_tx/control_memory/i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1189751 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 169
configure wave -valuecolwidth 131
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
WaveRestoreZoom {0 ps} {10810 ps}
