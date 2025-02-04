import Suite "mo:matchers/Suite";
import T "mo:matchers/Testable";
import M "mo:matchers/Matchers";
import Set "../src/Set";
import Iter "../src/Iter";
import Nat "../src/Nat";
import Runtime "../src/Runtime";
import Debug "../src/Debug";
import Text "../src/Text";
import Array "../src/Array";

let { run; test; suite } = Suite;

run(
  suite(
    "empty",
    [
      test(
        "size",
        Set.size(Set.empty<Nat>()),
        M.equals(T.nat(0))
      ),
      test(
        "is empty",
        Set.isEmpty(Set.empty<Nat>()),
        M.equals(T.bool(true))
      ),
      test(
        "clone",
        do {
          let original = Set.empty<Nat>();
          let clone = Set.clone(original);
          Set.size(clone)
        },
        M.equals(T.nat(0))
      ),
      // test(
      //   "iterate forward",
      //   Iter.toArray(Set.values(Set.empty<Nat>())),
      //   M.equals(T.array<(Nat, Text)>(entryTestable, []))
      // ),
      // test(
      //   "iterate backward",
      //   Iter.toArray(Set.reverseValues(Set.empty<Nat>())),
      //   M.equals(T.array<(Nat, Text)>(entryTestable, []))
      // ),
      test(
        "contains present",
        do {
          let set = Set.empty<Nat>();
          Set.add(set, Nat.compare, 0);
          Set.contains(set, Nat.compare, 0)
        },
        M.equals(T.bool(true))
      ),
      test(
        "contains absent",
        do {
          let set = Set.empty<Nat>();
          Set.contains(set, Nat.compare, 0)
        },
        M.equals(T.bool(false))
      ),
      test(
        "clear",
        do {
          let set = Set.empty<Nat>();
          Set.clear(set);
          Set.isEmpty(set)
        },
        M.equals(T.bool(true))
      ),
      // test(
      //   "equal",
      //   do {
      //     let set1 = Set.empty<Nat>();
      //     let set2 = Set.empty<Nat>();
      //     Set.equal(set1, set2, Nat.equal)
      //   },
      //   M.equals(T.bool(true))
      // ),
      // test(
      //   "maximum entry",
      //   do {
      //     let set = Set.empty<Nat>();
      //     Set.maxEntry(set)
      //   },
      //   M.equals(T.optional(T.natTestable, null : ?Nat))
      // ),
      // test(
      //   "minimum entry",
      //   do {
      //     let set = Set.empty<Nat>();
      //     Set.minEntry(set)
      //   },
      //   M.equals(T.optional(entryTestable, null : ?Nat))
      // ),
      // test(
      //   "from iterator",
      //   do {
      //     let set = Set.fromIter<Nat>(Iter.fromArray<Nat>([]), Nat.compare);
      //     Set.size(set)
      //   },
      //   M.equals(T.nat(0))
      // ),
      // test(
      //   "for each",
      //   do {
      //     let set = Set.empty<Nat>();
      //     Set.forEach<Nat>(
      //       set,
      //       func(_) {
      //         Runtime.trap("test failed")
      //       }
      //     );
      //     Set.size(set)
      //   },
      //   M.equals(T.nat(0))
      // ),
      // test(
      //   "filter",
      //   do {
      //     let input = Set.empty<Nat>();
      //     let output = Set.filter<Nat>(
      //       input,
      //       Nat.compare,
      //       func(_) {
      //         Runtime.trap("test failed")
      //       }
      //     );
      //     Set.size(output)
      //   },
      //   M.equals(T.nat(0))
      // ),
      // test(
      //   "map",
      //   do {
      //     let input = Set.empty<Nat>();
      //     let output = Set.map<Nat, Int>(
      //       input,
      //       Nat.compare,
      //       func(_) {
      //         Runtime.trap("test failed")
      //       }
      //     );
      //     Set.size(output)
      //   },
      //   M.equals(T.nat(0))
      // ),
      // test(
      //   "filter map",
      //   do {
      //     let input = Set.empty<Nat>();
      //     let output = Set.filterMap<Nat, Int>(
      //       input,
      //       Nat.compare,
      //       func(_) {
      //         Runtime.trap("test failed")
      //       }
      //     );
      //     Set.size(output)
      //   },
      //   M.equals(T.nat(0))
      // ),
      // test(
      //   "fold left",
      //   do {
      //     let set = Map.empty<Nat>();
      //     Set.foldLeft<Nat, Nat>(
      //       map,
      //       0,
      //       func(_, _) {
      //         Runtime.trap("test failed")
      //       }
      //     )
      //   },
      //   M.equals(T.nat(0))
      // ),
      // test(
      //   "fold right",
      //   do {
      //     let set = Set.empty<Nat>();
      //     Map.foldRight<Nat, Nat>(
      //       set,
      //       0,
      //       func(_, _) {
      //         Runtime.trap("test failed")
      //       }
      //     )
      //   },
      //   M.equals(T.nat(0))
      // ),
      // test(
      //   "all",
      //   do {
      //     let set = Set.empty<Nat>();
      //     Set.all<Nat>(
      //       set,
      //       func(_) {
      //         Runtime.trap("test failed")
      //       }
      //     )
      //   },
      //   M.equals(T.bool(true))
      // ),
      // test(
      //   "any",
      //   do {
      //     let set = Set.empty<Nat>();
      //     Set.any<Nat>(
      //       map,
      //       func(_) {
      //         Runtime.trap("test failed")
      //       }
      //     )
      //   },
      //   M.equals(T.bool(false))
      // ),
      // test(
      //   "to text",
      //   do {
      //     let set = Set.empty<Nat>();
      //     Set.toText<Nat>(set, Nat.toText, func(value) { value })
      //   },
      //   M.equals(T.text(""))
      // ),
      // test(
      //   "compare",
      //   do {
      //     let set1 = Set.empty<Nat>();
      //     let set2 = Set.empty<Nat>();
      //     assert (Set.compare(set1, set2, Nat.compare, Text.compare) == #equal);
      //     true
      //   },
      //   M.equals(T.bool(true))
      // ),
      // // TODO: Test freeze and thaw
    ]
  )
);

