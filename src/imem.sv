module imem (
    input logic [31:0] a,
    output logic [31:0] rd 
);

logic [31:0] RAM [1023:0];

// loads data from memory
initial begin
    $readmemh("program.mem", RAM); 
end

assign rd = RAM[a[31:2]];

endmodule


/*

// THIS IS FOR TESTING ONLY

module imem(
    input  logic [31:0] a,
    output logic [31:0] rd
);
    logic [31:0] RAM [63:0]; // 64 memory slots

    initial begin
    
        // int x5 = 10;
        // int x6 = x5 + 20;
        // memory[x5] = x6;

        RAM[0] = 32'h00a00293; // ADDI x5, x0, 10
        RAM[1] = 32'h01428313; // ADDI x6, x5, 20
        RAM[2] = 32'h0062a023; // SW x6, 0(x5) 
    end

    // Output the instruction (divide address by 4)
    assign rd = RAM[a[31:2]]; 
endmodule

*/