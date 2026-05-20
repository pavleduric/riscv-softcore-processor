module regfile (
    input logic clk, // clock
    input logic we, // write enable
  	input logic [4:0] rs1, // read address 1
  	input logic [4:0] rs2, // read address 2
    input  logic [4:0]  rd, // destination adress 
    input  logic [31:0] wd, // write data
    output logic [31:0] rd1, // output 1
    output logic [31:0] rd2 // output 2
    
);

logic [31:0] registers [31:0];

assign rd1 = (rs1 == 5'b00000) ? 32'd0 : registers[rs1]; // collect data at rs1
assign rd2 = (rs2 == 5'b00000) ? 32'd0 : registers[rs2]; // collect data at rs2

always_ff @(posedge clk) begin
    if (we && rd != 5'b00000) begin
        registers[rd] <= wd;
    end
end

endmodule