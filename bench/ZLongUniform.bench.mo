import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Iter "../src/Iter";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import MutQueue "../src/Queue";
import Runtime "../src/Runtime";
import Text "../src/Text";
import Stats "Stats";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare queue implementations");
    bench.description("Start with empty, then perform 100 random steps of pushFront/popBack (each repeated 5 times) with push twice as likely. Spikes in real-time operations are due to rebalancing");

    let numberOfSteps = 100;
    let numberOfOperationsPerStep = 5;
    bench.cols([
      "Real-Time",
      "Amortized",
      "Mutable"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    let distribution = ["push", "push", "pop"]; // pushFront twice as likely as popBack
    func input(n : Nat) : [Text] = fuzz.array.randomArray(n, func() : Text = fuzz.array.randomValue(distribution));
    let operations = input(numberOfSteps);
    let rows = Iter.zip(Nat.range(1, 1 + numberOfSteps), operations.vals())
    |> Iter.map<(Nat, Text), Text>(_, func(i, op) = op # " " # Nat.toText(i))
    |> Iter.toArray<Text>(_);
    bench.rows(rows);

    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();
    var mutQ = MutQueue.empty<Nat>();

    var newStats = Stats.empty("Real-Time");
    var oldStats = Stats.empty("Amortized");
    var mutStats = Stats.empty("Mutable");

    func newOp(op : Text) = switch op {
      case "pop" Stats.record(newStats, func _ = newQ := Option.get(NewQueue.popBack<Nat>(newQ), (newQ, 0)).0);
      case "push" Stats.record(newStats, func _ = newQ := NewQueue.pushFront<Nat>(newQ, 2));
      case _ Runtime.unreachable()
    };

    func oldOp(op : Text) = switch op {
      case "pop" Stats.record(oldStats, func _ = oldQ := Option.get(OldQueue.popBack<Nat>(oldQ), (oldQ, 0)).0);
      case "push" Stats.record(oldStats, func _ = oldQ := OldQueue.pushFront<Nat>(oldQ, 2));
      case _ Runtime.unreachable()
    };

    func mutOp(op : Text) = switch op {
      case "pop" Stats.record(mutStats, func _ = ignore MutQueue.popBack<Nat>(mutQ));
      case "push" Stats.record(mutStats, func _ = MutQueue.pushFront<Nat>(mutQ, 2));
      case _ Runtime.unreachable()
    };

    bench.runner(
      func(row, col) {
        // let op = Option.unwrap(Text.split(row, #char ' ').next());
        let iter = row.chars();
        ignore iter.next();
        let op = if (iter.next() == ?'o') "pop" else "push";

        switch col {
          case "Real-Time" {
            // Debug with: 2>out.txt
            // newQ := newOp(op, newQ);
            // let s1 = NewQueue.debugState(newQ);
            // newQ := newOp(op, newQ);
            // let s2 = NewQueue.debugState(newQ);
            // newQ := newOp(op, newQ);
            // let s3 = NewQueue.debugState(newQ);
            // newQ := newOp(op, newQ);
            // let s4 = NewQueue.debugState(newQ);
            // newQ := newOp(op, newQ);
            // let s5 = NewQueue.debugState(newQ);
            // Debug.print(debug_show [s1, s2, s3, s4, s5])
            Stats.times(func _ = newOp(op), numberOfOperationsPerStep)
          };
          case "Amortized" {
            Stats.times(func _ = oldOp(op), numberOfOperationsPerStep)
          };
          case "Mutable" {
            Stats.times(func _ = mutOp(op), numberOfOperationsPerStep)
          };
          case _ Runtime.unreachable()
        };

        if (row == rows[numberOfSteps - 1]) {
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
