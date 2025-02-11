// @testmode wasi

import Map "../src/immutable/Map";
import Nat "../src/Nat";
import Iter "../src/Iter";
import Debug "../src/Debug";
import Array "../src/Array";

import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";

let { run; test; suite } = Suite;

let entryTestable = T.tuple2Testable(T.natTestable, T.textTestable);

class MapMatcher(expected : [(Nat, Text)]) : M.Matcher<Map.Map<Nat, Text>> {
  public func describeMismatch(actual : Map.Map<Nat, Text>, _description : M.Description) {
    Debug.print(debug_show (Iter.toArray(Map.entries(actual))) # " should be " # debug_show (expected))
  };

  public func matches(actual : Map.Map<Nat, Text>) : Bool {
    Iter.toArray(Map.entries(actual)) == expected
  }
};

func checkMap(m: Map.Map<Nat, Text>) { Map.assertValid(m, Nat.compare); };

func insert(rbTree : Map.Map<Nat, Text>, key : Nat) : Map.Map<Nat, Text>  {
  let updatedTree = Map.add(rbTree, Nat.compare, key, debug_show (key));
  checkMap(updatedTree);
  updatedTree
};

func getAll(rbTree : Map.Map<Nat, Text>, keys : [Nat]) {
  for (key in keys.vals()) {
    let value = Map.get(rbTree, Nat.compare, key);
    assert (value == ?debug_show (key))
  }
};

func clear(initialRbMap : Map.Map<Nat, Text>) : Map.Map<Nat, Text> {
  var rbMap = initialRbMap;
  for ((key, value) in Map.entries(initialRbMap)) {
    // stable iteration
    assert (value == debug_show (key));
    let (newMap, result) = Map.take(rbMap, Nat.compare, key);
    rbMap := newMap;
    assert (result == ?debug_show (key));
    checkMap(rbMap)
  };
  rbMap
};

func expectedEntries(keys : [Nat]) : [(Nat, Text)] {
  Array.tabulate<(Nat, Text)>(keys.size(), func(index) { (keys[index], debug_show (keys[index])) })
};

func concatenateKeys(key : Nat, value : Text, accum : Text) : Text {
  accum # debug_show(key)
};

func concatenateKeys2(accum : Text, key : Nat, value : Text) : Text {
  accum # debug_show(key)
};

func concatenateValues(key : Nat, value : Text, accum : Text) : Text {
  accum # value
};

func concatenateValues2(accum: Text, key : Nat, value : Text) : Text {
  accum # value
};

func multiplyKeyAndConcat(key : Nat, value : Text) : Text {
  debug_show(key * 2) # value
};

func ifKeyLessThan(threshold : Nat, f : (Nat, Text) -> Text) : (Nat, Text) -> ?Text
  = func (key, value) {
    if(key < threshold)
      ?f(key, value)
    else null
  };

/* --------------------------------------- */

var buildTestMap = func() : Map.Map<Nat, Text> {
  Map.empty()
};

run(
  suite(
    "empty",
    [
      test(
        "size",
        Map.size(buildTestMap()),
        M.equals(T.nat(0))
      ),
      test(
        "entries",
        Iter.toArray(Map.entries(buildTestMap())),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "reverseEntries",
        Iter.toArray(Map.reverseEntries(buildTestMap())),
        M.equals(T.array<(Nat, Text)>(entryTestable, []))
      ),
      test(
        "keys",
        Iter.toArray(Map.keys(buildTestMap())),
        M.equals(T.array<Nat>(T.natTestable, []))
      ),
      test(
        "vals",
        Iter.toArray(Map.values(buildTestMap())),
        M.equals(T.array<Text>(T.textTestable, []))
      ),
      test(
        "empty from iter",
        Map.fromIter(Iter.fromArray([]), Nat.compare),
        MapMatcher([])
      ),
      test(
        "get absent",
        Map.get(buildTestMap(), Nat.compare, 0),
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test("containsKey absent",
        Map.containsKey(buildTestMap(), Nat.compare, 0),
        M.equals(T.bool(false))
      ),
      test(
        "maxEntry",
        Map.maxEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, null: ?(Nat, Text)))
      ),
      test(
        "minEntry",
        Map.minEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, null: ?(Nat, Text)))
      ),
      test(
        "take absent",
        Map.take(buildTestMap(), Nat.compare, 0).1,
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace absent/no value",
        Map.put(buildTestMap(), Nat.compare, 0, "Test").1,
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "replace absent/key appeared",
        Map.put(buildTestMap(), Nat.compare, 0, "Test").0,
        MapMatcher([(0, "Test")])
      ),
      test(
        "empty right fold keys",
        Map.foldRight(buildTestMap(), "", concatenateKeys),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold keys",
        Map.foldLeft(buildTestMap(), "", concatenateKeys2),
        M.equals(T.text(""))
      ),
      test(
        "empty right fold values",
        Map.foldRight(buildTestMap(), "", concatenateValues),
        M.equals(T.text(""))
      ),
      test(
        "empty left fold values",
        Map.foldLeft(buildTestMap(), "", concatenateValues2),
        M.equals(T.text(""))
      ),
      test(
        "traverse empty map",
        Map.map(buildTestMap(), multiplyKeyAndConcat),
        MapMatcher([])
      ),
      test(
        "empty map filter",
        Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(0, multiplyKeyAndConcat)),
        MapMatcher([])
      ),
      test(
        "empty all",
        Map.all<Nat, Text>(buildTestMap(), func (k, v) = false),
        M.equals(T.bool(true))
      ),
      test(
        "empty any",
        Map.any<Nat, Text>(buildTestMap(), func (k, v) = true),
        M.equals(T.bool(false))
      ),
      test(
        "empty to text",
         Map.toText<Nat, Text>(buildTestMap(), Nat.toText, func(value) { value }),
         M.equals(T.text("{}"))
      ),
    ]
  )
);

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  insert(Map.empty(), 0);
};

