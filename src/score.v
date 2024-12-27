module score(
    input clk,
    input collision,
    input [9:0] pix_x,
    input [9:0] pix_y,
    output reg score
);

reg [3:0] counter;
reg [31:0] timer = 0;
reg [3:0] count_ten = 0;
reg [5:0] x_unit = 6'd45;
reg [5:0] x_ten = 6'd0;
reg unit_num;
reg ten_num;

always @(posedge clk) begin
    if (collision) begin
      //timer = 0;
    end else begin
      if (timer < 5000000) begin
        timer = timer + 1;
      end else if(timer >= 5000000 && collision==0) begin
        timer = 0;
        if (counter == 9)
          counter = 0;
        else
          counter = counter + 1;
      end
    end
end

always @(posedge clk) begin
    if(counter == 9 && count_ten<9) count_ten <= count_ten + 1;
    if(count_ten == 9) count_ten <= 0;
end

number num_units(
    .clk(clk),
    .collision(collision),
    .pix_x(pix_x),
    .pix_y(pix_y),
    .x(x_unit),
    .counter(counter),
    .number(unit_num)
);

number num_tens(
    .clk(clk),
    .collision(collision),
    .pix_x(pix_x),
    .pix_y(pix_y),
    .x(x_ten),
    .counter(count_ten),
    .number(ten_num)
);

assign score = unit_num || ten_num;

endmodule
