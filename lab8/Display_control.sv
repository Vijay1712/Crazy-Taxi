module Display_control
(
    input logic Clk, FrameClk, Reset_h, GameOver, StartTransitionDone,
    input logic [31:0] Keycode,
    output logic StartGame, StartTransition, DrawGame, DrawWinner, EndGame
);

    enum logic [2:0] {START, START_TRANSITION, IN_GAME, RESULTS, END} curr_state, next_state;
    logic enter_released; // 1 is released, 0 is pressed
    logic [9:0] show_results_count, count_next;

    always_ff @(posedge Clk)
    begin
        curr_state <= (Reset_h)? START : next_state;
        enter_released <= (Keycode[7:0] == 8'h28)? (1'b0) : (1'b1);
    end

    // counter for results state auto transition to end state
    always_ff @(posedge FrameClk)
    begin
        if(~DrawWinner)
            show_results_count <= 10'd0;
        else
            show_results_count <= count_next;
    end
    assign count_next = show_results_count + 1'd1;

    // next state logic
    always_comb
    begin
        next_state = curr_state;
        case (curr_state)
            // press enter to start
            START: next_state = ((Keycode[7:0] == 8'h28) && enter_released)? START_TRANSITION: curr_state;
            START_TRANSITION: next_state = (StartTransitionDone)? IN_GAME : curr_state;
            // press ` to end game or end game if a player crashes into obstacle
            IN_GAME:
            begin
                next_state = curr_state;
                if(Keycode[7:0] == 8'h35)
                    next_state = END;
                else if(GameOver)
                    next_state = RESULTS;
            end
            RESULTS: next_state = (show_results_count == 10'd300)? END : curr_state;
            // press enter to play again
            END: next_state = (Keycode[7:0] == 8'h28)? START : curr_state;
        endcase
    end

    // output logic
    always_comb
    begin
        StartGame = 1'b0;
        StartTransition = 1'b0;
        DrawGame = 1'b0;
        DrawWinner = 1'b0;
        EndGame = 1'b0;
        case (curr_state)
            START: StartGame = 1'b1;
            START_TRANSITION: 
                begin
                    StartGame = 1'b1;
                    StartTransition = 1'b1;
                end
            IN_GAME: DrawGame = 1'b1;
            RESULTS: DrawWinner = 1'b1;
            END: EndGame = 1'b1;
        endcase
    end

endmodule