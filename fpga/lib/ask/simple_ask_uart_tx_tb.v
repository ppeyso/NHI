//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module simple_ask_uart_tx_tb();
   parameter ask_tx_length_model = 8;
   parameter TX_SIZE = 4;
   parameter clkdiv_tx = 100;
   reg clk = 1'b0;
   wire rst;
   always @(*) begin // 8 MHz
     #62.5
     clk <= ~clk;
   end

   por_gen por_gen (.clk(clk), .reset_out(rst) );

   wire [1:0] ask_tx;
   wire [ask_tx_length_model-1:0] ask_tx_model;
   wire tx;

   reg [7:0] i_tdata;
   reg i_tvalid = 1'b0;

   wire i_tready_ask;
   axis_ask_uart_tx_wrapper #(
      .ask_core_type("simple"),
      .ask_tx_length(2),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) simple_axis_ask_uart_tx_wrapper_ (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready_ask),
      // ASK output port
      .ask_tx(ask_tx)
   );

   axis_ask_uart_tx_wrapper #(
      .ask_core_type("model"),
      .ask_tx_length(ask_tx_length_model),
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) model_axis_ask_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready_ask),
      // ASK output port
      .ask_tx(ask_tx_model)
   );

   wire i_tready_uart;
   axis_uart_tx_wrapper #(
      .TX_SIZE(TX_SIZE),
      .clkdiv_tx(clkdiv_tx)
   ) axis_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready_uart),
      // Output TX port
      .tx(tx)
   );

   always @(*) begin
      #5250
      if(~rst) begin
         #13;
         #5250;
         //
         i_tdata <= 8'b01010101;
         i_tvalid <= 1'b1;
         #125;
         i_tdata <= 8'b01010101;
         #125;
         i_tdata <= 8'b01010101;     
         #125;
         i_tdata <= 8'b00000000;
         #125;
         i_tdata <= 8'b10101010;
         #125;
         i_tdata <= 8'b11111111;
         #125;
         i_tdata <= 8'b01010011;
         #125;
         i_tdata <= 8'b11001010;
         #125;
         i_tdata <= 8'b01011010;
         #125;
         i_tdata <= 8'b10100101;
         #125;
         i_tdata <= 8'b01010101;
         #125;
         i_tdata <= 8'b01010101;     
         #125;
         i_tdata <= 8'b00000000;
         #125;
         i_tdata <= 8'b10101010;
         #125;
         i_tdata <= 8'b11111111;
         #125;
         i_tdata <= 8'b01010011;
         #125;
         i_tdata <= 8'b00011000;
         #125;
         i_tvalid <= 1'b0;
         #525000;
         //
      end
   end

endmodule // simple_ask_uart_tx_tb
