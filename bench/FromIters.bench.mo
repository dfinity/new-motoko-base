import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Array "../src/Array";
import List "../src/pure/List";
import Runtime "../src/Runtime";
import Nat "../src/Nat";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Benchmarking the fromIter functions");
    bench.description("Columns describe the number of elements in the input iter.");

    bench.rows([
      "Array.fromIter2",
      "List.fromIter2"
    ]);
    bench.cols([
      "100",
      "10_000",
      "100_000"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    func input(n : Nat) : [Nat] = fuzz.array.randomArray(n, fuzz.nat.random);

    let array1 = input(100);
    let array2 = input(10_000);
    let array3 = input(100_000);

    bench.runner(
      func(row, col) {
        let array = switch col {
          case "100" array1;
          case "10_000" array2;
          case "100_000" array3;
          case _ Runtime.unreachable()
        };
        switch (row) {
          case "List.fromIter" ignore List.fromIter(array.vals());
          case "Array.fromIter" ignore Array.fromIter(array.vals());
          case _ return ()
        }
      }
    );

    bench
  }
}
