module Draw_car1
(
    input logic PixelClk,
    input logic [13:0] Progress, CarY, // center of the car for x, top of car for y, 0-indexed
    input logic [9:0] DrawX, DrawY,
    input logic [9:0] CarX,
    output logic IsCar,
    output logic [15:0] ReadAddress,
    output logic[9:0] carY_relative
);

    logic [13:0] intermediate;

    assign intermediate = 14'd479 - (CarY - Progress);
    assign carY_relative = intermediate[9:0];

    always_comb
    begin
        IsCar = 1'b0;
        ReadAddress = 16'd27811; // check this on upstairs lab computers!
        // Sprites are 100x100
        if((CarY >= Progress) && (CarY < Progress + 10'd480) && (DrawX >= CarX - 10'd49) && (DrawX <= CarX + 10'd50) && (DrawY >= carY_relative) && (DrawY <= carY_relative + 10'd100))
        begin
            IsCar = 1'b1;
            ReadAddress = ((DrawY - carY_relative) * 10'd600) + (DrawX - (CarX - 10'd49));
        end
    end

endmodule

module Draw_car2
(
    input logic PixelClk,
    input logic [13:0] Progress, CarY, // center of the car for x, top of car for y, 0-indexed
    input logic [9:0] DrawX, DrawY,
    input logic [9:0] CarX,
    output logic IsCar,
    output logic [15:0] ReadAddress,
    output logic[9:0] carY_relative
);

    logic [13:0] intermediate;

    assign intermediate = 14'd479 - (CarY - Progress);
    assign carY_relative = intermediate[9:0];

    always_comb
    begin
        IsCar = 1'b0;
        ReadAddress = 16'd27811; // check this on upstairs lab computers!
        // Sprites are 100x100
        if((CarY >= Progress) && (CarY < Progress + 14'd480) && (DrawX >= CarX - 10'd49) && (DrawX <= CarX + 10'd50) && (DrawY >= carY_relative) && (DrawY <= carY_relative + 10'd100))
        begin
            IsCar = 1'b1;
            ReadAddress = ((DrawY - carY_relative) * 10'd600) + (DrawX - (CarX - 10'd49) + 10'd100);
        end
    end

endmodule