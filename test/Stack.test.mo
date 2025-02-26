import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Stack "../src/Stack";
import Iter "../src/Iter";
import Nat "../src/Nat";
import PureList "../src/pure/List";

let { run; test; suite } = Suite;

run(
  suite(
    "empty",
    [
      test(
        "new stack is empty",
        Stack.isEmpty(Stack.empty<Nat>()),
        M.equals(T.bool(true))
      ),
      test(
        "new stack has size 0",
        Stack.size(Stack.empty<Nat>()),
        M.equals(T.nat(0))
      ),
      test(
        "peek empty returns null",
        Stack.peek(Stack.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      ),
      test(
        "pop empty returns null",
        Stack.pop(Stack.empty<Nat>()),
        M.equals(T.optional(T.natTestable, null : ?Nat))
      )
    ]
  )
);

run(
  suite(
    "singleton",
    [
      test(
        "creates stack with one element",
        do {
          let s = Stack.singleton<Nat>(123);
          Stack.size(s) == 1 and Stack.peek(s) == ?123
        },
        M.equals(T.bool(true))
      )
    ]
  )
);

run(
  suite(
    "push/pop operations",
    [
      test(
        "push increases size",
        do {
          let s = Stack.empty<Nat>();
          Stack.push(s, 1);
          Stack.size(s)
        },
        M.equals(T.nat(1))
      ),
      test(
        "push/pop maintains LIFO order",
        do {
          let s = Stack.empty<Nat>();
          Stack.push(s, 1);
          Stack.push(s, 2);
          Stack.push(s, 3);
          assert ([Stack.pop(s), Stack.pop(s), Stack.pop(s)] == [?3, ?2, ?1]);
          Stack.size(s)
        },
        M.equals(T.int(0))
      ),
      test(
        "peek doesn't remove element",
        do {
          let s = Stack.empty<Nat>();
          Stack.push(s, 42);
          let p1 = Stack.peek(s);
          let p2 = Stack.peek(s);
          p1 == p2 and p1 == ?42 and Stack.size(s) == 1
        },
        M.equals(T.bool(true))
      )
    ]
  )
);

run(
  suite(
    "clear and clone",
    [
      test(
        "clear empties stack",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.clear(s);
          Stack.isEmpty(s)
        },
        M.equals(T.bool(true))
      ),
      test(
        "clone creates independent copy",
        do {
          let original = Stack.fromIter<Nat>([1, 2, 3].values());
          let copy = Stack.clone(original);
          ignore Stack.pop(original);
          Stack.size(copy) == 3 and Stack.peek(copy) == ?3
        },
        M.equals(T.bool(true))
      )
    ]
  )
);

run(
  suite(
    "iteration and search",
    [
      test(
        "contains finds element",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.contains(s, 2, Nat.equal)
        },
        M.equals(T.bool(true))
      ),
      test(
        "get retrieves correct element",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.get(s, 1) == ?2
        },
        M.equals(T.bool(true))
      ),
      test(
        "values iterates in LIFO order",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          Iter.toArray(Stack.values(s))
        },
        M.equals(T.array(T.natTestable, [3, 2, 1]))
      )
    ]
  )
);

run(
  suite(
    "transformations",
    [
      test(
        "reverse changes order",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.reverse(s);
          Iter.toArray(Stack.values(s))
        },
        M.equals(T.array(T.natTestable, [1, 2, 3]))
      ),
      test(
        "map transforms elements",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          let mapped = Stack.map<Nat, Text>(s, func(x) { Nat.toText(x) });
          Iter.toArray(Stack.values(mapped))
        },
        M.equals(T.array(T.textTestable, ["3", "2", "1"]))
      ),
      test(
        "filter keeps matching elements",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3, 4].values());
          let evens = Stack.filter<Nat>(s, func(x) { x % 2 == 0 });
          Iter.toArray(Stack.values(evens))
        },
        M.equals(T.array(T.natTestable, [4, 2]))
      ),
      test(
        "filterMap combines map and filter",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3, 4].values());
          let evenDoubled = Stack.filterMap<Nat, Nat>(
            s,
            func(x) {
              if (x % 2 == 0) { ?(x * 2) } else { null }
            }
          );
          Iter.toArray(Stack.values(evenDoubled))
        },
        M.equals(T.array(T.natTestable, [8, 4]))
      )
    ]
  )
);

run(
  suite(
    "queries",
    [
      test(
        "all true when all match",
        do {
          let s = Stack.fromIter<Nat>([2, 4, 6].values());
          Stack.all<Nat>(s, func(x) { x % 2 == 0 })
        },
        M.equals(T.bool(true))
      ),
      test(
        "all false when any doesn't match",
        do {
          let s = Stack.fromIter<Nat>([2, 3, 4].values());
          Stack.all<Nat>(s, func(x) { x % 2 == 0 })
        },
        M.equals(T.bool(false))
      ),
      test(
        "any true when one matches",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.any<Nat>(s, func(x) { x % 2 == 0 })
        },
        M.equals(T.bool(true))
      ),
      test(
        "any false when none match",
        do {
          let s = Stack.fromIter<Nat>([1, 3, 5].values());
          Stack.any<Nat>(s, func(x) { x % 2 == 0 })
        },
        M.equals(T.bool(false))
      )
    ]
  )
);

