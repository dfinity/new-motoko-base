import Iter "../src/Iter";
import Array "../src/Array";
import Nat "../src/Nat";
import Int "../src/Int";
import { suite; test; expect } "mo:test";
import Runtime "../src/Runtime";
import Tuple "../src/Tuple";

suite(
  "forEach",
  func() {
    test(
      "iterates over elements with index",
      func() {
        let xs = ["a", "b", "c", "d", "e", "f"];
        var y = "";
        var z = 0;

        Iter.forEach<(Nat, Text)>(
          Iter.enumerate(xs.vals()),
          func(i, x) {
            y := y # x;
            z += i
          }
        );

        expect.text(y).equal("abcdef");
        expect.nat(z).equal(15)
      }
    )
  }
);

suite(
  "map",
  func() {
    test(
      "maps elements using provided function",
      func() {
        let isEven = func(x : Int) : Bool { x % 2 == 0 };
        let _actual = Iter.map<Nat, Bool>([1, 2, 3].vals(), isEven);
        let actual = [var true, false, true];
        Iter.forEach<(Nat, Bool)>(
          Iter.enumerate(_actual),
          func(i, x) { actual[i] := x }
        );

        let expected = [false, true, false];
        for (i in actual.keys()) {
          expect.bool(actual[i]).equal(expected[i])
        }
      }
    )
  }
);

suite(
  "filter",
  func() {
    test(
      "filters elements using predicate",
      func() {
        let isOdd = func(x : Int) : Bool { x % 2 == 1 };
        let _actual = Iter.filter<Nat>([1, 2, 3].vals(), isOdd);
        let actual = [var 0, 0];
        Iter.forEach<(Nat, Nat)>(
          Iter.enumerate(_actual),
          func(i, x) { actual[i] := x }
        );
        expect.array<Nat>(Array.fromVarArray(actual), Nat.toText, Nat.equal).equal([1, 3])
      }
    )
  }
);

