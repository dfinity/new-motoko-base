import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Runtime "../src/Runtime";
import Array "../src/Array";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Benchmarking the Array module");
    bench.description("Benchmarking the performance with ...");

    bench.rows(["reverse"]);
    bench.cols(["100", "10_000", "100_000"]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    let array1 = fuzz.array.randomArray(100, fuzz.nat.random);
    let array2 = fuzz.array.randomArray(10_000, fuzz.nat.random);
    let array3 = fuzz.array.randomArray(100_000, fuzz.nat.random);

    bench.runner(
      func(row, col) = switch row {
        case "reverse" ignore switch col {
          case "100" Array.reverse(array1);
          case "10_000" Array.reverse(array2);
          case "100_000" Array.reverse(array3);
          case _ Runtime.unreachable()
        };
        case _ Runtime.unreachable()
      }
    );

    bench
  }
}
