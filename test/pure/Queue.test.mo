import Queue "../../src/pure/Queue";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Prim "mo:prim";
import { suite; test; expect } = "mo:test";

func iterateForward<T>(deque : Queue.Queue<T>) : Iter.Iter<T> {
  var current = deque;
  object {
    public func next() : ?T {
      switch (Queue.popFront(current)) {
        case null null;
        case (?result) {
          current := result.1;
          ?result.0
        }
      }
    }
  }
};

func iterateBackward<T>(deque : Queue.Queue<T>) : Iter.Iter<T> {
  var current = deque;
  object {
    public func next() : ?T {
      switch (Queue.popBack(current)) {
        case null null;
        case (?result) {
          current := result.0;
          ?result.1
        }
      }
    }
  }
};

func toText(deque : Queue.Queue<Nat>) : Text {
  var text = "[";
  var isFirst = true;
  for (element in iterateForward(deque)) {
    if (not isFirst) {
      text #= ", "
    } else {
      isFirst := false
    };
    text #= debug_show (element)
  };
  text #= "]";
  text
};

func reduceFront<T>(deque : Queue.Queue<T>, amount : Nat) : Queue.Queue<T> {
  var current = deque;
  for (_ in Nat.range(0, amount)) {
    switch (Queue.popFront(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.1
    }
  };
  current
};

func reduceBack<T>(deque : Queue.Queue<T>, amount : Nat) : Queue.Queue<T> {
  var current = deque;
  for (_ in Nat.range(0, amount)) {
    switch (Queue.popBack(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.0
    }
  };
  current
};

var deque = Queue.empty<Nat>();

suite(
  "construct",
  func() {
    test(
      "empty",
      func() {
        expect.bool(Queue.isEmpty(deque)).isTrue()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array<Nat>(Iter.toArray(iterateForward(deque)), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(Iter.toArray(iterateBackward(deque)), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(deque), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(deque), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "pop front",
      func() {
        expect.option<(Nat, Queue.Queue<Nat>)>(
          Queue.popFront(deque),
          func(n, _) = Nat.toText(n),
          func(a, b) = a.0 == b.0
        ).isNull()
      }
    );

    test(
      "pop back",
      func() {
        expect.option<(Queue.Queue<Nat>, Nat)>(
          Queue.popBack(deque),
          func(_, n) = Nat.toText(n),
          func(a, b) = a.1 == b.1
        ).isNull()
      }
    )
  }
);

deque := Queue.pushFront(Queue.empty<Nat>(), 1);

suite(
  "single item",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(deque)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(Iter.toArray(iterateForward(deque)), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(Iter.toArray(iterateBackward(deque)), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(deque), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(deque), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option<(Nat, Queue.Queue<Nat>)>(
          Queue.popFront(deque),
          func(n, _) = Nat.toText(n),
          func(a, b) = a.0 == b.0
        ).equal(?(1, Queue.empty()))
      }
    );

    test(
      "pop back",
      func() {
        expect.option<(Queue.Queue<Nat>, Nat)>(
          Queue.popBack(deque),
          func(_, n) = Nat.toText(n),
          func(a, b) = a.1 == b.1
        ).equal(?(Queue.empty(), 1))
      }
    )
  }
);

let testSize = 100;

func populateForward(from : Nat, to : Nat) : Queue.Queue<Nat> {
  var deque = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    deque := Queue.pushFront(deque, number)
  };
  deque
};

deque := populateForward(1, testSize);

suite(
  "forward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(deque)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          Iter.toArray(iterateForward(deque)),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              testSize - index
            }
          )
        )
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(
          Iter.toArray(iterateBackward(deque)),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              index + 1
            }
          )
        )
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(deque), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(deque), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option<(Nat, Queue.Queue<Nat>)>(
          Queue.popFront(deque),
          func(n, _) = Nat.toText(n),
          func(a, b) = a.0 == b.0
        ).equal(?(testSize, populateForward(1, testSize - 1)))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(Queue.isEmpty(reduceFront(deque, testSize))).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(Queue.isEmpty(reduceBack(deque, testSize))).isTrue()
      }
    )
  }
);

