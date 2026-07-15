module tb_fifo_sync();
  parameter FIFO_DEPTH = 8;
  parameter DATA_WIDTH = 32;
  reg clk = 0;
  reg rst_n;
  reg cs;
  reg rd_en;
  reg wr_en;
  reg [DATA_WIDTH-1:0] data_in;
  reg [DATA_WIDTH-1:0] data_out;
  wire empty;
  wire full;
  
  integer i;
  
  fifo_sync#(FIFO_DEPTH, DATA_WIDTH)
  dut(
    data_in,
    clk,
    rst_n,
    cs,
    wr_en,
    rd_en,
    data_out,
    full,
    empty
  );

  //clk generation
  always begin #5 clk = ~clk; end

  //write_data operation
  task write_data(input [DATA_WIDTH-1:0] d_in);
    begin
      @(posedge clk);
      cs = 1; wr_en = 1;
      data_in = d_in;
      $display($time, "write_data data_in = %0d", data_in);
      @(posedge clk);
      cs = 1; wr_en = 0;
    end
  endtask

  //read_data operation
  task read_data();
    begin
      @(posedge clk);
      cs = 1; rd_en = 1;
      @(posedge clk);
      $display($time, "read_data data_out = %0d", data_out);
      cs = 1; rd_en = 0;
    end
  endtask
  
  initial begin
    #1;
    rst_n = 0; rd_en = 0; wr_en = 0;
    
    @(posedge clk)
    rst_n = 1;
    $display($time, "\n SCENARIO 1");
    write_data(1);
    write_data(10);
    write_data(100);
    read_data();
    read_data();
    read_data();

    //write and read data after one clock for empty flag
    $display($time, "SCENARIO 2");
    for(i = 0; i<FIFO_DEPTH; i=i+1) begin
      write_data(2**i);
      read_data();
    end

    //full the fifo with data then read for full flag
    $display($time, "SCENARIO 3");
    for(i = 0; i<FIFO_DEPTH; i=i+1) begin
      write_data(2**i);
    end
    
    for(i = 0; i<FIFO_DEPTH; i=i+1) begin
      read_data();
    end
    
    #40; $finish;
  end
    
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
