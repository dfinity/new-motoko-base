import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Iter "../src/Iter";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import Runtime "../src/Runtime";
import Text "../src/Text";
import Debug "../src/Debug";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare pure/Queue with base:Deque");
    bench.description("Start with empty, then perform 100 random steps of pushFront/popBack (each repeated 5 times) with push twice as likely. Spikes in real-time operations are due to rebalancing");

    let numberOfSteps = 100;
    bench.cols([
      "Real-Time",
      "Amortized"
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
            newQ := newOp(op, newOp(op, newOp(op, newOp(op, newOp(op, newQ)))))
          };
          case "Amortized" {
            oldQ := oldOp(op, oldOp(op, oldOp(op, oldOp(op, oldOp(op, oldQ)))))
          };
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
