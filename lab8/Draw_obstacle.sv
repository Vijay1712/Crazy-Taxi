module Draw_obstacle 
(
    input logic DrawGame, PixelClk, FrameClk, Exists_next,
    input logic [13:0] Progress, ObstacleYInit,
    input logic [9:0] ObstacleX, // center of the obstacle, 0-indexed
    input logic [9:0] DrawX, DrawY,
    output logic IsObstacle,
    output logic [15:0] ReadAddress,
    output logic Exists,
    output logic [9:0] obstacleY_relative
);

    logic [13:0] obstacle_y, obstacle_y_next, intermediate;

    always_ff @(posedge FrameClk)
    begin
        if(~DrawGame)
            obstacle_y <= ObstacleYInit;
        else
            obstacle_y <= obstacle_y_next;

        // lock in exists variable for the current y location
        if((~DrawGame) | (obstacle_y < Progress))
            Exists <= Exists_next;
    end


    always_comb
    begin
        intermediate = 14'd479 - (obstacle_y - Progress);
        obstacleY_relative = intermediate[9:0];
        obstacle_y_next = (obstacle_y < Progress)? (obstacle_y + 10'd400) : (obstacle_y);
    end

    always_comb
    begin
        IsObstacle = 1'b0;
        ReadAddress = 16'd27811; // check this on upstairs lab computers!
        // Sprites are 100x100
        if(Exists && (obstacle_y >= Progress) && (obstacle_y < Progress + 14'd480) && (DrawX >= ObstacleX - 10'd49) && (DrawX <= ObstacleX + 10'd50) && (DrawY >= obstacleY_relative - 10'd49) && (DrawY <= obstacleY_relative + 10'd50))
        begin
            IsObstacle = 1'b1;
            ReadAddress = ((DrawY - (obstacleY_relative - 10'd49)) * 10'd600) + (DrawX - (ObstacleX - 10'd49) + 10'd300);
        end
    end

endmodule
