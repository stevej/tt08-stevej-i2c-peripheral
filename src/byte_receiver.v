`ifndef _BYTE_RECEIVER_
`define _BYTE_RECEIVER_

`default_nettype none `timescale 1us / 100 ns

// Reads in a full byte 1 bit at a time as long as enable is high.
// Assumes the caller is tracking when 8 bits have been read.
module byte_receiver (
    input clk,
    input reset,
    input enable,
    input in,
    output [7:0] out
);

  reg [7:0] data;
  assign out = data;
  always @(posedge clk) begin
    if (reset) begin
      data <= 8'b0;
    end else begin
      if (enable) begin
        data[7:1] <= data[6:0];
        data[0]   <= in;
      end
    end
  end
endmodule
`endif
