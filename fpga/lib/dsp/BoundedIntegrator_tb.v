//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

`timescale 1ns / 1ps
module BoundedIntegrator_tb ();
   parameter WIDTH = 8;
   parameter SIZE = 6;                  // 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 8 17 18 19 ...
   parameter LogTow_SIZE_PlusOne = 3;   // 1 2 2 3 3 3 3 4 4 4  4  4  4  4  4  5  5  5  5  ...
   reg clk = 1'b0;
   wire rst;
   reg clear = 1'b0;

   always @(*) begin // 8 MHz
      #62.5
      clk <= ~clk;
   end

   por_gen por_gen (.clk(clk), .reset_out(rst) );

   reg [WIDTH-1:0] i_tdata = 8'd0;
   reg i_tvalid = 1'b0;
   wire i_tready;
   wire [WIDTH+LogTow_SIZE_PlusOne-1:0] BoundedIntegrator_tdata;
   wire BoundedIntegrator_tvalid;
   reg BoundedIntegrator_tready = 1'b1;
   BoundedIntegrator #(
      .WIDTH(WIDTH),
      .SIZE(SIZE),
      .LogTow_SIZE_PlusOne(LogTow_SIZE_PlusOne)
   ) BoundedIntegrator (
      .clk(clk), .reset(rst), .clear(clear),
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready),
      .o_tdata(BoundedIntegrator_tdata),
      .o_tvalid(BoundedIntegrator_tvalid),
      .o_tready(BoundedIntegrator_tready)
   );

   wire [WIDTH-1:0] SumDelayFilter_tdata;
   wire SumDelayFilter_tvalid;
   reg SumDelayFilter_tready = 1'b1;
   SumDelayFilter #(
      .WIDTH(WIDTH),
      .SIZE(5),        // 1 2 3 4  5  6  7   ...
      .TowPowSIZE(32), // 2 4 8 16 32 64 128 ...
      .DelaySelector(24)
   ) SumDelayFilter (
      .clk(clk), .reset(rst), .clear(1'b0),
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready),
      .o_tdata(SumDelayFilter_tdata),
      .o_tvalid(SumDelayFilter_tvalid),
      .o_tready(SumDelayFilter_tready)
   );


   integer i;
   always @(*) begin
      #5250
      if(~rst) begin
         #13;
         #5250;
         //
         i_tdata <= 'b01111111;
         i_tvalid <= 1'b1;
         #125;
         i_tdata <= 8'b10000000;
         #125;
         i_tdata <= 8'b01111111;
         #125;
         i_tdata <= 8'b10000000;
         #125;
         i_tdata <= 8'b01111111;
         #125;
         i_tdata <= 8'b10000000;
         #125;
         i_tdata <= 8'b01111111;
         #125;
         i_tdata <= 8'b10000000;
         #125;
         i_tdata <= 8'b01111111;
         #125;
         i_tdata <= 8'b10000000;
         #125;
         i_tdata <= 8'b01111111;
         #125;
         i_tdata <= 8'b10000000;
         #125;
         //
         i_tdata <= 8'b01111111;
         #1000;
         i_tdata <= 8'b10000000;
         #1000;
         i_tdata <= 8'b01111111;
         #1000;
         i_tdata <= 8'b10000000;
         #1000;
         //
         i_tdata <= 8'b10000000;
         #2000;
         i_tdata <= 8'b01111111;
         #2000;
         i_tdata <= 8'b10000000;
         #2000;
         i_tdata <= 8'b01111111;
         #2000;
         i_tdata <= 8'd0;
         #2000;
         //
         for(i=0;i<400;i=i+1) begin
            i_tdata <= i_tdata+1;
            #125;
         end
      end
   end

endmodule // BoundedIntegrator_tb
