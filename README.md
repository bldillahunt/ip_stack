At the moment, this archive contains building blocks for creating a full IP stack.  Here are some of the modules that have been completed and simulated:
  1. fifo_to_axis.v: Handles the process of getting data from a generic FIFO to an AXI4 Stream interface.
  2. header_capture.v: Grabs the header from any data stream, removes it, and then sends the header and payload downstream.
  3. header_insertion.v: Adds a header to a data stream.
Note: Each of these modules can be configured for any data bus size that is supported by AXI4-Stream. The header_insertion/header_capture modules can be configured for any header size.
