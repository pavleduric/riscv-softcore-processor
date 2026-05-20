module cu (
    input logic [31:0] instr,
    output logic        RegWrite,     // 1 = Write to Register File
    output logic        ALUSrc,       // 0 = rs2 goes to ALU, 1 = ImmExt goes to ALU
    output logic        MemWrite,     // 1 = Write to Data Memory
    output logic        MemRead,      // 1 = Read from Data Memory
    output logic        Branch,       // 1 = This is a branch instruction
    output logic        ResultSrc,    // 0 = ALU result to RegFile, 1 = Mem data to RegFile
    output logic [3:0]  ALUControl,   // Tells the ALU which operation to perform
    output logic [31:0] ImmExt        // The sign-extended immediate value
);

    // PART 1
    // Break the 32-bit instruction into readable chunks
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign opcode = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];


    // PART 2
    // Extract immediate bits based on opcode and sign-extend to 32 bits
    always_comb begin
        case (opcode)

            // I-Type
            7'b0010011, 7'b0000011: 
                ImmExt = {{20{instr[31]}}, instr[31:20]};
            
            // S-Type
            7'b0100011: 
                ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            
            // B-Type
            7'b1100011: 
                ImmExt = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            
            // Default (R-Type)
            default: 
                ImmExt = 32'd0;
        endcase
    end


    // PART 3
    always_comb begin

        // Set safe defaults to prevent glitches
        RegWrite = 1'b0;
        ALUSrc = 1'b0;
        MemWrite = 1'b0;
        MemRead = 1'b0;
        Branch = 1'b0;
        ResultSrc = 1'b0;
        ALUControl = 4'b0000; // Default ALU to ADD

        case (opcode)

            // R-TYPE (ADD, SUB, AND, OR, ...)
            7'b0110011: begin

                RegWrite = 1'b1; // Writing an answer back
                ALUSrc   = 1'b0; // ALU takes rs2
                
                // Determine which math
                case (funct3)
                    3'b000: ALUControl = (funct7 == 7'b0100000) ? 4'b1000 : 4'b0000; // SUB or ADD
                    3'b111: ALUControl = 4'b0111; // AND
                    3'b110: ALUControl = 4'b0110; // OR
                    3'b100: ALUControl = 4'b0100; // XOR
                    default: ALUControl = 4'b0000;
                endcase
            end

            // I-TYPE ALU (ADDI, ANDI, ....)
            7'b0010011: begin
                RegWrite = 1'b1; // Writing an answer back
                ALUSrc   = 1'b1; // ALU takes the Immediate
                
                // Determine math
                case (funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b111: ALUControl = 4'b0111; // ANDI
                    3'b110: ALUControl = 4'b0110; // ORI
                    3'b100: ALUControl = 4'b0100; // XORI
                    default: ALUControl = 4'b0000;
                endcase
            end

            // LOAD
            7'b0000011: begin
                RegWrite  = 1'b1; // Saving to register
                ALUSrc    = 1'b1; // ALU use immediate
                MemRead   = 1'b1; // Turn on Data Memory read
                ResultSrc = 1'b1; // Send Data Memory output to RegFile
                ALUControl = 4'b0000; // ALU must ADD base address + offset
            end

            // STORE
            7'b0100011: begin
                MemWrite      = 1'b1; // Turn on Data Memory write
                ALUSrc        = 1'b1; // ALU takes Immediate
                ALUControl = 4'b0000; // ALU must ADD base
            end

            // BRANCH
            7'b1100011: begin
                Branch        = 1'b1; // Signal PC logic that a jump might happen
                ALUSrc        = 1'b0; // ALU compares rs2 & rs1
                ALUControl = 4'b1000; // ALU checks rs1 - rs2 == 0
            end

            default: begin
                // If an unknown opcode is fetched, everything stays disabled
            end
        endcase
    end


endmodule