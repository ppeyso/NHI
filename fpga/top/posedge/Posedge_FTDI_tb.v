//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module Posedge_FTDI_tb ( );
   parameter RX_SIZE = 16;
   parameter clkdiv_rx = 100;
   parameter TX_SIZE = 16;
   parameter clkdiv_tx = 100;
   
   reg CLOCK = 1'b0;
   reg RESET_N = 1'b1;
   wire [7:0] leds;
   reg [7:0] dip_switch = 8'b0;
   reg [3:0] push_button = 4'b1111;
   wire UART_RX, UART_TX;
   assign UART_RX = UART_TX;
   always @(*) begin
      #20.83333333333;
      CLOCK <= ~CLOCK;
   end
   always @(*) begin
      #300;
      RESET_N <= ~RESET_N;
      #210;
      RESET_N <= ~RESET_N;
		#210;
   end
   always @(*) begin
      #41000;
      dip_switch <= dip_switch + 110;
      #4100;
      push_button <= push_button + 1;
      #9100;
      push_button <= push_button - 1;
      #41000;
   end

   Posedge_FTDI_MegaWing #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) Posedge_FTDI_MegaWing (
      // Clock and Reset pins
      .CLOCK(CLOCK), .RESET_N(RESET_N),
      // USB<->UART Pins
      .UART_TX(UART_TX), .UART_RX(UART_RX),
      // dip-switches
      .dip_switch(dip_switch),
      // Push-Buttons
      .push_button(push_button),
      // LEDs
      .leds(leds)
   );

   wire UART_TX_LoopBack;
   Posedge_FTDI_LoopBack #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) Posedge_FTDI_LoopBack (
      .CLOCK(CLOCK), .RESET_N(RESET_N),
      // Input RX port
      .UART_RX(UART_RX),
      // Output TX port
      .UART_TX(UART_TX_LoopBack)
   );

endmodule // Posedge_FTDI_tb
