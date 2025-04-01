# Benchmark Results


Benchmark files:
• bench/FromIters.bench.mo
• bench/PureListStackSafety.bench.mo

			
## Benchmarking the fromIter functions
			
_Columns describe the number of elements in the input iter._
			

Instructions

|                              |    100 |    10_000 |    100_000 |
| :--------------------------- | -----: | --------: | ---------: |
| Array.fromIter               | 53_380 | 5_152_341 | 51_503_956 |
| List.fromIter                | 35_442 | 3_421_829 | 34_204_830 |
| List.fromIter . Iter.reverse | 56_156 | 5_392_969 | 53_907_356 |
			

Heap

|                              |   100 | 10_000 | 100_000 |
| :--------------------------- | ----: | -----: | ------: |
| Array.fromIter               | 272 B |  272 B |   272 B |
| List.fromIter                | 272 B |  272 B |   272 B |
| List.fromIter . Iter.reverse | 272 B |  272 B |   272 B |
			

Garbage Collection

|                              |      100 |     10_000 |  100_000 |
| :--------------------------- | -------: | ---------: | -------: |
| Array.fromIter               | 2.76 KiB | 234.79 KiB | 2.29 MiB |
| List.fromIter                | 3.51 KiB | 312.88 KiB | 3.05 MiB |
| List.fromIter . Iter.reverse | 5.11 KiB | 469.17 KiB | 4.58 MiB |
			
		
Saving results to .bench/FromIters.bench.json

			
## List Stack safety
			
_Check stack-safety of the following `pure/List`-related functions._
			

Instructions

|                     |             |
| :------------------ | ----------: |
| pure/List.split     |  27_403_702 |
| pure/List.all       |   9_301_158 |
| pure/List.any       |   9_401_587 |
| pure/List.map       |  26_005_119 |
| pure/List.filter    |  24_305_594 |
| pure/List.filterMap |  30_606_218 |
| pure/List.partition |  24_706_541 |
| pure/List.join      |  38_606_857 |
| pure/List.flatten   |  29_607_264 |
| pure/List.take      |  27_407_284 |
| pure/List.drop      |  11_004_663 |
| pure/List.foldRight |  21_806_964 |
| pure/List.merge     |  36_411_003 |
| pure/List.chunks    |  61_513_743 |
| pure/Queue          | 177_572_226 |
			

Heap

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
			

Garbage Collection

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
			
		
Saving results to .bench/PureListStackSafety.bench.json
