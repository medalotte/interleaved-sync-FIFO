# SystemVerilog-interleaved-sync-FIFO
Description of high-throughput and high-capacity synchronous FIFO for FPGA implementation by using SystemVerilog

## Feature
- Interface are designed by VALID-READY handshake
- You can read data at each cycle because of data prefetch and interleaving
- Latency is 6 cycle
- Don't use distributed RAM, but BRAM
- **Only use single port BRAM**
    - In general, FIFO use dual port BRAM

## License
MIT
