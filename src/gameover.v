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

