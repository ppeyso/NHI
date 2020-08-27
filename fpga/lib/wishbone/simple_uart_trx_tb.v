//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module simple_uart_trx_tb();
   reg clk = 1'b0;
   wire rst;
   always @(*) begin
     #62.5
     clk <= ~clk;
   end

   por_gen por_gen (.clk(clk), .reset_out(rst) );

   wire trxline;

   reg [7:0] i_tdata;
   reg i_tvalid = 1'b0;
   wire i_tready;
   axis_uart_tx_wrapper #(
      .TX_SIZE(4),
      .clkdiv_tx(100)
   ) axis_uart_tx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready),
      // Output TX port
      .tx(trxline)
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

   wire [7:0] o_tdata;
   wire o_tvalid;
   reg o_tready = 1'b0;
   axis_uart_rx_wrapper #(
      .RX_SIZE(4),
      .clkdiv_rx(100)
   ) axis_uart_rx_wrapper (
      .clk(clk), .rst(rst),
      // AXI Stream ports
      .o_tdata(o_tdata),
      .o_tvalid(o_tvalid),
      .o_tready(o_tready),
      // Input RX port
      .rx(trxline)
   );
   always @(*) begin
      #5250
      if(~rst) begin
         #13;
         #52500;
         o_tready <= 1'b1;
      end
   end

endmodule // simple_uart_rx_tb
