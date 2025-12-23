onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Gold /ip_layer_testbench/ethernet_header
add wave -noupdate -color Gold /ip_layer_testbench/current_packet_size
add wave -noupdate -color Gold /ip_layer_testbench/packet_size_pointer
add wave -noupdate -color Gold /ip_layer_testbench/clock
add wave -noupdate -color Gold /ip_layer_testbench/reset
add wave -noupdate -color Gold /ip_layer_testbench/mac_receiver_state
add wave -noupdate -color Gold /ip_layer_testbench/temac_rx_tvalid
add wave -noupdate -color Gold -radix hexadecimal /ip_layer_testbench/temac_rx_tdata
add wave -noupdate -color Gold /ip_layer_testbench/temac_rx_tlast
add wave -noupdate -color Gold /ip_layer_testbench/temac_rx_tuser
add wave -noupdate -color Gold /ip_layer_testbench/temac_rx_filter_tuser
add wave -noupdate -color Gold /ip_layer_testbench/ip_rx_tready
add wave -noupdate -color Gold /ip_layer_testbench/ip_rx_tvalid
add wave -noupdate -color Gold /ip_layer_testbench/ip_rx_tdata
add wave -noupdate -color Gold /ip_layer_testbench/ip_rx_tlast
add wave -noupdate -color Gold /ip_layer_testbench/arp_rx_tready
add wave -noupdate -color Gold /ip_layer_testbench/arp_rx_tvalid
add wave -noupdate -color Gold /ip_layer_testbench/arp_rx_tdata
add wave -noupdate -color Gold /ip_layer_testbench/arp_rx_tlast
add wave -noupdate -color Gold /ip_layer_testbench/temac_address
add wave -noupdate -color Gold /ip_layer_testbench/received_mac_address
add wave -noupdate -color Gold /ip_layer_testbench/valid_mac_address
add wave -noupdate -color Gold /ip_layer_testbench/interpacket_gap_timer
add wave -noupdate -color Gold /ip_layer_testbench/lfsr_data_register
add wave -noupdate -color Gold /ip_layer_testbench/lfsr_shift_register
add wave -noupdate -color Gold /ip_layer_testbench/lfsr_data_counter
add wave -noupdate -color Gold /ip_layer_testbench/lfsr_test_vector
add wave -noupdate -color Gold /ip_layer_testbench/i
add wave -noupdate -color Gold /ip_layer_testbench/udp_rx_tready
add wave -noupdate -color Gold /ip_layer_testbench/udp_rx_tvalid
add wave -noupdate -color Gold /ip_layer_testbench/udp_rx_tdata
add wave -noupdate -color Gold /ip_layer_testbench/udp_rx_tlast
add wave -noupdate -color Gold /ip_layer_testbench/tcp_rx_tready
add wave -noupdate -color Gold /ip_layer_testbench/tcp_rx_tvalid
add wave -noupdate -color Gold /ip_layer_testbench/tcp_rx_tdata
add wave -noupdate -color Gold /ip_layer_testbench/tcp_rx_tlast
add wave -noupdate -color Gold /ip_layer_testbench/icmp_rx_tready
add wave -noupdate -color Gold /ip_layer_testbench/icmp_rx_tvalid
add wave -noupdate -color Gold /ip_layer_testbench/icmp_rx_tdata
add wave -noupdate -color Gold /ip_layer_testbench/icmp_rx_tlast
add wave -noupdate -color Gold /ip_layer_testbench/local_ip_address
add wave -noupdate -color Gold /ip_layer_testbench/source_ip_address
add wave -noupdate -color Gold /ip_layer_testbench/dest_ip_address
add wave -noupdate -color Gold /ip_layer_testbench/ip_version
add wave -noupdate -color Gold /ip_layer_testbench/ip_header_length
add wave -noupdate -color Gold /ip_layer_testbench/ip_dscp
add wave -noupdate -color Gold /ip_layer_testbench/ip_ecn
add wave -noupdate -color Gold /ip_layer_testbench/ip_total_length
add wave -noupdate -color Gold /ip_layer_testbench/ip_identification
add wave -noupdate -color Gold /ip_layer_testbench/ip_flags
add wave -noupdate -color Gold /ip_layer_testbench/ip_fragment_offset
add wave -noupdate -color Gold /ip_layer_testbench/ip_ttl
add wave -noupdate -color Gold /ip_layer_testbench/ip_protocol
add wave -noupdate -color Gold /ip_layer_testbench/ip_header_checksum
add wave -noupdate -color Gold /ip_layer_testbench/ip_source_address
add wave -noupdate -color Gold /ip_layer_testbench/ip_dest_address
add wave -noupdate -color Gold /ip_layer_testbench/ip_data_buffer
add wave -noupdate /ip_layer_testbench/dut_ip_layer/reset
add wave -noupdate /ip_layer_testbench/dut_ip_layer/clock
add wave -noupdate /ip_layer_testbench/dut_ip_layer/eth_rx_tvalid
add wave -noupdate -radix hexadecimal /ip_layer_testbench/dut_ip_layer/eth_rx_tdata
add wave -noupdate /ip_layer_testbench/dut_ip_layer/eth_rx_tlast
add wave -noupdate /ip_layer_testbench/dut_ip_layer/eth_rx_tready
add wave -noupdate /ip_layer_testbench/dut_ip_layer/udp_rx_tready
add wave -noupdate /ip_layer_testbench/dut_ip_layer/udp_rx_tvalid
add wave -noupdate /ip_layer_testbench/dut_ip_layer/udp_rx_tdata
add wave -noupdate /ip_layer_testbench/dut_ip_layer/udp_rx_tlast
add wave -noupdate /ip_layer_testbench/dut_ip_layer/tcp_rx_tready
add wave -noupdate /ip_layer_testbench/dut_ip_layer/tcp_rx_tvalid
add wave -noupdate /ip_layer_testbench/dut_ip_layer/tcp_rx_tdata
add wave -noupdate /ip_layer_testbench/dut_ip_layer/tcp_rx_tlast
add wave -noupdate /ip_layer_testbench/dut_ip_layer/icmp_rx_tready
add wave -noupdate /ip_layer_testbench/dut_ip_layer/icmp_rx_tvalid
add wave -noupdate /ip_layer_testbench/dut_ip_layer/icmp_rx_tdata
add wave -noupdate /ip_layer_testbench/dut_ip_layer/icmp_rx_tlast
add wave -noupdate /ip_layer_testbench/dut_ip_layer/local_ip_address
add wave -noupdate /ip_layer_testbench/dut_ip_layer/source_ip_address
add wave -noupdate /ip_layer_testbench/dut_ip_layer/dest_ip_address
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_version
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_header_length
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_dscp
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_ecn
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_total_length
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_identification
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_flags
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_fragment_offset
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_ttl
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_protocol
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_header_checksum
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_source_address
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_dest_address
add wave -noupdate /ip_layer_testbench/dut_ip_layer/byte_counter
add wave -noupdate /ip_layer_testbench/dut_ip_layer/ip_receiver_state
add wave -noupdate /ip_layer_testbench/dut_ip_layer/enable_payload_buffer
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_byte_counter
add wave -noupdate /ip_layer_testbench/dut_ip_layer/start_of_frame
add wave -noupdate /ip_layer_testbench/dut_ip_layer/end_of_frame
add wave -noupdate /ip_layer_testbench/dut_ip_layer/enable_payload_transmit
add wave -noupdate /ip_layer_testbench/dut_ip_layer/payload_buffer
add wave -noupdate /ip_layer_testbench/dut_ip_layer/tlast_buffer
add wave -noupdate /ip_layer_testbench/dut_ip_layer/buffer_pointer
add wave -noupdate /ip_layer_testbench/dut_ip_layer/buffer_counter
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_data_valid
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_data
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_expected
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_done
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_correct
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_value
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_input_array
add wave -noupdate /ip_layer_testbench/dut_ip_layer/checksum_input_data
add wave -noupdate /ip_layer_testbench/dut_ip_layer/i
add wave -noupdate /ip_layer_testbench/dut_ip_layer/end_of_payload
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1255992 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 284
configure wave -valuecolwidth 80
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {1170078 ps} {1182117 ps}
