/*
 MIT License

 Copyright (c) 2019 Yuya Kudo

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

//-----------------------------------------------------------------------------
// module      : interleaved_sync_fifo
// description :
module interleaved_sync_fifo
  #(parameter
    /*
     You can specify the following parameters.
     1. DATA_WIDTH : input and output data width
     2. FIFO_DEPTH : data capacity
     */
    DATA_WIDTH = 8,
    FIFO_DEPTH = 256)
   (/*
     input data, and control signal based on valid-ready protocol
     */
    input logic [DATA_WIDTH-1:0]  in_data,
    input logic                   in_valid,
    output logic                  in_ready,

    /*
     output data, and control signal based on valid-ready protocol
     */
    output logic [DATA_WIDTH-1:0] out_data,
    output logic                  out_valid,
    input logic                   out_ready,

    /*
     signal about FIFO status
     cnt         : amount of data stored at FIFO
     almost_full : assert when data stored at FIFO reach FIFO_DEPTH - 1
     */
    output logic                  cnt,
    output logic                  almost_full,

    /*
     signal about input data and control based on valid-ready protocol
     */
    input logic                   clk,
    input logic                   rstn);

endmodule