// run(
//   suite(
//     "singleton",
//     [
//       test(
//         "size",
//         Map.size<Nat, Text>(Map.singleton(0, "0")),
//         M.equals(T.nat(1))
//       ),
//       test(
//         "is empty",
//         Map.isEmpty<Nat, Text>(Map.singleton(0, "0")),
//         M.equals(T.bool(false))
//       ),
//       test(
//         "clone",
//         do {
//           let original = Map.singleton<Nat, Text>(0, "0");
//           let clone = Map.clone(original);
//           assert (Map.equal(original, clone, Nat.equal, Text.equal));
//           Map.size(clone)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "iterate forward",
//         Iter.toArray(Map.entries(Map.singleton<Nat, Text>(0, "0"))),
//         M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
//       ),
//       test(
//         "iterate backward",
//         Iter.toArray(Map.reverseEntries(Map.singleton<Nat, Text>(0, "0"))),
//         M.equals(T.array<(Nat, Text)>(entryTestable, [(0, "0")]))
//       ),
//       test(
//         "contains present key",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.containsKey(map, Nat.compare, 0)
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "contains absent key",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.containsKey(map, Nat.compare, 1)
//         },
//         M.equals(T.bool(false))
//       ),
//       test(
//         "get present",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.get(map, Nat.compare, 0)
//         },
//         M.equals(T.optional(T.textTestable, ?"0"))
//       ),
//       test(
//         "get absent",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.get(map, Nat.compare, 1)
//         },
//         M.equals(T.optional(T.textTestable, null : ?Text))
//       ),
//       test(
//         "update present",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.put(map, Nat.compare, 0, "Zero")
//         },
//         M.equals(T.optional(T.textTestable, ?"0"))
//       ),
//       test(
//         "update absent",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.put(map, Nat.compare, 1, "1")
//         },
//         M.equals(T.optional(T.textTestable, null : ?Text))
//       ),
//       test(
//         "replace if exists present",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           assert (Map.replaceIfExists(map, Nat.compare, 0, "Zero") == ?"0");
//           Map.size(map)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "replace if exists absent",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           assert (Map.replaceIfExists(map, Nat.compare, 1, "1") == null);
//           Map.size(map)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "delete",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.delete(map, Nat.compare, 0);
//           Map.size(map)
//         },
//         M.equals(T.nat(0))
//       ),
//       test(
//         "clear",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.clear(map);
//           Map.isEmpty(map)
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "equal",
//         do {
//           let map1 = Map.singleton<Nat, Text>(0, "0");
//           let map2 = Map.singleton<Nat, Text>(0, "0");
//           Map.equal(map1, map2, Nat.equal, Text.equal)
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "not equal",
//         do {
//           let map1 = Map.singleton<Nat, Text>(0, "0");
//           let map2 = Map.singleton<Nat, Text>(1, "1");
//           Map.equal(map1, map2, Nat.equal, Text.equal)
//         },
//         M.equals(T.bool(false))
//       ),
//       test(
//         "maximum entry",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.maxEntry(map)
//         },
//         M.equals(T.optional(entryTestable, ?(0, "0")))
//       ),
//       test(
//         "minimum entry",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.minEntry(map)
//         },
//         M.equals(T.optional(entryTestable, ?(0, "0")))
//       ),
//       test(
//         "iterate keys",
//         Iter.toArray(Map.keys(Map.singleton<Nat, Text>(0, "0"))),
//         M.equals(T.array<Nat>(T.natTestable, [0]))
//       ),
//       test(
//         "iterate values",
//         Iter.toArray(Map.values(Map.singleton<Nat, Text>(0, "0"))),
//         M.equals(T.array<Text>(T.textTestable, ["0"]))
//       ),
//       test(
//         "from iterator",
//         do {
//           let map = Map.fromIter<Nat, Text>(Iter.fromArray<(Nat, Text)>([(0, "0")]), Nat.compare);
//           assert (Map.get(map, Nat.compare, 0) == ?"0");
//           assert (Map.equal(map, Map.singleton<Nat, Text>(0, "0"), Nat.equal, Text.equal));
//           Map.size(map)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "for each",
//         do {
//           let map = Map.singleton<Nat, Text>(0, "0");
//           Map.forEach<Nat, Text>(
//             map,
//             func(key, value) {
//               assert (key == 0);
//               assert (value == "0")
//             }
//           );
//           Map.size(map)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "filter",
//         do {
//           let input = Map.singleton<Nat, Text>(0, "0");
//           let output = Map.filter<Nat, Text>(
//             input,
//             Nat.compare,
//             func(key, value) {
//               assert (key == 0);
//               assert (value == "0");
//               true
//             }
//           );
//           assert (Map.equal(input, output, Nat.equal, Text.equal));
//           Map.size(output)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "map",
//         do {
//           let input = Map.singleton<Nat, Text>(0, "0");
//           let output = Map.map<Nat, Text, Int>(
//             input,
//             Nat.compare,
//             func(key, value) {
//               assert (key == 0);
//               assert (value == "0");
//               +key
//             }
//           );
//           assert (Map.get(output, Nat.compare, 0) == ?+0);
//           Map.size(output)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "filter map",
//         do {
//           let input = Map.singleton<Nat, Text>(0, "0");
//           let output = Map.filterMap<Nat, Text, Int>(
//             input,
//             Nat.compare,
//             func(key, value) {
//               assert (key == 0);
//               assert (value == "0");
//               ?+key
//             }
//           );
//           assert (Map.get(output, Nat.compare, 0) == ?+0);
//           Map.size(output)
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "fold left",
//         do {
//           let map = Map.singleton<Nat, Text>(1, "1");
//           Map.foldLeft<Nat, Text, Nat>(
//             map,
//             0,
//             func(accumulator, key, value) {
//               accumulator + key
//             }
//           )
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "fold right",
//         do {
//           let map = Map.singleton<Nat, Text>(1, "1");
//           Map.foldRight<Nat, Text, Nat>(
//             map,
//             0,
//             func(key, value, accumulator) {
//               key + accumulator
//             }
//           )
//         },
//         M.equals(T.nat(1))
//       ),
//       test(
//         "all",
//         do {
//           let map = Map.singleton<Nat, Text>(1, "1");
//           Map.all<Nat, Text>(
//             map,
//             func(key, value) {
//               key == 1 and value == "1"
//             }
//           )
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "any",
//         do {
//           let map = Map.singleton<Nat, Text>(1, "1");
//           Map.any<Nat, Text>(
//             map,
//             func(key, value) {
//               key == 1 and value == "1"
//             }
//           )
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "to text",
//         do {
//           let map = Map.singleton<Nat, Text>(1, "1");
//           Map.toText<Nat, Text>(map, Nat.toText, func(value) { value })
//         },
//         M.equals(T.text("(1, 1)"))
//       ),
//       test(
//         "compare less key",
//         do {
//           let map1 = Map.singleton<Nat, Text>(0, "0");
//           let map2 = Map.singleton<Nat, Text>(1, "1");
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare less value",
//         do {
//           let map1 = Map.singleton<Nat, Text>(0, "0");
//           let map2 = Map.singleton<Nat, Text>(0, "Zero");
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare equal",
//         do {
//           let map1 = Map.singleton<Nat, Text>(0, "0");
//           let map2 = Map.singleton<Nat, Text>(0, "0");
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #equal);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare greater key",
//         do {
//           let map1 = Map.singleton<Nat, Text>(1, "1");
//           let map2 = Map.singleton<Nat, Text>(0, "0");
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare greater value",
//         do {
//           let map1 = Map.singleton<Nat, Text>(0, "Zero");
//           let map2 = Map.singleton<Nat, Text>(0, "0");
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       // TODO: Test freeze and thaw
//     ]
//   )
// );