run(
  suite(
    "comparison",
    [
      test(
        "equal returns true for identical stacks",
        do {
          let s1 = Stack.fromIter<Nat>([1, 2, 3].values());
          let s2 = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.equal(s1, s2, Nat.equal)
        },
        M.equals(T.bool(true))
      ),
      test(
        "equal returns false for different stacks",
        do {
          let s1 = Stack.fromIter<Nat>([1, 2, 3].values());
          let s2 = Stack.fromIter<Nat>([1, 2, 4].values());
          Stack.equal(s1, s2, Nat.equal)
        },
        M.equals(T.bool(false))
      ),
      test(
        "compare orders correctly",
        do {
          let s1 = Stack.fromIter<Nat>([1, 2].values());
          let s2 = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.compare(s1, s2, Nat.compare) == #less
        },
        M.equals(T.bool(true))
      )
    ]
  )
);

run(
  suite(
    "text representation",
    [
      test(
        "toText formats correctly",
        do {
          let s = Stack.fromIter<Nat>([1, 2, 3].values());
          Stack.toText(s, Nat.toText)
        },
        M.equals(T.text("[3, 2, 1]"))
      )
    ]
  )
);

// TODO: Replace by PRNG in `Random`.
class Random(seed : Nat) {
  var current = seed;

  public func next() : Nat {
    current := (123138118391 * current + 133489131) % 9999;
    current
  };

  public func reset() {
    current := seed
  }
};

let randomSeed = 4711;
let largeSize = 1_000;

run(
  suite(
    "large scale operations",
    [
      test(
        "many push/pop operations",
        do {
          let s = Stack.empty<Nat>();
          let random = Random(randomSeed);
          var expectedSum = 0;
          var actualSum = 0;
          for (i in Nat.range(0, largeSize)) {
            let value = random.next();
            Stack.push(s, value);
            expectedSum += value
          };
          assert (Stack.size(s) == largeSize);
          while (not Stack.isEmpty(s)) {
            switch (Stack.pop(s)) {
              case (?value) { actualSum += value };
              case null { assert false }; // Should never happen
            }
          };
          Stack.isEmpty(s) and expectedSum == actualSum
        },
        M.equals(T.bool(true))
      ),
      test(
        "alternating push/pop operations",
        do {
          let s = Stack.empty<Nat>();
          let random = Random(randomSeed);
          var count = 0;
          for (i in Nat.range(0, largeSize)) {
            if (random.next() % 2 == 0) {
              Stack.push(s, i);
              count += 1
            } else {
              switch (Stack.pop(s)) {
                case (?_) { count -= 1 };
                case null {}; // Stack can be empty
              }
            };
            assert (Stack.size(s) == count)
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "large scale transformations",
        do {
          let original = Stack.tabulate<Nat>(largeSize, func(i) { i });
          let doubled = Stack.map<Nat, Nat>(original, func(x) { x * 2 });
          let filtered = Stack.filter<Nat>(doubled, func(x) { x % 4 == 0 });
          let mapped = Stack.filterMap<Nat, Nat>(
            filtered,
            func(x) {
              if (x % 8 == 0) ?x else null
            }
          );
          assert (Stack.size(original) == largeSize);
          assert (Stack.size(doubled) == largeSize);
          assert (Stack.size(filtered) == largeSize / 2);
          assert (Stack.size(mapped) == largeSize / 4);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "large scale iteration",
        do {
          let s = Stack.tabulate<Nat>(largeSize, func(i) = i);
          var sum = 0;
          var count = 0;
          for (value in Stack.values(s)) {
            sum += value;
            count += 1
          };
          assert (count == largeSize);
          let expectedSum = (largeSize - 1 : Nat) * largeSize / 2;
          sum == expectedSum
        },
        M.equals(T.bool(true))
      ),
      test(
        "large scale clone and compare",
        do {
          let original = Stack.tabulate<Nat>(largeSize, func(i) = i);
          let clone = Stack.clone(original);
          assert (Stack.equal(original, clone, Nat.equal));
          Stack.push(original, largeSize);
          assert (not Stack.equal(original, clone, Nat.equal));
          assert (Stack.compare(clone, original, Nat.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      )
    ]
  )
);

run(
  suite(
    "stack conversion",
    [
      test(
        "toPure",
        do {
          let stack = Stack.empty<Nat>();
          for (index in Nat.range(0, largeSize)) {
            Stack.push(stack, index)
          };
          let pureList = Stack.toPure(stack);
          var index = largeSize;
          for (element in PureList.values(pureList)) {
            index -= 1;
            assert (element == index)
          };
          PureList.size(pureList)
        },
        M.equals(T.nat(largeSize))
      ),
      test(
        "fromPure",
        do {
          var pureList = PureList.empty<Nat>();
          for (index in Nat.range(0, largeSize)) {
            pureList := PureList.push(pureList, index)
          };
          let stack = Stack.fromPure<Nat>(pureList);
          var index = largeSize;
          for (element in PureList.values(pureList)) {
            index -= 1;
            assert (element == index)
          };
          Stack.size(stack)
        },
        M.equals(T.nat(largeSize))
      )
    ]
  )
)
