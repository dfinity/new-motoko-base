import Deque "../../src/pure/Deque";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Prim "mo:prim";
import { suite; test; expect } "mo:test";

type Deque<T> = Deque.Deque<T>;

func iterateForward<T>(queue : Deque<T>) : Iter.Iter<T> {
  var current = queue;
  object {
    public func next() : ?T {
      switch (Deque.popFront(current)) {
        case null null;
        case (?result) {
          current := result.1;
          ?result.0
        }
      }
    }
  }
};

func iterateBackward<T>(queue : Deque<T>) : Iter.Iter<T> {
  var current = queue;
  object {
    public func next() : ?T {
      switch (Deque.popBack(current)) {
        case null null;
        case (?result) {
          current := result.0;
          ?result.1
        }
      }
    }
  }
};

func frontToText(t : (Nat, Deque<Nat>)) : Text {
  "(" # Nat.toText(t.0) # ", " # Deque.toText(t.1, Nat.toText) # ")"
};

func frontEqual(t1 : (Nat, Deque<Nat>), t2 : (Nat, Deque<Nat>)) : Bool {
  t1.0 == t2.0 and Deque.equal(t1.1, t2.1, Nat.equal)
};

func backToText(t : (Deque<Nat>, Nat)) : Text {
  "(" # Deque.toText(t.0, Nat.toText) # ", " # Nat.toText(t.1) # ")"
};

func backEqual(t1 : (Deque<Nat>, Nat), t2 : (Deque<Nat>, Nat)) : Bool {
  t1.1 == t2.1 and Deque.equal(t1.0, t2.0, Nat.equal)
};

func reduceFront<T>(queue : Deque<T>, amount : Nat) : Deque<T> {
  var current = queue;
  for (_ in Nat.range(0, amount)) {
    switch (Deque.popFront(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.1
    }
  };
  current
};

func reduceBack<T>(queue : Deque<T>, amount : Nat) : Deque<T> {
  var current = queue;
  for (_ in Nat.range(0, amount)) {
    switch (Deque.popBack(current)) {
      case null Prim.trap("should not be null");
      case (?result) current := result.0
    }
  };
  current
};

var queue = Deque.empty<Nat>();

suite(
  "construct",
  func() {
    test(
      "empty",
      func() {
        expect.bool(Deque.isEmpty(queue)).isTrue()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array<Nat>(Iter.toArray(iterateForward(queue)), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(Iter.toArray(iterateBackward(queue)), Nat.toText, Nat.equal).size(0)
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Deque.peekFront(queue), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Deque.peekBack(queue), Nat.toText, Nat.equal).isNull()
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Deque.popFront(queue),
          frontToText,
          frontEqual
        ).isNull()
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          Deque.popBack(queue),
          backToText,
          backEqual
        ).isNull()
      }
    )
  }
);

queue := Deque.pushFront(Deque.empty<Nat>(), 1);

suite(
  "single item",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Deque.isEmpty(queue)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(Iter.toArray(iterateForward(queue)), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "iterate backward",
      func() {
        expect.array(Iter.toArray(iterateBackward(queue)), Nat.toText, Nat.equal).equal([1])
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Deque.peekFront(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Deque.peekBack(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Deque.popFront(queue),
          frontToText,
          frontEqual
        ).equal(?(1, Deque.empty()))
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          Deque.popBack(queue),
          backToText,
          backEqual
        ).equal(?(Deque.empty(), 1))
      }
    )
  }
);

let testSize = 100;

func populateForward(from : Nat, to : Nat) : Deque<Nat> {
  var queue = Deque.empty<Nat>();
  for (number in Nat.range(from, to)) {
    queue := Deque.pushFront(queue, number)
  };
  queue
};

queue := populateForward(1, testSize + 1);

suite(
  "forward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Deque.isEmpty(queue)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          Iter.toArray(iterateForward(queue)),
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
          Iter.toArray(iterateBackward(queue)),
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
        expect.option(Deque.peekFront(queue), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Deque.peekBack(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Deque.popFront(queue),
          frontToText,
          frontEqual
        ).equal(?(testSize, populateForward(1, testSize)))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(Deque.isEmpty(reduceFront(queue, testSize))).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(Deque.isEmpty(reduceBack(queue, testSize))).isTrue()
      }
    )
  }
);

