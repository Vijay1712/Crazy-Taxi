module Draw_winner
(
    input logic FrameClk, PixelClk, DrawWinner,
    input logic [9:0] DrawX, DrawY,
    input logic Winner, // 0 for P1 WINS, 1 for P2 WINS
    output logic [7:0] VGA_R, VGA_G, VGA_B
);

    logic [3:0] color;
    logic [23:0] rgb;
    logic [15:0] read_address, read_address_next;
    logic is_draw_region, is_transparent;
    logic [9:0] winner_x, winner_y;

    always_ff @(posedge PixelClk)
    begin
        if(~DrawWinner)
        begin
            winner_x <= 10'd225;
            winner_y <= 10'd170;
        end
        read_address <= read_address_next;
    end

    winnerRAM winners
    (
        .data_In(4'd0),
		.write_address(16'd0),
        .read_address(read_address), 
		.we(1'b0),
        .Clk(PixelClk),
        .data_Out(color)
    );

    // draw logic
    always_comb
    begin
        is_draw_region = 1'b0;
        read_address_next = 16'd0;
        if((DrawX >= winner_x) && (DrawX < winner_x + 10'd200) && (DrawY >= winner_y) && (DrawY < winner_y + 10'd140))
        begin
            is_draw_region = 1'b1;
            case (Winner)
                1'b0: read_address_next = ((DrawY - winner_y) * 10'd400) + (DrawX - winner_x);
                1'b1: read_address_next = ((DrawY - winner_y) * 10'd400) + (DrawX - winner_x + 10'd200);
            endcase
        end
    end

    // display foreground or background
    always_comb
    begin
        if(is_draw_region & ~is_transparent)
        begin
            VGA_R = rgb[23:16];
            VGA_G = rgb[15:8];
            VGA_B = rgb[7:0];
        end
        else
        begin
            VGA_R = 8'hff;
            VGA_G = 8'hff;
            VGA_B = 8'hff;
        end
    end 
    
    // color encoding
    always_comb
    begin
        rgb = 24'h000000;
        is_transparent = 1'b0;
        case (color)
            4'h0: rgb = 24'he01800;
            4'h1: rgb = 24'h605cf4;
            4'h2: rgb = 24'hfc4000;
            4'h3: rgb = 24'hf1693a;
            4'h4: rgb = 24'hc8f3f7;
            4'h5: rgb = 24'hc00800;
            4'h6: rgb = 24'h8c98f8;
            4'h7: rgb = 24'h584cf4;
            4'h8: is_transparent = 1'b1;
        endcase
    end

endmodule