suite(
  "filterMap",
  func() {
    func mk(inputs : [Nat], expected : [Nat]) {
      let actual = Iter.filterMap<Nat, Nat>(inputs.vals(), func(x) = if (x % 2 == 0) ?(x * 10) else null);
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("some", func() = mk([1, 2, 3, 4], [20, 40]));
    test("none", func() = mk([1, 3, 5, 7], []));
    test("empty", func() = mk([], []))
  }
);

suite(
  "flatten",
  func() {
    func mk(inputs : [[Nat]], expected : [Nat]) {
      let actual = Iter.flatten(Iter.map<[Nat], Iter.Iter<Nat>>(inputs.vals(), func(x) = Iter.fromArray<Nat>(x)));
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("some", func() = mk([[1, 2], [3], [4, 5, 6]], [1, 2, 3, 4, 5, 6]));
    test("none", func() = mk([[], []], []));
    test("empty", func() = mk([], []))
  }
);

suite(
  "flatMap",
  func() {
    func mk(inputs : [Nat], expected : [Nat]) {
      let actual = Iter.flatMap<Nat, Nat>(inputs.vals(), func(x) = [x, x * 10].vals());
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("some", func() = mk([1, 2, 3], [1, 10, 2, 20, 3, 30]));
    test("none", func() = mk([], []))
  }
);

suite(
  "take",
  func() {
    func mk(inputs : [Nat], n : Nat, expected : [Nat]) {
      let actual = Iter.take<Nat>(inputs.vals(), n);
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("some", func() = mk([1, 2, 3, 4, 5], 3, [1, 2, 3]));
    test("zero", func() = mk([1, 2, 3], 0, []));
    test("more", func() = mk([1, 2, 3], 5, [1, 2, 3]));
    test("empty", func() = mk([], 3, []));
    test("exact", func() = mk([1, 2, 3], 3, [1, 2, 3]))
  }
);

suite(
  "drop",
  func() {
    func mk(inputs : [Nat], n : Nat, expected : [Nat]) {
      let actual = Iter.drop<Nat>(inputs.vals(), n);
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("some", func() = mk([1, 2, 3, 4, 5], 3, [4, 5]));
    test("zero", func() = mk([1, 2, 3], 0, [1, 2, 3]));
    test("more", func() = mk([1, 2, 3], 5, []));
    test("empty", func() = mk([], 3, []));
    test("exact", func() = mk([1, 2, 3], 3, []))
  }
);

suite(
  "takeWhile",
  func() {
    func mk(inputs : [Nat], expected : [Nat]) {
      let actual = Iter.takeWhile<Nat>(inputs.vals(), func(x) = x < 4);
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("some", func() = mk([1, 2, 3, 4, 5, 4, 3, 2, 1], [1, 2, 3]));
    test("none", func() = mk([4, 5, 6], []));
    test("empty", func() = mk([], []));
    test("all", func() = mk([1, 2, 3], [1, 2, 3]))
  }
);

suite(
  "dropWhile",
  func() {
    func mk(inputs : [Nat], expected : [Nat]) {
      let actual = Iter.dropWhile<Nat>(inputs.vals(), func(x) = x < 4);
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("some", func() = mk([1, 2, 3, 4, 5, 4, 3, 2, 1], [4, 5, 4, 3, 2, 1]));
    test("all", func() = mk([4, 5, 6], [4, 5, 6]));
    test("empty", func() = mk([], []));
    test("none", func() = mk([1, 2, 3], []))
  }
);

suite(
  "zip",
  func() {
    func mk(input1 : [Nat], input2 : [Nat], expected : [(Nat, Nat)]) {
      let actual = Iter.zip<Nat, Nat>(input1.vals(), input2.vals());
      expect.array<(Nat, Nat)>(Iter.toArray(actual), Tuple.makeToText<Nat, Nat>(Nat.toText, Nat.toText), Tuple.makeEqual<Nat, Nat>(Nat.equal, Nat.equal)).equal(expected)
    };
    test("matched", func() = mk([1, 2, 3], [4, 5, 6], [(1, 4), (2, 5), (3, 6)]));
    test("left skipped", func() = mk([1, 2, 3], [4, 5], [(1, 4), (2, 5)]));
    test("right skipped", func() = mk([1, 2], [4, 5, 6], [(1, 4), (2, 5)]));
    test("empty left", func() = mk([], [1, 2], []));
    test("empty right", func() = mk([1, 2], [], []));
    test("empty both", func() = mk([], [], []))
  }
);

suite(
  "zipWith",
  func() {
    func mk(input1 : [Nat], input2 : [Nat], expected : [Nat]) {
      let actual = Iter.zipWith<Nat, Nat, Nat>(input1.vals(), input2.vals(), func(x, y) = x + y);
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("matched", func() = mk([1, 2, 3], [4, 5, 6], [5, 7, 9]));
    test("left skipped", func() = mk([1, 2, 3], [4, 5], [5, 7]));
    test("right skipped", func() = mk([1, 2], [4, 5, 6], [5, 7]));
    test("empty left", func() = mk([], [1, 2], []));
    test("empty right", func() = mk([1, 2], [], []));
    test("empty both", func() = mk([], [], []))
  }
);

suite(
  "zip3",
  func() {
    func mk(input1 : [Nat], input2 : [Nat], input3 : [Nat], expected : [(Nat, Nat, Nat)]) {
      let actual = Iter.zip3<Nat, Nat, Nat>(input1.vals(), input2.vals(), input3.vals());
      expect.array<(Nat, Nat, Nat)>(Iter.toArray(actual), Tuple.makeToText3<Nat, Nat, Nat>(Nat.toText, Nat.toText, Nat.toText), Tuple.makeEqual3<Nat, Nat, Nat>(Nat.equal, Nat.equal, Nat.equal)).equal(expected)
    };
    test("matched", func() = mk([1, 2, 3], [4, 5, 6], [7, 8, 9], [(1, 4, 7), (2, 5, 8), (3, 6, 9)]));
    test("left skipped", func() = mk([1, 2, 3], [4, 5], [7, 8, 9], [(1, 4, 7), (2, 5, 8)]));
    test("right skipped", func() = mk([1, 2], [4, 5, 6], [7, 8, 9], [(1, 4, 7), (2, 5, 8)]));
    test("empty left", func() = mk([], [1, 2], [7, 8, 9], []));
    test("empty middle", func() = mk([1, 2], [], [7, 8, 9], []));
    test("empty right", func() = mk([1, 2], [4, 5, 6], [], []));
    test("empty all", func() = mk([], [], [], []))
  }
);

suite(
  "zipWith3",
  func() {
    func mk(input1 : [Nat], input2 : [Nat], input3 : [Nat], expected : [Nat]) {
      let actual = Iter.zipWith3<Nat, Nat, Nat, Nat>(input1.vals(), input2.vals(), input3.vals(), func(x, y, z) = x + y + z);
      expect.array<Nat>(Iter.toArray(actual), Nat.toText, Nat.equal).equal(expected)
    };
    test("matched", func() = mk([1, 2, 3], [4, 5, 6], [7, 8, 9], [12, 15, 18]));
    test("left skipped", func() = mk([1, 2, 3], [4, 5], [7, 8, 9], [12, 15]));
    test("right skipped", func() = mk([1, 2], [4, 5, 6], [7, 8, 9], [12, 15]));
    test("empty left", func() = mk([], [1, 2], [7, 8, 9], []));
    test("empty middle", func() = mk([1, 2], [], [7, 8, 9], []));
    test("empty right", func() = mk([1, 2], [4, 5, 6], [], []));
    test("empty all", func() = mk([], [], [], []))
  }
);

suite(
  "singleton",
  func() {
    test(
      "creates iterator with single element",
      func() {
        let x = 1;
        let y = Iter.singleton<Nat>(x);
        assert (y.next() == ?x);
        assert (y.next() == null)
      }
    )
  }
);

suite(
  "infinite",
  func() {
    test(
      "creates infinite iterator of same element",
      func() {
        let x = 1;
        let y = Iter.infinite<Nat>(x);
        for (_ in Nat.range(0, 10000)) {
          assert (y.next() == ?x)
        }
      }
    )
  }
);

suite(
  "fromArray",
  func() {
    test(
      "creates iterator from array",
      func() {
        let expected = [1, 2, 3];
        let _actual = Iter.fromArray<Nat>(expected);
        let actual = [var 0, 0, 0];

        Iter.forEach<(Nat, Nat)>(
          Iter.enumerate(_actual),
          func(i, x) { actual[i] := x }
        );

        for (i in actual.keys()) {
          expect.nat(actual[i]).equal(expected[i])
        }
      }
    )
  }
);

suite(
  "fromVarArray",
  func() {
    test(
      "creates iterator from var array",
      func() {
        let expected = [var 1, 2, 3];
        let _actual = Iter.fromVarArray<Nat>(expected);
        let actual = [var 0, 0, 0];

        Iter.forEach<(Nat, Nat)>(
          Iter.enumerate(_actual),
          func(i, x) { actual[i] := x }
        );

        for (i in actual.keys()) {
          expect.nat(actual[i]).equal(expected[i])
        }
      }
    )
  }
);

suite(
  "toArray",
  func() {
    test(
      "converts iterator to array",
      func() {
        let expected = [1, 2, 3];
        let actual = Iter.toArray<Nat>(expected.vals());
        expect.nat(actual.size()).equal(expected.size());
        for (i in actual.keys()) {
          expect.nat(actual[i]).equal(expected[i])
        }
      }
    )
  }
);

suite(
  "toVarArray",
  func() {
    test(
      "converts iterator to var array",
      func() {
        let expected = [var 1, 2, 3];
        let actual = Iter.toVarArray<Nat>(expected.vals());
        expect.nat(actual.size()).equal(expected.size());
        for (i in actual.keys()) {
          expect.nat(actual[i]).equal(expected[i])
        }
      }
    )
  }
);

suite(
  "sort",
  func() {
    test(
      "sorts elements using comparison function",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];
        let expected : [Nat] = [1, 2, 3, 4, 5];
        let actual = Iter.toArray(Iter.sort<Nat>(input.vals(), Nat.compare));
        expect.array<Nat>(actual, Nat.toText, Nat.equal).equal(expected)
      }
    )
  }
);

suite(
  "Array range",
  func() {
    test(
      "empty range returns null",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];
        let sEmpty = Array.range(input, 0, 0);
        assert (sEmpty.next() == null)
      }
    );

    test(
      "prefix range returns first element",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];
        let sPrefix = Array.range(input, 0, 1);
        assert (sPrefix.next() == ?4);
        assert (sPrefix.next() == null)
      }
    );

    test(
      "suffix range returns last element",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];
        let sSuffix = Array.range(input, 4, 5);
        assert (sSuffix.next() == ?5);
        assert (sSuffix.next() == null)
      }
    );

    test(
      "infix range returns middle element",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];
        let sInfix = Array.range(input, 3, 4);
        assert (sInfix.next() == ?2);
        assert (sInfix.next() == null)
      }
    );

    test(
      "full range returns all elements",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];
        let sFull = Array.range(input, 0, input.size());
        assert (sFull.next() == ?4);
        assert (sFull.next() == ?3);
        assert (sFull.next() == ?1);
        assert (sFull.next() == ?2);
        assert (sFull.next() == ?5);
        assert (sFull.next() == null)
      }
    );

    test(
      "negative indices are handled correctly",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];

        let sNegStart = Array.range(input, -2, 5);
        assert (sNegStart.next() == ?2);
        assert (sNegStart.next() == ?5);
        assert (sNegStart.next() == null);

        let sNegEnd = Array.range(input, 0, -2);
        assert (sNegEnd.next() == ?4);
        assert (sNegEnd.next() == ?3);
        assert (sNegEnd.next() == ?1);
        assert (sNegEnd.next() == null);

        let sNegBoth = Array.range(input, -3, -1);
        assert (sNegBoth.next() == ?1);
        assert (sNegBoth.next() == ?2);
        assert (sNegBoth.next() == null)
      }
    );

    test(
      "out-of-bounds indices are clamped",
      func() {
        let input : [Nat] = [4, 3, 1, 2, 5];

        let sOobStart = Array.range(input, -10, 2);
        assert (sOobStart.next() == ?4);
        assert (sOobStart.next() == ?3);
        assert (sOobStart.next() == null);

        let sOobEnd = Array.range(input, 3, 10);
        assert (sOobEnd.next() == ?2);
        assert (sOobEnd.next() == ?5);
        assert (sOobEnd.next() == null)
      }
    )
  }
);

