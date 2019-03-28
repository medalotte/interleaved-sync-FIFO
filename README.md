# SystemVerilog-interleaved-sync-FIFO
Description of synchronous FIFO that consist of Single Port RAM for FPGA implementation by using SystemVerilog

## Feature
- **It is not practical because this module was created experimentally**
- **Only use Single Port RAM**
    - In general, FIFO use Dual Port RAM
    - Description of synchronous FIFO consist of Dual Port RAM is [here](https://github.com/kyk0910/SystemVerilog-sync-FIFO)
- Interface are designed by VALID-READY handshake
- You can read data at each cycle because of data prefetch and interleaving even though only use Single Port RAM
- Latency is 6 cycle
- Don't use distributed RAM, but BRAM

## License
MIT
