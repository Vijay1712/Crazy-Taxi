module Points 
(
    input logic FrameClk, DrawGame,
    input logic Increment_p1, Increment_p2,
    output logic [11:0] P1_points_hex, P2_points_hex
);

    logic [11:0] p1_score, p2_score, p1_next, p2_next;

    assign P1_points_hex = p1_score;
    assign P2_points_hex = p2_score;

    always_ff @(posedge FrameClk)
    begin
        if(~DrawGame)
        begin
            p1_score <= 12'h000;
            p2_score <= 12'h000;
        end
        else 
        begin
            if(Increment_p1)
                p1_score <= p1_next;
            if(Increment_p2)
                p2_score <= p2_next;
        end
    end

    always_comb
    begin
        p1_next = p1_score;
        if(p1_score[3:0] == 4'h9)
        begin
            if(p1_score[7:4] == 4'h9)
            begin
                p1_next = {(p1_score[11:8] + 4'd1), 8'd0};
            end
            else
                p1_next = {p1_score[11:8], (p1_score[7:4] + 4'd1), (4'd0)};
        end
        else
            p1_next = {p1_score[11:8], p1_score[7:4], (p1_score[3:0] + 4'd1)};
    end

    always_comb
    begin
        p2_next = p2_score;
        if(p2_score[3:0] == 4'h9)
        begin
            if(p2_score[7:4] == 4'h9)
            begin
                p2_next = {(p2_score[11:8] + 4'd1), 8'd0};
            end
            else
                p2_next = {p2_score[11:8], (p2_score[7:4] + 4'd1), (4'd0)};
        end
        else
            p2_next = {p2_score[11:8], p2_score[7:4], (p2_score[3:0] + 4'd1)};
    end
endmodule
