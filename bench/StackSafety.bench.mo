import Bench "mo:bench";

import Nat "../src/Nat";
import List "../src/pure/List";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("");
    bench.description("");

    bench.rows([
      "List.split"
    ]);
    bench.cols(["Should not cause a stack overflow"]);

    let splitN = 100_000;
    let list = List.repeat(1, splitN);

    bench.runner(
      func(row, col) {
        switch row {
          case "List.split" ignore List.split(list, splitN - 1 : Nat);
          case _ return ()
        }
      }
    );

    bench
  }
}
