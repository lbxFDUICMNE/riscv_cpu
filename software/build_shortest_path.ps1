param([string]$ToolBin = $env:RISCV_TOOL_BIN)
$ErrorActionPreference = 'Stop'
if (-not $ToolBin) {
    $ToolBin = 'D:\riscv_tools\xpack-riscv-none-elf-gcc-15.2.0-1-win32-x64\xpack-riscv-none-elf-gcc-15.2.0-1\bin'
}
$gcc = Join-Path $ToolBin 'riscv-none-elf-gcc.exe'
$objcopy = Join-Path $ToolBin 'riscv-none-elf-objcopy.exe'
$objdump = Join-Path $ToolBin 'riscv-none-elf-objdump.exe'
$stem = Join-Path $PSScriptRoot 'shortest_path'
$image = Join-Path $PSScriptRoot 'shortest_path_riscvtest.txt'
& $gcc -march=rv32im -mabi=ilp32 -O1 -ffreestanding -fno-builtin -fno-pic -fno-pie -fno-delete-null-pointer-checks -fno-tree-loop-distribute-patterns -fno-asynchronous-unwind-tables -fno-unwind-tables -msmall-data-limit=0 -nostdlib '-Wl,--entry=_start' '-Wl,-Ttext=0' '-Wl,--build-id=none' -o "$stem.elf" (Join-Path $PSScriptRoot 'startup.S') "$stem.c"
if ($LASTEXITCODE -ne 0) { throw 'GCC failed' }
& $objcopy -O binary "$stem.elf" "$stem.bin"
if ($LASTEXITCODE -ne 0) { throw 'objcopy failed' }
$disassembly = (& $objdump -d "$stem.elf") -join [Environment]::NewLine
if ($LASTEXITCODE -ne 0) { throw 'objdump failed' }
[System.IO.File]::WriteAllText("$stem.dis", $disassembly)
if ($disassembly -match '(?m)^\s*[0-9a-f]+:\s+[0-9a-f]+\s+(div|divu|rem|remu)\b') {
    throw 'Unsupported DIV/REM in generated code'
}
$bytes = [System.IO.File]::ReadAllBytes("$stem.bin")
if ($bytes.Length -gt 4096 -or $bytes.Length % 4 -ne 0) { throw 'Image size/alignment invalid' }
$lines = for ($i = 0; $i -lt $bytes.Length; $i += 4) {
    $word = [uint32]0
    for ($j = 0; $j -lt 4; $j++) {
        $word = $word -bor ([uint32]$bytes[$i + $j] -shl (8 * $j))
    }
    $word.ToString('x8')
}
[System.IO.File]::WriteAllLines($image, [string[]]$lines)
Write-Host "Generated $($lines.Count) words ($($bytes.Length) bytes): $image"
