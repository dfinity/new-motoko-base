import Deque "../../src/pure/Deque";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Prim "mo:prim";
import { suite; test; expect } "mo:test";
import Text "../../src/Text";
import Debug "../../src/Debug";

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
);

suite(
  "code coverage",
  func() {
    test(
      "singleton",
      func() {
        let q = Deque.singleton(1);
        expect.bool(Deque.isEmpty(q)).isFalse();
        expect.option(Deque.peekFront(q), Nat.toText, Nat.equal).equal(?1);
        expect.option(Deque.peekBack(q), Nat.toText, Nat.equal).equal(?1)
      }
    );

    test(
      "all",
      func() {
        let testAll = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          expect.bool(Deque.all<Nat>(q, func n = n > 0)).isTrue();
          expect.bool(Deque.all<Nat>(q, func n = n < 3)).isFalse()
        };
        testAll([4]);
        testAll([1, 5]);
        testAll([1, 2, 6]);
        testAll([1, 2, 3, 4]);
        testAll([1, 2, 2, 3, 3, 4]);
        testAll([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "filterMap",
      func() {
        let testFilterMap = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          let mapped = Deque.filterMap<Nat, Text>(
            q,
            func n = if (n % 2 == 0) ?Nat.toText(n) else null
          );
          expect.array<Text>(
            Iter.toArray(Deque.values(mapped)),
            func t = t,
            Text.equal
          ).equal(Array.filterMap<Nat, Text>(testElements, func n = if (n % 2 == 0) ?Nat.toText(n) else null))
        };
        testFilterMap([]);
        testFilterMap([1]);
        testFilterMap([1, 2]);
        testFilterMap([1, 2, 3]);
        testFilterMap([1, 2, 3, 4]);
        testFilterMap([1, 2, 2, 3, 3, 4]);
        testFilterMap([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "forEach",
      func() {
        let testForEach = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          var result = "";
          Deque.forEach<Nat>(
            q,
            func n {
              result #= Nat.toText n
            }
          );
          expect.text(result).equal(Array.foldLeft<Nat, Text>(testElements, "", func(acc, n) = acc # Nat.toText n))
        };
        testForEach([]);
        testForEach([1]);
        testForEach([1, 2]);
        testForEach([1, 2, 3]);
        testForEach([1, 2, 3, 4]);
        testForEach([1, 2, 2, 3, 3, 4]);
        testForEach([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "toText",
      func() {
        let testToText = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          expect.text(Deque.toText(q, Nat.toText)).equal("PureDeque" # Array.toText<Nat>(testElements, Nat.toText))
        };
        testToText([]);
        testToText([1]);
        testToText([1, 2]);
        testToText([1, 2, 3]);
        testToText([1, 2, 3, 4]);
        testToText([1, 2, 2, 3, 3, 4]);
        testToText([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "size",
      func() {
        let testSize = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          expect.nat(Deque.size(q)).equal(testElements.size())
        };
        testSize([]);
        testSize([1]);
        testSize([1, 2]);
        testSize([1, 2, 3]);
        testSize([1, 2, 3, 4]);
        testSize([1, 2, 2, 3, 3, 4]);
        testSize([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "contains",
      func() {
        let testContains = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          let alwaysThere = 1;
          let neverThere = 123;
          expect.bool(Deque.contains(q, Nat.equal, alwaysThere)).equal(Array.find<Nat>(testElements, func n = Nat.equal(n, alwaysThere)) != null);
          expect.bool(Deque.contains(q, Nat.equal, neverThere)).equal(Array.find<Nat>(testElements, func n = Nat.equal(n, neverThere)) != null)
        };
        testContains([]);
        testContains([1]);
        testContains([1, 2]);
        testContains([1, 2, 3]);
        testContains([1, 2, 3, 4]);
        testContains([1, 2, 2, 3, 3, 4]);
        testContains([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "any",
      func() {
        let testAny = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          expect.bool(Deque.any<Nat>(q, func n = n > 2)).equal(Array.any<Nat>(testElements, func n = n > 2));
          expect.bool(Deque.any<Nat>(q, func n = n > 3)).equal(Array.any<Nat>(testElements, func n = n > 3))
        };
        testAny([]);
        testAny([3]);
        testAny([1, 3]);
        testAny([1, 2, 3]);
        testAny([1, 2, 3, 2]);
        testAny([1, 2, 3, 2, 1]);
        testAny([1, 2, 0, 2, 1, 3]);
        testAny([1, 2, 0, 2, 1, 3, 1])
      }
    );

    test(
      "map",
      func() {
        let testMap = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          let mapped = Deque.map<Nat, Nat>(q, func n = n * 2);
          expect.array(
            Iter.toArray(Deque.values(mapped)),
            Nat.toText,
            Nat.equal
          ).equal(Array.map<Nat, Nat>(testElements, func n = n * 2))
        };
        testMap([]);
        testMap([1]);
        testMap([1, 2]);
        testMap([1, 2, 3]);
        testMap([1, 2, 3, 4]);
        testMap([1, 2, 2, 3, 3, 4]);
        testMap([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    );

    test(
      "reverse",
      func() {
        let testReverse = func(testElements : [Nat]) {
          let q = Deque.fromIter(testElements.vals());
          let reversed = Deque.reverse(q);
          expect.array(
            Iter.toArray(Deque.values(reversed)),
            Nat.toText,
            Nat.equal
          ).equal(Array.reverse(testElements))
        };

        testReverse([]);
        testReverse([1]);
        testReverse([1, 2]);
        testReverse([1, 2, 3]);
        testReverse([1, 2, 3, 4]);
        testReverse([1, 2, 2, 3, 3, 4]);
        testReverse([1, 2, 2, 3, 3, 4, 5, 6, 7, 8, 9])
      }
    )
  }
);

suite(
  "edge cases",
  func() {
    test(
      "empty queue operations",
      func() {
        let q = Deque.empty<Nat>();
        expect.bool(Deque.isEmpty(q)).isTrue();
        expect.nat(Deque.size(q)).equal(0);
        expect.option(Deque.peekFront(q), Nat.toText, Nat.equal).isNull();
        expect.option(Deque.peekBack(q), Nat.toText, Nat.equal).isNull();
        expect.option(
          Deque.popFront(q),
          frontToText,
          frontEqual
        ).isNull();
        expect.option(
          Deque.popBack(q),
          backToText,
          backEqual
        ).isNull()
      }
    );

    test(
      "rebalancing threshold",
      func() {
        // Create a queue that's exactly at the rebalancing threshold
        var q = Deque.empty<Nat>();
        for (i in Nat.range(1, 4)) {
          q := Deque.pushFront(q, i)
        };
        for (i in Nat.range(5, 12)) {
          q := Deque.pushBack(q, i)
        };
        let #rebal(_) = q else Prim.trap "Should be in rebalancing state";
        // Test operations during rebalancing
        Debug.print(debug_show (q));
        expect.text(Deque.toText(q, Nat.toText)).equal("PureDeque[3, 2, 1, 5, 6, 7, 8, 9, 10, 11]");
        q := Deque.pushFront(q, 0);
        q := Deque.pushBack(q, 13);
        expect.bool(Deque.isEmpty(q)).isFalse();
        expect.option(Deque.peekFront(q), Nat.toText, Nat.equal).equal(?0);
        expect.option(Deque.peekBack(q), Nat.toText, Nat.equal).equal(?13)
      }
    );

    test(
      "alternating operations",
      func() {
        var q = Deque.empty<Nat>();
        // Alternating pushes
        for (i in Nat.range(0, 5)) {
          q := Deque.pushFront(q, i);
          q := Deque.pushBack(q, i + 100)
        };
        // Mixed operations
        expect.option(Deque.popFront(q), frontToText, frontEqual).equal(?(4, Deque.fromIter([3, 2, 1, 0, 100, 101, 102, 103, 104].vals())));
        q := Deque.pushBack(q, 200);
        expect.option(Deque.popBack(q), backToText, backEqual).equal(?(Deque.fromIter([4, 3, 2, 1, 0, 100, 101, 102, 103, 104].vals()), 200));
        q := Deque.pushFront(q, 300);
        // Verify order is maintained
        expect.array(
          Iter.toArray(Deque.values(q)),
          Nat.toText,
          Nat.equal
        ).equal([300, 4, 3, 2, 1, 0, 100, 101, 102, 103, 104, 200])
      }
    )
  }
)
