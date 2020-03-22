`timescale 1ns/1ps

//Define Parameters original 
// `define xbar_size 128
// `define acc_size 32
// `define mult_size 24
// `define offset_bits 4
// `define activation_bits 12
// `define xbar_in_bits 16
// `define xbar_out_bits 32
// `define wt_bits 16
// `define wt_int_bits 4
// `define n_size 8 //No. of bits needed to write no. of non zero values in input (log2(xbar_size))

//Define Parameters fro debugging ... Comment this section after debugging
`define xbar_size 32
`define acc_size 32
`define mult_size 24
`define activation_bits 16
`define xbar_in_bits 16
`define xbar_out_bits 32
`define wt_bits 16
`define wt_int_bits 4
`define n_size 8  
`define n 32 
`define p 1 /// to compensate for setup time
