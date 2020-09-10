//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module controlled_por_gen
  (input clk,
   input reset,
   output reset_out);

   reg 		por_rst;
   reg [7:0] 	por_counter = 8'h0;

   always @(posedge clk)
     if(reset)
       begin
          por_counter <= 8'h0;
          por_rst <= 1'b1;
       end
     else if (por_counter != 8'h55)
       begin
          por_counter <= por_counter + 8'h1;
          por_rst <= 1'b1;
       end
     else
       por_rst <= 1'b0;

   assign reset_out = por_rst;

endmodule // por_gen
