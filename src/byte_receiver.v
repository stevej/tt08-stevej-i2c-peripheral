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
    output reg [7:0] out  // byte_buffer
);

  always @(posedge clk) begin
    if (reset) begin
      out <= 8'b0;
    end else begin
      if (enable) begin
        out[7:1] <= out[6:0];
        out[0]   <= in;
      end
    end
  end
endmodule
`endif
