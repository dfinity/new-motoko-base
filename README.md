# Benchmark Results



<details>

<summary>bench/ArrayBuilding.bench.mo $({\color{gray}0\%})$</summary>

### Large known-size array building

_Compares performance of different data structures for building arrays of known size._


Instructions: ${\color{gray}0\\%}$
Heap: ${\color{gray}0\\%}$
Stable Memory: ${\color{gray}0\\%}$
Garbage Collection: ${\color{gray}0\\%}$


**Instructions**

|                  |    1000 |     100000 |     1000000 |
| :--------------- | ------: | ---------: | ----------: |
| List             | 612_011 | 53_730_969 | 531_478_624 |
| Buffer           | 367_424 | 36_403_920 | 364_004_168 |
| pure/List        | 318_496 | 31_604_567 | 316_062_532 |
| VarArray ?T      | 201_911 | 19_903_407 | 199_003_655 |
| VarArray T       | 178_245 | 17_503_741 | 175_003_989 |
| Array (baseline) |  44_088 |  4_103_584 |  41_003_832 |


**Heap**

|                  |  1000 | 100000 | 1000000 |
| :--------------- | ----: | -----: | ------: |
| List             | 272 B |  272 B |   272 B |
| Buffer           | 272 B |  272 B |   272 B |
| pure/List        | 272 B |  272 B |   272 B |
| VarArray ?T      | 272 B |  272 B |   272 B |
| VarArray T       | 272 B |  272 B |   272 B |
| Array (baseline) | 272 B |  272 B |   272 B |


**Garbage Collection**

|                  |      1000 |     100000 |   1000000 |
| :--------------- | --------: | ---------: | --------: |
| List             | 10.05 KiB | 797.56 KiB |  7.67 MiB |
| Buffer           |  8.71 KiB | 782.15 KiB |  7.63 MiB |
| pure/List        | 19.95 KiB |   1.91 MiB | 19.07 MiB |
| VarArray ?T      |  8.24 KiB | 781.68 KiB |  7.63 MiB |
| VarArray T       |  8.23 KiB | 781.67 KiB |  7.63 MiB |
| Array (baseline) |   4.3 KiB | 391.02 KiB |  3.82 MiB |


</details>
Saving results to .bench/ArrayBuilding.bench.json

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

<summary>bench/ListBufferNewArray.bench.mo $({\color{gray}0\%})$</summary>

### List vs. Buffer for creating known-size arrays

_Performance comparison between List and Buffer for creating a new array._


Instructions: ${\color{gray}0\\%}$
Heap: ${\color{gray}0\\%}$
Stable Memory: ${\color{gray}0\\%}$
Garbage Collection: ${\color{gray}0\\%}$


**Instructions**

|           | 0 (baseline) |     1 |      5 |     10 | 100 (for loop) |
| :-------- | -----------: | ----: | -----: | -----: | -------------: |
| List      |        1_753 | 3_319 | 10_314 | 15_845 |         82_859 |
| pure/List |        1_450 | 1_564 |  2_738 |  4_205 |         33_746 |
| Buffer    |        2_378 | 2_539 |  3_905 |  5_612 |         39_474 |


**Heap**

|           | 0 (baseline) |     1 |     5 |    10 | 100 (for loop) |
| :-------- | -----------: | ----: | ----: | ----: | -------------: |
| List      |        272 B | 272 B | 272 B | 272 B |          272 B |
| pure/List |        272 B | 272 B | 272 B | 272 B |          272 B |
| Buffer    |        272 B | 272 B | 272 B | 272 B |          272 B |


**Garbage Collection**

|           | 0 (baseline) |     1 |     5 |    10 | 100 (for loop) |
| :-------- | -----------: | ----: | ----: | ----: | -------------: |
| List      |        576 B | 616 B | 776 B | 884 B |       1.93 KiB |
| pure/List |        360 B | 380 B | 460 B | 560 B |        2.3 KiB |
| Buffer    |        856 B | 864 B | 896 B | 936 B |       1.62 KiB |


</details>
Saving results to .bench/ListBufferNewArray.bench.json

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

<details>

<summary>bench/Queues.bench.mo $({\color{gray}0\%})$</summary>

### Different queue implementations

_Compare the performance of the following queue implementations_:
- `pure/Queue`: The default immutable double-ended queue implementation.
  * Pros: Good amortized performance, meaning that the average cost of operations is low `O(1)`.
  * Cons: In worst case, an operation can take `O(size)` time rebuilding the queue as demonstrated in the `Pop front 2 elements` scenario.
- `pure/RealTimeQueue`
  * Pros: Every operation is guaranteed to take at most `O(1)` time and space.
  * Cons: Poor amortized performance: Instruction cost is on average 3x for *pop* and 8x for *push* compared to `pure/Queue`.
- mutable `Queue`
  * Pros: Also `O(1)` guarantees with a lower constant factor than `pure/RealTimeQueue`. Amortized performance is comparable to `pure/Queue`.
  * Cons: It is mutable and cannot be used in `shared` types (not shareable)_._


Instructions: ${\color{gray}0\\%}$
Heap: ${\color{gray}0\\%}$
Stable Memory: ${\color{gray}0\\%}$
Garbage Collection: ${\color{gray}0\\%}$


**Instructions**

|                            | pure/Queue | pure/RealTimeQueue | mutable Queue |
| :------------------------- | ---------: | -----------------: | ------------: |
| Initialize with 2 elements |      3_571 |              2_592 |         3_401 |
| Push 500 elements          |    103_492 |            867_120 |       243_585 |
| Pop front 2 elements       |     98_792 |              5_009 |         4_326 |
| Pop 150 front&back         |    106_545 |            350_417 |       140_211 |


**Heap**

|                            | pure/Queue | pure/RealTimeQueue | mutable Queue |
| :------------------------- | ---------: | -----------------: | ------------: |
| Initialize with 2 elements |      324 B |              300 B |         352 B |
| Push 500 elements          |   8.08 KiB |           8.17 KiB |      19.8 KiB |
| Pop front 2 elements       |      240 B |              240 B |         192 B |
| Pop 150 front&back         |  -4.42 KiB |             -492 B |    -11.45 KiB |


**Garbage Collection**

|                            | pure/Queue | pure/RealTimeQueue | mutable Queue |
| :------------------------- | ---------: | -----------------: | ------------: |
| Initialize with 2 elements |      508 B |              444 B |         456 B |
| Push 500 elements          |   10.1 KiB |         137.84 KiB |         344 B |
| Pop front 2 elements       |  12.19 KiB |              528 B |         424 B |
| Pop 150 front&back         |  15.61 KiB |          49.66 KiB |      12.1 KiB |


</details>
Saving results to .bench/Queues.bench.json
