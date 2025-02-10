import Stack "../../src/pure/Stack";
import Nat "../../src/Nat";
import Order "../../src/Order";
import Debug "../../src/Debug";
import Int "../../src/Int";
import Iter "../../src/Iter";
import Result "../../src/Result";
import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

/*

FIXME:

* flatten is quadratic
* Array.mo doesn't implement `all`, `some`, `compare`
* merge takes lte predicate of type (T,T)-> Bool, not comparison of type: (T,T) -> Ord
* split is not tail recursive and calls redundant helpers

TODO:
  * most of these test don't test evaluation order or short-circuiting.
  * from/to(Var)Array functions could use matchers tests beyond the existing assert only tests
*/

func ordT(o : Order.Order) : T.TestableItem<Order.Order> = {
  item = o;
  display = func(o : Order.Order) : Text { debug_show (o) };
  equals = Order.equal
};

type X = Nat;

func opnatEq(a : ?Nat, b : ?Nat) : Bool {
  switch (a, b) {
    case (null, null) { true };
    case (?aaa, ?bbb) { aaa == bbb };
    case (_, _) { false }
  }
};

// Temporarily unused because of the comment-disabled test cases below.
// func opnat_isnull(a : ?Nat) : Bool {
//   switch a {
//     case (null) { true };
//     case (?aaa) { false }
//   }
// };

// ## Construction
let l1 = Stack.empty<X>();
let l2 = Stack.push<X>(l1, 2);
let l3 = Stack.push<X>(l2, 3);

// ## Projection -- use nth
assert (opnatEq(Stack.get<X>(l3, 0), ?3));
assert (opnatEq(Stack.get<X>(l3, 1), ?2));
assert (opnatEq(Stack.get<X>(l3, 2), null));
//assert (opnatEq (hd<X>(l3), ?3));
//assert (opnatEq (hd<X>(l2), ?2));
//assert (opnat_isnull(hd<X>(l1)));

/*
   // ## Projection -- use nth
   assert (opnatEq(nth<X>(l3, 0), ?3));
   assert (opnatEq(nth<X>(l3, 1), ?2));
   assert (opnatEq(nth<X>(l3, 2), null));
   assert (opnatEq (hd<X>(l3), ?3));
   assert (opnatEq (hd<X>(l2), ?2));
   assert (opnat_isnull(hd<X>(l1)));
   */

// ## Deconstruction
let (a1, _t1) = Stack.pop<X>(l3);
assert (opnatEq(a1, ?3));
let (a2, _t2) = Stack.pop<X>(l2);
assert (opnatEq(a2, ?2));
let (a3, t3) = Stack.pop<X>(l1);
assert (opnatEq(a3, null));
assert (Stack.isEmpty<X>(t3));

// ## Stack functions
assert (Stack.size<X>(l1) == 0);
assert (Stack.size<X>(l2) == 1);
assert (Stack.size<X>(l3) == 2);

// ## Stack functions
assert (Stack.size<X>(l1) == 0);
assert (Stack.size<X>(l2) == 1);
assert (Stack.size<X>(l3) == 2);

do {
  Debug.print("  flatten");

  let expected : Stack.Stack<Nat> = ?(1, ?(2, ?(3, null)));
  // [[1, 2], [3]]
  let nested : Stack.Stack<Stack.Stack<Nat>> = ?(?(1, ?(2, null)), ?(?(3, null), null));
  let actual = Stack.flatten<Nat>(nested);

  assert Stack.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 });

};

do {
  Debug.print("  fromArray");

  let expected : Stack.Stack<Nat> = ?(1, ?(2, ?(3, Stack.empty<Nat>())));
  let array = [1, 2, 3];
  let actual = Stack.fromArray<Nat>(array);

  assert Stack.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 })
};

do {
  Debug.print("  fromVarArray");

  let expected : Stack.Stack<Nat> = ?(1, ?(2, ?(3, Stack.empty<Nat>())));
  let array = [var 1, 2, 3];
  let actual = Stack.fromVarArray<Nat>(array);

  assert Stack.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 })
};

