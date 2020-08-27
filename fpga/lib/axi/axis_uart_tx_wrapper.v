//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module axis_uart_tx_wrapper #(
   parameter TX_SIZE = 16,
   parameter clkdiv_tx = 100
)(
   input clk, input rst,
   // AXI Stream ports
   input [7:0] i_tdata,
   input i_tvalid,
   output i_tready,
   // Output TX port
   output tx
);
   wire [7:0] fifo_in = i_tdata;
   wire fifo_write = i_tvalid;
   wire [15:0] clkdiv = $unsigned(clkdiv_tx);
   wire [15:0] fifo_level_tx;
   wire fifo_full;
   wire baudclk;
   simple_uart_tx #(
      .SIZE(TX_SIZE)
   ) simple_uart_tx (
      .clk(clk), .rst(rst),
      .fifo_in(fifo_in), .fifo_write(fifo_write), .fifo_level(fifo_level_tx), .fifo_full(fifo_full), 
      .clkdiv(clkdiv), .baudclk(baudclk), .tx(tx)
   );
   assign i_tready = ~fifo_full;
endmodule // axis_uart_tx_wrapper
