module Draw_points
(
    input logic PixelClk, DrawGame,
    input logic [9:0] DrawX, DrawY,                                         // Current pixel coordinates
    input logic [11:0] P1_score_hex, P2_score_hex,
    input logic [9:0] P1score_x, P2score_x, Score_y,                        // 0-indexed start points
    output logic [7:0] VGA_R, VGA_G, VGA_B,                                 // VGA RGB output
    output logic Is_score,
    output logic Is_transparent
);

    logic [14:0] write_address, read_address, read_address_next;
    logic [23:0] rgb;
    logic [3:0] color;
    logic is_p1, is_p1_next;
    logic [23:0] player_color;

    numbersRAM numbers
    (
        .data_In(4'b0), 
        .write_address(write_address),
        .read_address(read_address), 
		.we(1'b0),
        .Clk(PixelClk),
        .data_Out(color)
    );

    always_ff @(posedge PixelClk)
    begin
        read_address <= read_address_next;
        is_p1 <= is_p1_next;
    end

    assign player_color = (is_p1)? (24'he01800) : (24'h605cf4); // red or purple

    // color processing
    // numbers sheet encoding
    always_comb
    begin
        rgb = 24'd0;
        Is_transparent = 1'b0;
        case (color)
            4'h0: Is_transparent = 1'b1;  
            4'h1: rgb = 24'hffffff;
            4'h2: rgb = player_color; 
        endcase
    end

    assign VGA_R = rgb[23:16];
    assign VGA_G = rgb[15:8];
    assign VGA_B = rgb[7:0];

    always_comb
    begin
        Is_score = 1'b1;
        read_address_next = 15'd0;
        is_p1_next = 1'b1;
        if((DrawY >= Score_y) && DrawY < (Score_y + 10'd30))
        begin
            // p1 score drawing range
            if((DrawX >= P1score_x) && (DrawX <= P1score_x + 10'd30))
                read_address_next = ((DrawY - Score_y) * 10'd300) + ((P1_score_hex[11:8] * 10'd30) + (DrawX - P1score_x));
            else if ((DrawX >= P1score_x + 10'd35) && (DrawX <= P1score_x + 10'd65))
                read_address_next = ((DrawY - Score_y) * 10'd300) + ((P1_score_hex[7:4] * 10'd30) + (DrawX - (P1score_x + 10'd35)));
            else if ((DrawX >= P1score_x + 10'd70) && (DrawX <= P1score_x + 10'd100))
                read_address_next = ((DrawY - Score_y) * 10'd300) + ((P1_score_hex[3:0] * 10'd30) + (DrawX - (P1score_x + 10'd70)));
            else
            begin
                // p2 score drawing range
                is_p1_next = 1'b0;
                if ((DrawX >= P2score_x) && (DrawX <= P2score_x + 10'd30))
                    read_address_next = ((DrawY - Score_y) * 10'd300) + ((P2_score_hex[11:8] * 10'd30) + (DrawX - P2score_x));
                else if ((DrawX >= P2score_x + 10'd35) && (DrawX <= P2score_x + 10'd65))
                    read_address_next = ((DrawY - Score_y) * 10'd300) + ((P2_score_hex[7:4] * 10'd30) + (DrawX - (P2score_x + 10'd35)));
                else if ((DrawX >= P2score_x + 10'd70) && (DrawX <= P2score_x + 10'd100))
                    read_address_next = ((DrawY - Score_y) * 10'd300) + ((P2_score_hex[3:0] * 10'd30) + (DrawX - (P2score_x + 10'd70)));
                else 
                    Is_score = 1'b0;
            end
        end
        else 
            Is_score = 1'b0;
    end
endmodule