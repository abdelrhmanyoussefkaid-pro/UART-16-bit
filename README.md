# 16-bit UART Design & Verification --- Verilog

## 📌 Project Overview

This project implements a **16-bit UART communication system** using
**Verilog HDL**.

The design is built from separate RTL modules for baud-rate generation,
transmission, reception, and RX synchronization. A dedicated testbench
is used to verify the complete UART communication through a **loopback
connection**, where the transmitted data is directly connected to the
receiver input.

The project focuses on understanding and implementing the complete UART
TX/RX data path using a synchronous digital design approach.

------------------------------------------------------------------------

## ✨ Features

-   16-bit UART data transmission
-   16-bit UART data reception
-   9600 Baud Rate
-   50 MHz System Clock
-   Separate TX and RX modules
-   Baud-rate generator
-   2-Flip-Flop synchronizer for RX input
-   FSM-based TX and RX control
-   LSB-first data transmission
-   Start and Stop bit handling
-   Loopback verification
-   QuestaSim / ModelSim compatible simulation
-   Self-checking testbench

------------------------------------------------------------------------

## 🏗️ System Architecture

``` text
                    ┌────────────────────┐
                    │  Baud Generator    │
                    │                    │
                    │ 50 MHz → 9600 Baud │
                    └─────────┬──────────┘
                              │
                         baud_tick
                              │
             ┌────────────────┴────────────────┐
             │                                 │
             ▼                                 ▼
      ┌─────────────┐                   ┌─────────────┐
      │     TX      │                   │     RX      │
      │             │                   │             │
      │ 16-bit Data │                   │ 16-bit Data │
      └──────┬──────┘                   └──────▲──────┘
             │                                 │
             │ tx                              │ rx_sync
             │                                 │
             └─────────── Loopback ────────────┘
                              │
                       ┌──────▼──────┐
                       │Synchronizer │
                       │   2-FF      │
                       └─────────────┘
```

------------------------------------------------------------------------

## 📂 Project Files

  -----------------------------------------------------------------------
  File                   Description
  ---------------------- ------------------------------------------------
  `baud_generation.v`    Generates the UART baud tick from the 50 MHz
                         system clock

  `synchronizer.v`       2-Flip-Flop synchronizer for the asynchronous RX
                         input

  `tx.v`                 UART transmitter

  `rx.v`                 UART receiver

  `top.v`                Top-level module connecting all UART blocks

  `tb.v`                 Testbench for functional verification

  `run.do`               QuestaSim/ModelSim simulation script
  -----------------------------------------------------------------------

------------------------------------------------------------------------

## ⚙️ Design Specifications

### Clock

``` text
System Clock = 50 MHz
Clock Period = 20 ns
```

### UART Configuration

``` text
Data Width = 16 bits
Baud Rate  = 9600
Start Bit  = 1 bit
Data Bits  = 16 bits
Stop Bit   = 1 bit
Parity     = None
```

The UART frame is therefore:

``` text
Idle | Start |       16-bit Data       | Stop
  1  |   0   | D0 D1 D2 ... D14 D15   |  1
```

The data is transmitted **LSB first**.

------------------------------------------------------------------------

## 🔢 Baud Rate Generation

The baud generator uses the following relationship:

``` text
Divisor = Clock Frequency / Baud Rate
```

For this project:

``` text
Divisor = 50,000,000 / 9,600
        ≈ 5208
```

Therefore, a `baud_tick` is generated approximately every:

``` text
5208 clock cycles
```

This produces a baud rate close to:

``` text
9600 baud
```

------------------------------------------------------------------------

## 🚀 Transmitter (TX)

The transmitter uses a finite state machine with four states:

``` text
IDLE
START
DATA
STOP
```

### TX State Flow

``` text
             tx_start
IDLE ─────────────────────► START
 ▲                           │
 │                           │ baud_tick
 │                           ▼
 │                          DATA
 │                           │
 │                           │ bit_counter = 15
 │                           │ + baud_tick
 │                           ▼
 └────────────────────────── STOP
                 baud_tick
```

### TX Operation

1.  TX remains HIGH during `IDLE`.
2.  When `tx_start` is asserted, the input data is stored.
3.  TX sends a LOW start bit.
4.  The 16 data bits are transmitted sequentially.
5.  Data is transmitted LSB first.
6.  A HIGH stop bit is transmitted.
7.  TX returns to `IDLE`.

------------------------------------------------------------------------

## 📥 Receiver (RX)

The receiver also uses a four-state FSM:

``` text
IDLE
START
DATA
STOP
```

### RX Operation

