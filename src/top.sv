module top (
    input  logic       clk,
    input  logic       reset, // Physical reset
    input  logic [1:0] btn, // Physical Cmod A7 buttons
    output logic [1:0] led  // Physical Cmod A7 LEDs
);

    // Declare wires
    logic [31:0] pc_current;
    logic [31:0] instr;
    logic [31:0] result_wd;

    // Control Wires
    logic RegWrite, ALUSrc, MemWrite, MemRead, Branch, ResultSrc;
    logic [3:0]  ALUControl;
    logic [31:0] ImmExt;

    // Datapath Wires
    logic [31:0] rd1, rd2;   // Out of RegFile
    logic [31:0] alu_result; // Out of ALU
    logic zero;              // Out of ALU
    logic [31:0] read_data;  // Out of Data Memory


    // MUXs and gates

    // MUX 1: 
    // 1 -> pass ImmExt; 0 -> pass rd2
    logic [31:0] alu_input_b;
    assign alu_input_b = ALUSrc ? ImmExt : rd2;

    // MUX 2: 
    // 1 -> pass RAM Data; 0 -> pass ALU result
    assign result_wd = ResultSrc ? read_data : alu_result;

    // Logic for jumping
    logic branch_enable;
    assign branch_enable = Branch & zero;

    // Calculate where to jump to
    logic [31:0] target_address;
    assign target_address = pc_current + ImmExt;


    // Instantate Modules
    
    // The Program Counter
    pc my_pc (
        .clk(clk),
        .reset(reset),
        .branch_en(branch_enable),
        .target_addr(target_address),
        .pc_out(pc_current)
    );

    // The Instruction Memory
    imem my_imem (
        .a(pc_current),
        .rd(instr)
    );

    // The Control Unit
    cu my_cu (
        .instr(instr),
        .RegWrite(RegWrite),
        .ALUSrc(ALUSrc),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .Branch(Branch),
        .ResultSrc(ResultSrc),
        .ALUControl(ALUControl),
        .ImmExt(ImmExt)
    );

    // The Register File
    regfile my_reg (
        .clk(clk),
        .we(RegWrite),
        .rs1(instr[19:15]),
        .rs2(instr[24:20]),
        .rd(instr[11:7]),
        .wd(result_wd),
        .rd1(rd1),
        .rd2(rd2)
    );

    // The ALU
    alu my_alu (
        .a(rd1),
        .b(alu_input_b),
        .alu_ctrl(ALUControl),
        .result(alu_result),
        .zero(zero)
    );

    // The Data Memory
    dmem my_dmem (
        .clk(clk),
        .we(MemWrite),
        .a(alu_result),
        .wd(rd2),
        .btn(btn), // physical button
        .led(led), // physical LEDs
        .rd(read_data)
    );

endmodule