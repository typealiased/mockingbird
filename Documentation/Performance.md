# Performance

Last revised on September 12, 2019 for version `0.5.0`.

## Methodology

- [hyperfine](https://github.com/sharkdp/hyperfine) is used for generator speed benchmarking.
- [loc](https://github.com/cgag/loc) is used for file complexity benchmarking.

The generator is run against 1,000 source files each containing 3 protocols with multiple levels of inheritance and 
up to 15 members. See [MetagenerateCommand.swift](/MockingbirdCli/Interface/MetagenerateCommand.swift) 
for the benchmarking source template.

```bash
$ mockingbird metagenerate --output ./MockingbirdTestsHost/Generated --count 1000
```

All results are from a MacBook Pro (15-inch, 2018), 2.9 GHz Intel Core i9, 32 GB 2400 MHz DDR4.

## Generator Speed

Since Mockingbird typically runs as part of the build process, it’s imperative that mocks generate quickly. 
Mockingbird’s performance baseline is 1 ms per generated mock.

Aside from leveraging best practices such as concurrency and caching, Mockingbird achieves reasonably good 
performance by eschewing [Sourcery](https://github.com/krzysztofzablocki/Sourcery) and 
[Stencil](https://github.com/stencilproject/Stencil). Although the frameworks provide a robust solution to parsing 
and templating Swift sources, a more tailored approach allows for greater optimization.

```bash
$ hyperfine --warmup 10 'mockingbird generate --project ./Mockingbird.xcodeproj --target MockingbirdTestsHost --output MockingbirdMocks.generated.swift'
```

| Mean (s) | Min (s) | Max (s) |
| --- | --- | --- |
| 1.543 ± 0.096 | 1.434 | 1.736 |

This comes out to 0.51 ms per generated mock, which also includes the overhead in parsing the Xcode project file.

## File Complexity

It’s also important to consider the complexity of generated code which can negatively affect compile times for test 
targets. Although not perfect, lines of code acts as a reasonable proxy for measuring file complexity. Mockingbird’s 
baseline is 200 lines of code per generated mock.

```bash
$ loc MockingbirdMocks.generated.swift 
```

| Lines | Blank | Comment | Code |
| --- | --- | --- | --- |
| 697,829 | 110,340 | 35,791 | 551,698 |

This comes out to 184 lines of code per generated mock.

## Comparisons

For the sake of completeness, benchmarks for other Swift mocking frameworks with similar feature goals as 
Mockingbird will be included here.

### Cuckoo

```bash
$ hyperfine --warmup 10 'cuckoo generate --testable "MockingbirdTestsHost" --output CuckooMocks.generated.swift ./MockingbirdTestsHost/*.swift'
```

| Mean (s) | Min (s) | Max (s) |
| --- | --- | --- |
| 53.697 ± 0.341 | 53.142 | 54.122 |

17.9 ms per generated mock; Mockingbird is 35x faster.

```bash
$ loc CuckooMocks.generated.swift
```

| Lines | Blank | Comment | Code |
| --- | --- | --- | --- |
| 1,186,999 | 423,999 | 1,000 | 762,000 |

254 lines of code per generated mock; Mockingbird is 28% smaller.
