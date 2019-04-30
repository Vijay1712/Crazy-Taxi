module Move_car
(
    input logic FrameClk, DrawGame, Transition,
    input logic [31:0] Keycode,
    input logic [7:0] Jump, Left, Right, Break,
    input logic [1:0] StartLane, OtherCarLane, // 0-indexed from left
    input logic [13:0] OtherCarY,
    input logic [13:0] CarSpeed,
    output logic [13:0] CarX, CarY,
    output logic [1:0] Lane
);

    logic jump_released, left_released, right_released;
    logic [13:0] carX_next, carY_next;

    always_comb
    begin
        case(CarX)
            14'd205: Lane = 2'd0;
            14'd320: Lane = 2'd1;
            14'd434: Lane = 2'd2;
            default: Lane = -2'd1;
        endcase
    end

    always_ff @(posedge FrameClk)
    begin
        jump_released <= ((Keycode[7:0] == Jump) || (Keycode[15:8] == Jump) || (Keycode[23:16] == Jump) || (Keycode[31:24] == Jump))? (1'b0) : (1'b1);
        left_released <= ((Keycode[7:0] == Left) || (Keycode[15:8] == Left) || (Keycode[23:16] == Left) || (Keycode[31:24] == Left))? (1'b0) : (1'b1);
        right_released <= ((Keycode[7:0] == Right) || (Keycode[15:8] == Right) || (Keycode[23:16] == Right) || (Keycode[31:24] == Right))? (1'b0) : (1'b1);

        if(~DrawGame | Transition) // don't move the cars when not in game
        begin 
            CarY <= 14'd99;
            case (StartLane)
                2'd0: CarX <= 14'd205; 
                2'd1: CarX <= 14'd320; 
                2'd2: CarX <= 14'd434; 
            endcase
        end
        else 
        begin
            CarX <= carX_next;
            CarY <= carY_next;
        end
    end

    always_comb
    begin
        carX_next = CarX;
        carY_next = CarY + CarSpeed;

        if (((Keycode[7:0] == Jump) || (Keycode[15:8] == Jump) || (Keycode[23:16] == Jump) || (Keycode[31:24] == Jump)) && jump_released && ((OtherCarLane != Lane) || (OtherCarY < CarY) || (OtherCarY > CarY + 10'd150)))
            carY_next = CarY + 14'd150; 
        if (((Keycode[7:0] == Left) || (Keycode[15:8] == Left) || (Keycode[23:16] == Left) || (Keycode[31:24] == Left)) && left_released && ((OtherCarLane != Lane - 2'd1) || (OtherCarY < CarY - 10'd100) || (OtherCarY > CarY + 10'd100)))
        begin
            case(CarX)
                14'd205: carX_next = 14'd205;
                14'd320: carX_next = 14'd205;
                14'd434: carX_next = 14'd320;
            endcase
        end
        if (((Keycode[7:0] == Right) || (Keycode[15:8] == Right) || (Keycode[23:16] == Right) || (Keycode[31:24] == Right)) && right_released && ((OtherCarLane != Lane + 2'd1) || (OtherCarY < CarY - 10'd100) || (OtherCarY > CarY + 10'd100)))
        begin
            case(CarX)
                14'd205: carX_next = 14'd320;
                14'd320: carX_next = 14'd434;
                14'd434: carX_next = 14'd434;
            endcase
        end
        if(((Keycode[7:0] == Break) || (Keycode[15:8] == Break) || (Keycode[23:16] == Break) || (Keycode[31:24] == Break)) && ((OtherCarLane != Lane) || (OtherCarY > CarY + 14'd100) || (OtherCarY < CarY - 14'd100)))
            carY_next = CarY;
    end

endmodule
