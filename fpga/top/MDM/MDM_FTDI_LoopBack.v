//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module MDM_FTDI_LoopBack #(
   parameter RX_SIZE = 4,
   parameter clkdiv_rx = 50,
   parameter TX_SIZE = 4,
   parameter clkdiv_tx = 50
)(
   // Clock and Reset Pins
   input CLOCK, input RESET_N,
   // USB<->UART Pins
   output UART_TX, input UART_RX,
   // LED Pin
   output LED
);

   assign LED = ~UART_RX;
   // assign LED = ~UART_TX;

   wire reset;
   reset_sync reset_sync (
      .clk(CLOCK),
      .reset_in(~RESET_N),
      .reset_out(reset)
   );

   wire rst;
   controlled_por_gen controlled_por_gen (
      .clk(CLOCK),
      .reset(reset),
      .reset_out(rst)
   );

   wire [7:0] tdata;
   wire tvalid;
   wire tready;
   axis_uart_rx_wrapper #(
      .RX_SIZE(RX_SIZE),
      .clkdiv_rx(clkdiv_rx)
   ) axis_uart_rx_wrapper (
      .clk(CLOCK), .rst(rst),
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
      .clk(CLOCK), .rst(rst),
      // AXI Stream ports
      .i_tdata(tdata),
      .i_tvalid(tvalid),
      .i_tready(tready),
      // Output TX port
      .tx(UART_TX)
   );

endmodule // MDM_FTDI_LoopBack