suite(
  "repeat",
  func() {
    test(
      "repeats element specified number of times",
      func() {
        let iter1 = Iter.repeat<Char>('a', 3);
        assert (iter1.next() == ?'a');
        assert (iter1.next() == ?'a');
        assert (iter1.next() == ?'a');
        assert (iter1.next() == null)
      }
    );

    test(
      "zero count returns empty iterator",
      func() {
        let iter2 = Iter.repeat<Nat>(1, 0);
        assert (iter2.next() == null)
      }
    );

    test(
      "count of one returns singleton iterator",
      func() {
        let iter3 = Iter.repeat<Bool>(true, 1);
        assert (iter3.next() == ?true);
        assert (iter3.next() == null)
      }
    )
  }
);

suite(
  "reverse",
  func() {
    test(
      "reverses elements in iterator",
      func() {
        let array1 = [1, 2, 3, 4];
        let iter1 = Iter.reverse(array1.vals());
        assert (iter1.next() == ?4);
        assert (iter1.next() == ?3);
        assert (iter1.next() == ?2);
        assert (iter1.next() == ?1);
        assert (iter1.next() == null)
      }
    );

    test(
      "empty array remains empty",
      func() {
        let array2 = ([] : [Nat]);
        let iter2 = Iter.reverse(array2.vals());
        assert (iter2.next() == null)
      }
    );

    test(
      "single element array remains unchanged",
      func() {
        let array3 = ['a'];
        let iter3 = Iter.reverse(array3.vals());
        assert (iter3.next() == ?'a');
        assert (iter3.next() == null)
      }
    )
  }
);

