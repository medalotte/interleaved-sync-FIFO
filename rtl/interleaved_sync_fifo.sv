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
// description : This module is 1t synchronous fifo realized by interleaving 2t synchronous fifo
//               for FPGA implementation, and don't use distributed RAM, but BRAM
module interleaved_sync_fifo
  #(parameter
    /*
     You can specify the following parameters.
     1. DATA_WIDTH : input and output data width
     2. FIFO_DEPTH : data capacity
     */
    DATA_WIDTH    = 8,
    FIFO_DEPTH    = 256,
    LB_FIFO_DEPTH = $clog2(FIFO_DEPTH))
   (/*
     data, and control signal based on valid-ready protocol
     */
    input  logic [DATA_WIDTH-1:0]  in_data,
    input  logic                   in_valid,
    output logic                   in_ready,
    output logic [DATA_WIDTH-1:0]  out_data,
    output logic                   out_valid,
    input  logic                   out_ready,

    /*
     signal about FIFO status and controll
     conut : amount of data stored in the FIFO
     clear : clear data in the FIFO
     clk   : clock
     rstn  : active low reset signal
     */
    output logic [LB_FIFO_DEPTH:0] count,
    input  logic                   clear,
    input  logic                   clk,
    input  logic                   rstn);

   localparam HALF_FIFO_DEPTH    = FIFO_DEPTH / 2;
   localparam LB_HALF_FIFO_DEPTH = $clog2(HALF_FIFO_DEPTH);

   logic [LB_FIFO_DEPTH:0]         count_r;
   logic                           in_exec, out_exec;

   logic                           fifo0_in_ready, fifo1_in_ready;
   logic [DATA_WIDTH-1:0]          fifo0_out_data, fifo1_out_data;
   logic                           fifo0_out_valid, fifo1_out_valid;
   logic                           fifo0_out_ready, fifo1_out_ready;
   logic [LB_HALF_FIFO_DEPTH:0]    fifo0_count, fifo1_count;

   logic [DATA_WIDTH-1:0]          fifo0_in_data_r, fifo1_in_data_r;
   logic                           fifo0_in_valid_r, fifo1_in_valid_r;

   logic [DATA_WIDTH-1:0]          fifo0_prefetch_data_r, fifo1_prefetch_data_r;
   logic                           fifo0_prefetch_valid_r, fifo1_prefetch_valid_r;

   logic                           fifo0_in_exec, fifo1_in_exec;
   logic                           fifo0_in_exec_done, fifo1_in_exec_done;
   logic                           fifo0_out_exec, fifo1_out_exec;
   logic                           fifo0_prefetch_exec, fifo1_prefetch_exec;

   logic                           in_sel, out_sel;

   sync_2t_fifo #(DATA_WIDTH, HALF_FIFO_DEPTH) fifo0(.in_data(fifo0_in_data_r),
                                                     .in_valid(fifo0_in_valid_r),
                                                     .in_ready(fifo0_in_ready),
                                                     .out_data(fifo0_out_data),
                                                     .out_valid(fifo0_out_valid),
                                                     .out_ready(fifo0_out_ready),
                                                     .clear(clear),
                                                     .count(fifo0_count),
                                                     .clk(clk),
                                                     .rstn(rstn));

   sync_2t_fifo #(DATA_WIDTH, HALF_FIFO_DEPTH) fifo1(.in_data(fifo1_in_data_r),
                                                     .in_valid(fifo1_in_valid_r),
                                                     .in_ready(fifo1_in_ready),
                                                     .out_data(fifo1_out_data),
                                                     .out_valid(fifo1_out_valid),
                                                     .out_ready(fifo1_out_ready),
                                                     .clear(clear),
                                                     .count(fifo1_count),
                                                     .clk(clk),
                                                     .rstn(rstn));

   always_comb begin
      in_ready  = (count_r < FIFO_DEPTH) ? 1 : 0;
      out_valid = out_sel ? fifo1_prefetch_valid_r : fifo0_prefetch_valid_r;
      out_data  = out_sel ? fifo1_prefetch_data_r  : fifo0_prefetch_data_r;
      count     = count_r;
      in_exec   = in_valid  & in_ready;
      out_exec  = out_valid & out_ready;

      fifo0_in_exec      = in_valid & (in_sel == 0) & !fifo0_in_valid_r;
      fifo0_in_exec_done = fifo0_in_valid_r & fifo0_in_ready;
      fifo1_in_exec      = in_valid & (in_sel == 1) & !fifo1_in_valid_r;
      fifo1_in_exec_done = fifo1_in_valid_r & fifo1_in_ready;

      fifo0_prefetch_exec = fifo0_out_valid & !fifo0_prefetch_valid_r;
      fifo0_out_ready     = !fifo0_prefetch_valid_r;
      fifo0_out_exec      = out_ready & (out_sel == 0) & fifo0_prefetch_valid_r;
      fifo1_prefetch_exec = fifo1_out_valid & !fifo1_prefetch_valid_r;
      fifo1_out_ready     = !fifo1_prefetch_valid_r;
      fifo1_out_exec      = out_ready & (out_sel == 1) & fifo1_prefetch_valid_r;
   end

   always_ff @(posedge clk) begin
     if(!rstn | clear) begin
        count_r <= 0;

        fifo0_in_data_r  <= 0;
        fifo1_in_data_r  <= 0;
        fifo0_in_valid_r <= 0;
        fifo1_in_valid_r <= 0;

        fifo0_prefetch_data_r  <= 0;
        fifo1_prefetch_data_r  <= 0;
        fifo0_prefetch_valid_r <= 0;
        fifo1_prefetch_valid_r <= 0;

        in_sel  <= 0;
        out_sel <= 0;
     end
     else begin
        case({in_exec, out_exec})
          2'b10:   count_r <= count_r + 1;
          2'b01:   count_r <= count_r - 1;
          default: count_r <= count_r;
        endcase

        if(fifo0_in_exec) begin
           fifo0_in_data_r  <= in_data;
           fifo0_in_valid_r <= 1;
           in_sel           <= 1;
        end
        else if(fifo0_in_exec_done) begin
           fifo0_in_valid_r <= 0;
        end

        if(fifo1_in_exec) begin
           fifo1_in_data_r  <= in_data;
           fifo1_in_valid_r <= 1;
           in_sel           <= 0;
        end
        else if(fifo1_in_exec_done) begin
           fifo1_in_valid_r <= 0;
        end

        if(fifo0_prefetch_exec) begin
           fifo0_prefetch_data_r  <= fifo0_out_data;
           fifo0_prefetch_valid_r <= 1;
        end
        else if(fifo0_out_exec) begin
           fifo0_prefetch_valid_r <= 0;
           out_sel                <= 1;
        end

        if(fifo1_prefetch_exec) begin
           fifo1_prefetch_data_r  <= fifo1_out_data;
           fifo1_prefetch_valid_r <= 1;
        end
        else if(fifo1_out_exec) begin
           fifo1_prefetch_valid_r <= 0;
           out_sel                <= 0;
        end
     end
   end

endmodule
