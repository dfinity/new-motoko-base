# Benchmark Results


Benchmark files:
• bench/FromIters.bench.mo

			
## Benchmarking the fromIter functions
			
_Columns describe the number of elements in the input iter._
			

Instructions

|                |    100 |    10_000 |    100_000 |
| :------------- | -----: | --------: | ---------: |
| Array.fromIter | 53_243 | 5_152_204 | 51_503_819 |
| List.fromIter  | 39_313 | 3_801_900 | 38_004_901 |
			

Heap

|                |   100 | 10_000 | 100_000 |
| :------------- | ----: | -----: | ------: |
| Array.fromIter | 272 B |  272 B |   272 B |
| List.fromIter  | 272 B |  272 B |   272 B |
			

Garbage Collection

|                |      100 |     10_000 |  100_000 |
| :------------- | -------: | ---------: | -------: |
| Array.fromIter | 2.76 KiB | 234.79 KiB | 2.29 MiB |
| List.fromIter  | 3.53 KiB | 312.91 KiB | 3.05 MiB |
			
		
Saving results to .bench/FromIters.bench.json