suite(
  "empty",
  func() {
    test(
      "returns empty iterator",
      func() {
        let emptyIter = Iter.empty<Nat>();
        assert (emptyIter.next() == null)
      }
    )
  }
);

suite(
  "size",
  func() {
    test(
      "returns correct size for various iterators",
      func() {
        expect.nat(Iter.size(Iter.empty<Nat>())).equal(0);
        expect.nat(Iter.size([1, 2, 3].vals())).equal(3);

        let boundedIter = object {
          var count = 0;
          public func next() : ?Nat {
            if (count >= 5) { null } else {
              count += 1;
              ?1
            }
          }
        };
        expect.nat(Iter.size(boundedIter)).equal(5)
      }
    )
  }
);

suite(
  "enumerate",
  func() {
    test(
      "empty iterator returns null",
      func() {
        let emptyEnum = Iter.enumerate(Iter.empty<Text>());
        assert (emptyEnum.next() == null)
      }
    );

    test(
      "single element returns tuple with index 0",
      func() {
        let singleEnum = Iter.enumerate(["a"].vals());
        assert (singleEnum.next() == ?(0, "a"));
        assert (singleEnum.next() == null)
      }
    );

    test(
      "multiple elements return tuples with increasing indices",
      func() {
        let multiEnum = Iter.enumerate([10, 20, 30].vals());
        assert (multiEnum.next() == ?(0, 10));
        assert (multiEnum.next() == ?(1, 20));
        assert (multiEnum.next() == ?(2, 30));
        assert (multiEnum.next() == null)
      }
    )
  }
);

