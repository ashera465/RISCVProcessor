// memory.sv
//This is a memory block used to store some instructions for the RISC-V ISA.
module memory #(
    //Define 64 WORDS Default
    parameter WORDS = 64
) (

    //We need a clock.
    //If write enabled we write the data at the specified address input, otherwise, we read the data from the address and output.
    //Reset is active low, all mem set to 0
    input logic clk,
    input logic [31:0] address,
    input logic [31:0] write_data,
    input logic write_enable,
    input logic rst_n,

    output logic [31:0] read_data
);

/*
* This memory is byte addressed
* But have no support for mis-aligned write nor reads.
*/

reg [31:0] mem [0:WORDS-1];  // Memory array of words (32-bits)

always @(posedge clk) begin
    // reset logic
    // If reset is 0, then system is in reset state
    // Note that [x]'b[y] will set refer the first x bits in the sequence to the value y.
    if (rst_n == 1'b0) begin
        for (int i = 0; i < WORDS; i++) begin
            //All words in memory set to 0
            mem[i] <= 32'b0;  
        end
    end
    //If the above case is not run, then reset is high and memory can be written
    else if (write_enable) begin
        // Ensure the address is aligned to a word boundary.
        //This is checked with the first 2 bits of the address 
        if (address[1:0] == 2'b00) begin 
            //here, address[31:2] is the word index
            //Reason is that you should remember that the memory is byte addressed, but we are writing a word (4 bytes) at a time.
            //Hence we don't care about 2 LSB bits of the address
            mem[address[31:2]] <= write_data;
        end
    end
end

// Read logic. This happens asynchronously.
//The reason is that RISCV needs this for the Program Counter
always_comb begin
    //here, address[31:2] is the word index
    read_data = mem[address[31:2]]; 
end

endmodule