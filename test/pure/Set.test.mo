// @testmode wasi

import Set "../../src/pure/Set";
import Array "../../src/Array";
import Nat "../../src/Nat";
import Iter "../../src/Iter";
import Debug "../../src/Debug";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let entryTestable = T.natTestable;

class SetMatcher(expected : [Nat]) : M.Matcher<Set.Set<Nat>> {
  public func describeMismatch(actual : Set.Set<Nat>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(Set.values(actual))) # " should be " # debug_show (expected))
  };

  public func matches(actual : Set.Set<Nat>) : Bool {
    Iter.toArray(Set.values(actual)) == expected
  }
};

func insert(s : Set.Set<Nat>, key : Nat) : Set.Set<Nat>  {
  let s1 = Set.add(s, Nat.compare, key);
  Set.assertValid(s1, Nat.compare);
  s1
};

func concatenateKeys(key : Nat, accum : Text) : Text {
  accum # debug_show(key)
};

func concatenateKeys2(accum : Text, key : Nat) : Text {
  accum # debug_show(key)
};

func containsAll (set : Set.Set<Nat>, elems : [Nat]) {
    for (elem in elems.vals()) {
        assert (Set.contains(set, Nat.compare, elem))
    }
};

func clear(initialSet : Set.Set<Nat>) : Set.Set<Nat> {
  var set = initialSet;
  for (elem in Set.values(initialSet)) {
    let newSet = Set.delete(set, Nat.compare, elem);
    set := newSet;
    Set.assertValid(set, Nat.compare)
  };
  set
};

func add1(x : Nat) : Nat { x + 1 };

func ifElemLessThan(threshold : Nat, f : Nat -> Nat) : Nat -> ?Nat
  = func (x) {
    if(x < threshold)
      ?f(x)
    else null
  };


/* --------------------------------------- */

var buildTestSet = func() : Set.Set<Nat> {
  Set.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        Set.size(buildTestSet()),
        M.equals(T.nat(0))
      ),
      test(
        "values",
        Iter.toArray(Set.values(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, []))
      ),
      test(
        "reverseValues",
        Iter.toArray(Set.reverseValues(buildTestSet())),
        M.equals  (T.array<Nat>(entryTestable, []))
      ),
      test(
        "empty from iter",
        Set.fromIter(Iter.fromArray([]), Nat.compare),
        SetMatcher([])
      ),
      test(
        "contains absent",
        Set.contains(buildTestSet(), Nat.compare, 0),
        M.equals(T.bool(false))
      ),
      test(
        "empty right fold",
        Set.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold",
        Set.foldLeft(buildTestSet(), "", concatenateKeys2),
        M.equals(T.text(""))
      ),
      test(
        "traverse empty set",
        Set.map(buildTestSet(), Nat.compare, add1),
        SetMatcher([])
      ),
      test(
        "empty filter map",
        Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "is empty",
        Set.isEmpty(buildTestSet()),
        M.equals(T.bool(true))
      ),
      test(
        "max",
        Set.max(buildTestSet()),
        M.equals(T.optional(entryTestable, null: ?Nat))
      ),
      test(
        "min",
        Set.min(buildTestSet()),
        M.equals(T.optional(entryTestable, null: ?Nat))
      ),
      test(
        "compare",
        do {
          let set1 = Set.empty<Nat>();
          let set2 = Set.empty<Nat>();
          assert (Set.compare(set1, set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
    ]
  )
);

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  insert(Set.empty(), 0);
};

var expected = [0];

