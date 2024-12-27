/*
 * Copyright (c) 2024 Uri Shaked
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;
  wire sound;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [9:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  wire ground = (pix_y > 430 && pix_y<440);
  wire score;
  wire gameover;
  wire b1,b2,b3;
  wire v1=1;
  wire v2,v3;
  reg [9:0] counter_jmp;
  reg jmp_down=0;
  reg jmp;
  reg [31:0] speed=0;
  wire speed_clk=0;

  wire collision=0;
  wire jmp_btn;

  score sc(
    .clk(clk),
	.collision(collision),
	.pix_x(pix_x),
	.pix_y(pix_y),
    .score(score)
  );

  gameover go(
    .pix_x(pix_x),
    .pix_y(pix_y),
    .gameover(gameover)
  );

  localparam SPRITE_X = 90;
  localparam SPRITE_Y = 370;
  localparam SPRITE_SIZE = 64;

  reg [63:0] dino_bitmap [0:63];
  initial begin
    jmp=0;
    counter_jmp=0;
    // speed_clk =0;
    // speed = 0;
    dino_bitmap[ 0] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    dino_bitmap[ 1] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    dino_bitmap[ 2] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    dino_bitmap[ 3] = 64'b0000000000000000000000000000000000111111111111111111111000000000;
    dino_bitmap[ 4] = 64'b0000000000000000000000000000000000111111111111111111111000000000;
    dino_bitmap[ 5] = 64'b0000000000000000000000000000000000111111111111111111111000000000;
    dino_bitmap[ 6] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[ 7] = 64'b0000000000000000000000000000000111111001111111111111111110000000;
    dino_bitmap[ 8] = 64'b0000000000000000000000000000000111111001111111111111111110000000;
    dino_bitmap[ 9] = 64'b0000000000000000000000000000000111111001111111111111111110000000;
    dino_bitmap[10] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[11] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[12] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[13] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[14] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[15] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[16] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[17] = 64'b0000000000000000000000000000000111111111111111111111111110000000;
    dino_bitmap[18] = 64'b0000000000000000000000000000000111111111111100000000000000000000;
    dino_bitmap[19] = 64'b0000000000000000000000000000000111111111111100000000000000000000;
    dino_bitmap[20] = 64'b0000000000000000000000000000000111111111111100000000000000000000;
    dino_bitmap[21] = 64'b0000000000000000000000000000000111111111111111111111000000000000;
    dino_bitmap[22] = 64'b0000000000000000000000000000000111111111111111111111000000000000;
    dino_bitmap[23] = 64'b0000011100000000000000000000111111111111110000000000000000000000;
    dino_bitmap[24] = 64'b0000011100000000000000000000111111111111110000000000000000000000;
    dino_bitmap[25] = 64'b0000011100000000000000000000111111111111110000000000000000000000;
    dino_bitmap[26] = 64'b0000011100000000000000000111111111111111110000000000000000000000;
    dino_bitmap[27] = 64'b0000011100000000000000000111111111111111110000000000000000000000;
    dino_bitmap[28] = 64'b0000011111000000000011111111111111111111111111100000000000000000;
    dino_bitmap[29] = 64'b0000011111000000000011111111111111111111111111100000000000000000;
    dino_bitmap[30] = 64'b0000011111000000000011111111111111111111111111100000000000000000;
    dino_bitmap[31] = 64'b0000011111111000001111111111111111111111110011100000000000000000;
    dino_bitmap[32] = 64'b0000011111111000001111111111111111111111110011100000000000000000;
    dino_bitmap[33] = 64'b0000011111111000001111111111111111111111110011100000000000000000;
    dino_bitmap[34] = 64'b0000011111111111111111111111111111111111110000000000000000000000;
    dino_bitmap[35] = 64'b0000011111111111111111111111111111111111110000000000000000000000;
    dino_bitmap[36] = 64'b0000011111111111111111111111111111111111110000000000000000000000;
    dino_bitmap[37] = 64'b0000011111111111111111111111111111111111110000000000000000000000;
    dino_bitmap[38] = 64'b0000011111111111111111111111111111111111110000000000000000000000;
    dino_bitmap[39] = 64'b0000000011111111111111111111111111111111110000000000000000000000;
    dino_bitmap[40] = 64'b0000000011111111111111111111111111111111110000000000000000000000;
    dino_bitmap[41] = 64'b0000000011111111111111111111111111111110000000000000000000000000;
    dino_bitmap[42] = 64'b0000000000111111111111111111111111111110000000000000000000000000;
    dino_bitmap[43] = 64'b0000000000111111111111111111111111111110000000000000000000000000;
    dino_bitmap[44] = 64'b0000000000111111111111111111111111111110000000000000000000000000;
    dino_bitmap[45] = 64'b0000000000000111111111111111111111111000000000000000000000000000;
    dino_bitmap[46] = 64'b0000000000000111111111111111111111111000000000000000000000000000;
    dino_bitmap[47] = 64'b0000000000000111111111111111111111111000000000000000000000000000;
    dino_bitmap[48] = 64'b0000000000000001111111111111111111000000000000000000000000000000;
    dino_bitmap[49] = 64'b0000000000000001111111111111111111000000000000000000000000000000;
    dino_bitmap[50] = 64'b0000000000000001111111111111111111000000000000000000000000000000;
    dino_bitmap[51] = 64'b0000000000000000001111111000111111000000000000000000000000000000;
    dino_bitmap[52] = 64'b0000000000000000001111111000111111000000000000000000000000000000;
    dino_bitmap[53] = 64'b0000000000000000001111100000000111000000000000000000000000000000;
    dino_bitmap[54] = 64'b0000000000000000001111100000000111000000000000000000000000000000;
    dino_bitmap[55] = 64'b0000000000000000001111100000000111000000000000000000000000000000;
    dino_bitmap[56] = 64'b0000000000000000001100000000000111000000000000000000000000000000;
    dino_bitmap[57] = 64'b0000000000000000001100000000000111000000000000000000000000000000;
    dino_bitmap[58] = 64'b0000000000000000001100000000000111000000000000000000000000000000;
    dino_bitmap[59] = 64'b0000000000000000001111100000000111111000000000000000000000000000;
    dino_bitmap[60] = 64'b0000000000000000001111100000000111111000000000000000000000000000;
    dino_bitmap[61] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    dino_bitmap[62] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
    dino_bitmap[63] = 64'b0000000000000000000000000000000000000000000000000000000000000000;
  end

  wire sprite = video_active &&
                    pix_x >= SPRITE_X && pix_x < SPRITE_X + SPRITE_SIZE &&
                    pix_y >= SPRITE_Y - counter_jmp && pix_y < SPRITE_Y + SPRITE_SIZE -counter_jmp &&
                    dino_bitmap[pix_y - SPRITE_Y + counter_jmp][63 - (pix_x - SPRITE_X)];

// reg [31:0] v1_count;
// reg [31:0] v2_count;
// reg [31:0] v3_count;
//
// always @(posedge clk) begin
//     if(v1_count == 50000) begin
//         v1 <= ~v1;
//         v1_count <= 0;
//      end
//      else begin
//         v1_count <= v1_count + 1;
//      end
// end
//
// always @(posedge clk) begin
//     if(v2_count == 80000) begin
//         v2 <= ~v2;
//         v2_count <= 0;
//      end
//      else begin
//         v2_count <= v2_count + 1;
//      end
// end
//
// always @(posedge clk) begin
//     if(v3_count == 30000) begin
//         v3 <= ~v3;
//         v3_count <= 0;
//      end
//      else begin
//         v3_count <= v3_count + 1;
//      end
// end
//
// always @(posedge clk) begin
//     if(dino && b1 || dino && b2 || dino && b3) collision <= 1;
// end
//
// wire b1 = (pix_x>380 - counter && pix_x<420 - counter) && (pix_y > 400 && pix_y < 430);
// wire b2 = (pix_x>340 - counter && pix_x<380 - counter) && (pix_y > 410 && pix_y < 430);
// wire b3 = (pix_x>320 - counter && pix_x<380 - counter) && (pix_y > 410 && pix_y < 430);
//
// wire display = (ground || sprite || score || (v1 && b1) || (v2 && b2) || (v3 && b3) || (collision && gameover));

  wire b1 = (pix_x>340 - counter && pix_x<380 - counter) && (pix_y > 410 && pix_y < 430);



  // always @(posedge clk) begin
  //   if(speed == 20000) begin
  //     speed_clk <= ~speed_clk;
  //     speed <= 0;
  //   end
  //   else begin
  //     speed <= speed + 1;
  //   end
  // end
  // always @(posedge clk) begin
  //     if(jmp_btn) jmp <=1;
  // end


  wire display = (ground || sprite || score || b1 || (collision && gameover));

  assign R = display ? 2'b11 : 2'b00;
  assign G = display ? 2'b11 : 2'b00;
  assign B = display ? 2'b11 : 2'b00;

  always @(posedge vsync) begin
    if (jmp ==0) begin
      counter_jmp <= 0;
    end
    if(counter_jmp == 50) begin
      counter_jmp <= counter_jmp-1;
      jmp_down <= 1;
    end
    if(jmp_down==0 && jmp==1)begin
      counter_jmp <= counter_jmp + 1;
    end
    if(jmp_down==1) begin
      counter_jmp <= counter_jmp-1;
    end
    if(counter_jmp==0 && jmp==1) begin
        jmp_down<=0;
        counter_jmp <= counter_jmp + 1;
    end
  end
  always @(posedge vsync) begin
    if (~rst_n) begin
      counter <= 0;
    end
    if(counter == 300) counter <=0;
     else begin
      counter <= counter + 1;
    end
  end

endmodule

module gameover(
    input [9:0] pix_x,
    input [9:0] pix_y,
    output gameover
);

  wire g = (pix_x > 250 && pix_x <300) && (pix_y >220 && pix_y < 230) ||
  (pix_x > 250 && pix_x <260) && (pix_y > 220 && pix_y < 280) ||
  (pix_x > 250 && pix_x <300) && (pix_y >270 && pix_y < 280) ||
  (pix_x > 290 && pix_x <=300) && (pix_y > 247 && pix_y < 280) ||
  (pix_x > 280 && pix_x <300) && (pix_y >247 && pix_y < 257);

  wire o = (pix_x > 310 && pix_x <360) && (pix_y >220 && pix_y < 230) ||
  (pix_x > 310 && pix_x <320) && (pix_y > 220 && pix_y < 280) ||
  (pix_x > 310 && pix_x <360) && (pix_y >270 && pix_y < 280) ||
  (pix_x > 350 && pix_x <=360) && (pix_y > 220 && pix_y < 280);

  wire ex = (pix_x > 375 && pix_x <385) && (pix_y > 220 && pix_y < 260) ||
  (pix_x > 375 && pix_x < 385) && (pix_y > 270 && pix_y < 280);

  assign gameover = ( g || o || ex );

endmodule

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


module number(
    input clk,
    input collision,
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

