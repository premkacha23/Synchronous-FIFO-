module sync_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 12,
    parameter PTR_WIDTH = 4
)(
    input wire clk,
    input wire rst,
    input wire wr_en,
    input wire rd_en,
    input wire [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout,
    output wire empty,
    output wire full
);

    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    reg [PTR_WIDTH-1:0] write_ptr, read_ptr;
    reg [PTR_WIDTH:0] data_count;

    assign empty = (data_count == 0);
    assign full  = (data_count == DEPTH);

    // Write logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            write_ptr <= 0;
        end else if (wr_en && !full) begin
            fifo_mem[write_ptr] <= din;
            write_ptr <= write_ptr + 1;
        end
    end

    // Read logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            read_ptr <= 0;
            dout <= 0;
        end else if (rd_en && !empty) begin
            dout <= fifo_mem[read_ptr];
            read_ptr <= read_ptr + 1;
        end
    end

    // Count logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b10: data_count <= data_count + 1;
                2'b01: data_count <= data_count - 1;
                default: data_count <= data_count;
            endcase
        end
    end

endmodule
