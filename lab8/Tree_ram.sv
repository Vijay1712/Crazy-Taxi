/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module treeRAM
(
		input logic [3:0] data_In,
		input logic [12:0] write_address, read_address, // covers 8192 mem locations
		input logic we, Clk,

		output logic [3:0] data_Out
);

logic [3:0] mem [8000]; 

initial
begin
	 $readmemh("sprite_bytes/trees-cleaned.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
