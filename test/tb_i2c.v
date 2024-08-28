/**
Testing I2C Slace for reading/writing 8 bits of data only
*/

`timescale 1ns / 1ps

module tb_i2c ();

  reg clk;

  wire SDA;
  wire SCL;

  pullup(SDA);
  pullup(SCL);

  reg [6:0] addressToSend= 7'b000_1000; //8
  reg readWite = 1'b1; //write
  reg [7:0] dataToSend = 8'b0110_0111; //103 = 0x67

  integer ii=0;

  initial begin
    clk = 0;
    force SCL = clk;
    forever begin
      clk = #1 ~clk;
      force SCL = clk;
    end
  end


  Slave #() UUT
    (.SDA(SDA),
     .SCL(SCL));

  initial
    begin
      $display("Starting Testbench...");

      clk = 0;
      force SCL = clk;

      #11

      // Set SDA Low to start
      force SDA = 0;

      // Write address
      for(ii=0; ii<7; ii=ii+1)
        begin
          $display("Address SDA %h to %h", SDA, addressToSend[ii]);
          #2 force SDA = addressToSend[ii];
        end

      // Are we wanting to read or write to/from the device?
      $display("Read/Write %h SDA: %h", readWite, SDA);
      #2 force SDA = readWite;

      // Next SDA will be driven by slave, so release it
      release SDA;

      $display("SDA: %h", SDA);
      #2; // Wait for ACK bit

      for(ii=0; ii<8; ii=ii+1)
        begin
          $display("Data SDA %h to %h", SDA, dataToSend[ii]);
          #2 force SDA = dataToSend[ii];
        end

      #2; // Wait for ACK bit

       // Next SDA will be driven by slave, so release it
      release SDA;

      // Force SDA high again, we are done
      #2 force SDA = 1;

      #100;
      $finish();
    end

  initial
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
