`ifndef _I2C_PERIPH_
`define _I2C_PERIPH_

`default_nettype none `timescale 1us / 100 ns

`include "byte_transmitter.v"
`include "byte_receiver.v"

module i2c_periph (
    input clk,
    input reset,
    input read_channel,
    output reg [7:0] direction,  // set to the correct mask before using write_channel
    output write_channel
);

  localparam [3:0] Stop = 4'b0001;
  localparam [3:0] Start = 4'b0010;
  localparam [3:0] Dispatch = 4'b0011;
  localparam [3:0] AddressAndRw = 4'b0100;
  localparam [3:0] OneZeroPeriph = 4'b0101;
  localparam [3:0] ZeroOnePeriph = 4'b0110;
  localparam [3:0] Fnv1aPeriph = 4'b0111;
  localparam [3:0] LzcPeriph = 4'b1000;
  localparam [3:0] WriteBuffer = 4'b1001;
  localparam [3:0] Reset = 4'b1010;

  localparam [7:0] ReadMask = 8'b0000_0000;
  localparam [7:0] WriteMask = 8'b0010_0000;

  reg [3:0] current_state;
  reg last_sda;
  reg [6:0] address;
  // Keeps track of how many bytes have been written or read.
  reg [3:0] byte_count;
  reg [7:0] input_byte_buffer;
  reg [7:0] output_byte_buffer;
  reg read_request;

  reg byte_receiver_enable;
  byte_receiver byte_receiver (
      .clk(clk),
      .reset(reset),
      .enable(byte_receiver_enable),
      .in(read_channel),
      .out(output_byte_buffer)
  );

  reg byte_transmitter_enable;
  byte_transmitter byte_transmitter (
      .clk(clk),
      .reset(reset),
      .enable(byte_transmitter_enable),
      .in(input_byte_buffer),
      .out(write_channel)
  );

  reg [7:0] one_zero;
  reg [7:0] zero_one;

  always @(posedge clk) begin
    if (reset) begin
      direction <= ReadMask;
      current_state <= Stop;
      last_sda <= 0;
      byte_count <= 0;
      input_byte_buffer <= 8'b0000_0000;
      byte_receiver_enable <= 0;
      byte_transmitter_enable <= 0;
      address <= 7'b000_0000;
      one_zero <= 8'b1010_1010;
      zero_one <= 8'b0101_0101;
    end else begin
      case (current_state)
        Stop: begin
          if (last_sda == 0 && read_channel == 1) begin
            current_state <= Start;
          end
        end
        Start: begin
          if (address > 7'b000_0000) begin
            current_state <= Dispatch;
          end else begin
            current_state <= AddressAndRw;
          end
        end
        AddressAndRw: begin
          byte_receiver_enable <= 1;
          if (byte_count < 8) begin
            byte_count <= byte_count + 1;
          end else begin
            direction <= WriteMask;  // should this be here?
            address <= output_byte_buffer[7:1];
            read_request <= output_byte_buffer[0];
            current_state <= Dispatch;
          end
        end
        // Now that we have the address, we can read and write bytes per each peripherals needs.
        Dispatch: begin
          if (read_request) begin
            case (address)
              7'h55:   current_state <= OneZeroPeriph;
              7'h2A:   current_state <= ZeroOnePeriph;
              7'h3F:   current_state <= Fnv1aPeriph;
              default: current_state <= LzcPeriph;
            endcase
          end else begin
          end
        end
        // Will this break because I'm not doing anything with the ACK after a byte?
        OneZeroPeriph: begin
          // todo: check that the direction is read.
          direction <= WriteMask;
          input_byte_buffer <= one_zero;
          byte_transmitter_enable <= 1;
          byte_count <= 0;
          current_state <= WriteBuffer;
        end
        ZeroOnePeriph: begin
          // todo: check that the direction is read.
          direction <= WriteMask;
          input_byte_buffer <= zero_one;
          byte_transmitter_enable <= 1;
          byte_count <= 0;
          current_state <= WriteBuffer;
        end
        WriteBuffer: begin
          if (byte_count == 8) begin
            byte_transmitter_enable <= 0;
            current_state <= Stop;
          end else begin
            byte_count <= byte_count + 1;
          end
        end
        Reset: begin
          address <= 7'b000_0000;
          current_state <= Stop;
        end
        default: current_state <= Stop;
      endcase
      last_sda <= read_channel;
    end
  end
endmodule
`endif