func populateBackward(from : Nat, to : Nat) : Queue.Queue<Nat> {
  var deque = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    deque := Queue.pushBack(deque, number)
  };
  deque
};

deque := populateBackward(1, testSize);

suite(
  "backward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(deque)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          Iter.toArray(iterateForward(deque)),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              index + 1
            }
          )
        )
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(
          Iter.toArray(iterateBackward(deque)),
          Nat.toText,
          Nat.equal
        ).equal(
          Array.tabulate(
            testSize,
            func(index : Nat) : Nat {
              testSize - index
            }
          )
        )
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Queue.peekFront(deque), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Queue.peekBack(deque), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "pop front",
      func() {
        expect.option<(Nat, Queue.Queue<Nat>)>(
          Queue.popFront(deque),
          func(n, _) = Nat.toText(n),
          func(a, b) = a.0 == b.0
        ).equal(?(1, populateBackward(2, testSize)))
      }
    );

    test(
      "pop back",
      func() {
        expect.option<(Queue.Queue<Nat>, Nat)>(
          Queue.popBack(deque),
          func(_, n) = Nat.toText(n),
          func(a, b) = a.1 == b.1
        ).equal(?(populateBackward(1, testSize - 1), testSize))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(Queue.isEmpty(reduceFront(deque, testSize))).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(Queue.isEmpty(reduceBack(deque, testSize))).isTrue()
      }
    )
  }
);

object Random {
  var number = 4711;
  public func next() : Int {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

func randomPopulate(amount : Nat) : Queue.Queue<Nat> {
  var current = Queue.empty<Nat>();
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      Queue.pushFront(current, Nat.sub(amount, number))
    } else {
      Queue.pushBack(current, amount + number)
    }
  };
  current
};

func isSorted(deque : Queue.Queue<Nat>) : Bool {
  let array = Iter.toArray(iterateForward(deque));
  let sorted = Array.sort(array, Nat.compare);
  Array.equal(array, sorted, Nat.equal)
};

func randomRemoval(deque : Queue.Queue<Nat>, amount : Nat) : Queue.Queue<Nat> {
  var current = deque;
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      let pair = Queue.popFront(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.1
      }
    } else {
      let pair = Queue.popBack(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.0
      }
    }
  };
  current
};

deque := randomPopulate(testSize);

suite(
  "random insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Queue.isEmpty(deque)).isFalse()
      }
    );

    test(
      "correct order",
      func() {
        expect.bool(isSorted(deque)).isTrue()
      }
    );

    test(
      "consistent iteration",
      func() {
        expect.array(
          Iter.toArray(iterateForward(deque)),
          Nat.toText,
          Nat.equal
        ).equal(Array.reverse(Iter.toArray(iterateBackward(deque))))
      }
    );

    test(
      "random quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(deque, testSize / 4))).isTrue()
      }
    );

    test(
      "random half removal",
      func() {
        expect.bool(isSorted(randomRemoval(deque, testSize / 2))).isTrue()
      }
    );

    test(
      "random three quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(deque, testSize * 3 / 4))).isTrue()
      }
    );

    test(
      "random total removal",
      func() {
        expect.bool(Queue.isEmpty(randomRemoval(deque, testSize))).isTrue()
      }
    )
  }
);

func randomInsertionDeletion(steps : Nat) : Queue.Queue<Nat> {
  var current = Queue.empty<Nat>();
  var size = 0;
  for (number in Nat.range(0, steps - 1)) {
    let random = Random.next();
    current := switch (random % 4) {
      case 0 {
        size += 1;
        Queue.pushFront(current, Nat.sub(steps, number))
      };
      case 1 {
        size += 1;
        Queue.pushBack(current, steps + number)
      };
      case 2 {
        switch (Queue.popFront(current)) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.1
          }
        }
      };
      case 3 {
        switch (Queue.popBack(current)) {
          case null {
            assert (size == 0);
            current
          };
          case (?result) {
            size -= 1;
            result.0
          }
        }
      };
      case _ Prim.trap("Impossible case")
    };
    assert (isSorted(current))
  };
  current
};

suite(
  "completely random",
  func() {
    test(
      "random insertion and deletion",
      func() {
        expect.bool(isSorted(randomInsertionDeletion(1000))).isTrue()
      }
    )
  }
)
