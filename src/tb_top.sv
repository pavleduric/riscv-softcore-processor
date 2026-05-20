//-------------------------------
// TESTBENCH
//-------------------------------

module tb_top();

    // Declare wires
    logic clk;
    logic reset;
    logic [1:0] btn;
    logic [1:0] led;

    // Instantiate the CPU (DUT)
    top dut (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .led(led)
    );

    // Create the Clock (100 MHz)
    always begin
        #5 clk = ~clk; 
    end

    // Simulation sequence
    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top);

        // Start at 0
        clk = 0;
        btn = 2'b00;  // no buttons
        
        // press reset
        reset = 1;    
        #10;
        
        // release reset
        reset = 0;    
        
        // let run for 500ns
        #500;
        $display("Simulation Complete.");
        $finish;
    end

endmodule