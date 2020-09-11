# Synopsys Design Constraints SDC file for the MDM board
# FPGA:	A3P125-VQ100-GRADE1 Part Number: A3P125-1VQ100T1

# Clocks
create_clock -name CLOCK -period 250 -waveform {0.0 125.0} [get_ports CLOCK];   # 4MHz

# create_clock -name CLOCK -period 125 -waveform {0.0 62.5} [get_ports CLOCK];  # 8MHz
