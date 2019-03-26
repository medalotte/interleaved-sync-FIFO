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
// module      : single_port_RAM_tb
// description :
module single_port_RAM_tb();
   localparam DATA_WIDTH    = 8;
   localparam RAM_DEPTH     = 256;
   localparam CLK_FREQ      = 100_000_000;
   localparam LB_RAM_DEPTH = $clog2(RAM_DEPTH);

   logic [DATA_WIDTH-1:0]   din;
   logic [LB_RAM_DEPTH-1:0] addr;
   logic [DATA_WIDTH-1:0]   dout;
   logic                    wr_en;
   logic                    clk;

   //-----------------------------------------------------------------------------
   // clock generater
   localparam CLK_PERIOD = 1_000_000_000 / CLK_FREQ;

   initial begin
      clk = 1'b0;
   end

   always #(CLK_PERIOD / 2) begin
      clk = ~clk;
   end

   //-----------------------------------------------------------------------------
   // DUT
   single_port_RAM #(DATA_WIDTH, RAM_DEPTH) dut(.din(din),
                                                .addr(addr),
                                                .dout(dout),
                                                .wr_en(wr_en),
                                                .clk(clk));

   //-----------------------------------------------------------------------------
   // test scenario
   logic [RAM_DEPTH-1:0][DATA_WIDTH-1:0] verification_ram = '{default:0};
   int unsigned                          max_data_val = $pow(2, DATA_WIDTH) - 1;
   int unsigned                          val;

   initial begin
      for(int i = 0; i < RAM_DEPTH; i++) begin
         val = $urandom_range(0, max_data_val);

         // input to verification ram
         verification_ram[i] = val;

         // input to dut
         addr  <= i;
         din   <= val;
         wr_en <= 1;

         repeat(1) @(posedge clk);
         wr_en <= 0;
      end

      for(int i = 0; i < RAM_DEPTH; i++) begin
         // output from dut
         addr  <= i;
         wr_en <= 0;

         // 2cycle delay
         repeat(2) @(posedge clk);

         repeat(1) @(posedge clk);
         assert(dout == verification_ram[i])
           else $error("dout is incorrect : %d", dout);
      end

      $finish;
   end

endmodule
