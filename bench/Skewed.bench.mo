import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare pure/Queue with base:Deque");
    bench.description("TODO");

    bench.rows([
      "Initialize with 2 elements",
      "Push 500 elements",
      "Pop front 2 elements",
      "Pop back 2 elements"
    ]);
    bench.cols([
      "Real-Time",
      "Amortized"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    func input(n : Nat) : [Nat] = fuzz.array.randomArray(n, fuzz.nat.random);

    let init = input(2);
    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();

    let toPush = input(500);

    // Scenario:
    // - Start with 2 elements (old queue = ([x], 2, [y]))
    // - Push many elements to the queue (create very skewed old queue)
    // - Pop from the smaller end (cause the old queue to be rebalanced in one operation)

    bench.runner(
      func(row, col) = switch (col, row) {
        case ("Real-Time", "Initialize with 2 elements") newQ := NewQueue.fromIter<Nat>(init.vals());
        case ("Amortized", "Initialize with 2 elements") oldQ := OldQueue.fromIter<Nat>(init.vals());
        case ("Real-Time", "Push 500 elements") {
          for (i in toPush.vals()) {
            newQ := NewQueue.pushBack<Nat>(newQ, i)
          }
        };
        case ("Amortized", "Push 500 elements") {
          for (i in toPush.vals()) {
            oldQ := OldQueue.pushBack<Nat>(oldQ, i)
          }
        };
        case ("Real-Time", "Pop front 2 elements") Option.unwrap(
          do ? {
            newQ := NewQueue.popFront<Nat>(NewQueue.popFront<Nat>(newQ)!.1)!.1
          }
        );
        case ("Amortized", "Pop front 2 elements") Option.unwrap(
          do ? {
            oldQ := OldQueue.popFront<Nat>(OldQueue.popFront<Nat>(oldQ)!.1)!.1
          }
        );
        case ("Real-Time", "Pop back 2 elements") Option.unwrap(
          do ? {
            newQ := NewQueue.popBack<Nat>(NewQueue.popBack<Nat>(newQ)!.0)!.0
          }
        );
        case ("Amortized", "Pop back 2 elements") Option.unwrap(
          do ? {
            oldQ := OldQueue.popBack<Nat>(OldQueue.popBack<Nat>(oldQ)!.0)!.0
          }
        );
        case _ Runtime.unreachable()
      }
    );

    bench
  }
}
