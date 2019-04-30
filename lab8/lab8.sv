


//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [31:0] keycode;
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	logic [9:0] draw_x, draw_y;

    // control logic related
    logic game_over, start_game, draw_game, draw_winner, end_game;
    logic start_transition, transition_done, show_results_done;
    logic [7:0] start_r, start_g, start_b, draw_r, draw_g, draw_b; 
    logic [7:0] winner_r, winner_g, winner_b, end_r, end_g, end_b;

    // part of the game state itself
    logic [9:0] progress;
    logic winner;

    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst
    (
        .Clk(Clk),
        .Reset(Reset_h),
        // signals connected to NIOS II
        .from_sw_address(hpi_addr),
        .from_sw_data_in(hpi_data_in),
        .from_sw_data_out(hpi_data_out),
        .from_sw_r(hpi_r),
        .from_sw_w(hpi_w),
        .from_sw_cs(hpi_cs),
        .from_sw_reset(hpi_reset),
        // signals connected to EZ-OTG chip
        .OTG_DATA(OTG_DATA),    
        .OTG_ADDR(OTG_ADDR),    
        .OTG_RD_N(OTG_RD_N),    
        .OTG_WR_N(OTG_WR_N),    
        .OTG_CS_N(OTG_CS_N),
        .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
    lab7_soc nios_system
    (
       .clk_clk(Clk),         
       .reset_reset_n(1'b1),           // Never reset NIOS
       .sdram_wire_addr(DRAM_ADDR), 
       .sdram_wire_ba(DRAM_BA),   
       .sdram_wire_cas_n(DRAM_CAS_N),
       .sdram_wire_cke(DRAM_CKE),  
       .sdram_wire_cs_n(DRAM_CS_N), 
       .sdram_wire_dq(DRAM_DQ),   
       .sdram_wire_dqm(DRAM_DQM),  
       .sdram_wire_ras_n(DRAM_RAS_N),
       .sdram_wire_we_n(DRAM_WE_N), 
       .sdram_clk_clk(DRAM_CLK),
       .keycode_export(keycode),  
       .otg_hpi_address_export(hpi_addr),
       .otg_hpi_data_in_port(hpi_data_in),
       .otg_hpi_data_out_port(hpi_data_out),
       .otg_hpi_cs_export(hpi_cs),
       .otg_hpi_r_export(hpi_r),
       .otg_hpi_w_export(hpi_w),
       .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance
    (
        .Clk(Clk),
	    .Reset(Reset_h),    
		.VGA_HS(VGA_HS),            // Horizontal sync pulse.  Active low
        .VGA_VS(VGA_VS),            // Vertical sync pulse.  Active low
        .VGA_CLK(VGA_CLK),          // 25 MHz VGA clock input
        .VGA_BLANK_N(VGA_BLANK_N),  // Blanking interval indicator.  Active low.
        .VGA_SYNC_N(VGA_SYNC_N),    // Composite Sync signal.  Active low. 
        .DrawX(draw_x),             // horizontal coordinate
        .DrawY(draw_y)  
    );
    
    Display_control game_control
    (
        .Clk(Clk), 
        .FrameClk(VGA_VS),
        .Reset_h(Reset_h), 
        .GameOver(game_over), 
        .StartTransitionDone(transition_done),
        .Keycode(keycode), 
        .StartGame(start_game), 
        .StartTransition(start_transition),
        .DrawGame(draw_game), 
        .DrawWinner(draw_winner),
        .EndGame(end_game)
    );

    // display control mux
    always_comb
    begin
        if(start_game)
        begin
            VGA_R = start_r;
            VGA_G = start_g;
            VGA_B = start_b;
        end
        else if(draw_game)
        begin
            VGA_R = draw_r;
            VGA_G = draw_g;
            VGA_B = draw_b;
        end
        else if(draw_winner)
        begin
            VGA_R = winner_r;
            VGA_G = winner_g;
            VGA_B = winner_b;
        end
        else if(end_game)
        begin
            VGA_R = end_r;
            VGA_G = end_g;
            VGA_B = end_b;
        end
        else
        begin
            VGA_R = 8'd0;
            VGA_G = 8'd0;
            VGA_B = 8'd0;
        end
    end

    Draw_start start_screen 
    (
        .FrameClk(VGA_VS), 
        .PixelClk(VGA_CLK), 
        .StartGame(start_game), 
        .DrawX(draw_x), 
        .DrawY(draw_y),
        .StartTransition(start_transition),
        .VGA_R(start_r), 
        .VGA_G(start_g), 
        .VGA_B(start_b),
        .TransitionDone(transition_done)
    );

    Draw_game crazy_taxi
    (
        .FrameClk(VGA_VS), 
        .PixelClk(VGA_CLK), 
        .Reset_h(Reset_h), 
        .DrawGame(draw_game),
        .DrawWinner(draw_winner),
        .DrawX(draw_x), 
        .DrawY(draw_y), 
        .Keycode(keycode), 
        .VGA_R(draw_r), 
        .VGA_G(draw_g), 
        .VGA_B(draw_b),
        .GameOver(game_over),
        .Winner(winner)
    );

    Draw_winner winner_screen
    (
        .FrameClk(VGA_VS),
        .PixelClk(VGA_CLK), 
        .DrawWinner(draw_winner),
        .DrawX(draw_x),
        .DrawY(draw_y),
        .Winner(winner), // 0 for P1 WINS, 1 for P2 WINS
        .VGA_R(winner_r),
        .VGA_G(winner_g),
        .VGA_B(winner_b)
    );
    
    Draw_end end_screen 
    (
        .FrameClk(VGA_VS), 
        .PixelClk(VGA_CLK), 
        .Reset_h(Reset_h), 
        .DrawX(draw_x), 
        .DrawY(draw_y), 
        .VGA_R(end_r), 
        .VGA_G(end_g), 
        .VGA_B(end_b)
    );

    // Display keycode on hex display
    HexDriver hex_inst_0 (keycode[11:8], HEX0);
    HexDriver hex_inst_1 (keycode[15:12], HEX1);

endmodule
