module Game_data
(
    input logic Clk, Reset_h, Read_h, Write_h, Chip_select_h,
    input logic [2:0] Address, // 2^3 addresses
    input logic [31:0] Write_data,
    output logic [31:0] Read_data,
    output logic [31:0] Export_data
);
    /* Register file organization
     * 0 - Game state
     * 1 - Player 1 score
     * 2 - Player 2 score
     * 3 - 
     * 4 - 
     * 5 - 
     * 6 -
     * 7 -
    */

    logic [31:0] registers [8]; // 8 32-bit registers
    logic [31:0] data_in;
    logic [2:0] address_next; 

    always_ff @(posedge Clk)
    begin
        if(Reset_h)
        begin
            for(int i = 0; i < 8; i++)
                registers[i] <= 32'd0;
        end
        registers[Address] <= (Chip_select_h & Write_h)? Write_data : registers[Address];
    end

    assign Read_data = (Chip_select_h & Read_h)? registers[Address] : 32'd0; 
    assign Export_data = registers[0];

endmodule