suite(
  "step",
  func() {
    test(
      "step of zero returns empty iterator",
      func() {
        let step0 = Iter.step([1, 2, 3, 4, 5].vals(), 0);
        assert (step0.next() == null)
      }
    );

    test(
      "step of one returns all elements",
      func() {
        let step1 = Iter.step([1, 2, 3].vals(), 1);
        assert (step1.next() == ?1);
        assert (step1.next() == ?2);
        assert (step1.next() == ?3);
        assert (step1.next() == null)
      }
    );

    test(
      "step of two returns every other element",
      func() {
        let step2 = Iter.step([1, 2, 3, 4, 5].vals(), 2);
        assert (step2.next() == ?1);
        assert (step2.next() == ?3);
        assert (step2.next() == ?5);
        assert (step2.next() == null)
      }
    );

    test(
      "step larger than size returns first element only",
      func() {
        let stepBig = Iter.step([1, 2, 3].vals(), 4);
        assert (stepBig.next() == ?1);
        assert (stepBig.next() == null)
      }
    )
  }
);

suite(
  "concat",
  func() {
    test(
      "empty iterators return empty iterator",
      func() {
        let emptyConcat = Iter.concat(Iter.empty(), Iter.empty());
        assert (emptyConcat.next() == null)
      }
    );

    test(
      "left empty returns right iterator",
      func() {
        let leftEmpty = Iter.concat(Iter.empty<Nat>(), [1, 2].vals());
        assert (leftEmpty.next() == ?1);
        assert (leftEmpty.next() == ?2);
        assert (leftEmpty.next() == null)
      }
    );

    test(
      "right empty returns left iterator",
      func() {
        let rightEmpty = Iter.concat([1, 2].vals(), Iter.empty());
        assert (rightEmpty.next() == ?1);
        assert (rightEmpty.next() == ?2);
        assert (rightEmpty.next() == null)
      }
    );

    test(
      "concatenates two non-empty iterators",
      func() {
        let fullConcat = Iter.concat([1, 2].vals(), [3, 4].vals());
        assert (fullConcat.next() == ?1);
        assert (fullConcat.next() == ?2);
        assert (fullConcat.next() == ?3);
        assert (fullConcat.next() == ?4);
        assert (fullConcat.next() == null)
      }
    )
  }
);

suite(
  "all",
  func() {
    test(
      "empty iterator returns true",
      func() = expect.bool(Iter.all<Nat>(Iter.empty<Nat>(), func(x) = Runtime.unreachable())).isTrue()
    );
    test(
      "all elements satisfy predicate",
      func() = expect.bool(Iter.all<Nat>([2, 4, 6].vals(), func(x) = x % 2 == 0)).isTrue()
    );
    test(
      "not all elements satisfy predicate",
      func() = expect.bool(Iter.all<Nat>([2, 4, 5].vals(), func(x) = x % 2 == 0)).isFalse()
    )
  }
);

suite(
  "any",
  func() {
    test(
      "empty iterator returns false",
      func() = expect.bool(Iter.any<Nat>(Iter.empty<Nat>(), func(x) = Runtime.unreachable())).isFalse()
    );
    test(
      "some elements satisfy predicate",
      func() = expect.bool(Iter.any<Nat>([2, 4, 5].vals(), func(x) = x % 2 == 0)).isTrue()
    );
    test(
      "no elements satisfy predicate",
      func() = expect.bool(Iter.any<Nat>([1, 3, 5].vals(), func(x) = x % 2 == 0)).isFalse()
    )
  }
);

suite(
  "find",
  func() {
    test(
      "empty iterator returns null",
      func() {
        let emptyFind = Iter.find<Nat>(Iter.empty<Nat>(), func(x) = Runtime.unreachable());
        expect.option(emptyFind, Nat.toText, Nat.equal).equal(null)
      }
    );
    test(
      "element satisfying predicate is found",
      func() {
        let found = Iter.find<Nat>([1, 2, 3, 4].vals(), func(x) = x % 2 == 0);
        expect.option(found, Nat.toText, Nat.equal).equal(?2)
      }
    );
    test(
      "no element satisfies predicate",
      func() {
        let notFound = Iter.find<Nat>([1, 3, 5].vals(), func(x) = x % 2 == 0);
        expect.option(notFound, Nat.toText, Nat.equal).equal(null)
      }
    )
  }
);

suite(
  "contains",
  func() {
    test(
      "empty iterator returns false",
      func() = expect.bool(Iter.contains<Nat>(Iter.empty<Nat>(), Nat.equal, 42)).isFalse()
    );
    test(
      "element is found",
      func() = expect.bool(Iter.contains<Nat>([1, 2, 3].vals(), Nat.equal, 2)).isTrue()
    );
    test(
      "element is not found",
      func() = expect.bool(Iter.contains<Nat>([1, 2, 3].vals(), Nat.equal, 4)).isFalse()
    )
  }
)
