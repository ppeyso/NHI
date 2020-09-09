//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

// This block implement : y[n] = x[n]+y[n-1]-x[n-m]

module BoundedIntegrator #(
   parameter WIDTH = 16,
   parameter SIZE = 5,                 // 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 ...
   parameter LogTow_SIZE_PlusOne = 3   // 1 2 2 3 3 3 3 4 4 4  4  4  4  4  4  5  5  5  5  ...
)(
   input clk, input reset, input clear,
   input [WIDTH-1:0] i_tdata,
   input i_tvalid,
   output i_tready,
   output [WIDTH+LogTow_SIZE_PlusOne-1:0] o_tdata,
   output o_tvalid,
   input o_tready
);
   reg [WIDTH-1:0] delaied [SIZE-1:0];

   always @(posedge clk)
      if(reset | clear)
         delaied[0] <= 0;
      else if(i_tvalid & o_tready)
         delaied[0] <= i_tdata;

   genvar i;
   generate
      for(i=1;i<SIZE;i=i+1) begin
         always @(posedge clk)
            if(reset | clear)
               delaied[i] <= 0;
            else if(i_tvalid & o_tready)
               delaied[i] <= delaied[i-1];
      end
   endgenerate

   reg signed [WIDTH+LogTow_SIZE_PlusOne-1:0] BoundedIntegral;
   always @(posedge  clk)
      if(reset | clear)
         BoundedIntegral <= 0;
      else if(i_tvalid & o_tready)
         BoundedIntegral <= BoundedIntegral+$signed(i_tdata)-$signed(delaied[SIZE-1]);

   assign o_tdata = BoundedIntegral;
   assign o_tvalid = i_tvalid & o_tready;
   assign i_tready = o_tready;

endmodule // BoundedIntegrator