func populateBackward(from : Nat, to : Nat) : Deque<Nat> {
  var queue = Deque.empty<Nat>();
  for (number in Nat.range(from, to)) {
    queue := Deque.pushBack(queue, number)
  };
  queue
};

queue := populateBackward(1, testSize + 1);

suite(
  "backward insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Deque.isEmpty(queue)).isFalse()
      }
    );

    test(
      "iterate forward",
      func() {
        expect.array(
          Iter.toArray(iterateForward(queue)),
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
          Iter.toArray(iterateBackward(queue)),
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
        expect.option(Deque.peekFront(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Deque.peekBack(queue), Nat.toText, Nat.equal).equal(?testSize)
      }
    );

    test(
      "pop front",
      func() {
        expect.option(
          Deque.popFront(queue),
          frontToText,
          frontEqual
        ).equal(?(1, populateBackward(2, testSize + 1)))
      }
    );

    test(
      "pop back",
      func() {
        expect.option(
          Deque.popBack(queue),
          backToText,
          backEqual
        ).equal(?(populateBackward(1, testSize), testSize))
      }
    );

    test(
      "empty after front removal",
      func() {
        expect.bool(Deque.isEmpty(reduceFront(queue, testSize))).isTrue()
      }
    );

    test(
      "empty after back removal",
      func() {
        expect.bool(Deque.isEmpty(reduceBack(queue, testSize))).isTrue()
      }
    )
  }
);

queue := Deque.filter<Nat>(Deque.fromIter([1, 2, 3, 4, 5].vals()), func n = n < 3);

suite(
  "filter invariants",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Deque.isEmpty(queue)).isFalse()
      }
    );

    test(
      "peek front",
      func() {
        expect.option(Deque.peekFront(queue), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "peek back",
      func() {
        expect.option(Deque.peekBack(queue), Nat.toText, Nat.equal).equal(?2)
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

func randomPopulate(amount : Nat) : Deque<Nat> {
  var current = Deque.empty<Nat>();
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      Deque.pushFront(current, Nat.sub(amount, number))
    } else {
      Deque.pushBack(current, amount + number)
    }
  };
  current
};

func isSorted(queue : Deque<Nat>) : Bool {
  let array = Iter.toArray(iterateForward(queue));
  let sorted = Array.sort(array, Nat.compare);
  Array.equal(array, sorted, Nat.equal)
};

func randomRemoval(queue : Deque<Nat>, amount : Nat) : Deque<Nat> {
  var current = queue;
  for (number in Nat.range(0, amount)) {
    current := if (Random.next() % 2 == 0) {
      let pair = Deque.popFront(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.1
      }
    } else {
      let pair = Deque.popBack(current);
      switch pair {
        case null Prim.trap("should not be null");
        case (?result) result.0
      }
    }
  };
  current
};

queue := randomPopulate(testSize);

suite(
  "random insertion",
  func() {
    test(
      "not empty",
      func() {
        expect.bool(Deque.isEmpty(queue)).isFalse()
      }
    );

    test(
      "correct order",
      func() {
        expect.bool(isSorted(queue)).isTrue()
      }
    );

    test(
      "consistent iteration",
      func() {
        expect.array(
          Iter.toArray(iterateForward(queue)),
          Nat.toText,
          Nat.equal
        ).equal(Array.reverse(Iter.toArray(iterateBackward(queue))))
      }
    );

    test(
      "random quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize / 4))).isTrue()
      }
    );

    test(
      "random half removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize / 2))).isTrue()
      }
    );

    test(
      "random three quarter removal",
      func() {
        expect.bool(isSorted(randomRemoval(queue, testSize * 3 / 4))).isTrue()
      }
    );

    test(
      "random total removal",
      func() {
        expect.bool(Deque.isEmpty(randomRemoval(queue, testSize))).isTrue()
      }
    )
  }
);

func randomInsertionDeletion(steps : Nat) : Deque<Nat> {
  var current = Deque.empty<Nat>();
  var size = 0;
  for (number in Nat.range(0, steps - 1)) {
    let random = Random.next();
    current := switch (random % 4) {
      case 0 {
        size += 1;
        Deque.pushFront(current, Nat.sub(steps, number))
      };
      case 1 {
        size += 1;
        Deque.pushBack(current, steps + number)
      };
      case 2 {
        switch (Deque.popFront(current)) {
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
        switch (Deque.popBack(current)) {
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
