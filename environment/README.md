# Environment

## Learner VM baseline

The primary learner environment, as reported on 2026-11-20:

- Ubuntu 26.04.1 LTS
- x86-64
- NASM 3.01
- GNU binutils / GNU ld 2.46
- GCC 15.2.0
- GDB 17.1

The lab targets this existing Ubuntu x86-64 virtual machine under Hyper-V,
hosted on Windows 11. Visual Studio Code is the preferred editor. No custom
kernel, bootloader, or graphical environment is required.

Git is also required. Bash and standard Ubuntu command-line utilities are
assumed.

## Required tools

- NASM assembler
- GNU binutils, particularly `ld`, and inspection tools such as
  `objdump` and `readelf`
- Bash, Git, and standard Ubuntu command-line utilities

## Optional tools

- **GCC:** installed in the learner VM, but not part of the lab implementation
  or build path. The language interpreters, compilers, and runtime components
  developed in this project remain NASM implementations. GCC may be used only
  for explicitly documented comparison or ABI experiments if a later lab
  calls for it.
- **GDB:** installed and useful for optional inspection of registers,
  instruction flow, memory, and stack state. The core labs will provide
  deterministic commands and expected results without requiring interactive
  debugging.
- **QEMU:** not currently required; it will only be introduced if a later
  lesson has a specific need for machine emulation.

## Verification and installation

Run the repository check from its root:

    bash environment/verify.sh

The script checks the architecture and required tools, reports the versions
of NASM and GNU ld, and reports GCC/GDB versions when those optional tools
are present. It does not modify the system or install packages automatically.

On Ubuntu, install the required packages with:

    sudo apt update
    sudo apt install nasm binutils git

Optional tools can be installed separately if needed:

    sudo apt install gcc gdb

## Platform assumptions

- Linux x86-64 userspace.
- ELF64 executable format.
- System V AMD64 calling convention when calling procedures across ABI
  boundaries.
- Direct Linux system calls where appropriate; syscall numbers and register
  conventions will be documented per lesson.

## Compatibility policy

The learner's Ubuntu 26.04.1 / NASM 3.01 environment is the primary practical
compatibility target. GitHub Actions currently provides an independent
Ubuntu 24.04 / NASM 2.16.01 compatibility check. Lab source should avoid
unnecessary assembler-version-specific features and should pass both
environments where their toolchains support the same documented behavior.
