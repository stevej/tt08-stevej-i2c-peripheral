`ifndef _BYTE_TRANSMITTER_
`define _BYTE_TRANSMITTER_

`default_nettype none `timescale 1us / 100 ns
// Given a byte, writes out 1 bit at a time while enable is high.
// Assumes the caller is tracking when 8 bits is sent.
module byte_transmitter (
    input clk,
    input reset,
    input enable,
    inout reg [7:0] in,
    output out
);

  always @(posedge clk) begin
    if (!reset) begin
      if (enable) begin
        out <= in[7];
        in[7:1] = in[6:0];
        in[0]   = 0;
      end
    end
  end
endmodule
`endif
