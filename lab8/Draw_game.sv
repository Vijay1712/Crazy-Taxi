//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  Draw_game
( 
    input logic FrameClk, PixelClk, Reset_h, DrawGame, DrawWinner,
    input logic [9:0] DrawX, DrawY,                     // Current pixel coordinates
    input logic [31:0] Keycode,
    output logic [7:0] VGA_R, VGA_G, VGA_B,             // VGA RGB output
    output logic GameOver,
    output logic Winner                                 // 0 for P1 WINS, 1 for P2 WINS
);

    logic is_sprite, is_transparent;
    logic [23:0] sprite_rgb, background_rgb;
    logic [7:0] sprite_red, sprite_green, sprite_blue, background_red, background_green, background_blue;
    logic [15:0] write_address, read_address, read_address_next;

    // cars
    logic [15:0] car1_address, car2_address;
    logic is_car1, is_car2, car1_moved, car2_moved;
    logic [13:0] car1_x, car1_y, car2_x, car2_y;
    logic [9:0] car1_relative_y, car2_relative_y;

    // obstacles
    logic [15:0] obstacle1_address, obstacle2_address, obstacle3_address, obstacle4_address, obstacle5_address, obstacle6_address;
    logic is_obstacle1, is_obstacle2, is_obstacle3, is_obstacle4, is_obstacle5, is_obstacle6;

    // score
    logic is_score, score_is_transparent;
    logic [7:0] score_red, score_green, score_blue;
    logic [11:0] p1_hex_score, p2_hex_score;
    logic increment_p1, increment_p2;

    logic [3:0] color, write_dummy;
    logic [13:0] progress, progress_in, speed, speed_next;
    logic [1:0] car1_lane, car2_lane;
    
    logic [24:0] count, count_next;
    logic transition;
    logic [7:0] randLane;

    // collisions
    logic cone1_exists, cone2_exists, cone3_exists, cone4_exists, cone5_exists, cone6_exists;
    logic [9:0] cone1_y, cone2_y, cone3_y, cone4_y, cone5_y, cone6_y;
    logic car1_ded, car2_ded;

    // trees
    logic is_tree1, is_tree2, is_tree3;
    logic tree1_is_transparent, tree2_is_transparent, tree3_is_transparent; 
    logic [7:0] tree1_r, tree1_g, tree1_b, tree2_r, tree2_g, tree2_b, tree3_r, tree3_g, tree3_b;

    logic [13:0] car1y_old, car2y_old;

    // Note: dimensions of sprite sheet is 600x100 pixels
    frameRAM sprite_memory(.data_In(write_dummy), .write_address(write_address), .read_address(read_address), .we(1'b0), .Clk(PixelClk), .data_Out(color));

    // draw cars
    Draw_car1 car1(.PixelClk(PixelClk), .CarX(car1_x), .CarY(car1_y), .DrawX(DrawX), .DrawY(DrawY), .Progress(progress), .IsCar(is_car1), .ReadAddress(car1_address), .carY_relative(car1_relative_y));
    Draw_car2 car2(.PixelClk(PixelClk), .CarX(car2_x), .CarY(car2_y), .DrawX(DrawX), .DrawY(DrawY), .Progress(progress), .IsCar(is_car2), .ReadAddress(car2_address), .carY_relative(car2_relative_y));

    // move cars
    Move_car moveCar1(.FrameClk(FrameClk), .DrawGame(DrawGame), .Transition(transition),  .Keycode(Keycode), .Jump(8'h1a), .Left(8'h04), .Right(8'h07), .Break(8'h16), .StartLane(2'd0), .OtherCarLane(car2_lane), .OtherCarY(car2_y), .CarSpeed(speed), .CarX(car1_x), .CarY(car1_y), .Lane(car1_lane));
    Move_car moveCar2(.FrameClk(FrameClk), .DrawGame(DrawGame), .Transition(transition), .Keycode(Keycode), .Jump(8'h52), .Left(8'h50), .Right(8'h4f), .Break(8'h51), .StartLane(2'd2), .OtherCarLane(car1_lane), .OtherCarY(car1_y), .CarSpeed(speed), .CarX(car2_x), .CarY(car2_y), .Lane(car2_lane));

    // draw obstacles
    Draw_obstacle lane1(.DrawGame(DrawGame), .Progress(progress), .PixelClk(PixelClk), .FrameClk(FrameClk), .Exists_next(randLane[2]), .ObstacleX(10'd200), .ObstacleYInit(10'd200), .DrawX(DrawX), .DrawY(DrawY), .IsObstacle(is_obstacle1), .ReadAddress(obstacle1_address), .Exists(cone1_exists), .obstacleY_relative(cone1_y));
    Draw_obstacle lane2(.DrawGame(DrawGame), .Progress(progress), .PixelClk(PixelClk), .FrameClk(FrameClk), .Exists_next(randLane[1]), .ObstacleX(10'd320), .ObstacleYInit(10'd200), .DrawX(DrawX), .DrawY(DrawY), .IsObstacle(is_obstacle2), .ReadAddress(obstacle2_address), .Exists(cone2_exists), .obstacleY_relative(cone2_y));
    Draw_obstacle lane3(.DrawGame(DrawGame), .Progress(progress), .PixelClk(PixelClk), .FrameClk(FrameClk), .Exists_next(randLane[0]), .ObstacleX(10'd430), .ObstacleYInit(10'd200), .DrawX(DrawX), .DrawY(DrawY), .IsObstacle(is_obstacle3), .ReadAddress(obstacle3_address), .Exists(cone3_exists), .obstacleY_relative(cone3_y));

    // draw score
    Draw_points drawScore
    ( 
        .PixelClk(PixelClk), 
        .DrawGame(DrawGame),
        .DrawX(DrawX),
        .DrawY(DrawY),
        .P1_score_hex(p1_hex_score), 
        .P2_score_hex(p2_hex_score),
        .P1score_x(10'd27),
        .P2score_x(10'd512),
        .Score_y(10'd20),                    
        .VGA_R(score_red),
        .VGA_G(score_green),
        .VGA_B(score_blue),                               
        .Is_score(is_score),
        .Is_transparent(score_is_transparent)
    );

    Points calculateHexScore
    (
        .FrameClk(FrameClk),
        .DrawGame(DrawGame),
        .Increment_p1(increment_p1),
        .Increment_p2(increment_p2),
        .P1_points_hex(p1_hex_score), 
        .P2_points_hex(p2_hex_score)
    );

    random randomLaneGenerator 
    (
        .Clk(FrameClk),
        .Reset_h(~DrawGame),
        .rnd(randLane)
    );

    Collision obstacleCollision
    (
        .FrameClk(FrameClk),
        .DrawGame(DrawGame),
        .DrawWinner(DrawWinner),
        .Car1Lane(car1_lane),
        .Car2Lane(car2_lane),
        .Car1Y(car1_relative_y),
        .Car2Y(car2_relative_y),
        .Cone1Y(cone1_y),
        .Cone2Y(cone2_y),
        .Cone3Y(cone3_y),
        .Cone4Y(cone4_y),
        .Cone5Y(cone5_y),
        .Cone6Y(cone6_y),
        .Cone1Exists(cone1_exists),
        .Cone2Exists(cone2_exists),
        .Cone3Exists(cone3_exists),
        .Cone4Exists(cone4_exists),
        .Cone5Exists(cone5_exists),
        .Cone6Exists(cone6_exists),
        .IsCar1_ded(car1_ded),
        .IsCar2_ded(car2_ded)
    );

    DrawTree sunglassTree (
        .PixelClk(PixelClk),
        .FrameClk(FrameClk),
        .DrawGame(DrawGame),
        .Progress(progress), 
        .TreeYInit(10'd200), 
        .DrawX(DrawX),
        .DrawY(DrawY),
        .TreeX(10'd100),
        .WhichTree(2'd0),
        .IsTree(is_tree1),
        .VGA_R(tree1_r),
        .VGA_G(tree1_g),
        .VGA_B(tree1_b),
        .is_transparent(tree1_is_transparent)
    );

    DrawTree weirdTree (
        .PixelClk(PixelClk),
        .FrameClk(FrameClk),
        .DrawGame(DrawGame),
        .Progress(progress), 
        .TreeYInit(10'd50),  
        .DrawX(DrawX),
        .DrawY(DrawY),
        .TreeX(10'd50),
        .WhichTree(2'd1),
        .IsTree(is_tree2),
        .VGA_R(tree2_r),
        .VGA_G(tree2_g),
        .VGA_B(tree2_b),
        .is_transparent(tree2_is_transparent)
    );

    DrawTree lotsaLeavesTree (
        .PixelClk(PixelClk),
        .FrameClk(FrameClk),
        .DrawGame(DrawGame),
        .Progress(progress), 
        .TreeYInit(10'd150),  
        .DrawX(DrawX),
        .DrawY(DrawY),
        .TreeX(10'd500),
        .WhichTree(2'd2),
        .IsTree(is_tree3),
        .VGA_R(tree3_r),
        .VGA_G(tree3_g),
        .VGA_B(tree3_b),
        .is_transparent(tree3_is_transparent)
    );

    always_ff @(posedge FrameClk)
    begin
        if(~DrawGame | transition)
        begin
            car1y_old <= 14'd0;
            car2y_old <= 14'd0;
        end
        else if ((car1_y / 10) > (car1y_old / 10))
            car1y_old <= car1_y;
        else if ((car2_y / 10) > (car2y_old / 10))
            car2y_old <= car2_y;
    end

    always_comb
    begin
        increment_p1 = 1'b0;
        increment_p2 = 1'b0;
        if(DrawGame & ~transition & ((car1_y / 10) > (car1y_old / 10)))
            increment_p1 = 1'b1;
        if(DrawGame & ~transition & ((car2_y / 10) > (car2y_old / 10)))
            increment_p2 = 1'b1;
    end

    assign GameOver = (car1_ded || car2_ded)? (1'b1) : (1'b0);
    assign Winner = (car1_ded == 1'b1)? (1'd1) : (1'd0); 

    // progress represents the position of the bottom of the screen relative to the game world
    always_ff @(posedge FrameClk)
    begin
        if (~DrawGame | transition)
        begin
            progress <= 14'd0;
            speed <= 1'd0;
        end
        else
        begin
            progress <= progress_in; 
            speed <= 1'd1;
        end
    end

    always_ff @(posedge FrameClk)
    begin
        if(~DrawGame)
            count <= 25'd0;
        else
            count <= count_next;
    end

    assign count_next = count + 1'd1;
    assign transition = (count >= 25'd100)? (1'd0) : (1'd1);

    always_comb
    begin
        progress_in = progress;
        if (car1_y > progress + 14'd470)
            progress_in = car2_y + 14'd50; // previously was progress + 14'd470
        else if (car2_y > progress + 14'd470)
            progress_in = car1_y + 14'd50;
    end


    // draw score, sprite or background
    // Output colors to VGA
    assign sprite_red = sprite_rgb[23:16];
    assign sprite_green = sprite_rgb[15:8];
    assign sprite_blue = sprite_rgb[7:0];

    assign background_red = background_rgb[23:16];
    assign background_green = background_rgb[15:8];
    assign background_blue = background_rgb[7:0];

    always_comb
    begin
        if(is_score & ~score_is_transparent)
        begin
            VGA_R = score_red;
            VGA_G = score_green;
            VGA_B = score_blue; 
        end
        else if(is_sprite & ~is_transparent)
        begin
            VGA_R = sprite_red;
            VGA_G = sprite_green;
            VGA_B = sprite_blue;
        end
        else if(is_tree1 & ~tree1_is_transparent)
        begin
            VGA_R = tree1_r;
            VGA_G = tree1_g; 
            VGA_B = tree1_b;
        end
        else if(is_tree2 & ~tree2_is_transparent)
        begin
            VGA_R = tree2_r;
            VGA_G = tree2_g; 
            VGA_B = tree2_b;
        end
        else if(is_tree3 & ~tree3_is_transparent)
        begin
            VGA_R = tree3_r;
            VGA_G = tree3_g; 
            VGA_B = tree3_b;
        end
        else
        begin
            VGA_R = background_red;
            VGA_G = background_green;
            VGA_B = background_blue;
        end
    end

    // read from sprite sheet
    always_ff @(posedge PixelClk)
    begin
        read_address <= read_address_next;
    end

    always_comb
    begin
        is_sprite = 1'b1;
        background_rgb = 24'h000000;
        read_address_next = 16'd0;
        if (is_car1)
            read_address_next = car1_address;
		else if (is_car2)
			read_address_next = car2_address;
        else if (is_obstacle1)
            read_address_next = obstacle1_address;
        else if (is_obstacle2)
            read_address_next = obstacle2_address;
        else if (is_obstacle3)
            read_address_next = obstacle3_address;
        else
            is_sprite = 1'b0;
            // background color handling goes here!
            if((14'd4950 <= progress + 14'd480) && (DrawY >= 14'd479 - (14'd4990 - progress)) && (DrawY < 14'd479 - (14'd5010 - progress)))
                background_rgb = 24'hff5050; // finish line
            else if((DrawX < 155) || (DrawX >= (640 - 155)))
                background_rgb = 24'h33cc33; // lawn
            else if(((DrawX >= 254) && (DrawX <= 269)) || ((DrawX >= 369) && (DrawX <= 384)))
                background_rgb = 24'hfff84b; // dividers
            else 
                background_rgb = 24'h000000; // road 
    end

    // 4-bit sprite sheet encoding to 24-bit rgb
    always_comb
    begin
        is_transparent = 1'b0;
        sprite_rgb = 24'd0;
        case(color)
            4'd0: is_transparent = 1'b1; // black	
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
                is_transparent = 1'b0; 
                sprite_rgb = 24'h000000;
            end
        endcase
    end
    
endmodule