do {
  Debug.print("  toArray");

  let expected = [1, 2, 3];
  let list : Stack.Stack<Nat> = ?(1, ?(2, ?(3, Stack.empty<Nat>())));
  let actual = Stack.toArray<Nat>(list);

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toVarArray");

  let expected = [var 1, 2, 3];
  let list : Stack.Stack<Nat> = ?(1, ?(2, ?(3, Stack.empty<Nat>())));
  let actual = Stack.toVarArray<Nat>(list);

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toIter");

  let list : Stack.Stack<Nat> = ?(1, ?(2, ?(3, Stack.empty<Nat>())));
  let _actual = Stack.toIter<Nat>(list);
  let actual = [var 0, 0, 0];
  let expected = [1, 2, 3];

  Iter.iterate<Nat>(_actual, func(x, i) { actual[i] := x });

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

func makeNatural(x : Int) : Result.Result<Nat, Text> = if (x >= 0) {
  #ok(Int.abs(x))
} else { #err(Int.toText(x) # " is not a natural number.") };

func listRes(itm : Result.Result<Stack.Stack<Nat>, Text>) : T.TestableItem<Result.Result<Stack.Stack<Nat>, Text>> {
  let resT = T.resultTestable(T.listTestable<Nat>(T.intTestable), T.textTestable);
  { display = resT.display; equals = resT.equals; item = itm }
};



let mapResult = Suite.suite(
  "mapResult",
  [
    Suite.test(
      "empty stack",
      Stack.mapResult<Int, Nat, Text>(Stack.empty(), makeNatural),
      M.equals(listRes(#ok(Stack.empty())))
    ),
    Suite.test(
      "success",
      Stack.mapResult<Int, Nat, Text>(?(1, ?(2, ?(3, null))), makeNatural),
      M.equals(listRes(#ok(?(1, ?(2, ?(3, null))))))
    ),
    Suite.test(
      "fail fast",
      Stack.mapResult<Int, Nat, Text>(?(-1, ?(2, ?(3, null))), makeNatural),
      M.equals(listRes(#err("-1 is not a natural number.")))
    ),
    Suite.test(
      "fail last",
      Stack.mapResult<Int, Nat, Text>(?(1, ?(2, ?(-3, null))), makeNatural),
      M.equals(listRes(#err("-3 is not a natural number.")))
    )
  ]
);

Suite.run(Suite.suite("Stack", [mapResult]));

let replicate = Suite.suite(
  "replicate",
  [
    Suite.test(
      "empty-list",
      Stack.repeat<Nat>(0, 0),
      M.equals(
        T.list(T.natTestable, Stack.empty<Nat>())
      )
    ),
    Suite.test(
      "small-list",
      Stack.repeat(3, 0),
      M.equals(
        T.list<Nat>(T.natTestable, ?(0, ?(0, ?(0, null))))
      )
    )
  ]
);

let tabulate = Suite.suite(
  "tabulate",
  [
    Suite.test(
      "empty-list",
      Stack.tabulate<Nat>(0, func i { i }),
      M.equals(
        T.list(T.natTestable, Stack.empty<Nat>())
      )
    ),
    Suite.test(
      "small-list",
      Stack.tabulate<Nat>(3, func i { i * 2 }),
      M.equals(
        T.list<Nat>(T.natTestable, ?(0, ?(2, ?(4, null))))
      )
    ),
    Suite.test(
      "large-list",
      Stack.tabulate<Nat>(10000, func i { 0 }),
      M.equals(
        T.list<Nat>(T.natTestable, Stack.repeat(10000, 0))
      )
    )
  ]
);

let append = Suite.suite(
  "append",
  [
    Suite.test(
      "small-list",
      Stack.concat(
        Stack.tabulate<Nat>(10, func i { i }),
        Stack.tabulate<Nat>(10, func i { i + 10 })
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(20, func i { i }))
      )
    ),
    Suite.test(
      "large-list",
      Stack.concat(
        Stack.tabulate<Nat>(10000, func i { i }),
        Stack.tabulate<Nat>(10000, func i { i + 10000 })
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(20000, func i { i }))
      )
    )
  ]
);

let isNil = Suite.suite(
  "isNil",
  [
    Suite.test(
      "empty",
      Stack.isEmpty(Stack.empty<Nat>()),
       M.equals(T.bool(true))
    ),
    Suite.test(
      "singleton",
      Stack.isEmpty(?(3, null)),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "nary",
      Stack.isEmpty(?(1, ?(2, ?(3, null)))),
      M.equals(T.bool(false))
    )
  ]
);

let push = Suite.suite(
  "push",
  [
    Suite.test(
      "empty",
      Stack.push(0, Stack.empty<Nat>()),
      M.equals(T.list(T.natTestable, ?(0, null)))
    ),
    Suite.test(
      "singleton",
      Stack.push(1, Stack.push(0, Stack.empty<Nat>())),
      M.equals(T.list(T.natTestable, ?(1, ?(0, null))))
    ),
    Suite.test(
      "nary",
      Stack.push(2, Stack.push(1, Stack.push(0, Stack.empty<Nat>()))),
      M.equals(T.list(T.natTestable, ?(2, ?(1, ?(0, null)))))
    )
  ]
);


let last = Suite.suite(
  "last",
  [
    Suite.test(
      "empty list",
      Stack.last(Stack.empty<Nat>()),
       M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton",
      Stack.last(?(3, null)),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "threesome",
      Stack.last(?(1, ?(2, ?(3, null)))),
      M.equals(T.optional(T.natTestable, ?3))
    )
  ]
);

let pop = Suite.suite(
  "pop",
  [
    Suite.test(
      "empty list",
      Stack.pop(Stack.empty<Nat>()),
      M.equals(T.tuple2(T.optionalTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (null, null) : (?Nat, Stack.Stack<Nat>) ))
    ),
    Suite.test(
      "singleton",
      Stack.pop(?(3, null)),
      M.equals(T.tuple2(T.optionalTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?3, null) : (?Nat, Stack.Stack<Nat>) ))
    ),
    Suite.test(
      "threesome",
      Stack.pop(?(1, ?(2, ?(3, null)))),
      M.equals(T.tuple2(T.optionalTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?1, ?(2, ?(3, null))) : (?Nat, Stack.Stack<Nat>) ))
    ),
  ]
);

let size = Suite.suite(
  "size",
  [
    Suite.test(
      "empty list",
      Stack.size(Stack.empty<Nat>()),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "singleton",
      Stack.size(?(3, null)),
      M.equals(T.nat(1))
    ),
    Suite.test(
      "threesome",
      Stack.size(?(1, ?(2, ?(3, null)))),
      M.equals(T.nat(3))
    ),
  ]
);

let get = Suite.suite(
  "get",
  [
    Suite.test(
      "empty list",
      Stack.get(Stack.empty<Nat>(), 0),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton-0",
      Stack.get(?(3, null), 0),
      M.equals(T.optional(T.natTestable, ?3 : ?Nat))
    ),
     Suite.test(
      "singleton-1",
      Stack.get(?(3, null), 1),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton-2",
      Stack.get(?(3, null), 2),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "threesome-0",
      Stack.get(?(1, ?(2, ?(3, null))), 0),
      M.equals(T.optional(T.natTestable, ?1 : ?Nat))
    ),
     Suite.test(
      "threesome-1",
      Stack.get(?(1, ?(2, ?(3, null))), 1),
      M.equals(T.optional(T.natTestable, ?2 : ?Nat))
    ),
     Suite.test(
      "threesome-3",
      Stack.get(?(1, ?(2, ?(3, null))), 3),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "threesome-4",
      Stack.get(?(1, ?(2, ?(3, null))), 4),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    )
  ]
);


let reverse = Suite.suite(
  "reverse",
  [
    Suite.test(
      "empty list",
      Stack.reverse(Stack.empty<Nat>()),
      M.equals(T.list(T.natTestable, null : Stack.Stack<Nat>))

    ),
    Suite.test(
      "singleton",
      Stack.reverse(?(3, null)),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "threesome",
      Stack.reverse(?(1, ?(2, ?(3, null)))),
      M.equals(T.list(T.natTestable, ?(3, ?(2, ?(1, null)))))
    ),
  ]
);

let iterate = Suite.suite(
  "iterate",
  [
    Suite.test(
      "empty list",
      do {
        var t = "";
        Stack.iterate<Nat>(Stack.empty<Nat>(), func n { t #= debug_show n });
        t
      },
      M.equals(T.text(""))
    ),
    Suite.test(
      "singleton",
      do {
        var t = "";
        Stack.iterate<Nat>(?(3, null), func n { t #= debug_show n });
        t
      },
      M.equals(T.text("3"))
    ),
    Suite.test(
      "threesome",
      do {
        var t = "";
        Stack.iterate<Nat>(?(1, ?(2, ?(3, null))), func n { t #= debug_show n });
        t
      },
      M.equals(T.text("123"))
    ),
  ]
);

let map = Suite.suite(
  "map",
  [
    Suite.test(
      "empty list",
      Stack.map<Nat,Nat>(
       Stack.empty<Nat>(),
      func n { n + 1 }),
      M.equals(T.list(T.natTestable, null : Stack.Stack<Nat>))
    ),
    Suite.test(
      "singleton",
      Stack.map<Nat,Nat>(
        ?(3, null),
        func n { n + 1 }),
      M.equals(T.list(T.natTestable, ?(4, null)))
    ),
    Suite.test(
      "threesome",
      Stack.map<Nat,Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n + 1 }),
      M.equals(T.list(T.natTestable, ?(2, ?(3, ?(4, null)))))
    ),
  ]
);


let filter = Suite.suite(
  "filter",
  [
    Suite.test(
      "empty list",
      Stack.filter<Nat>(
       Stack.empty<Nat>(),
       func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, null : Stack.Stack<Nat>))
    ),
    Suite.test(
      "singleton",
      Stack.filter<Nat>(
        ?(3, null),
      func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, null : Stack.Stack<Nat>))
    ),
    Suite.test(
      "threesome",
      Stack.filter<Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, ?(2, null)))
    ),
    Suite.test(
      "foursome",
      Stack.filter<Nat>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { n % 2 == 0 }),
      M.equals(T.list(T.natTestable, ?(2, ?(4, null))))
    ),
  ]
);

let partition = Suite.suite(
  "partition",
  [
    Suite.test(
      "empty list",
      Stack.partition<Nat>(
       Stack.empty<Nat>(),
       func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (null, null) : (Stack.Stack<Nat>, Stack.Stack<Nat>)))
    ),
    Suite.test(
      "singleton-false",
      Stack.partition<Nat>(
        ?(3, null),
      func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (null, ?(3, null)) : (Stack.Stack<Nat>, Stack.Stack<Nat>)))

    ),
    Suite.test(
      "singleton-true",
      Stack.partition<Nat>(
        ?(2, null),
      func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?(2, null), null) : (Stack.Stack<Nat>, Stack.Stack<Nat>)))
    ),
    Suite.test(
      "threesome",
      Stack.partition<Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?(2, null), ?(1, ?(3, null))) : (Stack.Stack<Nat>, Stack.Stack<Nat>)))
    ),
    Suite.test(
      "foursome",
      Stack.partition<Nat>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { n % 2 == 0 }),
      M.equals(T.tuple2(T.listTestable(T.natTestable),
                        T.listTestable(T.natTestable),
                        (?(2, ?(4, null)),
                         ?(1, ?(3, null))) : (Stack.Stack<Nat>, Stack.Stack<Nat>)))
    ),
  ]
);


