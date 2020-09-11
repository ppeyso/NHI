//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module MDM_FTDI_tb ( );
   parameter RX_SIZE = 4;
   parameter clkdiv_rx = 50;
   parameter TX_SIZE = 4;
   parameter clkdiv_tx = 50;

   reg CLOCK = 1'b0;
   reg RESET_N = 1'b1;
   wire rst;
   por_gen por_gen (.clk(CLOCK), .reset_out(rst) );
   reg [7:0] i_tdata;
   reg i_tvalid = 1'b0;
   wire i_tready;
   wire UART_RX, UART_TX;
   assign UART_RX = UART_TX;
   always @(*) begin
      #125; // 4MHz
      CLOCK <= ~CLOCK;
   end
   always @(*) begin
      #1313;
      RESET_N <= ~RESET_N;
      #310;
      RESET_N <= ~RESET_N;
		#410;
      #52500;
      //
      i_tdata <= 8'b01010101;
      i_tvalid <= 1'b1;
      #250;
      i_tdata <= 8'b01010101;
      #250;
      i_tdata <= 8'b01010101;     
      #250;
      i_tdata <= 8'b00000000;
      #250;
      i_tdata <= 8'b10101010;
      #250;
      i_tdata <= 8'b11111111;
      #250;
      i_tdata <= 8'b01010011;
      #250;
      i_tdata <= 8'b11001010;
      #250;
      i_tdata <= 8'b01011010;
      #250;
      i_tdata <= 8'b10100101;
      #250;
      i_tdata <= 8'b01010101;
      #250;
      i_tdata <= 8'b01010101;     
      #250;
      i_tdata <= 8'b00000000;
      #250;
      i_tdata <= 8'b10101010;
      #250;
      i_tdata <= 8'b11111111;
      #250;
      i_tdata <= 8'b01010011;
      #250;
      i_tdata <= 8'b00011000;
      #250;
      i_tvalid <= 1'b0;
      #525000;
   end
   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready),
      // Output TX port
      .tx(UART_TX)
   );

   wire UART_TX_LoopBack;
   MDM_FTDI_LoopBack #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) MDM_FTDI_LoopBack (
      // Clock and Reset Pins
      .CLOCK(CLOCK), .RESET_N(RESET_N),
      // USB<->UART Pins
      .UART_TX(UART_TX_LoopBack), .UART_RX(UART_RX),
      // LED
      .LED()
   );

   wire LED;
   MDM_SecondCounter #(
      .CLOCK_Fre(400)
   ) MDM_SecondCounter (
      // Clock and Reset Pins
      .CLOCK(CLOCK), .RESET_N(RESET_N),
      // USB<->UART Pins
      .UART_TX(), .UART_RX(),
      // LED
      .LED(LED)
   );

endmodule // MDM_FTDI_tb
