import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Iter "../src/Iter";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import MutQueue "../src/Queue";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare queue implementations");
    bench.description("PushFront 10_000 elements at step 0, then perform 110 steps of 50 x popBack");

    let initialSize = 10_000;
    let numberOfSteps = 110;
    let numberOfOperationsPerStep = 50;
    let steps = Nat.range(0, numberOfSteps) |> Iter.map<Nat, Text>(_, func i = Nat.toText(i)) |> Iter.toArray<Text>(_);
    bench.rows(steps);
    bench.cols([
      "Real-Time",
      "Amortized",
      "Mutable"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();
    var mutQ = MutQueue.empty<Nat>();

    // initialize with random elements
    let initials = fuzz.array.randomArray(initialSize, fuzz.nat.random);

    func times<T>(f : T -> T, n : Nat, x : T) : T {
      var acc = x;
      for (i in Nat.range(0, n)) {
        acc := f(acc)
      };
      acc
    };

    bench.runner(
      func(row, col) {
        if (row == "0") {
          switch col {
            case "Real-Time" {
              for (i in initials.vals()) {
                newQ := NewQueue.pushFront<Nat>(newQ, i)
              }
            };
            case "Amortized" {
              for (i in initials.vals()) {
                oldQ := OldQueue.pushFront<Nat>(oldQ, i)
              }
            };
            case "Mutable" {
              for (i in initials.vals()) {
                MutQueue.pushFront<Nat>(mutQ, i)
              }
            };
            case _ Runtime.unreachable()
          };
          return ()
        };

        switch col {
          case "Real-Time" newQ := times<NewQueue.Queue<Nat>>(func q = Option.unwrap(NewQueue.popBack<Nat>(q)).0, numberOfOperationsPerStep, newQ);
          case "Amortized" oldQ := times<OldQueue.Queue<Nat>>(func q = Option.unwrap(OldQueue.popBack<Nat>(q)).0, numberOfOperationsPerStep, oldQ);
          case "Mutable" times<()>(func _ = ignore MutQueue.popBack<Nat>(mutQ), numberOfOperationsPerStep, ());
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
