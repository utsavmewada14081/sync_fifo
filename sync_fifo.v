//synchronous fifo with parameterized fifo_depth and data_width
module fifo_sync #(parameter FIFO_DEPTH = 8,
DATA_WIDTH = 32)(
  input [DATA_WIDTH-1:0]data_in, 
  input clk,
  input rst_n, 
  input cs, 
  input wr_en, 
  input rd_en,
  output reg[DATA_WIDTH-1:0] data_out,
  output full,
  output empty
);
  
  localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);
  
  reg [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];
  
  reg [FIFO_DEPTH_LOG:0] write_pointer;
  reg [FIFO_DEPTH_LOG:0] read_pointer;
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      //reset write pointer at neg edge of reset
      write_pointer <= 0;
    else if(cs && wr_en && !full) begin
      fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;
      //icrementing write pointer
      write_pointer <= write_pointer + 1'b1;
    end
  end
  
  always@(posedge clk or negedge rst_n) begin
    if(!rst_n)
      //reset read pointer at neg edge of reset
      read_pointer<=0;
    else if (cs && rd_en && !empty) begin
      data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];
      //incrementing read pointer
      read_pointer <= read_pointer + 1'b1;
    end
  end

  //asserting empty flag
  assign empty = (read_pointer == write_pointer);
  //asserting full flag
  assign full = (read_pointer == {~write_pointer[3], write_pointer[2:0]});
  
endmodule
