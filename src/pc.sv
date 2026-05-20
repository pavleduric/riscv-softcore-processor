module pc (
    input logic clk,
    input logic reset,
    input logic branch_en, // if jumping (1) or not (0)
    input logic [31:0] target_addr,
  output logic [31:0] pc_out
);

logic [31:0] next_pc;

assign next_pc = branch_en ? target_addr : (pc_out + 32'd4);

// get next address at clk
always_ff @(posedge clk or posedge reset) begin
  	if (reset) begin
        pc_out <= 32'd0;
    end
    else begin
        pc_out <= next_pc;
    end
end

endmodule