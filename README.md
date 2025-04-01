# Benchmark Results


Benchmark files:
• bench/FromIters.bench.mo

			
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