run(
  suite(
    "single root",
    [
      test(
        "size",
        Set.size(buildTestSet()),
        M.equals(T.nat(1))
      ),
      test(
        "values",
        Iter.toArray(Set.values(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "reverseValues",
        Iter.toArray(Set.reverseValues(buildTestSet())),
        M.equals(T.array<Nat>(entryTestable, expected))
      ),
      test(
        "from iter",
        Set.fromIter(Iter.fromArray(expected), Nat.compare),
        SetMatcher(expected)
      ),
      test(
        "contains",
        Set.contains(buildTestSet(), Nat.compare, 0),
        M.equals(T.bool(true))
      ),
      test(
        "delete",
        Set.delete(buildTestSet(), Nat.compare, 0),
        SetMatcher([])
      ),
      test(
        "right fold",
        Set.foldRight(buildTestSet(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold",
        Set.foldLeft(buildTestSet(), "", concatenateKeys2),
        M.equals(T.text("0"))
      ),
      test(
        "traverse set",
        Set.map(buildTestSet(), Nat.compare, add1),
        SetMatcher([1])
      ),
      test(
        "filterMap / filter all",
        Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(0, add1)),
        SetMatcher([])
      ),
      test(
        "filterMap / no filter",
        Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(1, add1)),
        SetMatcher([1])
      ),
      test(
        "is empty",
        Set.isEmpty(buildTestSet()),
        M.equals(T.bool(false))
      ),
      test(
        "max",
        Set.max(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "min",
        Set.min(buildTestSet()),
        M.equals(T.optional(entryTestable, ?0))
      ),
      test(
        "all",
        Set.all<Nat>(buildTestSet(), func (k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "any",
        Set.any<Nat>(buildTestSet(), func (k) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "compare less",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(1);
          assert (Set.compare(set1, set2, Nat.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = Set.singleton<Nat>(0);
          let set2 = Set.singleton<Nat>(0);
          assert (Set.compare(set1, set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = Set.singleton<Nat>(1);
          let set2 = Set.singleton<Nat>(0);
          assert (Set.compare(set1, set2, Nat.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      ),
    ]
  )
);

/* --------------------------------------- */

expected := [0, 1, 2];

func rebalanceTests(buildTestSet : () -> Set.Set<Nat>) : [Suite.Suite] =
  [
    test(
      "size",
      Set.size(buildTestSet()),
      M.equals(T.nat(3))
    ),
    test(
      "Set match",
      buildTestSet(),
      SetMatcher(expected)
    ),
    test(
      "values",
      Iter.toArray(Set.values(buildTestSet())),
      M.equals(T.array<Nat>(entryTestable, expected))
    ),
    test(
      "reverseValues",
      Array.reverse(Iter.toArray(Set.reverseValues(buildTestSet()))),
      M.equals(T.array<Nat>(entryTestable, expected))
    ),
    test(
      "from iter",
      Set.fromIter(Iter.fromArray(expected), Nat.compare),
      SetMatcher(expected)
    ),
    test(
      "contains all",
      do {
        let set = buildTestSet();
        containsAll(set, [0, 1, 2]);
        set
      },
      SetMatcher(expected)
    ),
    test(
      "clear",
      clear(buildTestSet()),
      SetMatcher([])
    ),
    test(
      "right fold",
      Set.foldRight(buildTestSet(), "", concatenateKeys),
      M.equals(T.text("210"))
    ),
    test(
      "left fold",
      Set.foldLeft(buildTestSet(), "", concatenateKeys2),
      M.equals(T.text("012"))
    ),
    test(
      "traverse set",
      Set.map(buildTestSet(), Nat.compare, add1),
      SetMatcher([1, 2, 3])
    ),
    test(
      "traverse set/reshape",
      Set.map(buildTestSet(), Nat.compare, func (x : Nat) : Nat {5}),
      SetMatcher([5])
    ),
    test(
      "filterMap / filter all",
      Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(0, add1)),
      SetMatcher([])
    ),
    test(
      "filterMap / filter one",
      Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(1, add1)),
      SetMatcher([1])
    ),
    test(
      "filterMap / no filer",
      Set.filterMap(buildTestSet(), Nat.compare, ifElemLessThan(3, add1)),
      SetMatcher([1, 2, 3])
    ),
    test(
      "is empty",
      Set.isEmpty(buildTestSet()),
      M.equals(T.bool(false))
    ),
    test(
      "max",
      Set.max(buildTestSet()),
      M.equals(T.optional(entryTestable, ?2))
    ),
    test(
      "min",
      Set.min(buildTestSet()),
      M.equals(T.optional(entryTestable, ?0))
    ),
    test(
      "all true",
      Set.all<Nat>(buildTestSet(), func (k) = (k >= 0)),
      M.equals(T.bool(true))
    ),
    test(
      "all false",
      Set.all<Nat>(buildTestSet(), func (k) = (k > 0)),
      M.equals(T.bool(false))
    ),
    test(
      "any true",
      Set.any<Nat>(buildTestSet(), func (k) = (k >= 2)),
      M.equals(T.bool(true))
    ),
    test(
      "any false",
      Set.any<Nat>(buildTestSet(), func (k) = (k > 2)),
      M.equals(T.bool(false))
    ),
    test(
        "compare less key",
        do {
          let set1 = buildTestSet() |>
            Set.delete(_, Nat.compare, Set.size(_) - 1 : Nat);
          let set2 = buildTestSet();
          assert (Set.compare(set1, set2, Nat.compare) == #less);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare equal",
        do {
          let set1 = buildTestSet();
          let set2 = buildTestSet();
          assert (Set.compare(set1, set2, Nat.compare) == #equal);
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "compare greater key",
        do {
          let set1 = buildTestSet();
          let set2 = buildTestSet() |>
            Set.delete(_, Nat.compare, Set.size(_) - 1);

          assert (Set.compare(set1, set2, Nat.compare) == #greater);
          true
        },
        M.equals(T.bool(true))
      )
  ];

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 2);
  set := insert(set, 1);
  set := insert(set, 0);
  set
};

run(suite("rebalance left, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 2);
  set := insert(set, 0);
  set := insert(set, 1);
  set
};

run(suite("rebalance left, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 2);
  set := insert(set, 1);
  set
};

run(suite("rebalance right, left", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

buildTestSet := func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 1);
  set := insert(set, 2);
  set
};

run(suite("rebalance right, right", rebalanceTests(buildTestSet)));

/* --------------------------------------- */

run(
  suite(
    "repeated operations",
    [
      test(
        "repeated insert",
        do {
          var set = buildTestSet();
          assert (Set.contains(set, Nat.compare, 1));
          set := Set.add(set, Nat.compare, 1);
          Set.size(set)
        },
        M.equals(T.nat(3))
      ),
      test(
        "repeated delete",
        do {
          var set = buildTestSet();
          set := Set.delete(set, Nat.compare, 1);
          Set.delete(set, Nat.compare, 1)
        },
        SetMatcher([0, 2])
      )
    ]
  )
);

/* --------------------------------------- */

let buildTestSet012 = func() : Set.Set<Nat> {
  var set  = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 1);
  set := insert(set, 2);
  set
};

let buildTestSet01 = func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 0);
  set := insert(set, 1);
  set
};

let buildTestSet234 = func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 2);
  set := insert(set, 3);
  set := insert(set, 4);
  set
};

let buildTestSet345 = func() : Set.Set<Nat> {
  var set = Set.empty<Nat>();
  set := insert(set, 5);
  set := insert(set, 3);
  set := insert(set, 4);
  set
};

run(
  suite(
    "set operations",
    [
      test(
        "subset/subset of itself",
        Set.isSubset(buildTestSet012(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of itself",
        Set.isSubset(Set.empty(), Set.empty(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/empty set is subset of another set",
        Set.isSubset(Set.empty(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/subset",
        Set.isSubset(buildTestSet01(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "subset/not subset",
        Set.isSubset(buildTestSet012(), buildTestSet01(), Nat.compare),
        M.equals(T.bool(false))
      ),
      test(
        "equal/empty set",
        Set.equal(Set.empty(), Set.empty(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "equal/equal",
        Set.equal(buildTestSet012(), buildTestSet012(), Nat.compare),
        M.equals(T.bool(true))
      ),
      test(
        "equal/not equal",
        Set.equal(buildTestSet012(), buildTestSet01(), Nat.compare),
        M.equals(T.bool(false))
      ),
      test(
        "union/empty set",
        Set.union(Set.empty(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "union/union with empty set",
        Set.union(buildTestSet012(), Set.empty(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with itself",
        Set.union(buildTestSet012(), buildTestSet012(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union with subset",
        Set.union(buildTestSet012(), buildTestSet01(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "union/union expand",
        Set.union(buildTestSet012(), buildTestSet234(), Nat.compare),
        SetMatcher([0, 1, 2, 3, 4])
      ),
      test(
        "intersect/empty set",
        Set.intersect(Set.empty(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "intersect/intersect with empty set",
        Set.intersect(buildTestSet012(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "intersect/intersect with itself",
        Set.intersect(buildTestSet012(), buildTestSet012(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "intersect/intersect with subset",
        Set.intersect(buildTestSet012(), buildTestSet01(), Nat.compare),
        SetMatcher([0, 1])
      ),
      test(
        "intersect/intersect",
        Set.intersect(buildTestSet012(), buildTestSet234(), Nat.compare),
        SetMatcher([2])
      ),
      test(
        "intersect/no intersection",
        Set.intersect(buildTestSet012(), buildTestSet345(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "diff/empty set",
        Set.diff(Set.empty(), Set.empty(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "diff/diff with empty set",
        Set.diff(buildTestSet012(), Set.empty(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
      test(
        "diff/diff with empty set 2",
        Set.diff(Set.empty(), buildTestSet012(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "diff/diff with subset",
        Set.diff(buildTestSet012(), buildTestSet01(), Nat.compare),
        SetMatcher([2])
      ),
      test(
        "diff/diff with subset 2",
        Set.diff(buildTestSet01(), buildTestSet012(), Nat.compare),
        SetMatcher([])
      ),
      test(
        "diff/diff",
        Set.diff(buildTestSet012(), buildTestSet234(), Nat.compare),
        SetMatcher([0, 1])
      ),
      test(
        "diff/diff no intersection",
        Set.diff(buildTestSet012(), buildTestSet345(), Nat.compare),
        SetMatcher([0, 1, 2])
      ),
    ]
  )
);
