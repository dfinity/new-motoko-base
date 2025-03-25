import Bench "mo:bench";
import Fuzz "mo:fuzz";

import Iter "../src/Iter";
import Nat "../src/Nat";
import Option "../src/Option";
import OldQueue "../src/pure/OldQueue";
import NewQueue "../src/pure/Queue";
import Runtime "../src/Runtime";

// todo:
// - analyze a random sequence of operations (random pushes, then random pushes+pops)
// - use primitives to measure cycles needed (memory too?)
// - plot the results, analyse
// - use Prim.rts_* functions, they are the same as used by the bench module

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Compare pure/Queue with base:Deque");
    bench.description("Initialize with 500 elements, then perform 100 steps with 5 x popBack");

    let initialSize = 500;
    let numberOfSteps = 100;
    let steps = Nat.range(0, numberOfSteps) |> Iter.map<Nat, Text>(_, func i = Nat.toText(i)) |> Iter.toArray<Text>(_);
    bench.rows(steps);
    bench.cols([
      "Real-Time",
      "Amortized"
    ]);

    let fuzz = Fuzz.fromSeed(27850937); // fix seed for reproducibility

    let distribution = [1, 1]; // just skewed pops
    func input(n : Nat) : [Nat] = fuzz.array.randomArray(n, func() : Nat = fuzz.array.randomValue(distribution));
    let operations = input(numberOfSteps);

    var newQ = NewQueue.empty<Nat>();
    var oldQ = OldQueue.empty<Nat>();

    // initialize with random elements
    let initials = fuzz.array.randomArray(initialSize, fuzz.nat.random);

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
        if (row == "0") {
          switch col {
            case "Real-Time" newQ := NewQueue.fromIter(initials.vals());
            case "Amortized" oldQ := OldQueue.fromIter(initials.vals());
            case _ Runtime.unreachable()
          }
        };

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