let mapFilter = Suite.suite(
  "mapFilter",
  [
    Suite.test(
      "empty list",
      Stack.mapFilter<Nat, Text>(
       Stack.empty<Nat>(),
       func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, null : Stack.Stack<Text>))
    ),
    Suite.test(
      "singleton",
      Stack.mapFilter<Nat, Text>(
        ?(3, null),
       func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, null : Stack.Stack<Text>))
    ),
    Suite.test(
      "threesome",
      Stack.mapFilter<Nat, Text>(
        ?(1, ?(2, ?(3, null))),
       func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, ?("2", null)))
    ),
    Suite.test(
      "foursome",
      Stack.mapFilter<Nat, Text>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { if (n % 2 == 0) ?(debug_show n) else null }),
      M.equals(T.list(T.textTestable, ?("2", ?("4", null))))
    ),
  ]
);


let flatten = Suite.suite(
  "flatten",
  [
    Suite.test(
      "small-list",
      Stack.flatten(
        Stack.tabulate<Stack.Stack<Nat>>(10, func i { Stack.tabulate<Nat>(10, func j { i * 10 + j })})
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(100, func i { i }))
      )
    ),
    Suite.test(
      "small-nulls",
      Stack.flatten(
        Stack.tabulate<Stack.Stack<Nat>>(10, func i { null : Stack.Stack<Nat> })
      ),
      M.equals(
        T.list(T.natTestable, null : Stack.Stack<Nat>)
      )
    ),
   Suite.test(
      "flatten",
      Stack.flatten<Int>(?(?(1, ?(2, ?(3, null))),
                          ?(null,
                            ?(?(1, null),
                              null)))),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten empty start",
      Stack.flatten<Int>(?(null,
                         ?(?(1, ?(2, (?(3, null)))),
                           ?(null,
                             ?(?(1, null),
                               null))))),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten empty end",
      Stack.flatten<Int>(?(?(1, ?(2, (?(3, null)))),
                          ?(null,
                            ?(?(1, null),
                              ?(null,
                                null))))),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten singleton",
      Stack.flatten<Int>(?(?(1, ?(2, (?(3, null)))),
                          null)),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, (?(3, null))))))
    ),
    Suite.test(
      "flatten singleton empty",
      Stack.flatten<Int>(?(null, null)),
      M.equals(T.list<Int>(T.intTestable, null))
    ),
    Suite.test(
      "flatten empty",
      Stack.flatten<Int>(null),
      M.equals(T.list<Int>(T.intTestable, null))
    ),
  ]
);

