`timescale 1ns/1ps

module <%=tb_entity_name%>;
  // Define parameters
  parameter INPUT_WIDTH = <%=nb_inputs%>;
  parameter OUTPUT_WIDTH = <%=nb_outputs%>;
  parameter FILENAME = "<%=stim_file%>";
  parameter CLK_PERIOD = <%=clk_period%>;
  parameter STIM_CYCLES = <%=stim_cycles%>;
  parameter TOTAL_CYCLES = <%=total_cycles%>; // Safety limit

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
  wire [OUTPUT_WIDTH-1:0] tb_o;

  // DUT port map
  <%dut_portmap = @nl_data[:inputs].collect do |ip|
      i=ip[1..].to_i
      ri = nb_inputs - 1 - i # reversed word
      ".#{ip}(i[#{ri}])"
    end
    dut_portmap += @nl_data[:outputs].collect do |op|
      i=op[1..]
      ".#{op}(tb_o[#{i}])"
    end
  %><%=@nl_data[:entity_name]%> mapped_dut (<%=dut_portmap.join(', ')%>);

  // Main test sequence
  initial begin
    // Create a dump file
    $dumpfile("tb_<%=circ_name%>.vcd");
    <%=full_traces ? "" : "//" %>$dumpvars(0, tb_<%=circ_name%>);  // Dump all levels
    $dumpvars(1, clk);
    $dumpvars(1, i);
    $dumpvars(1, tb_o);
    $dumpvars(1, line_count);

    // Initialize signals
    clk = 1;
    reset_n = 0;
    i = 'b<%="0"*@nl_data[:outputs].length%>;

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
