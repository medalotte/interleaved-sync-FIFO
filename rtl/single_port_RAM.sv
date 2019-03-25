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
// module      : single_port_RAM
// description :
module single_port_RAM
  #(parameter
    /*
     You can specify the following two parameters.
     1. DATA_WIDTH : data width
     2. RAM_DEPTH  : data capacity
     */
    DATA_WIDTH   = 8,
    RAM_DEPTH    = 256,
    LB_RAM_DEPTH = $clog2(RAM_DEPTH))
   (input  logic [DATA_WIDTH-1:0]   din,
    input  logic [LB_RAM_DEPTH-1:0] addr,
    output logic [DATA_WIDTH-1:0]   dout,
    input  logic                    wr_en,
    input  logic                    clk);

   logic [RAM_DEPTH-1:0][DATA_WIDTH-1:0] ram;
   logic [DATA_WIDTH-1:0]                din_r;
   logic [LB_RAM_DEPTH-1:0]              addr_r;
   logic [DATA_WIDTH-1:0]                dout_r;
   logic                                 wr_en_r;

   always_ff @(posedge clk) begin
      din_r   <= din;
      addr_r  <= addr;
      wr_en_r <= wr_en;
   end

   always_ff @(posedge clk) begin
      if(wr_en_r) begin
         ram[addr_r] <= din_r;
         dout_r      <= ram[addr_r];
      end
      else begin
         dout_r <= ram[addr_r];
      end
   end

   assign dout = dout_r;

endmodule
