# SystemVerilog-interleaved-sync-FIFO
Description of low-latency and high-capacity synchronous FIFO for FPGA implementation by using SystemVerilog

## Feature
- Interface are designed by VALID-READY handshake
- You can read data at each cycle because of data prefetch and interleaving
- Don't use distributed RAM, but BRAM

## License
MIT
