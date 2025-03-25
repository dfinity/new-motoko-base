import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Iter "../src/Iter";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import Runtime "../src/Runtime";
import Text "../src/Text";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare pure/Queue with base:Deque");
    bench.description("Start with empty, then perform 100 random pushFront/popBack operations with push twice as likely");

    let numberOfSteps = 100;
    // let steps = Nat.range(0, numberOfSteps) |> Iter.map<Nat, Text>(_, func i = Nat.toText(i)) |> Iter.toArray<Text>(_);
    // bench.rows(steps);
    bench.cols([
      "Real-Time",
      "Amortized"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    let distribution = ["push", "push", "pop"]; // pushFront twice as likely as popBack
    func input(n : Nat) : [Text] = fuzz.array.randomArray(n, func() : Text = fuzz.array.randomValue(distribution));
    let operations = input(numberOfSteps);
    let rows = Iter.zip(Nat.range(0, numberOfSteps), operations.vals())
    |> Iter.map<(Nat, Text), Text>(_, func(i, op) = op # " " # Nat.toText(i))
    |> Iter.toArray<Text>(_);
    bench.rows(rows);

    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();

    func newOp(op : Text, q : NewQueue.Queue<Nat>) : NewQueue.Queue<Nat> = switch op {
      case "pop" Option.get(NewQueue.popBack<Nat>(q), (q, 0)).0;
      case "push" NewQueue.pushFront<Nat>(q, 2);
      case _ Runtime.unreachable()
    };

    func oldOp(op : Text, q : OldQueue.Queue<Nat>) : OldQueue.Queue<Nat> = switch op {
      case "pop" Option.get(OldQueue.popBack<Nat>(q), (q, 0)).0;
      case "push" OldQueue.pushFront<Nat>(q, 2);
      case _ Runtime.unreachable()
    };

    bench.runner(
      func(row, col) {
        // let op = Option.unwrap(Text.split(row, #char ' ').next());
        let iter = row.chars();
        ignore iter.next();
        let op = if (iter.next() == ?'o') "pop" else "push";

        switch col {
          case "Real-Time" newQ := newOp(op, newOp(op, newOp(op, newOp(op, newOp(op, newQ)))));
          case "Amortized" oldQ := oldOp(op, oldOp(op, oldOp(op, oldOp(op, oldOp(op, oldQ)))));
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
