`ifndef _MUX_2_1_
`define _MUX_2_1_

module mux_2_1 (
    input  one,
    input  two,
    input  selector,
    output out
);

  assign out = selector ? one : two;

endmodule
`endif
