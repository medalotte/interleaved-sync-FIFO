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

module sync_2t_fifo
  #(parameter
    /*
     You can specify the following parameters.
     1. DATA_WIDTH : input and output data width
     2. FIFO_DEPTH : data capacity
     */
    DATA_WIDTH    = 8,
    FIFO_DEPTH    = 256,
    LB_FIFO_DEPTH = $clog2(FIFO_DEPTH))
   (input  logic [DATA_WIDTH-1:0]  in_data,
    input  logic                   in_valid,
    output logic                   in_ready,
    output logic [DATA_WIDTH-1:0]  out_data,
    output logic                   out_valid,
    input  logic                   out_ready,
    input  logic                   clear,
    output logic [LB_FIFO_DEPTH:0] count,
    input  logic                   clk,
    input  logic                   rstn);

   localparam PREFETCH_FIFO_DEPTH    = 4;
   localparam LB_PREFETCH_FIFO_DEPTH = $clog2(PREFETCH_FIFO_DEPTH);

   logic [LB_FIFO_DEPTH-1:0]        raddr_r, waddr_r;
   logic [LB_FIFO_DEPTH:0]          fifo_count_r;
   logic                            in_exec, out_exec;

   logic [DATA_WIDTH-1:0]           mem_dout;
   logic [LB_FIFO_DEPTH-1:0]        mem_addr;
   logic [LB_FIFO_DEPTH:0]          mem_count_r;

   logic                            prefetch_fifo_in_valid_q[1:0];
   logic                            prefetch_fifo_in_ready;
   logic [LB_PREFETCH_FIFO_DEPTH:0] prefetch_fifo_count;

   logic                            prefetch_exec;
   logic [2:0]                      prefetch_count;

   single_port_RAM #(DATA_WIDTH, FIFO_DEPTH) single_port_ram(.din(in_data),
                                                             .addr(mem_addr),
                                                             .dout(mem_dout),
                                                             .wr_en(in_exec),
                                                             .clk(clk));

   reg_fifo #(DATA_WIDTH, PREFETCH_FIFO_DEPTH) prefetch_fifo(.in_data(mem_dout),
                                                             .in_valid(prefetch_fifo_in_valid_q[1]),
                                                             .in_ready(prefetch_fifo_in_ready),
                                                             .out_data(out_data),
                                                             .out_valid(out_valid),
                                                             .out_ready(out_ready),
                                                             .clear(clear),
                                                             .count(prefetch_fifo_count),
                                                             .clk(clk),
                                                             .rstn(rstn));

   always_comb begin
      in_ready       = (fifo_count_r < FIFO_DEPTH) ? 1 : 0;
      count          = fifo_count_r;
      in_exec        = in_valid  & in_ready;
      out_exec       = out_valid & out_ready;
      mem_addr       = in_exec ? waddr_r : raddr_r;
      prefetch_count = prefetch_fifo_count + prefetch_fifo_in_valid_q[0] + prefetch_fifo_in_valid_q[1];
      prefetch_exec  = (!in_exec) & (0 < mem_count_r) & (prefetch_count < PREFETCH_FIFO_DEPTH);
   end

   always_ff @(posedge clk) begin
     if(!rstn | clear) begin
        fifo_count_r             <= 0;
        waddr_r                  <= 0;
        raddr_r                  <= 0;
        mem_count_r              <= 0;
        prefetch_fifo_in_valid_q <= '{default:0};
     end
     else begin
        prefetch_fifo_in_valid_q[1] <= prefetch_fifo_in_valid_q[0];

        case({in_exec, out_exec})
          2'b10:   fifo_count_r <= fifo_count_r + 1;
          2'b01:   fifo_count_r <= fifo_count_r - 1;
          default: fifo_count_r <= fifo_count_r;
        endcase

        casez({in_exec, prefetch_exec})
          2'b1z: begin
             waddr_r                     <= waddr_r + 1;
             mem_count_r                 <= mem_count_r + 1;
             prefetch_fifo_in_valid_q[0] <= 0;
          end
          2'b01: begin
             raddr_r                     <= raddr_r + 1;
             mem_count_r                 <= mem_count_r - 1;
             prefetch_fifo_in_valid_q[0] <= 1;
          end
          default: begin
             prefetch_fifo_in_valid_q[0] <= 0;
          end
        endcase
     end
   end

endmodule
