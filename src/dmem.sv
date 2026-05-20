module dmem (
    input  logic        clk,
    input  logic        we,
    input  logic [31:0] a,        
    input  logic [31:0] wd,

    input  logic [1:0]  btn,
    output logic [1:0]  led,
    
    output logic [31:0] rd
);

// standard RAM storage
logic [31:0] RAM [1023:0];

//led wiring
logic [1:0] led_reg;
assign led = led_reg;

// READ LOGIC (async)
always_comb begin

    if (a == 32'h8000_0004) begin
        // If CPU asks for 0x80000004, ignore the RAM.
        // Pad the 2 physical button wires with 30 zeroes
        rd = {30'd0, btn}; 
    end
    else begin
        // drop 2 bits and look at bottom 10 bits only
        rd = RAM[a[11:2]]; 
    end
end


// WRITE LOGIC (sync)
always_ff @(posedge clk) begin
    // Only write if the Control Unit sets MemWrite to 1
    if (we) begin
            
        if (a == 32'h8000_0000) begin
            // If the CPU tries to save to 0x80000000, ignore the RAM, lock last 2 bits
            led_reg <= wd[1:0]; 
        end 
        // normal RAM write
        else begin
            RAM[a[11:2]] <= wd;
        end
            
    end
end

endmodule