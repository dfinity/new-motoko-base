import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/Queue";
import NewQueue "../src/pure/RealTimeQueue";
import MutQueue "../src/Queue";
import Runtime "../src/Runtime";

import Prim "mo:prim";

// todo:
// - analyze a random sequence of operations (random pushes, then random pushes+pops)
// - use primitives to measure cycles needed (memory too?)
// - plot the results, analyse
// - use Prim.rts_* functions, they are the same as used by the bench module

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare queue implementations");
    bench.description("");

    bench.rows([
      "Initialize with 2 elements",
      "Push 500 elements",
      "Pop front 2 elements",
      "Pop back 2 elements",
      "Push 10 front&back; Pop 5 front&back",
      "Pop 150 front&back"
    ]);
    bench.cols([
      "Real-Time",
      "Amortized",
      "Mutable"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    func input(n : Nat) : [Nat] = fuzz.array.randomArray(n, fuzz.nat.random);

    let init = input(2);
    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();
    var mutQ = MutQueue.empty<Nat>();

    let toPush = input(500);

    // Scenario:
    // - Start with 2 elements (old queue = ([x], 2, [y]))
    // - Push many elements to the queue (create very skewed old queue)
    // - Pop from the smaller end (cause the old queue to be rebalanced in one operation)

    bench.runner(
      func(row, col) = switch (col, row) {
        case ("Real-Time", "Initialize with 2 elements") newQ := NewQueue.fromIter<Nat>(init.vals());
        case ("Amortized", "Initialize with 2 elements") oldQ := OldQueue.fromIter<Nat>(init.vals());
        case ("Mutable", "Initialize with 2 elements") mutQ := MutQueue.fromIter<Nat>(init.vals());
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
        case ("Mutable", "Push 500 elements") {
          for (i in toPush.vals()) {
            MutQueue.pushBack<Nat>(mutQ, i)
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
        case ("Mutable", "Pop front 2 elements") Option.unwrap(
          do ? {
            ignore MutQueue.popFront<Nat>(mutQ);
            ignore MutQueue.popFront<Nat>(mutQ)
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
        case ("Mutable", "Pop back 2 elements") Option.unwrap(
          do ? {
            ignore MutQueue.popBack<Nat>(mutQ);
            ignore MutQueue.popBack<Nat>(mutQ)
          }
        );
        case ("Real-Time", "Push 10 front&back; Pop 5 front&back") {
          for (i in Nat.range(0, 10)) {
            newQ := NewQueue.pushBack<Nat>(NewQueue.pushFront<Nat>(newQ, i), i)
          };
          for (i in Nat.range(0, 5)) Option.unwrap(
            do ? {
              newQ := NewQueue.popBack<Nat>(NewQueue.popFront<Nat>(newQ)!.1)!.0
            }
          )
        };
        case ("Amortized", "Push 10 front&back; Pop 5 front&back") {
          for (i in Nat.range(0, 10)) {
            oldQ := OldQueue.pushBack<Nat>(OldQueue.pushFront<Nat>(oldQ, i), i)
          };
          for (i in Nat.range(0, 5)) Option.unwrap(
            do ? {
              oldQ := OldQueue.popBack<Nat>(OldQueue.popFront<Nat>(oldQ)!.1)!.0
            }
          )
        };
        case ("Mutable", "Push 10 front&back; Pop 5 front&back") {
          for (i in Nat.range(0, 10)) {
            MutQueue.pushFront<Nat>(mutQ, i);
            MutQueue.pushBack<Nat>(mutQ, i)
          };
          for (i in Nat.range(0, 5)) {
            ignore MutQueue.popFront<Nat>(mutQ);
            ignore MutQueue.popBack<Nat>(mutQ)
          }
        };
        case ("Real-Time", "Pop 150 front&back") {
          for (i in Nat.range(0, 150)) Option.unwrap(
            do ? {
              newQ := NewQueue.popBack<Nat>(NewQueue.popFront<Nat>(newQ)!.1)!.0
            }
          )
        };
        case ("Amortized", "Pop 150 front&back") {
          for (i in Nat.range(0, 150)) Option.unwrap(
            do ? {
              oldQ := OldQueue.popBack<Nat>(OldQueue.popFront<Nat>(oldQ)!.1)!.0
            }
          )
        };
        case ("Mutable", "Pop 150 front&back") {
          for (i in Nat.range(0, 150)) {
            ignore MutQueue.popFront<Nat>(mutQ);
            ignore MutQueue.popBack<Nat>(mutQ)
          }
        };
        case _ Runtime.unreachable()
      }
    );

    bench
  }
}
