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
   ) simple_axis_ask_uart_tx_wrapper (
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
   ////////////////////////////////////// RX //////////////////////////////////////
   wire [ask_tx_length_model-1:0] ask_rx_model;
   assign ask_rx_model = ( ask_tx_model[ask_tx_length_model-1]==1'b0 ? ask_tx_model : 0 );

   wire [ask_tx_length_model-1:0] DelayFilterOut;
   parameter DelaySIZE = 5;
   parameter TowPowSIZE = 32;
   reg [DelaySIZE-1:0] sel_data = 5'b00000;
   DelayFilter #(
      .WIDTH(ask_tx_length_model),
      .SIZE(DelaySIZE),
      .TowPowSIZE(TowPowSIZE)
   ) DelayFilter (
      .clk(clk), .reset(rst), .clear(1'b0),
      .i_tdata(ask_rx_model),
      .i_tvalid(1'b1),
      .i_tready(),
      .o_tdata(DelayFilterOut),
      .o_tvalid(),
      .o_tready(1'b1),
      .sel_data(sel_data),
      .sel_valid(1'b1)
   );

   wire [ask_tx_length_model-1:0] SumDelayFilter_tdata;
   SumDelayFilter #(
      .WIDTH(ask_tx_length_model),
      .SIZE(5),        // 1 2 3 4  5  6  7   ...
      .TowPowSIZE(32), // 2 4 8 16 32 64 128 ...
      .DelaySelector(24)
   ) SumDelayFilter (
      .clk(clk), .reset(rst), .clear(1'b0),
      .i_tdata(ask_rx_model),
      .i_tvalid(1'b1),
      .i_tready(),
      .o_tdata(SumDelayFilter_tdata),
      .o_tvalid(),
      .o_tready(1'b1)
   );


   parameter SIZE = 49;                 // 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 8 17 18 19 ...
   parameter LogTow_SIZE_PlusOne = 6;   // 1 2 2 3 3 3 3 4 4 4  4  4  4  4  4  5  5  5  5  ...
   wire [ask_tx_length_model+LogTow_SIZE_PlusOne-1:0] BoundedIntegratorOut;
   BoundedIntegrator #(
      .WIDTH(ask_tx_length_model),
      .SIZE(SIZE),
      .LogTow_SIZE_PlusOne(LogTow_SIZE_PlusOne)
   ) BoundedIntegrator (
      .clk(clk), .reset(rst), .clear(1'b0),
      .i_tdata(ask_rx_model),
      .i_tvalid(1'b1),
      .i_tready(),
      .o_tdata(BoundedIntegratorOut),
      .o_tvalid(),
      .o_tready(1'b1)
   );

endmodule // simple_ask_uart_tx_tb
