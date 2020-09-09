//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

// This block implement : y[n] = x[n-m]

module DelayFilter #(
   parameter WIDTH = 16,
   parameter SIZE = 5,        // 1 2 3 4  5  6  7   ...
   parameter TowPowSIZE = 32  // 2 4 8 16 32 64 128 ...
)(
   input clk, input reset, input clear,
   input [WIDTH-1:0] i_tdata,
   input i_tvalid,
   output i_tready,
   output [WIDTH-1:0] o_tdata,
   output o_tvalid,
   input o_tready,
   input [SIZE-1:0] sel_data,
   input sel_valid
);
   reg [WIDTH-1:0] delaied [TowPowSIZE-1:0];

   always @(posedge clk)
      if(reset | clear)
         delaied[0] <= 0;
      else if(i_tvalid & o_tready)
         delaied[0] <= i_tdata;

   genvar i;
   generate
      for(i=1;i<TowPowSIZE;i=i+1) begin
         always @(posedge clk)
            if(reset | clear)
               delaied[i] <= 0;
            else if(i_tvalid & o_tready)
               delaied[i] <= delaied[i-1];
      end
   endgenerate

   reg [SIZE-1:0] delay_selector;
   always @(posedge  clk)
      if(reset | clear)
         delay_selector <= 0;
      else if(sel_valid)
         delay_selector <= sel_data;

   assign o_tdata = delaied[$unsigned(delay_selector)];
   assign o_tvalid = i_tvalid & o_tready;
   assign i_tready = o_tready;

endmodule // DelayFilter
