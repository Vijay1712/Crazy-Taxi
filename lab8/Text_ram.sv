/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module textRAM
(
		input logic data_In,
		input logic [17:0] write_address, read_address, // covers 262144 mem locations
		input logic we, Clk,

		output logic data_Out
);

logic mem [150000]; 

initial
begin
	 $readmemb("sprite_bytes/text-cleaned.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
