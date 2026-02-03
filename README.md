# elfcheck

Check the information of ELF file and return result.

Always be used in bash or others scriptlang.

## Begining

Requires: [zig](https://ziglang.org)

### Download source and compile

Download: `git clone https://github.com/topshihun/elfcheck.git`

Compile:
- `cd elfcheck`
- `zig build`

### Run

Can use '-h' to print help information.
```sh
elfcheck -h
```

## Exmples

Check if the `elf/file` is 64 bit and X86_64 machine.
```sh
elfcheck is_x64=true machine=X86_64 elf/file
```

Check if the `elf/file` is little endian and RISCV machine.
```sh
elfcheck endian=little machine=RISCV elf/file
```

If it is checked true, `elfcheck` will return 0, if not, `elfcheck` will return 1.

`elfcheck` return 2 means incorrect usage.
