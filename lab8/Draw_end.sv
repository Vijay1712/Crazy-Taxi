module Draw_end
(
    input logic FrameClk, PixelClk, Reset_h,
    input logic [9:0] DrawX, DrawY,               // Current pixel coordinates
    output logic [7:0] VGA_R, VGA_G, VGA_B        // VGA RGB output
);

    logic [17:0] write_address, read_address, read_address_next;
    logic text_color;

    logic is_text, is_transparent;
    logic [23:0] text_rgb;

    logic [9:0] GameOverX, GameOverY, CreatedX, CreatedY, RoshiniX, RoshiniY, VijayX, VijayY, PromptX, PromptY;

    EndTextRAM endText
    (
        .data_In(1'b0), 
        .write_address(write_address),
        .read_address(read_address), 
		.we(1'b0),
        .Clk(PixelClk),
        .data_Out(text_color)
    );

    always_ff @(posedge PixelClk)
    begin
        if(Reset_h)
        begin
            GameOverX <= 10'd190;
            GameOverY <= 10'd70;
            CreatedX <= 10'd180;
            CreatedY <= 10'd170;
            RoshiniX <= 10'd15; 
            RoshiniY <= 10'd220;
            VijayX <= 10'd75;
            VijayY <= 10'd270;
            PromptX <= 10'd45;
            PromptY <= 10'd390;
        end
        read_address <= read_address_next;
    end

    always_comb
    begin
        if(is_text & ~is_transparent)
        begin
            VGA_R = text_rgb[23:16];
            VGA_G = text_rgb[15:8];
            VGA_B = text_rgb[7:0];
        end
        else // background red
        begin
            VGA_R = 8'hff;
            VGA_G = 8'h50;
            VGA_B = 8'h50;
        end
    end

    // textsheet is 620 x 350
    always_comb
    begin
        is_text = 1'b1;
        read_address_next = 18'd0;
        // game over is 300 x 50
        if((DrawX >= GameOverX) && (DrawX < GameOverX + 10'd300) && (DrawY >= GameOverY) && (DrawY < GameOverY + 10'd30))
            read_address_next = ((DrawY - GameOverY + 10'd150) * 10'd620) + (DrawX - GameOverX);
        // created by is 300 x 50
        else if((DrawX >= CreatedX) && (DrawX < CreatedX + 10'd300) && (DrawY >= CreatedY) && (DrawY < CreatedY + 10'd30))
            read_address_next = ((DrawY - CreatedY) * 10'd620) + (DrawX - CreatedX);
        // my name is 620 x 50 LOL
        else if((DrawX >= RoshiniX) && (DrawX < RoshiniX + 10'd620) && (DrawY >= RoshiniY) && (DrawY < RoshiniY + 10'd30))
            read_address_next = ((DrawY - RoshiniY + 10'd50) * 10'd620) + (DrawX - RoshiniX);
        // vijay's name is 500 x 50
        else if((DrawX >= VijayX) && (DrawX < VijayX + 10'd500) && (DrawY >= VijayY) && (DrawY < VijayY + 10'd30))
            read_address_next = ((DrawY - VijayY + 10'd100) * 10'd620) + (DrawX - VijayX);
        // prompt is 600 x 50
        else if((DrawX >= PromptX) && (DrawX < PromptX + 10'd600) && (DrawY >= PromptY) && (DrawY < PromptY + 10'd30))
            read_address_next = ((DrawY - PromptY + 10'd200) * 10'd620) + (DrawX - PromptX);
        else
            is_text = 1'b0;
    end

    // color processing
    // text sheet encoding
    always_comb
    begin
        text_rgb = 24'd0;
        is_transparent = 1'b0;
        case (text_color)
            1'b0: is_transparent = 1'b1;  
            1'b1: text_rgb = 24'hffffff;
        endcase
    end

endmodule