var expected = expectedEntries([0]);

run(
  suite(
    "single root",
    [
      test(
        "size",
        Map.size(buildTestMap()),
        M.equals(T.nat(1))
      ),
      test(
        "entries",
        Iter.toArray(Map.entries(buildTestMap())),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "reverseEntries",
        Iter.toArray(Map.reverseEntries(buildTestMap())),
        M.equals(T.array<(Nat, Text)>(entryTestable, expected))
      ),
      test(
        "keys",
        Iter.toArray(Map.keys(buildTestMap())),
        M.equals(T.array<Nat>(T.natTestable, [0]))
      ),
      test(
        "values",
        Iter.toArray(Map.values(buildTestMap())),
        M.equals(T.array<Text>(T.textTestable, ["0"]))
      ),
      test(
        "from iter",
        Map.fromIter(Iter.fromArray(expected), Nat.compare),
        MapMatcher(expected)
      ),
      test(
        "get",
        Map.get(buildTestMap(), Nat.compare, 0),
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "containsKey",
        Map.containsKey(buildTestMap(), Nat.compare, 0),
        M.equals(T.bool(true))
      ),
      test(
        "maxEntry",
        Map.maxEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "minEntry",
        Map.minEntry(buildTestMap()),
        M.equals(T.optional(entryTestable, ?(0, "0")))
      ),
      test(
        "put function result",
        Map.put(buildTestMap(), Nat.compare, 0, "TEST").1,
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "put map result",
        do {
          let rbMap = buildTestMap();
          Map.put(rbMap, Nat.compare, 0, "TEST").0
        },
        MapMatcher([(0, "TEST")])
      ),
      test(
        "take function result",
        Map.take(buildTestMap(), Nat.compare, 0).1,
        M.equals(T.optional(T.textTestable, ?"0"))
      ),
      test(
        "take map result",
        do {
          var rbMap = buildTestMap();
          rbMap := Map.take(rbMap, Nat.compare, 0).0;
          checkMap(rbMap);
          rbMap
        },
        MapMatcher([])
      ),
      test(
        "right fold keys",
        Map.foldRight(buildTestMap(), "", concatenateKeys),
        M.equals(T.text("0"))
      ),
      test(
        "left fold keys",
        Map.foldLeft(buildTestMap(), "", concatenateKeys2),
        M.equals(T.text("0"))
      ),
      test(
        "right fold values",
        Map.foldRight(buildTestMap(), "", concatenateValues),
        M.equals(T.text("0"))
      ),
      test(
        "left fold values",
        Map.foldLeft(buildTestMap(), "", concatenateValues2),
        M.equals(T.text("0"))
      ),
      test(
        "traverse map",
        Map.map(buildTestMap(), multiplyKeyAndConcat),
        MapMatcher([(0, "00")])
      ),
      test(
        "filter map/filter all",
        Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(0, multiplyKeyAndConcat)),
        MapMatcher([])
      ),
      test(
        "filter map/no filter",
        Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(1, multiplyKeyAndConcat)),
        MapMatcher([(0, "00")])
      ),
      test(
        "all",
        Map.all<Nat, Text>(buildTestMap(), func (k, v) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "any",
        Map.any<Nat, Text>(buildTestMap(), func (k, v) = (k == 0)),
        M.equals(T.bool(true))
      ),
      test(
        "to text",
        Map.toText<Nat, Text>(buildTestMap(), Nat.toText, func(value) { value }),
        M.equals(T.text("{(0, 0)}"))
      ),
    ]
  )
);
/* --------------------------------------- */

