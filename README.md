Built with

```
nim -d:release --gcc.options.speed="-Ofast -flto-fno-strict-aliasing -ffast-math" --gcc.options.linker="-flto" --objChecks="off" --fieldChecks="off" --rangeChecks="off" --boundChecks="off" --overflowChecks="off" --floatChecks="off" --nanChecks="off" --infChecks="off" --nilChecks="off" c wordchains_tidy.nim
```
