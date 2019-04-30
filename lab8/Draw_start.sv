module Draw_start 
(
    input logic FrameClk, PixelClk, StartGame,
    input logic [9:0] DrawX, DrawY,                                         // Current pixel coordinates
    input logic StartTransition,
    output logic [7:0] VGA_R, VGA_G, VGA_B,                                  // VGA RGB output
    output logic TransitionDone
);

    logic [17:0] write_address, sprite_read_address, sprite_read_address_next, text_read_address, text_read_address_next;
    logic [3:0] sprite_color;
    logic text_color;

    logic is_sprite, is_text, sprite_is_transparent, text_is_transparent;
    logic [23:0] text_rgb, sprite_rgb;

    logic [9:0] TitleX, TitleY, PromptX, PromptY, P1X, P1Y, P2X, P2Y, Car1X, Car1Y, Car2X, Car2Y;
    logic [9:0] car1_y_next, car2_y_next, p1_y_next, p2_y_next, prompt_y_next;
 
    textRAM text
    (
        .data_In(1'b0), 
        .write_address(write_address),
        .read_address(text_read_address), 
		.we(1'b0),
        .Clk(PixelClk),
        .data_Out(text_color)
    );

    frameRAM sprites
    (
        .data_In(4'd0), 
        .write_address(write_address), 
        .read_address(sprite_read_address), 
        .we(1'b0), 
        .Clk(PixelClk), 
        .data_Out(sprite_color)
    );

    always_ff @(posedge PixelClk)
    begin
        sprite_read_address <= sprite_read_address_next;
        text_read_address <= text_read_address_next;
    end

    always_comb
    begin
        if(is_text & ~text_is_transparent)
        begin
            VGA_R = text_rgb[23:16];
            VGA_G = text_rgb[15:8];
            VGA_B = text_rgb[7:0];
        end
        else if(is_sprite & ~sprite_is_transparent)
        begin
            VGA_R = sprite_rgb[23:16];
            VGA_G = sprite_rgb[15:8];
            VGA_B = sprite_rgb[7:0];
        end
        else // background blue
        begin 
            VGA_R = 8'h00;
            VGA_G = 8'hcc;
            VGA_B = 8'hff;
        end
    end

    // 600 x 250 spritesheet
    always_comb
    begin
        text_read_address_next = 18'd0;
        sprite_read_address_next = 18'd0;
        is_text = 1'b1;
        is_sprite = 1'b0;
        // title is in a 160 x 65 box
        if((DrawX >= TitleX) && (DrawX < TitleX + 10'd160) && (DrawY >= TitleY) && (DrawY < TitleY + 10'd65))
            text_read_address_next = ((DrawY - TitleY) * 10'd600) + (DrawX - TitleX);
        // prompt is in a 565 x 50 box
        else if((DrawX >= PromptX) && (DrawX < PromptX + 10'd565) && (DrawY >= PromptY) && (DrawY < PromptY + 10'd50))
            text_read_address_next = (((DrawY - PromptY) + 10'd100) * 10'd600) + (DrawX - PromptX);
        // p1 and p2 are in 60 x 35 boxes
        else if((DrawX >= P1X) && (DrawX < P1X + 10'd60) && (DrawY >= P1Y) && (DrawY < P1Y + 10'd35))
            text_read_address_next = (((DrawY - P1Y) + 10'd150) * 10'd600) + (DrawX - P1X);
        else if((DrawX >= P2X) && (DrawX < P2X + 10'd60) && (DrawY >= P2Y) && (DrawY < P2Y + 10'd35))
            text_read_address_next = (((DrawY - P2Y) + 10'd150) * 10'd600) + (DrawX - P2X + 10'd100);
        else if((DrawX >= Car1X - 10'd49) && (DrawX <= Car1X + 10'd50) && (DrawY >= Car1Y - 10'd49) && (DrawY <= Car1Y + 10'd50))
        begin
            is_sprite = 1'b1;
            is_text = 1'b0;
            sprite_read_address_next = ((DrawY - (Car1Y - 10'd49)) * 10'd600) + (DrawX - (Car1X - 10'd49));
        end
        else if((DrawX >= Car2X - 10'd49) && (DrawX <= Car2X + 10'd50) && (DrawY >= Car2Y - 10'd49) && (DrawY <= Car2Y + 10'd50))
        begin
            is_sprite = 1'b1;
            is_text = 1'b0;
            sprite_read_address_next = ((DrawY - (Car2Y - 10'd49)) * 10'd600) + (DrawX - (Car2X - 10'd49) + 10'd100);
        end
    end

    always_ff @(posedge FrameClk)
    begin
        if(~StartGame | ~StartTransition)
        begin
            TitleX <= 10'd240;
            TitleY <= 10'd70; 
            PromptX <= 10'd45;
            PromptY <= 10'd400;

            P1X <= 10'd175;
            P1Y <= 10'd300;
            P2X <= 10'd409;
            P2Y <= 10'd300; 

            Car1X <= 10'd205;
            Car1Y <= 10'd230;
            Car2X <= 10'd434;
            Car2Y <= 10'd230;
        end
        else if(StartTransition)
        begin
            P1Y <= p1_y_next;
            P2Y <= p2_y_next;
            PromptY <= prompt_y_next;
            Car1Y <= car1_y_next;
            Car2Y <= car2_y_next;
        end
    end

    assign TransitionDone = (Car1Y == 10'd430)? (1'b1) : (1'b0);

    always_comb
    begin
        car1_y_next = Car1Y + 10'd2;
        car2_y_next = Car2Y + 10'd2;
        p1_y_next = P1Y + 10'd2;
        p2_y_next = P2Y + 10'd2;
        prompt_y_next = PromptY + 10'd2;
    end

    // color processing
    // text sheet encoding
    always_comb
    begin
        text_rgb = 24'd0;
        text_is_transparent = 1'b0;
        case (text_color)
            1'b0: text_is_transparent = 1'b1;  
            1'b1: text_rgb = 24'hffffff;
        endcase
    end

    // sprite sheet encoding
    always_comb
    begin
        sprite_is_transparent = 1'b0;
        sprite_rgb = 24'd0;
        case(sprite_color)
            4'd0: sprite_is_transparent = 1'b1; // black	
            4'd1: sprite_rgb = 24'hc8f3f7; // light blue
            4'd2: sprite_rgb = 24'hfff84b; // yellow
            4'd3: sprite_rgb = 24'h605cf4; // purple
            4'd4: sprite_rgb = 24'h8c98f8; // light purple
            4'd5: sprite_rgb = 24'he01800; // red
            4'd6: sprite_rgb = 24'hfc4000; // dark orange
            4'd7: sprite_rgb = 24'hc00800; // dark red
            4'd8: sprite_rgb = 24'hf0e000; // dark yellow  
            4'd9: sprite_rgb = 24'h584cf4; // dark purple
            4'd10: sprite_rgb = 24'h00ac00; // dark green
            4'd11: sprite_rgb = 24'h00f000; // green
            4'd12: sprite_rgb = 24'hf1693a; // orange
            default: 
            begin
                sprite_is_transparent = 1'b0; 
                sprite_rgb = 24'h000000;
            end
        endcase
    end
    
endmodule