// let smallSize = 100;
// func smallMap() : Map.Map<Nat, Text> {
//   let map = Map.empty<Nat, Text>();
//   for (index in Nat.range(0, smallSize)) {
//     Map.add(map, Nat.compare, index, Nat.toText(index))
//   };
//   map
// };

// run(
//   suite(
//     "small map",
//     [
//       test(
//         "size",
//         Map.size<Nat, Text>(smallMap()),
//         M.equals(T.nat(smallSize))
//       ),
//       test(
//         "is empty",
//         Map.isEmpty<Nat, Text>(smallMap()),
//         M.equals(T.bool(false))
//       ),
//       test(
//         "clone",
//         do {
//           let original = smallMap();
//           let clone = Map.clone(original);
//           assert (Map.equal(original, clone, Nat.equal, Text.equal));
//           Map.size(clone)
//         },
//         M.equals(T.nat(smallSize))
//       ),
//       test(
//         "iterate forward",
//         Iter.toArray(Map.entries(smallMap())),
//         M.equals(
//           T.array<(Nat, Text)>(
//             entryTestable,
//             Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) })
//           )
//         )
//       ),
//       test(
//         "iterate backward",
//         Iter.toArray(Map.reverseEntries(smallMap())),
//         M.equals(T.array<(Nat, Text)>(entryTestable, Array.reverse(Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) }))))
//       ),
//       test(
//         "contains present keys",
//         do {
//           let map = smallMap();
//           for (index in Nat.range(0, smallSize)) {
//             assert (Map.containsKey(map, Nat.compare, index))
//           };
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "contains absent key",
//         do {
//           let map = smallMap();
//           Map.containsKey(map, Nat.compare, smallSize)
//         },
//         M.equals(T.bool(false))
//       ),
//       test(
//         "get present",
//         do {
//           let map = smallMap();
//           for (index in Nat.range(0, smallSize)) {
//             assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
//           };
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "get absent",
//         do {
//           let map = smallMap();
//           Map.get(map, Nat.compare, smallSize)
//         },
//         M.equals(T.optional(T.textTestable, null : ?Text))
//       ),
//       test(
//         "update present",
//         do {
//           let map = smallMap();
//           for (index in Nat.range(0, smallSize)) {
//             assert (Map.put(map, Nat.compare, index, Nat.toText(index) # "!") == ?Nat.toText(index))
//           };
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "update absent",
//         do {
//           let map = smallMap();
//           Map.put(map, Nat.compare, smallSize, Nat.toText(smallSize))
//         },
//         M.equals(T.optional(T.textTestable, null : ?Text))
//       ),
//       test(
//         "replace if exists present",
//         do {
//           let map = smallMap();
//           for (index in Nat.range(0, smallSize)) {
//             assert (Map.replaceIfExists(map, Nat.compare, index, Nat.toText(index) # "!") == ?Nat.toText(index))
//           };
//           Map.size(map)
//         },
//         M.equals(T.nat(smallSize))
//       ),
//       test(
//         "replace if exists absent",
//         do {
//           let map = smallMap();
//           assert (Map.replaceIfExists(map, Nat.compare, smallSize, Nat.toText(smallSize)) == null);
//           Map.size(map)
//         },
//         M.equals(T.nat(smallSize))
//       ),
//       test(
//         "delete",
//         do {
//           let map = smallMap();
//           for (index in Nat.range(0, smallSize)) {
//             Map.delete(map, Nat.compare, index)
//           };
//           Map.isEmpty(map)
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "clear",
//         do {
//           let map = smallMap();
//           Map.clear(map);
//           Map.isEmpty(map)
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "equal",
//         do {
//           let map1 = smallMap();
//           let map2 = smallMap();
//           Map.equal(map1, map2, Nat.equal, Text.equal)
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "not equal",
//         do {
//           let map1 = smallMap();
//           let map2 = smallMap();
//           Map.delete(map2, Nat.compare, smallSize - 1);
//           Map.equal(map1, map2, Nat.equal, Text.equal)
//         },
//         M.equals(T.bool(false))
//       ),
//       test(
//         "maximum entry",
//         do {
//           let map = smallMap();
//           Map.maxEntry(map)
//         },
//         M.equals(T.optional(entryTestable, ?(smallSize - 1, Nat.toText(smallSize - 1))))
//       ),
//       test(
//         "minimum entry",
//         do {
//           let map = smallMap();
//           Map.minEntry(map)
//         },
//         M.equals(T.optional(entryTestable, ?(0, "0")))
//       ),
//       test(
//         "iterate keys",
//         Iter.toArray(Map.keys(smallMap())),
//         M.equals(T.array<Nat>(T.natTestable, Array.tabulate<Nat>(smallSize, func(index) { index })))
//       ),
//       test(
//         "iterate values",
//         Iter.toArray(Map.values(smallMap())),
//         M.equals(T.array<Text>(T.textTestable, Array.tabulate<Text>(smallSize, func(index) { Nat.toText(index) })))
//       ),
//       test(
//         "from iterator",
//         do {
//           let array = Array.tabulate<(Nat, Text)>(smallSize, func(index) { (index, Nat.toText(index)) });
//           let map = Map.fromIter<Nat, Text>(Iter.fromArray(array), Nat.compare);
//           for (index in Nat.range(0, smallSize)) {
//             assert (Map.get(map, Nat.compare, index) == ?Nat.toText(index))
//           };
//           assert (Map.equal(map, smallMap(), Nat.equal, Text.equal));
//           Map.size(map)
//         },
//         M.equals(T.nat(smallSize))
//       ),
//       test(
//         "for each",
//         do {
//           let map = smallMap();
//           var index = 0;
//           Map.forEach<Nat, Text>(
//             map,
//             func(key, value) {
//               assert (key == index);
//               assert (value == Nat.toText(index));
//               index += 1
//             }
//           );
//           Map.size(map)
//         },
//         M.equals(T.nat(smallSize))
//       ),
//       test(
//         "filter",
//         do {
//           let input = smallMap();
//           let output = Map.filter<Nat, Text>(
//             input,
//             Nat.compare,
//             func(key, value) {
//               key % 2 == 0
//             }
//           );
//           for (index in Nat.range(0, smallSize)) {
//             let present = Map.containsKey(output, Nat.compare, index);
//             if (index % 2 == 0) {
//               assert (present);
//               assert (Map.get(output, Nat.compare, index) == ?Nat.toText(index))
//             } else {
//               assert (not present);
//               assert (Map.get(output, Nat.compare, index) == null)
//             }
//           };
//           Map.size(output)
//         },
//         M.equals(T.nat((smallSize + 1) / 2))
//       ),
//       test(
//         "map",
//         do {
//           let input = smallMap();
//           let output = Map.map<Nat, Text, Int>(
//             input,
//             Nat.compare,
//             func(key, value) {
//               +key
//             }
//           );
//           for (index in Nat.range(0, smallSize)) {
//             assert (Map.get(output, Nat.compare, index) == +index)
//           };
//           Map.size(output)
//         },
//         M.equals(T.nat(smallSize))
//       ),
//       test(
//         "filter map",
//         do {
//           let input = smallMap();
//           let output = Map.filterMap<Nat, Text, Int>(
//             input,
//             Nat.compare,
//             func(key, value) {
//               if (key % 2 == 0) {
//                 ?+key
//               } else {
//                 null
//               }
//             }
//           );
//           for (index in Nat.range(0, smallSize)) {
//             let present = Map.containsKey(output, Nat.compare, index);
//             if (index % 2 == 0) {
//               assert (present);
//               assert (Map.get(output, Nat.compare, index) == ?+index)
//             } else {
//               assert (not present);
//               assert (Map.get(output, Nat.compare, index) == null)
//             }
//           };
//           Map.size(output)
//         },
//         M.equals(T.nat((smallSize + 1) / 2))
//       ),
//       test(
//         "fold left",
//         do {
//           let map = smallMap();
//           Map.foldLeft<Nat, Text, Nat>(
//             map,
//             0,
//             func(accumulator, key, value) {
//               accumulator + key
//             }
//           )
//         },
//         M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
//       ),
//       test(
//         "fold right",
//         do {
//           let map = smallMap();
//           Map.foldRight<Nat, Text, Nat>(
//             map,
//             0,
//             func(key, value, accumulator) {
//               key + accumulator
//             }
//           )
//         },
//         M.equals(T.nat((smallSize * (smallSize - 1)) / 2))
//       ),
//       test(
//         "all",
//         do {
//           let map = smallMap();
//           Map.all<Nat, Text>(
//             map,
//             func(key, value) {
//               key < smallSize
//             }
//           )
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "any",
//         do {
//           let map = smallMap();
//           Map.any<Nat, Text>(
//             map,
//             func(key, value) {
//               key == (smallSize - 1 : Nat)
//             }
//           )
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "to text",
//         do {
//           let map = smallMap();
//           Map.toText<Nat, Text>(map, Nat.toText, func(value) { value })
//         },
//         do {
//           var text = "";
//           for (index in Nat.range(0, smallSize)) {
//             if (text != "") {
//               text #= ", "
//             };
//             text #= "(" # Nat.toText(index) # ", " # Nat.toText(index) # ")"
//           };
//           M.equals(T.text(text))
//         }
//       ),
//       test(
//         "compare less key",
//         do {
//           let map1 = smallMap();
//           Map.delete(map1, Nat.compare, smallSize - 1);
//           let map2 = smallMap();
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare less value",
//         do {
//           let map1 = smallMap();
//           let map2 = smallMap();
//           ignore Map.put(map2, Nat.compare, smallSize - 1, "Last");
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #less);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare equal",
//         do {
//           let map1 = smallMap();
//           let map2 = smallMap();
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #equal);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare greater key",
//         do {
//           let map1 = smallMap();
//           let map2 = smallMap();
//           Map.delete(map2, Nat.compare, smallSize - 1);
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       test(
//         "compare greater value",
//         do {
//           let map1 = smallMap();
//           ignore Map.put(map1, Nat.compare, smallSize - 1, "Last");
//           let map2 = smallMap();
//           assert (Map.compare(map1, map2, Nat.compare, Text.compare) == #greater);
//           true
//         },
//         M.equals(T.bool(true))
//       ),
//       // TODO: Test freeze and thaw
//     ]
//   )
// );

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
let numberOfElements = 10_000;

run(
  suite(
    "large set",
    [
      test(
        "add",
        do {
          let set = Set.empty<Nat>();
          for (index in Nat.range(0, numberOfElements)) {
            Set.add(set, Nat.compare, index);
            assert (Set.size(set) == index + 1);
            assert (Set.contains(set, Nat.compare, index))
          };
          for (index in Nat.range(0, numberOfElements)) {
            assert (Set.contains(set, Nat.compare, index))
          };
          assert (not Set.contains(set, Nat.compare, numberOfElements));
          Set.assertValid(set, Nat.compare);
          Set.size(set)
        },
        M.equals(T.nat(numberOfElements))
      ),
      test(
        "contains",
        do {
          let set = Set.empty<Nat>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (not Set.contains(set, Nat.compare, element)) {
              Set.add(set, Nat.compare, element)
            }
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (Set.contains(set, Nat.compare, element))
          };
          true
        },
        M.equals(T.bool(true))
      ),
      test(
        "delete",
        do {
          let set = Set.empty<Nat>();
          let random = Random(randomSeed);
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (not Set.contains(set, Nat.compare, element)) {
              Set.add(set, Nat.compare, element);
            }
          };
          assert(Set.size(set) > 0);
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            assert (Set.contains(set, Nat.compare, element));
          };
          random.reset();
          for (index in Nat.range(0, numberOfElements)) {
            let element = random.next();
            if (Set.contains(set, Nat.compare, element)) {
              Set.delete(set, Nat.compare, element);
              assert (not Set.contains(set, Nat.compare, element))
            };
            assert (not Set.contains(set, Nat.compare, element))
          };
          Set.assertValid(set, Nat.compare);
          Set.size(set)
        },
        M.equals(T.nat(0))
      ),
      // test(
      //   "iterate",
      //   do {
      //     let map = Map.empty<Nat, Text>();
      //     for (index in Nat.range(0, numberOfEntries)) {
      //       Map.add(map, Nat.compare, index, Nat.toText(index))
      //     };
      //     var index = 0;
      //     for ((key, value) in Map.entries(map)) {
      //       assert (key == index);
      //       assert (value == Nat.toText(index));
      //       index += 1
      //     };
      //     index
      //   },
      //   M.equals(T.nat(numberOfEntries))
      // ),
      // test(
      //   "reverseIterate",
      //   do {
      //     let map = Map.empty<Nat, Text>();
      //     for (index in Nat.range(0, numberOfEntries)) {
      //       Map.add(map, Nat.compare, index, Nat.toText(index))
      //     };
      //     var index = numberOfEntries;
      //     for ((key, value) in Map.reverseEntries(map)) {
      //       index -= 1;
      //       assert (key == index);
      //       assert (value == Nat.toText(index))
      //     };
      //     index
      //   },
      //   M.equals(T.nat(0))
      // )
    ]
  )
)