expected := expectedEntries([0, 1, 2]);

func rebalanceTests(buildTestMap : () -> Map.Map<Nat, Text>) : [Suite.Suite] =
  [
    test(
      "size",
      Map.size(buildTestMap()),
      M.equals(T.nat(3))
    ),
    test(
      "map match",
      buildTestMap(),
      MapMatcher(expected)
    ),
    test(
      "entries",
      Iter.toArray(Map.entries(buildTestMap())),
      M.equals(T.array<(Nat, Text)>(entryTestable, expected))
    ),
    test(
      "reverserEntries",
      Iter.toArray(Map.reverseEntries(buildTestMap())),
      M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(expected)))
    ),
    test(
      "keys",
      Iter.toArray(Map.keys(buildTestMap())),
      M.equals(T.array<Nat>(T.natTestable, [0, 1, 2]))
    ),
    test(
      "values",
      Iter.toArray(Map.values(buildTestMap())),
      M.equals(T.array<Text>(T.textTestable, ["0", "1", "2"]))
    ),
    test(
      "from iter",
      Map.fromIter(Iter.fromArray(expected), Nat.compare),
      MapMatcher(expected)
    ),
    test(
      "get all",
      do {
        let rbMap = buildTestMap();
        getAll(rbMap, [0, 1, 2]);
        rbMap
      },
      MapMatcher(expected)
    ),
    test(
      "containsKey",
      Array.tabulate<Bool>(4, func (k: Nat) = (Map.containsKey(buildTestMap(), Nat.compare, k))),
      M.equals(T.array<Bool>(T.boolTestable, [true, true, true, false]))
    ),
    test(
      "maxEntry",
      Map.maxEntry(buildTestMap()),
      M.equals(T.optional(entryTestable, ?(2, "2")))
    ),
    test(
      "minEntry",
      Map.minEntry(buildTestMap()),
      M.equals(T.optional(entryTestable, ?(0, "0")))
    ),
    test(
      "clear",
      clear(buildTestMap()),
      MapMatcher([])
    ),
    test(
      "right fold keys",
      Map.foldRight(buildTestMap(), "", concatenateKeys),
      M.equals(T.text("210"))
    ),
    test(
      "left fold keys",
      Map.foldLeft(buildTestMap(), "", concatenateKeys2),
      M.equals(T.text("012"))
    ),
    test(
      "right fold values",
      Map.foldRight(buildTestMap(), "", concatenateValues),
      M.equals(T.text("210"))
    ),
    test(
      "left fold values",
      Map.foldLeft(buildTestMap(), "", concatenateValues2),
      M.equals(T.text("012"))
    ),
    test(
      "traverse map",
      Map.map(buildTestMap(), multiplyKeyAndConcat),
      MapMatcher([(0, "00"), (1, "21"), (2, "42")])
    ),
    test(
      "filter map/filter all",
      Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(0, multiplyKeyAndConcat)),
      MapMatcher([])
    ),
    test(
      "filter map/filter one",
      Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(1, multiplyKeyAndConcat)),
      MapMatcher([(0, "00")])
    ),
    test(
      "filter map/no filter",
      Map.filterMap(buildTestMap(), Nat.compare, ifKeyLessThan(3, multiplyKeyAndConcat)),
      MapMatcher([(0, "00"), (1, "21"), (2, "42")])
    ),
    test(
      "all true",
      Map.all<Nat, Text>(buildTestMap(), func (k, v) = (k >= 0)),
      M.equals(T.bool(true))
    ),
    test(
      "all false",
      Map.all<Nat, Text>(buildTestMap(), func (k, v) = (k > 0)),
      M.equals(T.bool(false))
    ),
    test(
      "any true",
      Map.any<Nat, Text>(buildTestMap(), func (k, v) = (k >= 2)),
      M.equals(T.bool(true))
    ),
    test(
      "any false",
      Map.any<Nat, Text>(buildTestMap(), func (k, v) = (k > 2)),
      M.equals(T.bool(false))
    ),
    test(
        "to text",
         Map.toText<Nat, Text>(buildTestMap(), Nat.toText, func(value) { value }),
         M.equals(T.text("{(0, 0), (1, 1), (2, 2)}"))
      ),
  ];

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 1);
  rbMap := insert(rbMap, 0);
  rbMap
};

