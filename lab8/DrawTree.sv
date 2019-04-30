module DrawTree 
(
    input logic FrameClk, PixelClk, DrawGame,
    input logic [13:0] Progress, TreeYInit, // center of the car for x, top of car for y, 0-indexed
    input logic [9:0] DrawX, DrawY,
    input logic [9:0] TreeX,
    input logic [1:0] WhichTree,
    output logic IsTree,
    output logic [7:0] VGA_R, VGA_G, VGA_B,
    output logic is_transparent
);

    logic [3:0] color;
    logic [23:0] rgb;
    logic [12:0] read_address, read_address_next;
    logic [9:0] treeY_relative;

    logic [13:0] intermediate, tree_y, tree_y_next;

    always_ff @(posedge FrameClk)
    begin
        if(~DrawGame)
            tree_y <= TreeYInit;
        else
            tree_y <= tree_y_next;
    end

    always_comb
    begin
        intermediate = 14'd479 - (tree_y - Progress);
        treeY_relative = intermediate[9:0];
        tree_y_next = (tree_y < Progress)? (tree_y + 10'd400) : (tree_y);
    end

    // tree ram
    treeRAM trees
    (
        .data_In(4'd0),
		.write_address(13'd0),
        .read_address(read_address), 
		.we(1'b0),
        .Clk(PixelClk),
        .data_Out(color)
    );

    // read from tree ram
    always_ff @(posedge PixelClk)
    begin
        read_address <= read_address_next;
    end

    // draw logic
    always_comb
    begin
        IsTree = 1'b0;
        read_address_next = 12'd0;
        if((tree_y >= Progress) && (tree_y < Progress + 14'd480) && (DrawX >= TreeX) && (DrawX < TreeX + 10'd50) && (DrawY >= treeY_relative) && (DrawY < treeY_relative + 10'd50))
        begin
            IsTree = 1'b1;
            case(WhichTree)
                2'h0: read_address_next = ((DrawY - treeY_relative) * 10'd160) + (DrawX - TreeX);
                2'h1: read_address_next = ((DrawY - treeY_relative) * 10'd160) + (DrawX - TreeX + 10'd50);
                2'h2: read_address_next = ((DrawY - treeY_relative) * 10'd160) + (DrawX - TreeX + 10'd100);
            endcase
        end
    end

    // color logic
    assign VGA_R = rgb[23:16];
    assign VGA_G = rgb[15:8];
    assign VGA_B = rgb[7:0];

    always_comb
    begin
        rgb = 24'h000000;
        is_transparent = 1'b0;
        case (color)
            4'h0: rgb = 24'h000000;
            4'h1: rgb = 24'h00f000;
            4'h2: rgb = 24'h662429;
            4'h3: rgb = 24'h605cf4;
            4'h4: rgb = 24'h8c98f8;
            4'h5: rgb = 24'hc8f3f7;
            4'h6: is_transparent = 1'b1;
        endcase
    end

endmodule