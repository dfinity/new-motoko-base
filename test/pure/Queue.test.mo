import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

import Prim "mo:prim";
import Queue "../../src/pure/Queue";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";

let { run; test; suite } = Suite;

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

let natQueueTestable : T.Testable<Queue.Queue<Nat>> = object {
  public func display(deque : Queue.Queue<Nat>) : Text {
    toText(deque)
  };
  public func equals(first : Queue.Queue<Nat>, second : Queue.Queue<Nat>) : Bool {
    Array.equal(Iter.toArray(iterateForward(first)), Iter.toArray(iterateForward(second)), Nat.equal)
  }
};

func matchFrontRemoval(element : Nat, remainder : Queue.Queue<Nat>) : M.Matcher<?(Nat, Queue.Queue<Nat>)> {
  let testable = T.tuple2Testable(T.natTestable, natQueueTestable);
  M.equals(T.optional(testable, ?(element, remainder)))
};

func matchEmptyFrontRemoval() : M.Matcher<?(Nat, Queue.Queue<Nat>)> {
  let testable = T.tuple2Testable(T.natTestable, natQueueTestable);
  M.equals(T.optional(testable, null : ?(Nat, Queue.Queue<Nat>)))
};

func matchBackRemoval(remainder : Queue.Queue<Nat>, element : Nat) : M.Matcher<?(Queue.Queue<Nat>, Nat)> {
  let testable = T.tuple2Testable(natQueueTestable, T.natTestable);
  M.equals(T.optional(testable, ?(remainder, element)))
};

func matchEmptyBackRemoval() : M.Matcher<?(Queue.Queue<Nat>, Nat)> {
  let testable = T.tuple2Testable(natQueueTestable, T.natTestable);
  M.equals(T.optional(testable, null : ?(Queue.Queue<Nat>, Nat)))
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

/* --------------------------------------- */

var deque = Queue.empty<Nat>();

run(
  suite(
    "construct",
    [
      test(
        "empty",
        Queue.isEmpty(deque),
        M.equals(T.bool(true))
      ),
      test(
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "peek front",
        Queue.peekFront(deque),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "peek back",
        Queue.peekBack(deque),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "pop front",
        Queue.popFront(deque),
        matchEmptyFrontRemoval()
      ),
      test(
        "pop back",
        Queue.popBack(deque),
        matchEmptyBackRemoval()
      )
    ]
  )
);

/* --------------------------------------- */

deque := Queue.pushFront(Queue.empty<Nat>(), 1);

run(
  suite(
    "single item",
    [
      test(
        "not empty",
        Queue.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(T.array(T.natTestable, [1]))
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(T.array(T.natTestable, [1]))
      ),
      test(
        "peek front",
        Queue.peekFront(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "peek back",
        Queue.peekBack(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "pop front",
        Queue.popFront(deque),
        matchFrontRemoval(1, Queue.empty())
      ),
      test(
        "pop back",
        Queue.popBack(deque),
        matchBackRemoval(Queue.empty(), 1)
      )
    ]
  )
);

/* --------------------------------------- */

let testSize = 100;

func populateForward(from : Nat, to : Nat) : Queue.Queue<Nat> {
  var deque = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    deque := Queue.pushFront(deque, number)
  };
  deque
};

deque := populateForward(1, testSize);

run(
  suite(
    "forward insertion",
    [
      test(
        "not empty",
        Queue.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                testSize - index
              }
            )
          )
        )
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                index + 1
              }
            )
          )
        )
      ),
      test(
        "peek front",
        Queue.peekFront(deque),
        M.equals(T.optional(T.natTestable, ?testSize))
      ),
      test(
        "peek back",
        Queue.peekBack(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "pop front",
        Queue.popFront(deque),
        matchFrontRemoval(testSize, populateForward(1, testSize - 1))
      ),
      test(
        "empty after front removal",
        Queue.isEmpty(reduceFront(deque, testSize)),
        M.equals(T.bool(true))
      ),
      test(
        "empty after front removal",
        Queue.isEmpty(reduceBack(deque, testSize)),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

func populateBackward(from : Nat, to : Nat) : Queue.Queue<Nat> {
  var deque = Queue.empty<Nat>();
  for (number in Nat.range(from, to)) {
    deque := Queue.pushBack(deque, number)
  };
  deque
};

deque := populateBackward(1, testSize);

run(
  suite(
    "backward insertion",
    [
      test(
        "not empty",
        Queue.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "iterate forward",
        Iter.toArray(iterateForward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                index + 1
              }
            )
          )
        )
      ),
      test(
        "iterate backward",
        Iter.toArray(iterateBackward(deque)),
        M.equals(
          T.array(
            T.natTestable,
            Array.tabulate(
              testSize,
              func(index : Nat) : Nat {
                testSize - index
              }
            )
          )
        )
      ),
      test(
        "peek front",
        Queue.peekFront(deque),
        M.equals(T.optional(T.natTestable, ?1))
      ),
      test(
        "peek back",
        Queue.peekBack(deque),
        M.equals(T.optional(T.natTestable, ?testSize))
      ),
      test(
        "pop front",
        Queue.popFront(deque),
        matchFrontRemoval(1, populateBackward(2, testSize))
      ),
      test(
        "pop back",
        Queue.popBack(deque),
        matchBackRemoval(populateBackward(1, testSize - 1), testSize)
      ),
      test(
        "empty after front removal",
        Queue.isEmpty(reduceFront(deque, testSize)),
        M.equals(T.bool(true))
      ),
      test(
        "empty after front removal",
        Queue.isEmpty(reduceBack(deque, testSize)),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

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

run(
  suite(
    "random insertion",
    [
      test(
        "not empty",
        Queue.isEmpty(deque),
        M.equals(T.bool(false))
      ),
      test(
        "correct order",
        isSorted(deque),
        M.equals(T.bool(true))
      ),
      test(
        "consistent iteration",
        Iter.toArray(iterateForward(deque)),
        M.equals(T.array(T.natTestable, Array.reverse(Iter.toArray(iterateBackward(deque)))))
      ),
      test(
        "random quarter removal",
        isSorted(randomRemoval(deque, testSize / 4)),
        M.equals(T.bool(true))
      ),
      test(
        "random half removal",
        isSorted(randomRemoval(deque, testSize / 2)),
        M.equals(T.bool(true))
      ),
      test(
        "random three quarter removal",
        isSorted(randomRemoval(deque, testSize * 3 / 4)),
        M.equals(T.bool(true))
      ),
      test(
        "random total removal",
        Queue.isEmpty(randomRemoval(deque, testSize)),
        M.equals(T.bool(true))
      )
    ]
  )
);

/* --------------------------------------- */

func randomInsertionDeletion(steps : Nat) : Queue.Queue<Nat> {
  var current = Queue.empty<Nat>();
  var size = 0;
  for (number in Nat.range(1, steps)) {
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

run(
  suite(
    "completely random",
    [
      test(
        "random insertion and deletion",
        isSorted(randomInsertionDeletion(1000)),
        M.equals(T.bool(true))
      )
    ]
  )
)
