//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

// This block implement : y[n] = x[n] + x[n-m]

module SumDelayFilter #(
   parameter WIDTH = 16,
   parameter SIZE = 5,        // 1 2 3 4  5  6  7   ...
   parameter TowPowSIZE = 32, // 2 4 8 16 32 64 128 ...
   parameter DelaySelector = 24
)(
   input clk, input reset, input clear,
   input [WIDTH-1:0] i_tdata,
   input i_tvalid,
   output i_tready,
   output [WIDTH-1:0] o_tdata,
   output o_tvalid,
   input o_tready
);

   wire [WIDTH-1:0] DelayFilter_tdata;
   DelayFilter #(
      .WIDTH(WIDTH),
      .SIZE(SIZE),
      .TowPowSIZE(TowPowSIZE)
   ) DelayFilter (
      .clk(clk), .reset(reset), .clear(clear),
      .i_tdata(i_tdata),
      .i_tvalid(i_tvalid),
      .i_tready(i_tready),
      .o_tdata(DelayFilter_tdata),
      .o_tvalid(o_tvalid),
      .o_tready(o_tready),
      .sel_data(DelaySelector),
      .sel_valid(1'b1)
   );

   reg signed [WIDTH:0] sum;
   always @(posedge clk)
      if(reset | clear)
         sum <= 0;
      else if(i_tvalid & o_tready)
         sum <= $signed(i_tdata)+$signed(DelayFilter_tdata);

   assign o_tdata = sum[WIDTH:1];

endmodule // SumDelayFilter
