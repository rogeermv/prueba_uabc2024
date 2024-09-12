/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_rogelio_mv #( parameter MAX_COUNT = 24'd10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    wire reset = ! rst_n;
    wire [6:0] led_out;
    assign uo_out[6:0] = led_out;
    assign uo_out[7] = 1'b0;

     // use bidirectionals as outputs
    assign uio_oe = 8'b11111111;

    // put bottom 8 bits of second counter out on the bidirectional gpio
    assign uio_out = second_counter[7:0];

    // external clock is 10MHz, so need 24 bit counter
    reg [23:0] second_counter;
    reg [3:0] digit;

    always @(posedge clk) begin
        // if reset, set counter to 0
        if (reset) begin
            second_counter <= 0;
            digit <= 0;
        end else begin
            // if up to 16e6
            if (second_counter == MAX_COUNT) begin
                // reset
                second_counter <= 0;

                // increment digit
                digit <= digit + 1'b1;

                // only count from 0 to 15
                if (digit == 16)
                    digit <= 0;

            end else
                // increment counter
                second_counter <= second_counter + 1'b1;
        end
    end

    // instantiate segment display
    seg7 seg7(.counter(digit), .segments(led_out));

    module seg7 (
    input wire [3:0] counter,
    output reg [6:0] segments
);

    always @(*) begin
        case(counter)
            0: segments = 7'b0111110; //U
            1: segments = 7'b1110111; //A
            2: segments = 7'b1111100; //B
            3: segments = 7'b0111001; //C
            4: segments = 7'b1000000; //-
            5: segments = 7'b1111001; //E
            6: segments = 7'b0111000; //L 
            7: segments = 7'b1111001; //E
            8: segments = 7'b0111001; //C
            9: segments = 7'b0110001; //T
            10: segments = 7'b1010000; //R
            11: segments = 7'b0111111; //O
            12: segments = 7'b1010100; //N
            13: segments = 7'b0110000; //I
            14: segments = 7'b0111001; //C
            15: segments = 7'b1110111; //A
            default:    
                segments = 7'b0000000;
        endcase
    end

    
  // List all unused inputs to prevent warnings
  wire _unused = &{ena, 1'b0};

endmodule
