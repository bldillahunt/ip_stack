onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ethernet_testbench/clock
add wave -noupdate /ethernet_testbench/reset
add wave -noupdate /ethernet_testbench/ip_rx_tready
add wave -noupdate /ethernet_testbench/ip_rx_tvalid
add wave -noupdate /ethernet_testbench/ip_rx_tdata
add wave -noupdate /ethernet_testbench/ip_rx_tkeep
add wave -noupdate /ethernet_testbench/ip_rx_tlast
add wave -noupdate /ethernet_testbench/arp_rx_tready
add wave -noupdate /ethernet_testbench/arp_rx_tvalid
add wave -noupdate /ethernet_testbench/arp_rx_tdata
add wave -noupdate /ethernet_testbench/arp_rx_tkeep
add wave -noupdate /ethernet_testbench/arp_rx_tlast
add wave -noupdate /ethernet_testbench/tvalid_in
add wave -noupdate -radix hexadecimal /ethernet_testbench/tdata_in
add wave -noupdate /ethernet_testbench/tlast_in
add wave -noupdate /ethernet_testbench/tkeep_in
add wave -noupdate /ethernet_testbench/tready_tx_in
add wave -noupdate /ethernet_testbench/tready_out
add wave -noupdate /ethernet_testbench/beat_counter
add wave -noupdate -radix hexadecimal /ethernet_testbench/prbs_register
add wave -noupdate -radix hexadecimal /ethernet_testbench/prbs_verifier
add wave -noupdate /ethernet_testbench/data_valid
add wave -noupdate -radix hexadecimal /ethernet_testbench/header_capture_state
add wave -noupdate /ethernet_testbench/i
add wave -noupdate -radix hexadecimal /ethernet_testbench/tdata_shift_register
add wave -noupdate /ethernet_testbench/packet_byte_counter
add wave -noupdate /ethernet_testbench/header_byte_counter
add wave -noupdate -radix hexadecimal /ethernet_testbench/header_shift_register
add wave -noupdate -radix hexadecimal /ethernet_testbench/temac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/header_data_112bit
add wave -noupdate -radix hexadecimal /ethernet_testbench/verification_state
add wave -noupdate /ethernet_testbench/mac_rx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/mac_rx_tdata
add wave -noupdate /ethernet_testbench/mac_rx_tkeep
add wave -noupdate /ethernet_testbench/mac_rx_tlast
add wave -noupdate /ethernet_testbench/mac_rx_tuser
add wave -noupdate /ethernet_testbench/mac_rx_filter_tuser
add wave -noupdate /ethernet_testbench/ip_rx_tready
add wave -noupdate /ethernet_testbench/ip_rx_tvalid
add wave -noupdate /ethernet_testbench/ip_rx_tdata
add wave -noupdate /ethernet_testbench/ip_rx_tkeep
add wave -noupdate /ethernet_testbench/ip_rx_tlast
add wave -noupdate /ethernet_testbench/arp_rx_tready
add wave -noupdate /ethernet_testbench/arp_rx_tvalid
add wave -noupdate /ethernet_testbench/arp_rx_tdata
add wave -noupdate /ethernet_testbench/arp_rx_tkeep
add wave -noupdate /ethernet_testbench/arp_rx_tlast
add wave -noupdate /ethernet_testbench/received_mac_address
add wave -noupdate /ethernet_testbench/valid_mac_address
add wave -noupdate /ethernet_testbench/mac_tx_tready
add wave -noupdate /ethernet_testbench/mac_tx_tvalid
add wave -noupdate /ethernet_testbench/mac_tx_tdata
add wave -noupdate /ethernet_testbench/mac_tx_tkeep
add wave -noupdate /ethernet_testbench/mac_tx_tlast
add wave -noupdate /ethernet_testbench/mac_tx_tuser
add wave -noupdate /ethernet_testbench/mac_tx_filter_tuser
add wave -noupdate /ethernet_testbench/tvalid_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/tdata_out
add wave -noupdate /ethernet_testbench/tlast_out
add wave -noupdate /ethernet_testbench/tkeep_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/header_data
add wave -noupdate -radix hexadecimal /ethernet_testbench/source_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/destination_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/ethernet_type
add wave -noupdate -radix hexadecimal /ethernet_testbench/datagram_header
add wave -noupdate /ethernet_testbench/tvalid_tx_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/tdata_tx_out
add wave -noupdate /ethernet_testbench/tlast_tx_out
add wave -noupdate /ethernet_testbench/tkeep_tx_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/medium_data_size_uneven/tdata_leftover
add wave -noupdate /ethernet_testbench/medium_data_size_uneven/tkeep_leftover
add wave -noupdate -radix hexadecimal /ethernet_testbench/medium_data_size_uneven/prbs_shift_register
add wave -noupdate /ethernet_testbench/medium_data_size_uneven/tkeep_shift_register
add wave -noupdate -radix hexadecimal /ethernet_testbench/medium_data_size_uneven/verifier_shift_register
add wave -noupdate -radix hexadecimal /ethernet_testbench/medium_data_size_uneven/leftover_prbs_data
add wave -noupdate /ethernet_testbench/medium_data_size_uneven/byte_counter
add wave -noupdate /ethernet_testbench/dut_rx/reset
add wave -noupdate /ethernet_testbench/dut_rx/clock
add wave -noupdate /ethernet_testbench/dut_rx/temac_rx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/temac_rx_tdata
add wave -noupdate /ethernet_testbench/dut_rx/temac_rx_tkeep
add wave -noupdate /ethernet_testbench/dut_rx/temac_rx_tlast
add wave -noupdate /ethernet_testbench/dut_rx/temac_rx_tuser
add wave -noupdate /ethernet_testbench/dut_rx/temac_rx_filter_tuser
add wave -noupdate /ethernet_testbench/dut_rx/ip_rx_tready
add wave -noupdate /ethernet_testbench/dut_rx/ip_rx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/ip_rx_tdata
add wave -noupdate /ethernet_testbench/dut_rx/ip_rx_tkeep
add wave -noupdate /ethernet_testbench/dut_rx/ip_rx_tlast
add wave -noupdate /ethernet_testbench/dut_rx/arp_rx_tready
add wave -noupdate /ethernet_testbench/dut_rx/arp_rx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/arp_rx_tdata
add wave -noupdate /ethernet_testbench/dut_rx/arp_rx_tkeep
add wave -noupdate /ethernet_testbench/dut_rx/arp_rx_tlast
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/temac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/received_mac_address
add wave -noupdate /ethernet_testbench/dut_rx/valid_mac_address
add wave -noupdate /ethernet_testbench/dut_rx/tready_out
add wave -noupdate /ethernet_testbench/dut_rx/tvalid_in
add wave -noupdate /ethernet_testbench/dut_rx/tdata_in
add wave -noupdate /ethernet_testbench/dut_rx/tlast_in
add wave -noupdate /ethernet_testbench/dut_rx/tkeep_in
add wave -noupdate /ethernet_testbench/dut_rx/tready_in
add wave -noupdate /ethernet_testbench/dut_rx/tvalid_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/tdata_out
add wave -noupdate /ethernet_testbench/dut_rx/tlast_out
add wave -noupdate /ethernet_testbench/dut_rx/tkeep_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/header_data
add wave -noupdate /ethernet_testbench/dut_rx/header_data_valid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/source_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/destination_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/ethernet_type
add wave -noupdate /ethernet_testbench/dut_rx/temac_rx_tready
add wave -noupdate /ethernet_testbench/dut_rx/header_data_valid_reg
add wave -noupdate /ethernet_testbench/dut_rx/header_pending
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/current_header
add wave -noupdate /ethernet_testbench/dut_rx/temac_done_pending
add wave -noupdate /ethernet_testbench/dut_rx/arp_done_pending
add wave -noupdate /ethernet_testbench/dut_rx/ip_done_pending
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /ethernet_testbench/dut_rx/ethernet_receive_state
add wave -noupdate /ethernet_testbench/dut_rx/clear_header_pending
add wave -noupdate /ethernet_testbench/dut_rx/enable_arp_interface
add wave -noupdate /ethernet_testbench/dut_rx/enable_ip_interface
add wave -noupdate /ethernet_testbench/dut_rx/flush_data_stream
add wave -noupdate /ethernet_testbench/dut_rx/clear_arp_done_pending
add wave -noupdate /ethernet_testbench/dut_rx/clear_ip_done_pending
add wave -noupdate /ethernet_testbench/dut_rx/clear_temac_done_pending
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/clock
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/reset
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tready_out
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tvalid_in
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/tdata_in
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tlast_in
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tkeep_in
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tready_in
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tvalid_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/tdata_out
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tlast_out
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tkeep_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/header_data
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/header_data_valid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/header_state
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_write_enable
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/fifo_data_in
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/fifo_data_out
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_data_valid
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_data_empty
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_data_full
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_control_in
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_control_out
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_control_valid
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_control_empty
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_control_full
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/byte_counter
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/header_byte_counter
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/data_shift_register
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/control_shift_register
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_read_counter
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/ipg_counter
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/header_shift_register
add wave -noupdate /ethernet_testbench/dut_tx/reset
add wave -noupdate /ethernet_testbench/dut_tx/clock
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/source_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/destination_mac_address
add wave -noupdate /ethernet_testbench/dut_tx/ip_tx_tready
add wave -noupdate /ethernet_testbench/dut_tx/ip_tx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_tx_tdata
add wave -noupdate /ethernet_testbench/dut_tx/ip_tx_tkeep
add wave -noupdate /ethernet_testbench/dut_tx/ip_tx_tlast
add wave -noupdate /ethernet_testbench/dut_tx/arp_tx_tready
add wave -noupdate /ethernet_testbench/dut_tx/arp_tx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/arp_tx_tdata
add wave -noupdate /ethernet_testbench/dut_tx/arp_tx_tkeep
add wave -noupdate /ethernet_testbench/dut_tx/arp_tx_tlast
add wave -noupdate /ethernet_testbench/dut_tx/temac_tx_tvalid
add wave -noupdate /ethernet_testbench/dut_tx/temac_tx_tready
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/temac_tx_tdata
add wave -noupdate /ethernet_testbench/dut_tx/temac_tx_tkeep
add wave -noupdate /ethernet_testbench/dut_tx/temac_tx_tlast
add wave -noupdate /ethernet_testbench/dut_tx/temac_tx_tuser
add wave -noupdate /ethernet_testbench/dut_tx/temac_tx_filter_tuser
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/header_data
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/protocol_type
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ethernet_state
add wave -noupdate /ethernet_testbench/dut_tx/enable_ip_interface
add wave -noupdate /ethernet_testbench/dut_tx/enable_arp_interface
add wave -noupdate /ethernet_testbench/dut_tx/ip_mac_tready
add wave -noupdate /ethernet_testbench/dut_tx/ip_mac_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_mac_tdata
add wave -noupdate /ethernet_testbench/dut_tx/ip_mac_tlast
add wave -noupdate /ethernet_testbench/dut_tx/ip_mac_tkeep
add wave -noupdate /ethernet_testbench/dut_tx/arp_mac_tready
add wave -noupdate /ethernet_testbench/dut_tx/arp_mac_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/arp_mac_tdata
add wave -noupdate /ethernet_testbench/dut_tx/arp_mac_tlast
add wave -noupdate /ethernet_testbench/dut_tx/arp_mac_tkeep
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/source_swapped
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/destination_swapped
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/protocol_swapped
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6161177 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 220
configure wave -valuecolwidth 100
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
WaveRestoreZoom {6108991 ps} {6116664 ps}
