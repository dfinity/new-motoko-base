import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Iter "../src/Iter";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import Runtime "../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare pure/Queue with base:Deque");
    bench.description("Start with empty, then perform 100 random pushFront/popBack operations with push twice as likely");

    let numberOfSteps = 100;
    let steps = Nat.range(0, numberOfSteps) |> Iter.map<Nat, Text>(_, func i = Nat.toText(i)) |> Iter.toArray<Text>(_);
    bench.rows(steps);
    bench.cols([
      "Real-Time",
      "Amortized"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    let distribution = [1, 2, 2]; // pushFront twice as likely as popBack
    func input(n : Nat) : [Nat] = fuzz.array.randomArray(n, func() : Nat = fuzz.array.randomValue(distribution));
    let operations = input(numberOfSteps);

    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();

    func newOp(op : Nat, q : NewQueue.Queue<Nat>) : NewQueue.Queue<Nat> = switch op {
      case 0 Option.get(NewQueue.popFront<Nat>(q), (0, q)).1;
      case 1 Option.get(NewQueue.popBack<Nat>(q), (q, 0)).0;
      case 2 NewQueue.pushFront<Nat>(q, 2);
      case 3 NewQueue.pushBack<Nat>(q, 3);
      case _ Runtime.unreachable()
    };

    func oldOp(op : Nat, q : OldQueue.Queue<Nat>) : OldQueue.Queue<Nat> = switch op {
      case 0 Option.get(OldQueue.popFront<Nat>(q), (0, q)).1;
      case 1 Option.get(OldQueue.popBack<Nat>(q), (q, 0)).0;
      case 2 OldQueue.pushFront<Nat>(q, 2);
      case 3 OldQueue.pushBack<Nat>(q, 3);
      case _ Runtime.unreachable()
    };

    bench.runner(
      func(row, col) {
        let op = operations[Option.unwrap(Nat.fromText(row))];
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