let singleton = Suite.suite(
  "singleton",
  [
    Suite.test(
      "singleton",
      Stack.singleton<Int>(0),
      M.equals(T.list<Int>(T.intTestable, ?(0, null)))
    ),
  ]
);

let take = Suite.suite(
  "take",
  [
    Suite.test(
      "empty list",
      Stack.take(Stack.empty<Nat>(), 0),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "singleton-0",
      Stack.take(?(3, null), 0),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
     Suite.test(
      "singleton-1",
      Stack.take(?(3, null), 1),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "singleton-2",
      Stack.take(?(3, null), 2),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "threesome-0",
      Stack.take(?(1, ?(2, ?(3, null))), 0),
      M.equals(T.list(T.natTestable, null : Stack.Stack<Nat>))
    ),
     Suite.test(
      "threesome-1",
      Stack.take(?(1, ?(2, ?(3, null))), 1),
      M.equals(T.list(T.natTestable, ?(1, null)))
    ),
     Suite.test(
      "threesome-3",
      Stack.take(?(1, ?(2, ?(3, null))), 3),
      M.equals(T.list(T.natTestable, ?(1, ?(2, ?(3, null)))))
    ),
    Suite.test(
      "threesome-4",
      Stack.take(?(1, ?(2, ?(3, null))), 4),
      M.equals(T.list(T.natTestable, ?(1, ?(2, ?(3, null)))))
    )
  ]
);

let drop = Suite.suite(
  "drop",
  [
    Suite.test(
      "empty list",
      Stack.drop(Stack.empty<Nat>(), 0),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "singleton-0",
      Stack.drop(?(3, null), 0),
      M.equals(T.list<Nat>(T.natTestable, ?(3,null)))
    ),
     Suite.test(
      "singleton-1",
      Stack.drop(?(3, null), 1),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "singleton-2",
      Stack.drop(?(3, null), 2),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "threesome-0",
      Stack.drop(?(1, ?(2, ?(3, null))), 0),
      M.equals(T.list<Nat>(T.natTestable, ?(1, ?(2, ?(3, null)))))
    ),
     Suite.test(
      "threesome-1",
      Stack.drop(?(1, ?(2, ?(3, null))), 1),
      M.equals(T.list(T.natTestable, ?(2, ?(3, null))))
    ),
     Suite.test(
      "threesome-2",
      Stack.drop(?(1, ?(2, ?(3, null))), 2),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "threesome-3",
      Stack.drop(?(1, ?(2, ?(3, null))), 3),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "threesome-4",
      Stack.drop(?(1, ?(2, ?(3, null))), 4),
      M.equals(T.list<Nat>(T.natTestable, null))
    )
  ]
);

let foldLeft = Suite.suite(
  "foldLeft", [
  Suite.test(
      "foldLeft",
      Stack.foldLeft<Text, Text>(?("a", ?("b", ?("c", null))), "", func(acc, x) = acc # x),
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "foldLeft empty",
      Stack.foldLeft<Text, Text>(null, "base", func(x, acc) = acc # x),
      M.equals(T.text("base"))
    ),
  ]
);

let foldRight = Suite.suite(
  "foldRight", [
    Suite.test(
      "foldRight",
      Stack.foldRight<Text, Text>(?("a", ?("b", ?("c", null))), "", func(x, acc) = acc # x),
      M.equals(T.text("cba"))
    ),
    Suite.test(
      "foldRight empty",
      Stack.foldRight<Text, Text>(null, "base", func(x, acc) = acc # x),
      M.equals(T.text("base"))
    ),
  ]
);

let find = Suite.suite(
  "find", [
    Suite.test(
      "find",
      Stack.find<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x == 9),
      M.equals(T.optional(T.natTestable, ?9))
    ),
    Suite.test(
      "find fail",
      Stack.find<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "find empty",
      Stack.find<Nat>(null, func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
  ]
);

let all = Suite.suite(
  "all", [
    Suite.test(
      "all non-empty true",
      Stack.all<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x > 0),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "all non-empty false",
      Stack.all<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x =  x > 1),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "all empty",
      Stack.all<Nat>(null, func x = x >= 1),
      M.equals(T.bool(true))
    ),
  ]
);

let any = Suite.suite(
  "any", [
    Suite.test(
      "non-empty true",
      Stack.any<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x >= 8),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "non-empty false",
      Stack.any<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x =  x > 9),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "empty",
      Stack.any<Nat>(null, func x = true),
      M.equals(T.bool(false))
    ),
  ]
);


let merge = Suite.suite(
  "merge",
  [
    Suite.test(
      "small-list",
      Stack.merge<Nat>(
        Stack.tabulate<Nat>(10, func i { 2 * i  }),
        Stack.tabulate<Nat>(10, func i { 2 * i + 1 }),
        func (i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(20, func i { i }))
      )
    ),

    Suite.test(
      "small-list-alternating",
      Stack.merge<Nat>(
        Stack.tabulate<Nat>(10, func i {
          if (i % 2 == 0)
            { 2 * i }
          else
            { 2 * i + 1 } }),
        Stack.tabulate<Nat>(10, func i {
          if (not (i % 2 == 0)) // flipped!
            { 2 * i }
          else
            { 2 * i + 1 }
        }),
        func (i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(20, func i { i }))
      )
    ),

    Suite.test(
      "small-list-equal",
      Stack.merge<Nat>(
        Stack.tabulate<Nat>(10, func i { 2 * i  }),
        Stack.tabulate<Nat>(10, func i { 2 * i }),
        func (i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(20, func i { 2 * (i / 2) }))
      )
    ),

    Suite.test(
      "large-list",
      Stack.merge<Nat>(
        Stack.tabulate<Nat>(1000, func i { 2 * i }),
        Stack.tabulate<Nat>(1000, func i { 2 * i + 1 }),
        func (i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(2000, func i { i }))
      )
    )
  ]
);


let compare = Suite.suite(
  "compare",
  [
    Suite.test(
      "small-list-equal",
      Stack.compare<Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(10, func i { i }),
        Nat.compare
      ),
      M.equals(ordT(#equal))
      ),
    Suite.test(
      "small-list-less",
      Stack.compare<Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(11, func i { i }),
        Nat.compare
      ),
      M.equals(ordT(#less))
     ),
    Suite.test(
      "small-list-less",
      Stack.compare<Nat>(
        Stack.tabulate<Nat>(11, func i { i  }),
        Stack.tabulate<Nat>(10, func i { i }),
        Nat.compare
      ),
      M.equals(ordT(#greater))
     ),
    Suite.test(
      "empty-list-equal",
      Stack.compare<Nat>(
        null,
        null,
        Nat.compare
      ),
      M.equals(ordT(#equal))
      ),
    Suite.test(
      "small-list-less",
      Stack.compare<Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(10, func i { if (i < 9) { i } else { i + 1 } }),
        Nat.compare
      ),
      M.equals(ordT(#less))
     ),
    Suite.test(
      "small-list-greater",
      Stack.compare<Nat>(
        Stack.tabulate<Nat>(10, func i { if (i < 9) { i } else { i + 1 } }),
        Stack.tabulate<Nat>(10, func i { i }),
        Nat.compare
      ),
      M.equals(ordT(#greater))
     ),
  ]
);

let equal = Suite.suite(
  "equal",
  [
    Suite.test(
      "small-list-equal",
      Stack.equal<Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(10, func i { i }),
        Nat.equal
      ),
      M.equals(T.bool(true))
      ),
    Suite.test(
      "small-list-less",
      Stack.equal<Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(11, func i { i }),
        Nat.equal
      ),
      M.equals(T.bool(false))
     ),
    Suite.test(
      "small-list-less",
      Stack.equal<Nat>(
        Stack.tabulate<Nat>(11, func i { i  }),
        Stack.tabulate<Nat>(10, func i { i }),
        Nat.equal
      ),
      M.equals(T.bool(false))
     ),
    Suite.test(
      "empty-list-equal",
      Stack.equal<Nat>(
        null,
        null,
        Nat.equal
      ),
      M.equals(T.bool(true))
      ),
    Suite.test(
      "small-list-less",
      Stack.equal<Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(10, func i { if (i < 9) { i } else { i + 1 } }),
        Nat.equal
      ),
      M.equals(T.bool(false))
     ),
    Suite.test(
      "small-list-greater",
      Stack.equal<Nat>(
        Stack.tabulate<Nat>(10, func i { if (i < 9) { i } else { i + 1 } }),
        Stack.tabulate<Nat>(10, func i { i }),
        Nat.equal
      ),
      M.equals(T.bool(false))
     ),
  ]
);

let zipWith = Suite.suite(
  "zipWith",
  [
    Suite.test(
      "small-list-equal-len",
      Stack.zipWith<Nat, Nat, Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(10, func i { i }),
        func (i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(10, func i { i  *  i}))
      )),
    Suite.test(
      "small-list-shorter",
      Stack.zipWith<Nat, Nat, Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(11, func i { i }),
        func (i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(10, func i { i  *  i}))
      )),
    Suite.test(
      "small-list-longer",
      Stack.zipWith<Nat, Nat, Nat>(
        Stack.tabulate<Nat>(11, func i { i  }),
        Stack.tabulate<Nat>(10, func i { i }),
        func (i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, Stack.tabulate<Nat>(10, func i { i  *  i}))
      )),
    Suite.test(
      "small-list-empty-left",
      Stack.zipWith<Nat, Nat, Nat>(
        null,
        Stack.tabulate<Nat>(10, func i { i }),
        func (i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, null : Stack.Stack<Nat>)
      )),
    Suite.test(
      "small-list-empty-right",
      Stack.zipWith<Nat, Nat, Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        null,
        func (i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, null : Stack.Stack<Nat>)
      )),
    Suite.test(
      "small-list-both-empty",
      Stack.zipWith<Nat, Nat, Nat>(
        null,
        null,
        func (i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, null : Stack.Stack<Nat>)
      )),
  ]
);

let zip = Suite.suite(
  "zip",
  [
    Suite.test(
      "small-list-equal-len",
      Stack.zip<Nat, Nat>(
        Stack.tabulate<Nat>(10, func i { i }),
        Stack.tabulate<Nat>(10, func i { i })
      ),
      M.equals(
        T.list(T.tuple2Testable(T.natTestable,T.natTestable),
          Stack.tabulate<(Nat, Nat)>(10, func i { (i, i) }))
      )),
    Suite.test(
      "small-list-shorter",
      Stack.zip<Nat, Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        Stack.tabulate<Nat>(11, func i { i })
      ),
      M.equals(
        T.list(T.tuple2Testable(T.natTestable,T.natTestable),
          Stack.tabulate<(Nat, Nat)>(10, func i { (i, i) }))
      )),
    Suite.test(
      "small-list-longer",
      Stack.zip<Nat, Nat>(
        Stack.tabulate<Nat>(11, func i { i  }),
        Stack.tabulate<Nat>(10, func i { i })
      ),
      M.equals(
        T.list(T.tuple2Testable(T.natTestable,T.natTestable),
          Stack.tabulate<(Nat, Nat)>(10, func i { (i, i) }))
      )),
    Suite.test(
      "small-list-empty-left",
      Stack.zip<Nat, Nat>(
        null,
        Stack.tabulate<Nat>(10, func i { i })
      ),
      M.equals(
        T.list(T.tuple2Testable(T.natTestable,T.natTestable),
          null : Stack.Stack<(Nat, Nat)>)
      )),
    Suite.test(
      "small-list-empty-right",
      Stack.zip<Nat, Nat>(
        Stack.tabulate<Nat>(10, func i { i  }),
        null
      ),
      M.equals(
        T.list(T.tuple2Testable(T.natTestable,T.natTestable),
          null : Stack.Stack<(Nat, Nat)>)
      )),
    Suite.test(
      "small-list-both-empty",
      Stack.zip<Nat, Nat>(
        null,
        null
      ),
      M.equals(
        T.list(T.tuple2Testable(T.natTestable,T.natTestable),
          null : Stack.Stack<(Nat, Nat)>)
      )),
  ]
);

let split = Suite.suite(
  "split",
  [
    Suite.test(
      "split-zero-nonempty",
      Stack.split<Nat>(0,
        Stack.tabulate<Nat>(10, func i { i }),
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (null : Stack.Stack<Nat>,
           Stack.tabulate<Nat>(10, func i { i })))
      )),

    Suite.test(
      "split-zero-empty",
      Stack.split<Nat>(0,
        null
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (null : Stack.Stack<Nat>,
           null : Stack.Stack<Nat>))
      )),

    Suite.test(
      "split-nonzero-empty",
      Stack.split<Nat>(15,
        null
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (null : Stack.Stack<Nat>,
           null : Stack.Stack<Nat>))
      )),

    Suite.test(
      "split-too-few",
      Stack.split<Nat>(15,
        Stack.tabulate<Nat>(10, func i { i }),
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (Stack.tabulate<Nat>(10, func i { i }),
           null : Stack.Stack<Nat>
           ))
      )),

    Suite.test(
      "split-too-many",
      Stack.split<Nat>(10,
        Stack.tabulate<Nat>(15, func i { i }),
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (Stack.tabulate<Nat>(10, func i { i }),
           Stack.tabulate<Nat>(5, func i { 10 + i })
           ))
      )),

    Suite.test(
      "split-one",
      Stack.split<Nat>(1,
        Stack.tabulate<Nat>(15, func i { i }),
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (Stack.tabulate<Nat>(1, func i { i }),
           Stack.tabulate<Nat>(14, func i { 1 + i })
           ))
      )),

  ]
);

