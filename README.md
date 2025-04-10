# Benchmark Results



<details>

<summary>bench/FromIters.bench.mo $({\color{gray}0\%})$</summary>

### Benchmarking the fromIter functions

_Columns describe the number of elements in the input iter._


Instructions: ${\color{gray}0\\%}$
Heap: ${\color{gray}0\\%}$
Stable Memory: ${\color{gray}0\\%}$
Garbage Collection: ${\color{gray}0\\%}$


**Instructions**

|                              |    100 |    10_000 |    100_000 |
| :--------------------------- | -----: | --------: | ---------: |
| Array.fromIter               | 53_373 | 5_152_334 | 51_503_949 |
| List.fromIter                | 35_436 | 3_421_823 | 34_204_824 |
| List.fromIter . Iter.reverse | 56_149 | 5_392_962 | 53_907_349 |


**Heap**

|                              |   100 | 10_000 | 100_000 |
| :--------------------------- | ----: | -----: | ------: |
| Array.fromIter               | 272 B |  272 B |   272 B |
| List.fromIter                | 272 B |  272 B |   272 B |
| List.fromIter . Iter.reverse | 272 B |  272 B |   272 B |


**Garbage Collection**

|                              |      100 |     10_000 |  100_000 |
| :--------------------------- | -------: | ---------: | -------: |
| Array.fromIter               | 2.76 KiB | 234.79 KiB | 2.29 MiB |
| List.fromIter                | 3.51 KiB | 312.88 KiB | 3.05 MiB |
| List.fromIter . Iter.reverse | 5.11 KiB | 469.17 KiB | 4.58 MiB |


</details>
Saving results to .bench/FromIters.bench.json

<details>

<summary>bench/PureListStackSafety.bench.mo $({\color{gray}0\%})$</summary>

### List Stack safety

_Check stack-safety of the following `pure/List`-related functions._


Instructions: ${\color{gray}0\\%}$
Heap: ${\color{gray}0\\%}$
Stable Memory: ${\color{gray}0\\%}$
Garbage Collection: ${\color{gray}0\\%}$


**Instructions**

|                     |             |
| :------------------ | ----------: |
| pure/List.split     |  27_403_700 |
| pure/List.all       |   9_301_156 |
| pure/List.any       |   9_401_585 |
| pure/List.map       |  26_005_117 |
| pure/List.filter    |  24_305_592 |
| pure/List.filterMap |  30_606_216 |
| pure/List.partition |  24_706_539 |
| pure/List.join      |  38_606_854 |
| pure/List.flatten   |  29_607_262 |
| pure/List.take      |  27_407_282 |
| pure/List.drop      |  11_004_661 |
| pure/List.foldRight |  21_806_962 |
| pure/List.merge     |  36_411_001 |
| pure/List.chunks    |  61_513_741 |
| pure/Queue          | 161_571_999 |


**Heap**

|                     |       |
| :------------------ | ----: |
| pure/List.split     | 272 B |
| pure/List.all       | 272 B |
| pure/List.any       | 272 B |
| pure/List.map       | 272 B |
| pure/List.filter    | 272 B |
| pure/List.filterMap | 272 B |
| pure/List.partition | 272 B |
| pure/List.join      | 272 B |
| pure/List.flatten   | 272 B |
| pure/List.take      | 272 B |
| pure/List.drop      | 272 B |
| pure/List.foldRight | 272 B |
| pure/List.merge     | 272 B |
| pure/List.chunks    | 272 B |
| pure/Queue          | 272 B |


**Garbage Collection**

|                     |           |
| :------------------ | --------: |
| pure/List.split     |  3.05 MiB |
| pure/List.all       |     328 B |
| pure/List.any       |     328 B |
| pure/List.map       |  3.05 MiB |
| pure/List.filter    |  3.05 MiB |
| pure/List.filterMap |  3.05 MiB |
| pure/List.partition |  3.05 MiB |
| pure/List.join      |  3.05 MiB |
| pure/List.flatten   |  3.05 MiB |
| pure/List.take      |  3.05 MiB |
| pure/List.drop      |     328 B |
| pure/List.foldRight |  1.53 MiB |
| pure/List.merge     |  4.58 MiB |
| pure/List.chunks    |  7.63 MiB |
| pure/Queue          | 18.31 MiB |


</details>
Saving results to .bench/PureListStackSafety.bench.json
