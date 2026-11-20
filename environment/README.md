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

## Verification and installation

Run the repository check from its root:

    bash environment/verify.sh

It checks the architecture and availability of Bash, Git, NASM, and GNU ld.
On Ubuntu, install the required packages with:

    sudo apt update
    sudo apt install nasm binutils git

Then rerun the verification script. The script does not modify the system or install packages automatically.

## Platform assumptions

- Linux x86-64 userspace.
- ELF64 executable format.
- System V AMD64 calling convention when calling procedures across ABI
  boundaries.
- Direct Linux system calls where appropriate; syscall numbers and register
  conventions will be documented per lesson.

