module Collision 
(
    input logic FrameClk, DrawGame, DrawWinner,
    input logic [1:0] Car1Lane, Car2Lane,
    input logic [9:0] Car1Y, Car2Y,
    input logic [9:0] Cone1Y, Cone2Y, Cone3Y, Cone4Y, Cone5Y, Cone6Y,
    input logic Cone1Exists, Cone2Exists, Cone3Exists, Cone4Exists, Cone5Exists, Cone6Exists,
    output logic IsCar1_ded, IsCar2_ded
);

    logic IsCar1_ded_next, IsCar2_ded_next;
    logic [9:0] top_car1, bottom_car1, top_car2, bottom_car2;
    logic [9:0] top_cone1, bottom_cone1, top_cone2, bottom_cone2, top_cone3, bottom_cone3, top_cone4, bottom_cone4, top_cone5, bottom_cone5, top_cone6, bottom_cone6;

    always_ff @(posedge FrameClk)
    begin
        if(~DrawGame & ~DrawWinner)
        begin
            IsCar1_ded <= 1'b0;
            IsCar2_ded <= 1'b0;
        end
        else if (DrawGame)
        begin
            IsCar1_ded <= IsCar1_ded_next;
            IsCar2_ded <= IsCar2_ded_next;
        end
    end

    always_comb
    begin
        top_car1 = Car1Y + 10'd11;
        bottom_car1 = Car1Y + 10'd85;

        top_car2 = Car2Y + 10'd11;
        bottom_car2 = Car2Y + 10'd85;

        top_cone1 = Cone1Y - 10'd23;
        bottom_cone1 = Cone1Y - 10'd5;

        top_cone2 = Cone2Y - 10'd23;
        bottom_cone2 = Cone2Y - 10'd5;

        top_cone3 = Cone3Y - 10'd23;
        bottom_cone3 = Cone3Y - 10'd5;      
    end

    // check if car 1 has collided with cones
    always_comb
    begin
        IsCar1_ded_next = 1'b0;
        case(Car1Lane)
            2'd0:
            begin                  
                if(Cone1Exists)
                begin
                    if((top_car1 < top_cone1) && (bottom_car1 > bottom_cone1)) // cone in middle
                        IsCar1_ded_next = 1'b1;
                    else if((top_car1 > top_cone1) && (top_car1 < bottom_cone1)) // top car in cone
                        IsCar1_ded_next = 1'b1;
                    else if((bottom_car1 > top_cone1) && (bottom_car1 < bottom_cone1)) // 
                        IsCar1_ded_next = 1'b1;
                end
            end
            2'd1:
             begin                  
                if(Cone2Exists)
                begin
                    if((top_car1 < top_cone2) && (bottom_car1 > bottom_cone2)) // cone in middle
                        IsCar1_ded_next = 1'b1;
                    else if((top_car1 > top_cone2) && (top_car1 < bottom_cone2)) // top car in cone
                        IsCar1_ded_next = 1'b1;
                    else if((bottom_car1 > top_cone2) && (bottom_car1 < bottom_cone2)) // 
                        IsCar1_ded_next = 1'b1;
                end
            end

            2'd2:
             begin                  
                if(Cone3Exists)
                begin
                    if((top_car1 < top_cone3) && (bottom_car1 > bottom_cone3)) // cone in middle
                        IsCar1_ded_next = 1'b1;
                    else if((top_car1 > top_cone3) && (top_car1 < bottom_cone3)) // top car in cone
                        IsCar1_ded_next = 1'b1;
                    else if((bottom_car1 > top_cone3) && (bottom_car1 < bottom_cone3)) // 
                        IsCar1_ded_next = 1'b1;
                end
            end
        endcase
    end

    // check if car 2 has collided with cones
    always_comb
    begin
        IsCar2_ded_next = 1'b0;
        case(Car2Lane)
            2'd0:
            begin                  
                if(Cone1Exists)
                begin
                    if((top_car2 < top_cone1) && (bottom_car2 > bottom_cone1)) // cone in middle
                        IsCar2_ded_next = 1'b1;
                    else if((top_car2 > top_cone1) && (top_car2 < bottom_cone1)) // top car in cone
                        IsCar2_ded_next = 1'b1;
                    else if((bottom_car2 > top_cone1) && (bottom_car2 < bottom_cone1)) // 
                        IsCar2_ded_next = 1'b1;
                end
            end
            2'd1:
             begin                  
                if(Cone2Exists)
                begin
                    if((top_car2 < top_cone2) && (bottom_car2 > bottom_cone2)) // cone in middle
                        IsCar2_ded_next = 1'b1;
                    else if((top_car2 > top_cone2) && (top_car2 < bottom_cone2)) // top car in cone
                        IsCar2_ded_next = 1'b1;
                    else if((bottom_car2 > top_cone2) && (bottom_car2 < bottom_cone2)) // 
                        IsCar2_ded_next = 1'b1;
                end
            end

            2'd2:
             begin                  
                if(Cone3Exists)
                begin
                    if((top_car2 < top_cone3) && (bottom_car2 > bottom_cone3)) // cone in middle
                        IsCar2_ded_next = 1'b1;
                    else if((top_car2 > top_cone3) && (top_car2 < bottom_cone3)) // top car in cone
                        IsCar2_ded_next = 1'b1;
                    else if((bottom_car2 > top_cone3) && (bottom_car2 < bottom_cone3)) // 
                        IsCar2_ded_next = 1'b1;
                end
            end
        endcase
    end
endmodule