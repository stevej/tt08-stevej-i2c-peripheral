`ifndef _BYTE_TRANSMITTER_
`define _BYTE_TRANSMITTER_

`default_nettype none `timescale 1us / 100 ns

// Given a byte, writes out 1 bit at a time while enable is high.
// Assumes the caller is tracking when 8 bits is sent.
module byte_transmitter (
    input clk,
    input reset,
    input enable,
    input [7:0] in,  // byte_buffer
    output out
);

  reg [7:0] in_buffer;
  reg data;
  assign out = data;

  always @(posedge clk) begin
    if (reset) begin
      in_buffer <= in;
    end else begin
      if (enable) begin
        data <= in_buffer[7];
        in_buffer[7:1] <= in_buffer[6:0];
        in_buffer[0] <= 0;
      end
    end
  end
endmodule
`endif
