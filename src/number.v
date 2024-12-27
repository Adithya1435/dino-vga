module number(
    input clk,
    input [9:0] pix_x,
    input [9:0] pix_y,
    input reg [5:0] x,
    input reg [3:0] counter,
    output reg number
);

wire [9:0] char_x = pix_x - x;
wire [9:0] char_y = pix_y - 5;

wire [2:0] row = char_y[5:3];
wire [2:0] col = char_x[5:3];

always @(*) begin
    number = 0;
    if (char_x >= 0 && char_x < 70 && char_y >= 0 && char_y < 60) begin
        case (counter)
        4'd0: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 2 || col == 5);
                3'd2: number = (col == 2 || col == 5);
                3'd3: number = (col == 2 || col == 5);
                3'd4: number = (col == 2 || col == 5);
                3'd5: number = (col >= 2 && col <= 5);
                endcase
        4'd1: case (row)
                3'd0: number = (col == 4);
                3'd1: number = (col == 3 || col == 4);
                3'd2: number = (col == 4);
                3'd3: number = (col == 4);
                3'd4: number = (col == 4);
                3'd5: number = (col >= 3 && col <= 5);
                endcase
        4'd2: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 5);
                3'd2: number = (col >= 2 && col <= 5);
                3'd3: number = (col == 2);
                3'd4: number = (col == 2);
                3'd5: number = (col >= 2 && col <= 5);
                endcase
        4'd3: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 5);
                3'd2: number = (col >= 2 && col <= 5);
                3'd3: number = (col == 5);
                3'd4: number = (col == 5);
                3'd5: number = (col >= 2 && col <= 5);
                endcase
        4'd4: case (row)
                3'd0: number = (col == 5);
                3'd1: number = (col == 4 || col == 5);
                3'd2: number = (col == 3 || col == 5);
                3'd3: number = (col >= 2 && col <= 5);
                3'd4: number = (col == 5);
                3'd5: number = (col == 5);
                endcase
        4'd5: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 2);
                3'd2: number = (col >= 2 && col <= 5);
                3'd3: number = (col == 5);
                3'd4: number = (col == 5);
                3'd5: number = (col >= 2 && col <= 5);
                endcase
        4'd6: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 2);
                3'd2: number = (col >= 2 && col <= 5);
                3'd3: number = (col == 2 || col == 5);
                3'd4: number = (col == 2 || col == 5);
                3'd5: number = (col >= 2 && col <= 5);
                endcase
        4'd7: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 5);
                3'd2: number = (col == 5);
                3'd3: number = (col == 5);
                3'd4: number = (col == 5);
                3'd5: number = (col == 5);
                endcase
        4'd8: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 2 || col == 5);
                3'd2: number = (col >= 2 && col <= 5);
                3'd3: number = (col == 2 || col == 5);
                3'd4: number = (col == 2 || col == 5);
                3'd5: number = (col >= 2 && col <= 5);
                endcase
        4'd9: case (row)
                3'd0: number = (col >= 2 && col <= 5);
                3'd1: number = (col == 2 || col == 5);
                3'd2: number = (col >= 2 && col <= 5);
                3'd3: number = (col == 5);
                3'd4: number = (col == 5);
                3'd5: number = (col >= 2 && col <= 5);
                endcase
        default: number = 0;
        endcase
    end
  end
endmodule
