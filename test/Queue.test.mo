import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Queue "../src/Queue";
import Iter "../src/Iter";
import Nat "../src/Nat";
import Runtime "../src/Runtime";

let { run; test; suite } = Suite;

run(
  suite(
    "empty",
    [
      test(
        "size",
        Queue.size(Queue.empty<Nat>()),
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Queue.isEmpty(Queue.empty<Nat>()),
        M.equals(T.bool(true))
      ),
      test(
        "peek front",
        Queue.peekFront(Queue.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "peek back",
        Queue.peekBack(Queue.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "pop front",
        Queue.popFront(Queue.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "pop back",
        Queue.popBack(Queue.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "contains",
        Queue.contains(Queue.empty<Nat>(), Nat.equal, 0),
        M.equals(T.bool(false))
      ),
      test(
        "clone",
        Queue.size(Queue.clone(Queue.empty<Nat>())),
        M.equals(T.nat(0))
      ),
      test(
        "clear",
        do {
          let queue = Queue.empty<Nat>();
          Queue.clear(queue);
          Queue.size(queue)
        },
        M.equals(T.nat(0))
      ),
      test(
        "from iter",
        Queue.size(Queue.fromIter<Nat>(Iter.fromArray([]))),
        M.equals(T.nat(0))
      ),
      test(
        "vals",
        Iter.toArray(Queue.values(Queue.empty<Nat>())),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "equal",
        Queue.equal(Queue.empty<Nat>(), Queue.empty<Nat>(), Nat.equal),
        M.equals(T.bool(true))
      ),
      test(
        "compare",
        Queue.compare(Queue.empty<Nat>(), Queue.empty<Nat>(), Nat.compare) == #equal,
        M.equals(T.bool(true))
      ),
      test(
        "to text",
        Queue.toText(Queue.empty<Nat>(), Nat.toText),
        M.equals(T.text("Queue[]"))
      )
    ]
  )
);

run(
  suite(
    "singleton",
    [
      test(
        "size",
        Queue.size(Queue.singleton<Nat>(0)),
        M.equals(T.nat(1))
      ),
      test(
        "is empty",
        Queue.isEmpty(Queue.singleton<Nat>(0)),
        M.equals(T.bool(false))
      ),
      test(
        "peek front",
        Queue.peekFront(Queue.singleton<Nat>(0)),
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "peek back",
        Queue.peekBack(Queue.singleton<Nat>(0)),
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "pop front",
        do {
          let queue = Queue.singleton<Nat>(0);
          let front = Queue.popFront(queue);
          assert (Queue.isEmpty(queue));
          front
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "pop back",
        do {
          let queue = Queue.singleton<Nat>(0);
          let back = Queue.popBack(queue);
          assert (Queue.isEmpty(queue));
          back
        },
        M.equals(T.optional(T.natTestable, ?0))
      ),
      test(
        "contains present",
        Queue.contains(Queue.singleton<Nat>(0), Nat.equal, 0),
        M.equals(T.bool(true))
      ),
      test(
        "contains absent",
        Queue.contains(Queue.singleton<Nat>(0), Nat.equal, 1),
        M.equals(T.bool(false))
      ),
      test(
        "clone",
        do {
          let original = Queue.singleton<Nat>(0);
          let clone = Queue.clone(original);
          assert (Queue.popFront(original) == ?0);
          Queue.size(clone)
        },
        M.equals(T.nat(1))
      ),
      test(
        "clear",
        do {
          let queue = Queue.singleton<Nat>(0);
          Queue.clear(queue);
          Queue.size(queue)
        },
        M.equals(T.nat(0))
      ),
      test(
        "vals",
        Iter.toArray(Queue.values(Queue.singleton<Nat>(0))),
        M.equals(T.array(T.natTestable, [0]))
      ),
      test(
        "equal same",
        Queue.equal(Queue.singleton<Nat>(0), Queue.singleton<Nat>(0), Nat.equal),
        M.equals(T.bool(true))
      ),
      test(
        "equal different",
        Queue.equal(Queue.singleton<Nat>(0), Queue.singleton<Nat>(1), Nat.equal),
        M.equals(T.bool(false))
      ),
      test(
        "compare less",
        Queue.compare(Queue.singleton<Nat>(0), Queue.singleton<Nat>(1), Nat.compare) == #less,
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        Queue.compare(Queue.singleton<Nat>(1), Queue.singleton<Nat>(1), Nat.compare) == #equal,
        M.equals(T.bool(true))
      ),
      test(
        "compare greater",
        Queue.compare(Queue.singleton<Nat>(2), Queue.singleton<Nat>(1), Nat.compare) == #greater,
        M.equals(T.bool(true))
      ),
      test(
        "to text",
        Queue.toText(Queue.singleton<Nat>(123), Nat.toText),
        M.equals(T.text("Queue[123]"))
      )
    ]
  )
);

run(
  suite(
    "push operations",
    [
      test(
        "push front",
        do {
          let queue = Queue.empty<Nat>();
          Queue.pushFront(queue, 1);
          Queue.pushFront(queue, 2);
          Queue.pushFront(queue, 3);
          Iter.toArray(Queue.values(queue))
        },
        M.equals(T.array(T.natTestable, [3, 2, 1]))
      ),
      test(
        "push back",
        do {
          let queue = Queue.empty<Nat>();
          Queue.pushBack(queue, 1);
          Queue.pushBack(queue, 2);
          Queue.pushBack(queue, 3);
          Iter.toArray(Queue.values(queue))
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "mixed push",
        do {
          let queue = Queue.empty<Nat>();
          Queue.pushFront(queue, 2);
          Queue.pushBack(queue, 3);
          Queue.pushFront(queue, 1);
          Iter.toArray(Queue.values(queue))
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      )
    ]
  )
);

run(
  suite(
    "pop operations",
    [
      test(
        "pop front",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
          let results = [
            Queue.popFront(queue),
            Queue.popFront(queue),
            Queue.popFront(queue),
            Queue.popFront(queue)
          ];
          assert (Queue.isEmpty(queue));
          assert (results == [?1, ?2, ?3, null]);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "pop back",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
          let results = [
            Queue.popBack(queue),
            Queue.popBack(queue),
            Queue.popBack(queue),
            Queue.popBack(queue)
          ];
          assert (Queue.isEmpty(queue));
          assert (results == [?3, ?2, ?1, null]);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "mixed pop",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3, 4].vals());
          let results = [
            Queue.popFront(queue),
            Queue.popBack(queue),
            Queue.popFront(queue),
            Queue.popBack(queue),
            Queue.popFront(queue)
          ];
          assert (Queue.isEmpty(queue));
          assert (results == [?1, ?4, ?2, ?3, null]);
          true
        },
        M.equals(T.bool(true))
      )
    ]
  )
);

run(
  suite(
    "transformations",
    [
      test(
        "map",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
          let mapped = Queue.map<Nat, Text>(queue, Nat.toText);
          Iter.toArray(Queue.values(mapped))
        },
        M.equals(T.array(T.textTestable, ["1", "2", "3"]))
      ),
      test(
        "filter",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3, 4].vals());
          let filtered = Queue.filter<Nat>(queue, func n = n % 2 == 0);
          Iter.toArray(Queue.values(filtered))
        },
        M.equals(T.array(T.natTestable, [2, 4]))
      ),
      test(
        "filter map",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3, 4].vals());
          let result = Queue.filterMap<Nat, Text>(
            queue,
            func n = if (n % 2 == 0) ?Nat.toText(n) else null
          );
          Iter.toArray(Queue.values(result))
        },
        M.equals(T.array(T.textTestable, ["2", "4"]))
      ),
      test(
        "for each",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
          var sum = 0;
          Queue.forEach<Nat>(queue, func n { sum += n });
          sum
        },
        M.equals(T.nat(6))
      )
    ]
  )
);

