onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ethernet_testbench/clock
add wave -noupdate /ethernet_testbench/reset
add wave -noupdate /ethernet_testbench/ip_rx_tready
add wave -noupdate /ethernet_testbench/ip_rx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/ip_rx_tdata
add wave -noupdate /ethernet_testbench/ip_rx_tkeep
add wave -noupdate /ethernet_testbench/ip_rx_tlast
add wave -noupdate /ethernet_testbench/arp_rx_tready
add wave -noupdate /ethernet_testbench/arp_rx_tvalid
add wave -noupdate -radix hexadecimal /ethernet_testbench/arp_rx_tdata
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
add wave -noupdate -radix hexadecimal /ethernet_testbench/source_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/destination_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/ethernet_type
add wave -noupdate -radix hexadecimal /ethernet_testbench/datagram_header
add wave -noupdate /ethernet_testbench/tvalid_tx_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/tdata_tx_out
add wave -noupdate /ethernet_testbench/tlast_tx_out
add wave -noupdate /ethernet_testbench/tkeep_tx_out
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
add wave -noupdate -radix hexadecimal -childformat {{{/ethernet_testbench/dut_rx/tdata_out[7]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[6]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[5]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[4]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[3]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[2]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[1]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[0]} -radix hexadecimal}} -subitemconfig {{/ethernet_testbench/dut_rx/tdata_out[7]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[6]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[5]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[4]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[3]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[2]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[1]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[0]} {-height 15 -radix hexadecimal}} /ethernet_testbench/dut_rx/tdata_out
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
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/clock
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/reset
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/tready_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/tvalid_in
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
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/header_state
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
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/clock
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/reset
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tready_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tvalid_in
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/tdata_in
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tlast_in
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tkeep_in
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tready_in
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tvalid_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/tdata_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tlast_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/tkeep_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/header_data
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_write_enable
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/fifo_data_in
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/fifo_data_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_data_valid
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_data_empty
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_data_full
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_control_valid
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_control_empty
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_control_full
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/header_insertion_state
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_read_enable
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/reset
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/clock
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/fifo_read_enable
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/fifo_empty
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/fifo_full
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/fifo_data_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/fifo_data_valid
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/tready_in
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/tvalid_out
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/tdata_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/tlast_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/i
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/fifo_access_state
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/eof_shift_register
add wave -noupdate -radix hexadecimal -childformat {{{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[0]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[1]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[2]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[3]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[4]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[5]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[6]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[7]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[8]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[9]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[10]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[11]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[12]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[13]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[14]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[15]} -radix hexadecimal}} -expand -subitemconfig {{/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[0]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[1]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[2]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[3]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[4]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[5]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[6]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[7]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[8]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[9]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[10]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[11]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[12]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[13]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[14]} {-radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register[15]} {-radix hexadecimal}} /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/shift_register
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/input_counter
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/input_index
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/enable_data_output
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/flush_pipeline
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/axis_access_state
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/output_counter
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/output_index
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/small_data_size_even/tdata_interface/current_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1571756 ps} 0}
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
WaveRestoreZoom {1449284 ps} {1458982 ps}
