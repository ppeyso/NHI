//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module axis_ask_uart_tx_wrapper #(
   parameter ask_core_type = "simple", // "simple" or "model"
   parameter ask_tx_length = 2, // For "simple" implementation ask_tx_length should be equal by 2.
   parameter TX_SIZE = 16,
   parameter clkdiv_tx = 100
)(
   input clk, input rst,
   // AXI Stream ports
   input [7:0] i_tdata,
   input i_tvalid,
   output i_tready,
   // ASK output port
   output [ask_tx_length-1:0] ask_tx
);
   wire [7:0] fifo_in = i_tdata;
   wire fifo_write = i_tvalid;
   wire [15:0] clkdiv = $unsigned(clkdiv_tx);
   wire [15:0] fifo_level_tx;
   wire fifo_full;
   wire baudclk;
   generate
   if(ask_core_type=="simple")
      simple_ask_uart_tx #(
         .ask_tx_length(ask_tx_length),
         .SIZE(TX_SIZE)
      ) ask_uart_tx (
         .clk(clk), .rst(rst),
         .fifo_in(fifo_in), .fifo_write(fifo_write), .fifo_level(fifo_level_tx), .fifo_full(fifo_full), 
         .clkdiv(clkdiv), .baudclk(baudclk), .ask_tx(ask_tx)
      );
   else if(ask_core_type=="model")
      model_ask_uart_tx #(
         .ask_tx_length(ask_tx_length),
         .SIZE(TX_SIZE)
      ) ask_uart_tx (
         .clk(clk), .rst(rst),
         .fifo_in(fifo_in), .fifo_write(fifo_write), .fifo_level(fifo_level_tx), .fifo_full(fifo_full), 
         .clkdiv(clkdiv), .baudclk(baudclk), .ask_tx(ask_tx)
      );
   endgenerate
   assign i_tready = ~fifo_full;
endmodule // axis_ask_uart_tx_wrapper