let chunks = Suite.suite(
  "chunks",
  [
    Suite.test(
      "five-even-split",
      Stack.chunks<Nat>(
        Stack.tabulate<Nat>(10, func i { i }),
        5,
      ),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (Stack.tabulate<Stack.Stack<Nat>>(2, func i {
            Stack.tabulate<Nat>(5, func j { i * 5 + j }) })))
      )),
    Suite.test(
      "five-remainder",
      Stack.chunks<Nat>(5,
        Stack.tabulate<Nat>(13, func i { i }),
      ),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (Stack.tabulate<Stack.Stack<Nat>>((13+4)/5, func i {
            Stack.tabulate<Nat>(if (i < 13 / 5) 5 else 13 % 5, func j { i * 5 + j }) })))
      )),
    Suite.test(
      "five-too-few",
      Stack.chunks<Nat>(5,
        Stack.tabulate<Nat>(3, func i { i }),
      ),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (Stack.tabulate<Stack.Stack<Nat>>(1, func i {
            Stack.tabulate<Nat>(3, func j { i * 5 + j }) })))
      )),
    Suite.test(
      "split-zero",
      Stack.chunks<Nat>(0,
        Stack.tabulate<Nat>(5, func i { i }),
      ),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (null : Stack.Stack<Stack.Stack<Nat>>))
      )),
  ]
);


Suite.run(Suite.suite("Stack", [
  mapResult,
  replicate,
  tabulate,
  append,
  isNil,
  push,
  last,
  pop,
  size,
  get,
  reverse,
  iterate,
  map,
  filter,
  partition,
  mapFilter,
  flatten,
  singleton,
  take,
  drop,
  foldLeft,
  foldRight,
  find,
  all,
  any,
  merge,
  compare,
  equal,
  zipWith,
  zip,
  split,
  chunks
  ]))

