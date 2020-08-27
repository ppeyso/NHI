//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module Posedge_FTDI_LoopBack #(
   parameter RX_SIZE = 4,
   parameter clkdiv_rx = 100,
   parameter TX_SIZE = 4,
   parameter clkdiv_tx = 100
)(
   // Clock and Reset pins
   input CLOCK, input RESET_N,
   // USB<->UART Pins
   output UART_TX, input UART_RX
);

   wire reset = ~RESET_N; // active-high
   wire clk;              // 8MHz clock
   wire locked;
   clk_24MHz_8MHz clk_24MHz_8MHz
   (
      // Clock in ports
      .CLK_IN1(CLOCK),
      // Clock out ports
      .CLK_OUT1(clk),
      // Status and control signals
      .RESET(reset),
      .LOCKED(locked)
   );

   por_gen por_gen (
      .clk(clk),
      .reset_out(rst)
   );

   wire [7:0] tdata;
   wire tvalid;
   wire tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx)
   ) axis_uart_rx_wrapper (
      .clk(clk), .rst(rst | ~locked),
      // AXI Stream ports
      .o_tdata(tdata),
      .o_tvalid(tvalid),
      .o_tready(tready),
      // Input RX port
      .rx(UART_RX)
   );
 
   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(clk), .rst(rst | ~locked),
      // AXI Stream ports
      .i_tdata(tdata),
      .i_tvalid(tvalid),
      .i_tready(tready),
      // Output TX port
      .tx(UART_TX)
   );

endmodule // Posedge_FTDI_LoopBack
