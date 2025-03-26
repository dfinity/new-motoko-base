import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Iter "../src/Iter";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import MutQueue "../src/Queue";
import Runtime "../src/Runtime";
import Stats "Stats";

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

    let newStats = Stats.empty("Real-Time");
    let oldStats = Stats.empty("Amortized");
    let mutStats = Stats.empty("Mutable");

    // initialize with random elements
    let initials = fuzz.array.randomArray(initialSize, fuzz.nat.random);

    bench.runner(
      func(row, col) {
        if (row == "0") {
          switch col {
            case "Real-Time" {
              for (i in initials.vals()) {
                Stats.record(newStats, func _ = newQ := NewQueue.pushFront<Nat>(newQ, i))
              }
            };
            case "Amortized" {
              for (i in initials.vals()) {
                Stats.record(oldStats, func _ = oldQ := OldQueue.pushFront<Nat>(oldQ, i))
              }
            };
            case "Mutable" {
              for (i in initials.vals()) {
                Stats.record(mutStats, func _ = MutQueue.pushFront<Nat>(mutQ, i))
              }
            };
            case _ Runtime.unreachable()
          };
          return ()
        };

        switch col {
          case "Real-Time" Stats.times(func _ = Stats.record(newStats, func _ = newQ := Option.unwrap(NewQueue.popBack<Nat>(newQ)).0), numberOfOperationsPerStep);
          case "Amortized" Stats.times(func _ = Stats.record(oldStats, func _ = oldQ := Option.unwrap(OldQueue.popBack<Nat>(oldQ)).0), numberOfOperationsPerStep);
          case "Mutable" Stats.times(func _ = Stats.record(mutStats, func _ = ignore MutQueue.popBack<Nat>(mutQ)), numberOfOperationsPerStep);
          case _ Runtime.unreachable()
        };

        if (row == Nat.toText(numberOfSteps - 1)) {
          switch col {
            case "Real-Time" Stats.dump(newStats);
            case "Amortized" Stats.dump(oldStats);
            case "Mutable" Stats.dump(mutStats);
            case _ Runtime.unreachable()
          }
        }
      }
    );

    bench
  }
}
