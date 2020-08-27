//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module Posedge_FTDI_MegaWing #(
   parameter RX_SIZE = 4,
   parameter clkdiv_rx = 100,
   parameter TX_SIZE = 4,
   parameter clkdiv_tx = 100
)(
   // Clock and Reset pins
   input CLOCK, input RESET_N,
   // USB<->UART Pins
   output UART_TX, input UART_RX,
   // dip-switches
   input [7:0] dip_switch,
   // Push-Buttons
   input [3:0] push_button,
   // LEDs
   output reg [7:0] leds,
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

   wire [7:0] o_tdata;
   wire o_tvalid;
   wire o_tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx)
   ) axis_uart_rx_wrapper (
      .clk(clk), .rst(rst | ~locked),
      // AXI Stream ports
      .o_tdata(o_tdata),
      .o_tvalid(o_tvalid),
      .o_tready(o_tready),
      // Input RX port
      .rx(UART_RX)
   );
   always @(posedge clk) begin
      if(o_tvalid)
         leds <= o_tdata;
   end
   assign o_tready = locked;

   reg [7:0] i_tdata = 8'b0;
   reg i_tvalid = 1'b0;
   wire i_tready;
   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(clk), .rst(rst | ~locked),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready),
      // Output TX port
      .tx(UART_TX)
   );
   reg [7:0] dip_switches_reg;
   always @(posedge clk) begin
      if( (push_button[0] == 1'b0) & i_tready )
         dip_switches_reg <= dip_switch;
      if( (dip_switches_reg != i_tdata) & i_tready )
         i_tdata <= dip_switches_reg;
      if( (dip_switches_reg != i_tdata) & i_tready )
         i_tvalid <= 1'b1;
      else
         i_tvalid <= 1'b0;
   end

endmodule // Posedge_FTDI_MegaWing
