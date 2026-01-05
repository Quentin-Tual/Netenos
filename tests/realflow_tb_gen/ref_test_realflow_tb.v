`timescale 1ns/1ps

module activity_logger #(parameter string LOGFILE = "activity.log")(input logic reset_n);
    integer fh;

    initial begin
        fh = $fopen(LOGFILE, "w");
        if (!fh)
          $fatal("Cannot open %s", LOGFILE);
    end

    task log(string name, bit value, int cycle);
      string dir;

      if (!reset_n)
        return;
      if (cycle == 0) 
        return;
      
      dir = value ? "RISE" : "FALL";
      $fwrite(fh,
          "cycle=%0d  time=%0t  signal=%s  edge=%s\n",
            cycle,     $realtime,   name,       dir
      );
    endtask
endmodule

module activity_dumper #(parameter string NAME = "")(
    input logic sig,
    input integer cycle
);
  always @(posedge sig or negedge sig)
    tb_f51m.logger.log(NAME, sig, cycle);
endmodule

module outputs_xor #(
  parameter integer OUTPUT_WIDTH = 8
) (
  input [OUTPUT_WIDTH-1:0] o1,
  input [OUTPUT_WIDTH-1:0] o2,
  output [OUTPUT_WIDTH-1:0] o1_xor_o2
);
  assign o1_xor_o2 = o1 ^ o2;
endmodule

module tb_f51m;
  // Define parameters
  parameter INPUT_WIDTH = 8;
  parameter OUTPUT_WIDTH = 8;
  parameter FILENAME = "tests/realflow_tb_gen/test.txt";
  parameter CLK_PERIOD = 5;
  parameter STIM_CYCLES = 266;
  parameter TOTAL_CYCLES = 274; // Safety limit

  // Declare inputs and outputs
  reg [INPUT_WIDTH-1:0] i;
  reg clk;
  reg reset_n;
  string line_buffer;
  integer file_handle;
  integer line_count = 0;
  integer scan_result;

  // Clock generation - MUST be outside initial block
  initial clk = 0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // DUT wires
  wire [OUTPUT_WIDTH-1:0] tb_mapped_o;
  wire [OUTPUT_WIDTH-1:0] tb_pnr_o;
  wire [OUTPUT_WIDTH-1:0] tb_apnr_o;
  wire [OUTPUT_WIDTH-1:0] tb_pnrxapnr_o;

  outputs_xor #(.OUTPUT_WIDTH(OUTPUT_WIDTH)) diff_activity (
    .o1(tb_pnr_o),
    .o2(tb_apnr_o),
    .o1_xor_o2(tb_pnrxapnr_o)
  );

  // DUT port map
  mapped_f51m mapped_dut (.i0(i[7]), .i1(i[6]), .i2(i[5]), .i3(i[4]), .i4(i[3]), .i5(i[2]), .i6(i[1]), .i7(i[0]), .o0(tb_mapped_o[0]), .o1(tb_mapped_o[1]), .o2(tb_mapped_o[2]), .o3(tb_mapped_o[3]), .o4(tb_mapped_o[4]), .o5(tb_mapped_o[5]), .o6(tb_mapped_o[6]), .o7(tb_mapped_o[7]));

  pnr_f51m pnr_dut (.i0(i[7]), .i1(i[6]), .i2(i[5]), .i3(i[4]), .i4(i[3]), .i5(i[2]), .i6(i[1]), .i7(i[0]), .o0(tb_pnr_o[0]), .o1(tb_pnr_o[1]), .o2(tb_pnr_o[2]), .o3(tb_pnr_o[3]), .o4(tb_pnr_o[4]), .o5(tb_pnr_o[5]), .o6(tb_pnr_o[6]), .o7(tb_pnr_o[7]));

  a_pnr_f51m a_pnr_dut (.i0(i[7]), .i1(i[6]), .i2(i[5]), .i3(i[4]), .i4(i[3]), .i5(i[2]), .i6(i[1]), .i7(i[0]), .o0(tb_apnr_o[0]), .o1(tb_apnr_o[1]), .o2(tb_apnr_o[2]), .o3(tb_apnr_o[3]), .o4(tb_apnr_o[4]), .o5(tb_apnr_o[5]), .o6(tb_apnr_o[6]), .o7(tb_apnr_o[7]));

  // Instantiate the single global logger
  activity_logger logger(.reset_n(reset_n));

  // Instantiate dumpers
  activity_dumper #(.NAME("tb_pnrxapnr_o0")) dump_o0(.sig(tb_pnrxapnr_o[0]), .cycle(line_count));
  activity_dumper #(.NAME("tb_pnrxapnr_o1")) dump_o1(.sig(tb_pnrxapnr_o[1]), .cycle(line_count));
  activity_dumper #(.NAME("tb_pnrxapnr_o2")) dump_o2(.sig(tb_pnrxapnr_o[2]), .cycle(line_count));
  activity_dumper #(.NAME("tb_pnrxapnr_o3")) dump_o3(.sig(tb_pnrxapnr_o[3]), .cycle(line_count));
  activity_dumper #(.NAME("tb_pnrxapnr_o4")) dump_o4(.sig(tb_pnrxapnr_o[4]), .cycle(line_count));
  activity_dumper #(.NAME("tb_pnrxapnr_o5")) dump_o5(.sig(tb_pnrxapnr_o[5]), .cycle(line_count));
  activity_dumper #(.NAME("tb_pnrxapnr_o6")) dump_o6(.sig(tb_pnrxapnr_o[6]), .cycle(line_count));
  activity_dumper #(.NAME("tb_pnrxapnr_o7")) dump_o7(.sig(tb_pnrxapnr_o[7]), .cycle(line_count));

  // Main test sequence
  initial begin
    // Create a dump file
    $dumpfile("tb_f51m.vcd");
    //$dumpvars(0, tb_f51m);  // Dump all levels
    $dumpvars(1, clk);
    $dumpvars(1, i);
    $dumpvars(1, tb_pnrxapnr_o);
    $dumpvars(1, line_count);

    // Initialize signals
    clk = 1;
    reset_n = 0;
    i = 'b00000000;

    $display("Starting simulation at time %0t", $time);

    // Apply reset
    #(CLK_PERIOD*2) reset_n = 1;
    $display("Reset released at time %0t", $time);

    // Open the input file
    file_handle = $fopen(FILENAME, "r");
    if (file_handle == 0) begin
        $display("Error: Could not open file %s", FILENAME);
        $finish;
    end

    $display("Reading from file: %s", FILENAME);

    // Wait for first clock edge after reset
    @(posedge clk);

    // Read stimuli
    for (line_count = 0; line_count < STIM_CYCLES; line_count = line_count + 1) begin
      // Read on positive clock edge
      @(posedge clk);

      // Read lines until we get valid data
      while (1) begin
        // Read a line as string first
        scan_result = $fgets(line_buffer, file_handle);

        if (scan_result == 0) begin
          $display("End of file reached");
          $fclose(file_handle);
          $finish;
        end

        // Check if first character is '#'
        // Simple check - assumes no leading whitespace
        if (line_buffer[0] == "#") begin
          // It's a comment - display and skip
          $display("Skipping comment: %s", line_buffer);
          continue;  // Skip to next line
        end

        // Try to parse as binary
        scan_result = $sscanf(line_buffer, "%b", i);

        if (scan_result == 1) begin
          // Success!
          break;
        end else begin
          // Could be empty line or malformed
          if (line_buffer[0] != "\n" && line_buffer[0] != "\r" && line_buffer[0] != 0) begin
            $display("Warning: Failed to parse line: %s", line_buffer);
          end
          continue;
        end
      end

      $display("Time %0t: Cycle %0d - Applied i = %b (0x%h)", $time, line_count, i, i);
    end

    // Close file
    $fclose(file_handle);

    $display("Finished processing %0d lines", line_count);

    // Wait a few more cycles to observe final outputs
    repeat (4) @(posedge clk);

    $display("Simulation completed at time %0t", $time);
    $finish;
  end

endmodule
