//
// Copyright 2020 Nasim Hamrah Industries
//
// SPDX-License-Identifier: LGPL-3.0-or-later
//

module MDM_SecondCounter #(
   parameter CLOCK_Fre = 4000000
)(
   // Clock and Reset Pins
   input CLOCK, input RESET_N,
   // USB<->UART Pins
   output UART_TX, input UART_RX,
   // LED Pin
   output LED
);

   assign UART_TX = UART_RX;

   wire reset;
   reset_sync reset_sync (
      .clk(CLOCK),
      .reset_in(~RESET_N),
      .reset_out(reset)
   );

   wire rst;
   controlled_por_gen controlled_por_gen (
      .clk(CLOCK),
      .reset(reset),
      .reset_out(rst)
   );

   integer counter = 0;
   always @(posedge CLOCK)
      if(rst | counter == CLOCK_Fre)
         counter <= 0;
      else
         counter <= counter+1;

   assign LED = ( counter>(CLOCK_Fre/2) ? 1'b1 : 1'b0 );

endmodule // MDM_SecondCounter
