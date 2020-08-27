//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module axis_uart_rx_wrapper #(
   parameter RX_SIZE = 16,
   parameter clkdiv_rx = 100
)(
   input clk, input rst,
   // AXI Stream ports
   output [7:0] o_tdata,
   output o_tvalid,
   input o_tready,
   // Input RX port
   input rx
);
   wire [7:0] fifo_out;
   wire fifo_read = o_tready;
   wire [15:0] fifo_level_rx;
   wire fifo_empty;
   wire [15:0] clkdiv = $unsigned(clkdiv_rx);
   simple_uart_rx #(
      .SIZE(RX_SIZE)
   ) simple_uart_rx (
      .clk(clk), .rst(rst),
      .fifo_out(fifo_out), .fifo_read(fifo_read), .fifo_level(fifo_level_rx), .fifo_empty(fifo_empty),
      .clkdiv(clkdiv), .rx(rx)
   );
   assign o_tdata = fifo_out;
   assign o_tvalid = ( ( (fifo_empty != 1'b1) & (fifo_level_rx != 16'b0) ) ? 1'b1 : 1'b0);
endmodule // axis_uart_rx_wrapper
