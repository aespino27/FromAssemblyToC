# Environment

## Baseline

The lab targets the existing Ubuntu x86-64 virtual machine under Hyper-V,
hosted on Windows 11. Visual Studio Code is the preferred editor. No custom
kernel, bootloader, or graphical environment is required.

## Required tools

- NASM assembler
- GNU binutils, particularly `ld`, `as` only if a lesson explicitly needs it,
  and inspection tools such as `objdump`/`readelf`
- Bash and standard Ubuntu command-line utilities
- Git
- Visual Studio Code with a suitable Ubuntu connection workflow

QEMU is optional and will only be installed if a specific stage benefits from
machine emulation.

## Installation

Do not install anything solely on the basis of this preliminary document.
The first environment lesson will provide a version-checked setup script and
verification commands after the initial source tree and tool requirements have
been tested together.

## Platform assumptions

- Linux x86-64 userspace.
- ELF64 executable format.
- System V AMD64 calling convention when calling procedures across ABI
  boundaries.
- Direct Linux system calls where appropriate; syscall numbers and register
  conventions will be documented per lesson.