1.  RX waits for the line to go LOW.
2.  The LOW level indicates the start bit.
3.  The receiver waits for the baud timing.
4.  The 16 data bits are sampled sequentially.
5.  Received bits are stored in `rx_data_reg`.
6.  After the final data bit, the receiver enters the STOP state.
7.  The received data is transferred to `rx_data`.
8.  `rx_done` is asserted to indicate that reception is complete.

------------------------------------------------------------------------

## 🔄 RX Synchronizer

The external RX signal passes through a **2-Flip-Flop synchronizer**
before entering the RX module.

``` text
External RX
    │
    ▼
┌─────────┐
│  FF1    │
└────┬────┘
     │
     ▼
┌─────────┐
│  FF2    │
└────┬────┘
     │
     ▼
  rx_sync
     │
     ▼
    RX
```

The synchronizer reduces the risk of metastability when the RX input is
not aligned with the system clock.

Since UART lines are normally **HIGH when idle**, the synchronizer is
initialized to HIGH during reset.

------------------------------------------------------------------------

## 🧪 Verification

The design is verified using a Verilog testbench.

A loopback connection is used:

``` verilog
assign rx = tx;
```

This means that any data transmitted by the TX module is automatically
received by the RX module.

### Verification Flow

``` text
tx_data
   │
   ▼
  TX
   │
   ▼
  tx
   │
   │ Loopback
   ▼
Synchronizer
   │
   ▼
  RX
   │
   ├──────────► rx_data
   │
   └──────────► rx_done
```

The testbench checks that:

``` text
Received Data == Transmitted Data
```

For example:

``` text
Transmitted Data = 1234
Received Data    = 1234
```

If the received data matches the transmitted data, the testbench
reports:

``` text
Test Success
```

------------------------------------------------------------------------

## 🖥️ Simulation

The project was developed and simulated using:

-   **Verilog HDL**
-   **QuestaSim / ModelSim**
-   **50 MHz simulation clock**

### Run Simulation

Open QuestaSim/ModelSim and execute:

``` tcl
vlib work
vlog baud_generation.v synchronizer.v tx.v rx.v top.v tb.v
vsim -voptargs=+acc work.tb
add wave *
run -all
```

Or simply run the provided:

``` text
run.do
```

script.

------------------------------------------------------------------------

## 📊 Expected Simulation

The waveform should contain the following important signals:

``` text
clk
rst
tx_start
tx_data
baud_tick
tx
rx
rx_sync
rx_data
rx_done
```

During transmission:

``` text
TX = 1  → Idle
TX = 0  → Start Bit
TX = Data Bits
TX = 1  → Stop Bit
```

At the end of reception:

``` text
rx_data = transmitted data
rx_done = 1 pulse
```

------------------------------------------------------------------------

## 🧩 Top-Level Interface

The top module contains:

``` text
Inputs:
    clk
    rst
    tx_start
    rx
    tx_data[15:0]

Outputs:
    tx
    rx_data[15:0]
    rx_done
```

### Top-Level Block

``` text
                    ┌─────────────────────────┐
                    │          TOP            │
                    │                         │
tx_data[15:0] ─────►│ TX                      │─────► tx
tx_start ──────────►│                         │
                    │                         │
rx ─────────────────► Synchronizer ──► RX     │
                    │                         │─────► rx_data[15:0]
                    │                         │─────► rx_done
                    │                         │
clk ───────────────►│ Baud Generator          │
rst ───────────────►│                         │
                    └─────────────────────────┘
```

------------------------------------------------------------------------

## 📚 Concepts Demonstrated

This project demonstrates practical implementation of:

-   UART communication
-   RTL design
-   Finite State Machines (FSM)
-   Sequential and combinational logic
-   Baud-rate generation
-   Clock-cycle based timing
-   Serial-to-parallel data reception
-   Parallel-to-serial data transmission
-   Bit counters
-   Data registers
-   Asynchronous input synchronization
-   RTL simulation
-   Functional verification
-   Loopback testing

------------------------------------------------------------------------

## 🔮 Possible Future Improvements

The design can be extended with:

-   Configurable baud rate
-   Configurable data width
-   Parity bit support
-   Multiple stop-bit configurations
-   TX busy signal
-   RX error detection
-   Framing error detection
-   Overrun detection
-   More advanced UART timing with center-bit sampling
-   Randomized verification
-   SystemVerilog/UVM verification environment

------------------------------------------------------------------------

## 👨‍💻 Author

**Abdelrhman Youssef**

Electronics and Communication Engineering Student\
Interested in Digital Design & Functional Verification

------------------------------------------------------------------------

## 📜 License

This project is intended for educational and portfolio purposes.
