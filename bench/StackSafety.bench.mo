import Bench "mo:bench";

import Nat "../src/Nat";
import Option "../src/Option";
import List "../src/pure/List";
import Queue "../src/pure/Queue";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Stack safety");
    bench.description("Check stack-safety of the following functions.");

    bench.rows([
      "pure/List.split",
      "pure/List.all",
      "pure/List.any",
      // "pure/List.map",
      // "pure/List.foldRight",
      // "pure/Queue",
    ]);
    bench.cols([""]);

    let list = List.repeat(1, 100_000);

    bench.runner(
      func(row, col) {
        switch row {
          case "pure/List.split" ignore List.split(list, 99_999);
          case "pure/List.all" ignore List.all<Nat>(list, func x = 1 == x);
          case "pure/List.any" ignore not List.any<Nat>(list, func x = 1 != x);
          // case "pure/List.map" ignore List.map<Nat, Nat>(list, func x = x + 1);
          // case "pure/List.foldRight" ignore List.foldRight<Nat, Nat>(list, 0, Nat.add);
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
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