run(suite("rebalance left, left", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 1);
  rbMap
};

run(suite("rebalance left, right", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 2);
  rbMap := insert(rbMap, 1);
  rbMap
};

run(suite("rebalance right, left", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

buildTestMap := func() : Map.Map<Nat, Text> {
  var rbMap = Map.empty() : Map.Map<Nat, Text>;
  rbMap := insert(rbMap, 0);
  rbMap := insert(rbMap, 1);
  rbMap := insert(rbMap, 2);
  rbMap
};

run(suite("rebalance right, right", rebalanceTests(buildTestMap)));

/* --------------------------------------- */

run(
  suite(
    "repeated operations",
    [
      test(
        "repeated add",
        do {
          var rbMap = buildTestMap();
          assert (Map.get(rbMap, Nat.compare, 1) == ?"1");
          rbMap := Map.add(rbMap, Nat.compare, 1, "TEST-1");
          Map.get(rbMap, Nat.compare, 1)
        },
        M.equals(T.optional(T.textTestable, ?"TEST-1"))
      ),
      test(
        "repeated put",
        do {
          let rbMap0 = buildTestMap();
          let (rbMap1, firstResult) = Map.put(rbMap0, Nat.compare, 1, "TEST-1");
          assert (firstResult == ?"1");
          let (rbMap2, secondResult) = Map.put(rbMap1, Nat.compare, 1, "1");
          assert (secondResult == ?"TEST-1");
          rbMap2
        },
        MapMatcher(expected)
      ),
      test(
        "repeated take",
        do {
          var rbMap0 = buildTestMap();
          let (rbMap1, result) = Map.take(rbMap0, Nat.compare, 1);
          assert (result == ?"1");
          checkMap(rbMap1);
          Map.take(rbMap1, Nat.compare, 1).1
        },
        M.equals(T.optional(T.textTestable, null : ?Text))
      ),
      test(
        "repeated delete",
        do {
          var rbMap = buildTestMap();
          rbMap := Map.delete(rbMap, Nat.compare, 1);
          Map.delete(rbMap, Nat.compare, 1)
        },
        MapMatcher(expectedEntries([0, 2]))
      )
    ]
  )
);
