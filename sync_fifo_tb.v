`timescale 1ns / 1ps

module sync_fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    parameter PTR_WIDTH  = 4;

    reg clk = 0;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg  [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire empty;
    wire full;

    // Instantiate DUT
    sync_fifo #(DATA_WIDTH, DEPTH, PTR_WIDTH) uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full)
    );

    // Clock generation (100 MHz → 10 ns period)
    always #5 clk = ~clk;

    initial begin
        $display("=== FIFO Testbench: Full / Empty / Corner Cases ===");

        // Reset
        rst   = 1;
        wr_en = 0;
        rd_en = 0;
        din   = 0;
        #20 rst = 0;

        // Write data: 0x10, 0x11, 0x12, ...
        $display("\n--- Writing Data to FIFO ---");
        repeat (DEPTH) begin
            @(negedge clk);
            wr_en = 1;
            din   = 8'h10 + ($time/10);
            $display("Time %0t: Writing %0h", $time, din);
        end

        // Attempt to write when full
        @(negedge clk);
        wr_en = 1;
        din   = 8'hAA;
        $display("Time %0t: Attempting write when FIFO is full (Data=%0h)", $time, din);

        @(negedge clk);
        wr_en = 0;

        // Read all data
        $display("\n--- Reading Data from FIFO ---");
        repeat (DEPTH) begin
            @(negedge clk);
            rd_en = 1;
            $display("Time %0t: Reading %0h", $time, dout);
        end

        // Attempt to read when empty
        @(negedge clk);
        rd_en = 1;
        $display("Time %0t: Attempting read when FIFO is empty", $time);

        @(negedge clk);
        rd_en = 0;

        #20;
        $display("\n=== FIFO Test Completed ===");
        $finish;
    end

endmodule
