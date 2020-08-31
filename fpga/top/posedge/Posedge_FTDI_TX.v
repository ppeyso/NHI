//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module Posedge_FTDI_TX #(
   parameter RX_SIZE = 4,
   parameter clkdiv_rx = 100,
   parameter TX_SIZE = 4,
   parameter clkdiv_tx = 100,
   parameter ila = "on" // "on" or "off"
)(
   // Clock and Reset pins
   input CLOCK, input RESET_N,
   // USB<->UART Pins
   output UART_TX, input UART_RX,
   // WING 3
   output W3_8,
   output W3_7,
   output W3_6
);

   wire reset = ~RESET_N; // active-high
   wire clk24, clk;       // 24MHz clock, 8MHz clock
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
 
   wire tready_uart;
   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(clk), .rst(rst | ~locked),
      // AXI Stream ports
      .i_tdata(tdata),
      .i_tvalid(tvalid),
      .i_tready(tready_uart),
      // Output TX port
      .tx(UART_TX)
   );

   wire tready_ask;
   wire [1:0] ask_tx;
   axis_ask_uart_tx_wrapper #(
      .ask_core_type("simple"),
      .ask_tx_length(2),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_ask_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(tdata),
      .i_tvalid(tvalid),
      .i_tready(tready_ask),
      // ASK output port
      .ask_tx(ask_tx)
   );

   assign tready = tready_uart & tready_ask;
   assign W3_8 = ( ask_tx==2'b01 ? 1'b1 : 1'b0 );
   assign W3_7 = ( ask_tx==2'b11 ? 1'b1 : 1'b0 );
   assign W3_6 = UART_TX;

   generate
      if(ila=="on") begin
         wire [35:0] CONTROL0;
         wire [15:0] ila_data;
         wire [2:0] ila_trig_0;
         chipscope_ila chipscope_ila (
            .CONTROL(CONTROL0),       // INOUT BUS [35:0]
            .CLK(clk),                // IN
            .DATA(ila_data),          // DATA [15:0]
            .TRIG0(ila_trig_0)        // IN BUS [2:0] 
         );
         assign ila_data = {1'b0, 1'b0, tdata, tvalid, tready, UART_TX, ask_tx, W3_8, W3_7};
         assign ila_trig_0 = {reset, rst, UART_RX};
         chipscope_icon chipscope_icon (
            .CONTROL0(CONTROL0)         // INOUT BUS [35:0]
         );
      end
   endgenerate

endmodule // Posedge_FTDI_TX