run(
  suite(
    "queries",
    [
      test(
        "all true",
        do {
          let queue = Queue.fromIter<Nat>([2, 4, 6].vals());
          Queue.all<Nat>(queue, func n = n % 2 == 0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "all false",
        do {
          let queue = Queue.fromIter<Nat>([2, 3, 4].vals());
          Queue.all<Nat>(queue, func n = n % 2 == 0)
        },
        M.equals(T.bool(false))
      ),
      test(
        "any true",
        do {
          let queue = Queue.fromIter<Nat>([1, 2, 3].vals());
          Queue.any<Nat>(queue, func n = n % 2 == 0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "any false",
        do {
          let queue = Queue.fromIter<Nat>([1, 3, 5].vals());
          Queue.any<Nat>(queue, func n = n % 2 == 0)
        },
        M.equals(T.bool(false))
      )
    ]
  )
);

// TODO: Use PRNG in new base library
class Random(seed : Nat) {
  var number = seed;

  public func reset() {
    number := seed
  };

  public func next() : Nat {
    number := (123138118391 * number + 133489131) % 9999;
    number
  }
};

let randomSeed = 4711;
let numberOfSteps = 10_000;

run(
  suite(
    "large queue",
    [
      test(
        "randomized FIFO",
        do {
          let queue = Queue.empty<Nat>();
          var nextInsert = 0;
          var nextRemove = 0;
          let random = Random(randomSeed);
          for (_ in Nat.range(0, numberOfSteps)) {
            if (random.next() % 2 == 0) {
              Queue.pushBack(queue, nextInsert);
              nextInsert += 1
            } else {
              assert (Queue.size(queue) == (nextInsert - nextRemove : Nat));
              switch (Queue.popFront(queue)) {
                case null {
                  assert (nextInsert == nextRemove)
                };
                case (?number) {
                  assert (number == nextRemove);
                  nextRemove += 1
                }
              }
            }
          };
          while (nextRemove < nextInsert) {
            switch (Queue.popFront(queue)) {
              case null Runtime.trap("Should not be empty");
              case (?number) {
                assert (number == nextRemove);
                nextRemove += 1
              }
            }
          };
          switch (Queue.popFront(queue)) {
            case null {
              assert (Queue.isEmpty(queue));
              assert (nextInsert == nextRemove)
            };
            case (?_) Runtime.trap("Should be empty")
          };
          Queue.size(queue)
        },
        M.equals(T.nat(0))
      ),
      test(
        "repeated grow shrink",
        do {
          let queue = Queue.empty<Nat>();
          for (_ in Nat.range(0, 2)) {
            for (number in Nat.range(0, numberOfSteps)) {
              Queue.pushBack(queue, number)
            };
            for (number in Nat.range(0, numberOfSteps)) {
              assert (Queue.popFront(queue) == ?number)
            };
            assert (Queue.isEmpty(queue))
          };
          Queue.size(queue)
        },
        M.equals(T.nat(0))
      ),
      test(
        "iterate",
        do {
          let queue = Queue.empty<Nat>();
          for (number in Nat.range(0, numberOfSteps)) {
            Queue.pushBack(queue, number)
          };
          var counter = 0;
          for (number in Queue.values(queue)) {
            assert (number == counter);
            counter += 1
          };
          assert (counter == numberOfSteps);
          for (number in Nat.range(0, numberOfSteps / 2)) {
            assert (Queue.popFront(queue) == ?number)
          };
          counter := numberOfSteps / 2;
          for (number in Queue.values(queue)) {
            assert (number == counter);
            counter += 1
          };
          assert (counter == numberOfSteps);
          Queue.size(queue)
        },
        M.equals(T.nat((numberOfSteps + 1) / 2))
      )
    ]
  )
)
