import Bench "mo:bench";

import Nat "../src/Nat";
import List "../src/pure/List";
import Queue "../src/pure/Queue";
import Option "../src/Option";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Stack safety");
    bench.description("Check stack-safety of the following functions.");

    bench.rows([
      "pure/List.split",
      "pure/Queue"
    ]);
    bench.cols([""]);

    bench.runner(
      func(row, col) {
        switch row {
          case "pure/List.split" {
            let list = List.repeat(1, 100_000);
            ignore List.split(list, 99_999)
          };
          // case "pure/Queue" {
          //   var q = Queue.empty<Nat>();
          //   let n = 100_000;
          //   for (i in Nat.range(0, 2 * n)) q := Queue.pushBack(q, i);
          //   assert Queue.size(q) == 2 * n;
          //   for (_ in Nat.range(0, n)) {
          //     q := Option.unwrap(Queue.popBack(q)).0;
          //     q := Option.unwrap(Queue.popFront(q)).1
          //   };
          //   assert Queue.size(q) == 0
          // };
          case _ return ()
        }
      }
    );

    bench
  }
}
