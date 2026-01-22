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
add wave -noupdate /ethernet_testbench/tready_out
add wave -noupdate /ethernet_testbench/beat_counter
add wave -noupdate -radix hexadecimal /ethernet_testbench/header_capture_state
add wave -noupdate /ethernet_testbench/i
add wave -noupdate -radix hexadecimal /ethernet_testbench/tdata_shift_register
add wave -noupdate /ethernet_testbench/packet_byte_counter
add wave -noupdate /ethernet_testbench/header_byte_counter
add wave -noupdate -radix hexadecimal /ethernet_testbench/header_shift_register
add wave -noupdate -radix hexadecimal /ethernet_testbench/temac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/header_data_112bit
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
add wave -noupdate /ethernet_testbench/received_mac_address
add wave -noupdate /ethernet_testbench/valid_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/source_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/destination_mac_address
add wave -noupdate -radix hexadecimal /ethernet_testbench/ethernet_type
add wave -noupdate -radix hexadecimal /ethernet_testbench/datagram_header
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /ethernet_testbench/verification_state
add wave -noupdate -radix hexadecimal /ethernet_testbench/prbs_register
add wave -noupdate -radix hexadecimal /ethernet_testbench/prbs_verifier
add wave -noupdate -color Magenta -itemcolor Magenta /ethernet_testbench/data_valid
add wave -noupdate /ethernet_testbench/tready_tx_in
add wave -noupdate -color Magenta -itemcolor Magenta /ethernet_testbench/tvalid_tx_out
add wave -noupdate -color Magenta -itemcolor Magenta -radix hexadecimal -childformat {{{/ethernet_testbench/tdata_tx_out[63]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[62]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[61]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[60]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[59]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[58]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[57]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[56]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[55]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[54]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[53]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[52]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[51]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[50]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[49]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[48]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[47]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[46]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[45]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[44]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[43]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[42]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[41]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[40]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[39]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[38]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[37]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[36]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[35]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[34]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[33]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[32]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[31]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[30]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[29]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[28]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[27]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[26]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[25]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[24]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[23]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[22]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[21]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[20]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[19]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[18]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[17]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[16]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[15]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[14]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[13]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[12]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[11]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[10]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[9]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[8]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[7]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[6]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[5]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[4]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[3]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[2]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[1]} -radix hexadecimal} {{/ethernet_testbench/tdata_tx_out[0]} -radix hexadecimal}} -subitemconfig {{/ethernet_testbench/tdata_tx_out[63]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[62]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[61]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[60]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[59]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[58]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[57]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[56]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[55]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[54]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[53]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[52]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[51]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[50]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[49]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[48]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[47]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[46]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[45]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[44]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[43]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[42]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[41]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[40]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[39]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[38]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[37]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[36]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[35]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[34]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[33]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[32]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[31]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[30]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[29]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[28]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[27]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[26]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[25]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[24]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[23]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[22]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[21]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[20]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[19]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[18]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[17]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[16]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[15]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[14]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[13]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[12]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[11]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[10]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[9]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[8]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[7]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[6]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[5]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[4]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[3]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[2]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[1]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal} {/ethernet_testbench/tdata_tx_out[0]} {-color Magenta -height 15 -itemcolor Magenta -radix hexadecimal}} /ethernet_testbench/tdata_tx_out
add wave -noupdate -color Magenta -itemcolor Magenta /ethernet_testbench/tlast_tx_out
add wave -noupdate -color Magenta -itemcolor Magenta /ethernet_testbench/tkeep_tx_out
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
add wave -noupdate -radix hexadecimal -childformat {{{/ethernet_testbench/dut_rx/tdata_out[63]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[62]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[61]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[60]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[59]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[58]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[57]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[56]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[55]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[54]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[53]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[52]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[51]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[50]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[49]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[48]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[47]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[46]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[45]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[44]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[43]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[42]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[41]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[40]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[39]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[38]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[37]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[36]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[35]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[34]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[33]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[32]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[31]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[30]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[29]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[28]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[27]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[26]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[25]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[24]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[23]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[22]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[21]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[20]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[19]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[18]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[17]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[16]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[15]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[14]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[13]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[12]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[11]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[10]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[9]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[8]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[7]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[6]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[5]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[4]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[3]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[2]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[1]} -radix hexadecimal} {{/ethernet_testbench/dut_rx/tdata_out[0]} -radix hexadecimal}} -subitemconfig {{/ethernet_testbench/dut_rx/tdata_out[63]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[62]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[61]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[60]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[59]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[58]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[57]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[56]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[55]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[54]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[53]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[52]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[51]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[50]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[49]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[48]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[47]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[46]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[45]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[44]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[43]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[42]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[41]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[40]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[39]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[38]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[37]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[36]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[35]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[34]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[33]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[32]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[31]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[30]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[29]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[28]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[27]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[26]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[25]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[24]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[23]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[22]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[21]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[20]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[19]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[18]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[17]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[16]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[15]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[14]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[13]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[12]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[11]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[10]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[9]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[8]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[7]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[6]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[5]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[4]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[3]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[2]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[1]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_rx/tdata_out[0]} {-height 15 -radix hexadecimal}} /ethernet_testbench/dut_rx/tdata_out
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
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/data_shift_register
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/control_shift_register
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/fifo_read_counter
add wave -noupdate /ethernet_testbench/dut_rx/eth_rx/ipg_counter
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_rx/eth_rx/header_shift_register
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
add wave -noupdate -radix hexadecimal -childformat {{{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[63]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[62]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[61]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[60]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[59]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[58]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[57]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[56]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[55]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[54]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[53]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[52]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[51]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[50]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[49]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[48]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[47]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[46]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[45]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[44]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[43]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[42]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[41]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[40]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[39]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[38]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[37]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[36]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[35]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[34]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[33]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[32]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[31]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[30]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[29]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[28]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[27]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[26]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[25]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[24]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[23]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[22]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[21]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[20]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[19]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[18]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[17]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[16]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[15]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[14]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[13]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[12]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[11]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[10]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[9]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[8]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[7]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[6]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[5]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[4]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[3]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[2]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[1]} -radix hexadecimal} {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[0]} -radix hexadecimal}} -subitemconfig {{/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[63]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[62]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[61]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[60]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[59]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[58]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[57]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[56]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[55]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[54]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[53]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[52]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[51]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[50]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[49]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[48]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[47]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[46]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[45]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[44]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[43]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[42]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[41]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[40]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[39]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[38]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[37]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[36]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[35]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[34]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[33]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[32]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[31]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[30]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[29]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[28]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[27]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[26]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[25]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[24]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[23]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[22]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[21]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[20]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[19]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[18]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[17]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[16]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[15]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[14]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[13]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[12]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[11]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[10]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[9]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[8]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[7]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[6]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[5]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[4]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[3]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[2]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[1]} {-height 15 -radix hexadecimal} {/ethernet_testbench/dut_tx/ip_interface/fifo_data_in[0]} {-height 15 -radix hexadecimal}} /ethernet_testbench/dut_tx/ip_interface/fifo_data_in
add wave -noupdate -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/fifo_data_out
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_data_valid
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_data_empty
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_data_full
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_control_valid
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_control_empty
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_control_full
add wave -noupdate -color Orange -itemcolor Orange -radix hexadecimal /ethernet_testbench/dut_tx/ip_interface/header_insertion_state
add wave -noupdate /ethernet_testbench/dut_tx/ip_interface/fifo_read_enable
add wave -noupdate /ethernet_testbench/header_leftover_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {27175000 ps} 0}
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
WaveRestoreZoom {0 ps} {7870528 ps}
