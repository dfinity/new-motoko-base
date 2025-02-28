// @testmode wasi

import Suite "mo:matchers/Suite";
import M "mo:matchers/Matchers";
import T "mo:matchers/Testable";

import List "../../src/pure/List";
import Nat "../../src/Nat";
import Order "../../src/Order";
import Debug "../../src/Debug";
import Int "../../src/Int";
import Result "../../src/Result";

/*

FIXME: (CHECK these)

* flatten is quadratic
* Array.mo doesn't implement `all`, `any`, `compare`
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
let l1 = List.empty<X>();
let l2 = List.push<X>(l1, 2);
let l3 = List.push<X>(l2, 3);

// ## Projection -- use nth
assert (opnatEq(List.get<X>(l3, 0), ?3));
assert (opnatEq(List.get<X>(l3, 1), ?2));
assert (opnatEq(List.get<X>(l3, 2), null));
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
let (a1, _t1) = List.pop<X>(l3);
assert (opnatEq(a1, ?3));
let (a2, _t2) = List.pop<X>(l2);
assert (opnatEq(a2, ?2));
let (a3, t3) = List.pop<X>(l1);
assert (opnatEq(a3, null));
assert (List.isEmpty<X>(t3));

// ## List functions
assert (List.size<X>(l1) == 0);
assert (List.size<X>(l2) == 1);
assert (List.size<X>(l3) == 2);

do {
  Debug.print("  flatten");

  let expected : List.List<Nat> = ?(1, ?(2, ?(3, null)));
  // [[1, 2], [3]]
  let nested : List.List<List.List<Nat>> = ?(?(1, ?(2, null)), ?(?(3, null), null));
  let actual = List.flatten<Nat>(nested);

  assert List.equal<Nat>(expected, actual, func(x1, x2) = x1 == x2);

};

do {
  Debug.print("  fromArray");

  let expected : List.List<Nat> = ?(1, ?(2, ?(3, List.empty<Nat>())));
  let array = [1, 2, 3];
  let actual = List.fromArray<Nat>(array);

  assert List.equal<Nat>(expected, actual, func(x1, x2) = x1 == x2)
};

do {
  Debug.print("  fromVarArray");

  let expected : List.List<Nat> = ?(1, ?(2, ?(3, List.empty<Nat>())));
  let array = [var 1, 2, 3];
  let actual = List.fromVarArray<Nat>(array);

  assert List.equal<Nat>(expected, actual, func(x1, x2) = x1 == x2)
};

do {
  Debug.print("  toArray");

  let expected = [1, 2, 3];
  let list : List.List<Nat> = ?(1, ?(2, ?(3, List.empty<Nat>())));
  let actual = List.toArray<Nat>(list);

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toVarArray");

  let expected = [var 1, 2, 3];
  let list : List.List<Nat> = ?(1, ?(2, ?(3, List.empty<Nat>())));
  let actual = List.toVarArray<Nat>(list);

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  values");

  let list : List.List<Nat> = ?(1, ?(2, ?(3, List.empty<Nat>())));
  let vals = List.values<Nat>(list);
  let actual = [var 0, 0, 0];
  let expected = [1, 2, 3];

  var i = 0;
  for (x in vals) {
    actual[i] := x;
    i += 1
  };

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

func makeNatural(x : Int) : Result.Result<Nat, Text> = if (x >= 0) {
  #ok(Int.abs(x))
} else { #err(Int.toText(x) # " is not a natural number.") };

func listRes(itm : Result.Result<List.List<Nat>, Text>) : T.TestableItem<Result.Result<List.List<Nat>, Text>> {
  let resT = T.resultTestable(T.listTestable<Nat>(T.intTestable), T.textTestable);
  { display = resT.display; equals = resT.equals; item = itm }
};

object unit : T.TestableItem<()> {
  public let item = ();
  public func display(()) : Text = "()";
  public func equals((), ()) : Bool = true
};

let hugeList = List.repeat('Y', 100_000);

let mapResult = Suite.suite(
  "mapResult",
  [
    Suite.test(
      "empty list",
      List.mapResult<Int, Nat, Text>(List.empty(), makeNatural),
      M.equals(listRes(#ok(List.empty())))
    ),
    Suite.test(
      "success",
      List.mapResult<Int, Nat, Text>(?(1, ?(2, ?(3, null))), makeNatural),
      M.equals(listRes(#ok(?(1, ?(2, ?(3, null))))))
    ),
    Suite.test(
      "fail fast",
      List.mapResult<Int, Nat, Text>(?(-1, ?(2, ?(3, null))), makeNatural),
      M.equals(listRes(#err("-1 is not a natural number.")))
    ),
    Suite.test(
      "fail last",
      List.mapResult<Int, Nat, Text>(?(1, ?(2, ?(-3, null))), makeNatural),
      M.equals(listRes(#err("-3 is not a natural number.")))
    ),
    Suite.test(
      "large",
      List.mapResult<Char, (), ()>(hugeList, func _ = #ok),
      M.equals(T.result<List.List<()>, ()>(T.listTestable<()> unit, unit, #ok null))
    )
  ]
);

Suite.run(Suite.suite("List", [mapResult]));

let repeat = Suite.suite(
  "repeat",
  [
    Suite.test(
      "empty-list",
      List.repeat<Nat>(0, 0),
      M.equals(
        T.list(T.natTestable, List.empty<Nat>())
      )
    ),
    Suite.test(
      "small-list",
      List.repeat(0, 3),
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
      List.tabulate<Nat>(0, func i = i),
      M.equals(
        T.list(T.natTestable, List.empty<Nat>())
      )
    ),
    Suite.test(
      "small-list",
      List.tabulate<Nat>(3, func i = i * 2),
      M.equals(
        T.list<Nat>(T.natTestable, ?(0, ?(2, ?(4, null))))
      )
    ),
    Suite.test(
      "large-list",
      List.tabulate<Char>(100_000, func _ = 'Y'),
      M.equals(
        T.list<Char>(T.charTestable, hugeList)
      )
    )
  ]
);

let concat = Suite.suite(
  "concat",
  [
    Suite.test(
      "small-list",
      List.concat(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(10, func i = i + 10)
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(20, func i = i))
      )
    ),
    Suite.test(
      "large-list",
      List.concat(
        List.tabulate<Nat>(10000, func i = i),
        List.tabulate<Nat>(10000, func i = i + 10000)
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(20000, func i = i))
      )
    ),
    Suite.test(
      "huge-list",
      List.concat(hugeList, List.singleton 'N') |> List.last _,
      M.equals(T.optional(T.charTestable, ?'N'))
    )
  ]
);

let isEmpty = Suite.suite(
  "isEmpty",
  [
    Suite.test(
      "empty",
      List.isEmpty(List.empty<Nat>()),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "singleton",
      List.isEmpty(?(3, null)),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "nary",
      List.isEmpty(?(1, ?(2, ?(3, null)))),
      M.equals(T.bool(false))
    )
  ]
);

let push = Suite.suite(
  "push",
  [
    Suite.test(
      "empty",
      List.push(List.empty<Nat>(), 0),
      M.equals(T.list(T.natTestable, ?(0, null)))
    ),
    Suite.test(
      "singleton",
      List.push(List.push(List.empty<Nat>(), 0), 1),
      M.equals(T.list(T.natTestable, ?(1, ?(0, null))))
    ),
    Suite.test(
      "nary",
      List.push(List.push(List.push(List.empty<Nat>(), 0), 1), 2),
      M.equals(T.list(T.natTestable, ?(2, ?(1, ?(0, null)))))
    )
  ]
);

let last = Suite.suite(
  "last",
  [
    Suite.test(
      "empty list",
      List.last(List.empty<Nat>()),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton",
      List.last(?(3, null)),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "threesome",
      List.last(?(1, ?(2, ?(3, null)))),
      M.equals(T.optional(T.natTestable, ?3))
    )
  ]
);

let pop = Suite.suite(
  "pop",
  [
    Suite.test(
      "empty list",
      List.pop(List.empty<Nat>()),
      M.equals(
        T.tuple2(
          T.optionalTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (null, null) : (?Nat, List.List<Nat>)
        )
      )
    ),
    Suite.test(
      "singleton",
      List.pop(?(3, null)),
      M.equals(
        T.tuple2(
          T.optionalTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (?3, null) : (?Nat, List.List<Nat>)
        )
      )
    ),
    Suite.test(
      "threesome",
      List.pop(?(1, ?(2, ?(3, null)))),
      M.equals(
        T.tuple2(
          T.optionalTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (?1, ?(2, ?(3, null))) : (?Nat, List.List<Nat>)
        )
      )
    )
  ]
);

let size = Suite.suite(
  "size",
  [
    Suite.test(
      "empty list",
      List.size(List.empty<Nat>()),
      M.equals(T.nat(0))
    ),
    Suite.test(
      "singleton",
      List.size(?(3, null)),
      M.equals(T.nat(1))
    ),
    Suite.test(
      "threesome",
      List.size(?(1, ?(2, ?(3, null)))),
      M.equals(T.nat(3))
    ),
    Suite.test(
      "many",
      List.size hugeList,
      M.equals(T.nat 100_000)
    )
  ]
);

let get = Suite.suite(
  "get",
  [
    Suite.test(
      "empty list",
      List.get(List.empty<Nat>(), 0),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton-0",
      List.get(?(3, null), 0),
      M.equals(T.optional(T.natTestable, ?3))
    ),
    Suite.test(
      "singleton-1",
      List.get(?(3, null), 1),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "singleton-2",
      List.get(?(3, null), 2),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "threesome-0",
      List.get(?(1, ?(2, ?(3, null))), 0),
      M.equals(T.optional(T.natTestable, ?1))
    ),
    Suite.test(
      "threesome-1",
      List.get(?(1, ?(2, ?(3, null))), 1),
      M.equals(T.optional(T.natTestable, ?2))
    ),
    Suite.test(
      "threesome-3",
      List.get(?(1, ?(2, ?(3, null))), 3),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "threesome-4",
      List.get(?(1, ?(2, ?(3, null))), 4),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "many",
      List.get(hugeList, 99_999),
      M.equals(T.optional(T.charTestable, ?'Y'))
    ),
    Suite.test(
      "past many",
      List.get(hugeList, 100_000),
      M.equals(T.optional(T.charTestable, null : ?Char))
    )
  ]
);

let reverse = Suite.suite(
  "reverse",
  [
    Suite.test(
      "empty list",
      List.reverse(List.empty<Nat>()),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "singleton",
      List.reverse(?(3, null)),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "threesome",
      List.reverse(?(1, ?(2, ?(3, null)))),
      M.equals(T.list(T.natTestable, ?(3, ?(2, ?(1, null)))))
    ),
    Suite.test(
      "many",
      List.reverse hugeList |> List.size _,
      M.equals(T.nat 100_000)
    )
  ]
);

let forEach = Suite.suite(
  "forEach",
  [
    Suite.test(
      "empty list",
      do {
        var t = "";
        List.forEach<Nat>(List.empty<Nat>(), func n = t #= debug_show n);
        t
      },
      M.equals(T.text(""))
    ),
    Suite.test(
      "singleton",
      do {
        var t = "";
        List.forEach<Nat>(?(3, null), func n = t #= debug_show n);
        t
      },
      M.equals(T.text("3"))
    ),
    Suite.test(
      "threesome",
      do {
        var t = "";
        List.forEach<Nat>(?(1, ?(2, ?(3, null))), func n = t #= debug_show n);
        t
      },
      M.equals(T.text("123"))
    ),
    Suite.test(
      "many",
      do {
        var c = 0;
        List.forEach<Char>(hugeList, func _ = c += 1);
        c
      },
      M.equals(T.nat 100_000)
    )
  ]
);

let map = Suite.suite(
  "map",
  [
    Suite.test(
      "empty list",
      List.map<Nat, Nat>(
        List.empty<Nat>(),
        func n { n + 1 }
      ),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "singleton",
      List.map<Nat, Nat>(
        ?(3, null),
        func n { n + 1 }
      ),
      M.equals(T.list(T.natTestable, ?(4, null)))
    ),
    Suite.test(
      "threesome",
      List.map<Nat, Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n + 1 }
      ),
      M.equals(T.list(T.natTestable, ?(2, ?(3, ?(4, null)))))
    )
  ]
);

let filter = Suite.suite(
  "filter",
  [
    Suite.test(
      "empty list",
      List.filter<Nat>(
        List.empty<Nat>(),
        func n { n % 2 == 0 }
      ),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "singleton",
      List.filter<Nat>(
        ?(3, null),
        func n { n % 2 == 0 }
      ),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "threesome",
      List.filter<Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n % 2 == 0 }
      ),
      M.equals(T.list(T.natTestable, ?(2, null)))
    ),
    Suite.test(
      "foursome",
      List.filter<Nat>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { n % 2 == 0 }
      ),
      M.equals(T.list(T.natTestable, ?(2, ?(4, null))))
    )
  ]
);

let partition = Suite.suite(
  "partition",
  [
    Suite.test(
      "empty list",
      List.partition<Nat>(
        List.empty<Nat>(),
        func n { n % 2 == 0 }
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (null, null) : (List.List<Nat>, List.List<Nat>)
        )
      )
    ),
    Suite.test(
      "singleton-false",
      List.partition<Nat>(
        ?(3, null),
        func n { n % 2 == 0 }
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (null, ?(3, null)) : (List.List<Nat>, List.List<Nat>)
        )
      )

    ),
    Suite.test(
      "singleton-true",
      List.partition<Nat>(
        ?(2, null),
        func n { n % 2 == 0 }
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (?(2, null), null) : (List.List<Nat>, List.List<Nat>)
        )
      )
    ),
    Suite.test(
      "threesome",
      List.partition<Nat>(
        ?(1, ?(2, ?(3, null))),
        func n { n % 2 == 0 }
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (?(2, null), ?(1, ?(3, null))) : (List.List<Nat>, List.List<Nat>)
        )
      )
    ),
    Suite.test(
      "foursome",
      List.partition<Nat>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { n % 2 == 0 }
      ),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (
            ?(2, ?(4, null)),
            ?(1, ?(3, null))
          ) : (List.List<Nat>, List.List<Nat>)
        )
      )
    )
  ]
);

let filterMap = Suite.suite(
  "filterMap",
  [
    Suite.test(
      "empty list",
      List.filterMap<Nat, Text>(
        List.empty<Nat>(),
        func n { if (n % 2 == 0) ?(debug_show n) else null }
      ),
      M.equals(T.list(T.textTestable, null : List.List<Text>))
    ),
    Suite.test(
      "singleton",
      List.filterMap<Nat, Text>(
        ?(3, null),
        func n { if (n % 2 == 0) ?(debug_show n) else null }
      ),
      M.equals(T.list(T.textTestable, null : List.List<Text>))
    ),
    Suite.test(
      "threesome",
      List.filterMap<Nat, Text>(
        ?(1, ?(2, ?(3, null))),
        func n { if (n % 2 == 0) ?(debug_show n) else null }
      ),
      M.equals(T.list(T.textTestable, ?("2", null)))
    ),
    Suite.test(
      "foursome",
      List.filterMap<Nat, Text>(
        ?(1, ?(2, ?(3, ?(4, null)))),
        func n { if (n % 2 == 0) ?(debug_show n) else null }
      ),
      M.equals(T.list(T.textTestable, ?("2", ?("4", null))))
    )
  ]
);

let flatten = Suite.suite(
  "flatten",
  [
    Suite.test(
      "small-list",
      List.flatten(
        List.tabulate<List.List<Nat>>(10, func i = List.tabulate<Nat>(10, func j = i * 10 + j))
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(100, func i = i))
      )
    ),
    Suite.test(
      "small-nulls",
      List.flatten(
        List.tabulate<List.List<Nat>>(10, func i = null : List.List<Nat>)
      ),
      M.equals(
        T.list(T.natTestable, null : List.List<Nat>)
      )
    ),
    Suite.test(
      "flatten",
      List.flatten<Int>(
        ?(
          ?(1, ?(2, ?(3, null))),
          ?(
            null,
            ?(
              ?(1, null),
              null
            )
          )
        )
      ),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten empty start",
      List.flatten<Int>(
        ?(
          null,
          ?(
            ?(1, ?(2, (?(3, null)))),
            ?(
              null,
              ?(
                ?(1, null),
                null
              )
            )
          )
        )
      ),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten empty end",
      List.flatten<Int>(
        ?(
          ?(1, ?(2, (?(3, null)))),
          ?(
            null,
            ?(
              ?(1, null),
              ?(
                null,
                null
              )
            )
          )
        )
      ),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, ?(3, ?(1, null))))))
    ),
    Suite.test(
      "flatten singleton",
      List.flatten<Int>(
        ?(
          ?(1, ?(2, (?(3, null)))),
          null
        )
      ),
      M.equals(T.list<Int>(T.intTestable, ?(1, ?(2, (?(3, null))))))
    ),
    Suite.test(
      "flatten singleton empty",
      List.flatten<Int>(?(null, null)),
      M.equals(T.list<Int>(T.intTestable, null))
    ),
    Suite.test(
      "flatten empty",
      List.flatten<Int>(null),
      M.equals(T.list<Int>(T.intTestable, null))
    )
  ]
);

let singleton = Suite.suite(
  "singleton",
  [
    Suite.test(
      "singleton",
      List.singleton<Int>(0),
      M.equals(T.list<Int>(T.intTestable, ?(0, null)))
    )
  ]
);

let take = Suite.suite(
  "take",
  [
    Suite.test(
      "empty list",
      List.take(List.empty<Nat>(), 0),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "singleton-0",
      List.take(?(3, null), 0),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "singleton-1",
      List.take(?(3, null), 1),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "singleton-2",
      List.take(?(3, null), 2),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "threesome-0",
      List.take(?(1, ?(2, ?(3, null))), 0),
      M.equals(T.list(T.natTestable, null : List.List<Nat>))
    ),
    Suite.test(
      "threesome-1",
      List.take(?(1, ?(2, ?(3, null))), 1),
      M.equals(T.list(T.natTestable, ?(1, null)))
    ),
    Suite.test(
      "threesome-3",
      List.take(?(1, ?(2, ?(3, null))), 3),
      M.equals(T.list(T.natTestable, ?(1, ?(2, ?(3, null)))))
    ),
    Suite.test(
      "threesome-4",
      List.take(?(1, ?(2, ?(3, null))), 4),
      M.equals(T.list(T.natTestable, ?(1, ?(2, ?(3, null)))))
    )
  ]
);

let drop = Suite.suite(
  "drop",
  [
    Suite.test(
      "empty list",
      List.drop(List.empty<Nat>(), 0),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "singleton-0",
      List.drop(?(3, null), 0),
      M.equals(T.list<Nat>(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "singleton-1",
      List.drop(?(3, null), 1),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "singleton-2",
      List.drop(?(3, null), 2),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "threesome-0",
      List.drop(?(1, ?(2, ?(3, null))), 0),
      M.equals(T.list<Nat>(T.natTestable, ?(1, ?(2, ?(3, null)))))
    ),
    Suite.test(
      "threesome-1",
      List.drop(?(1, ?(2, ?(3, null))), 1),
      M.equals(T.list(T.natTestable, ?(2, ?(3, null))))
    ),
    Suite.test(
      "threesome-2",
      List.drop(?(1, ?(2, ?(3, null))), 2),
      M.equals(T.list(T.natTestable, ?(3, null)))
    ),
    Suite.test(
      "threesome-3",
      List.drop(?(1, ?(2, ?(3, null))), 3),
      M.equals(T.list<Nat>(T.natTestable, null))
    ),
    Suite.test(
      "threesome-4",
      List.drop(?(1, ?(2, ?(3, null))), 4),
      M.equals(T.list<Nat>(T.natTestable, null))
    )
  ]
);

let foldLeft = Suite.suite(
  "foldLeft",
  [
    Suite.test(
      "foldLeft",
      List.foldLeft<Text, Text>(?("a", ?("b", ?("c", null))), "", func(acc, x) = acc # x),
      M.equals(T.text("abc"))
    ),
    Suite.test(
      "foldLeft empty",
      List.foldLeft<Text, Text>(null, "base", func(x, acc) = acc # x),
      M.equals(T.text("base"))
    )
  ]
);

let foldRight = Suite.suite(
  "foldRight",
  [
    Suite.test(
      "foldRight",
      List.foldRight<Text, Text>(?("a", ?("b", ?("c", null))), "", func(x, acc) = acc # x),
      M.equals(T.text("cba"))
    ),
    Suite.test(
      "foldRight empty",
      List.foldRight<Text, Text>(null, "base", func(x, acc) = acc # x),
      M.equals(T.text("base"))
    )
  ]
);

let find = Suite.suite(
  "find",
  [
    Suite.test(
      "find",
      List.find<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x == 9),
      M.equals(T.optional(T.natTestable, ?9))
    ),
    Suite.test(
      "find fail",
      List.find<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func _ = false),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    ),
    Suite.test(
      "find empty",
      List.find<Nat>(null, func _ = true),
      M.equals(T.optional(T.natTestable, null : ?Nat))
    )
  ]
);

let all = Suite.suite(
  "all",
  [
    Suite.test(
      "all non-empty true",
      List.all<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x > 0),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "all non-empty false",
      List.all<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x > 1),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "all empty",
      List.all<Nat>(null, func x = x >= 1),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "many",
      List.all<Char>(hugeList, func c = c == 'Y'),
      M.equals(T.bool true)
    )
  ]
);

let any = Suite.suite(
  "any",
  [
    Suite.test(
      "non-empty true",
      List.any<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x >= 8),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "non-empty false",
      List.any<Nat>(?(1, ?(9, ?(4, ?(8, null)))), func x = x > 9),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "empty",
      List.any<Nat>(null, func x = true),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "many",
      List.any<Char>(hugeList, func c = c != 'Y'),
      M.equals(T.bool false)
    )
  ]
);

let merge = Suite.suite(
  "merge",
  [
    Suite.test(
      "small-list",
      List.merge<Nat>(
        List.tabulate<Nat>(10, func i = 2 * i),
        List.tabulate<Nat>(10, func i = 2 * i + 1),
        func(i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(20, func i = i))
      )
    ),

    Suite.test(
      "small-list-alternating",
      List.merge<Nat>(
        List.tabulate<Nat>(
          10,
          func i {
            if (i % 2 == 0) { 2 * i } else { 2 * i + 1 }
          }
        ),
        List.tabulate<Nat>(
          10,
          func i {
            if (not (i % 2 == 0)) // flipped!
            { 2 * i } else { 2 * i + 1 }
          }
        ),
        func(i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(20, func i = i))
      )
    ),

    Suite.test(
      "small-list-equal",
      List.merge<Nat>(
        List.tabulate<Nat>(10, func i = 2 * i),
        List.tabulate<Nat>(10, func i = 2 * i),
        func(i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(20, func i = 2 * (i / 2)))
      )
    ),

    Suite.test(
      "large-list",
      List.merge<Nat>(
        List.tabulate<Nat>(1000, func i = 2 * i),
        List.tabulate<Nat>(1000, func i = 2 * i + 1),
        func(i, j) { i <= j }
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(2000, func i = i))
      )
    )
  ]
);

let compare = Suite.suite(
  "compare",
  [
    Suite.test(
      "small-list-equal",
      List.compare<Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(10, func i = i),
        Nat.compare
      ),
      M.equals(ordT(#equal))
    ),
    Suite.test(
      "small-list-less",
      List.compare<Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(11, func i = i),
        Nat.compare
      ),
      M.equals(ordT(#less))
    ),
    Suite.test(
      "small-list-less",
      List.compare<Nat>(
        List.tabulate<Nat>(11, func i = i),
        List.tabulate<Nat>(10, func i = i),
        Nat.compare
      ),
      M.equals(ordT(#greater))
    ),
    Suite.test(
      "empty-list-equal",
      List.compare<Nat>(
        null,
        null,
        Nat.compare
      ),
      M.equals(ordT(#equal))
    ),
    Suite.test(
      "small-list-less",
      List.compare<Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(10, func i = if (i < 9) i else i + 1),
        Nat.compare
      ),
      M.equals(ordT(#less))
    ),
    Suite.test(
      "small-list-greater",
      List.compare<Nat>(
        List.tabulate<Nat>(10, func i = if (i < 9) i else i + 1),
        List.tabulate<Nat>(10, func i = i),
        Nat.compare
      ),
      M.equals(ordT(#greater))
    )
  ]
);

let equal = Suite.suite(
  "equal",
  [
    Suite.test(
      "small-list-equal",
      List.equal<Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(10, func i = i),
        Nat.equal
      ),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "small-list-less",
      List.equal<Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(11, func i = i),
        Nat.equal
      ),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "small-list-less",
      List.equal<Nat>(
        List.tabulate<Nat>(11, func i = i),
        List.tabulate<Nat>(10, func i = i),
        Nat.equal
      ),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "empty-list-equal",
      List.equal<Nat>(
        null,
        null,
        Nat.equal
      ),
      M.equals(T.bool(true))
    ),
    Suite.test(
      "small-list-less",
      List.equal<Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(10, func i = if (i < 9) i else i + 1),
        Nat.equal
      ),
      M.equals(T.bool(false))
    ),
    Suite.test(
      "small-list-greater",
      List.equal<Nat>(
        List.tabulate<Nat>(10, func i = if (i < 9) i else i + 1),
        List.tabulate<Nat>(10, func i = i),
        Nat.equal
      ),
      M.equals(T.bool(false))
    )
  ]
);

let zipWith = Suite.suite(
  "zipWith",
  [
    Suite.test(
      "small-list-equal-len",
      List.zipWith<Nat, Nat, Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(10, func i = i),
        func(i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(10, func i = i * i))
      )
    ),
    Suite.test(
      "small-list-shorter",
      List.zipWith<Nat, Nat, Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(11, func i = i),
        func(i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(10, func i = i * i))
      )
    ),
    Suite.test(
      "small-list-longer",
      List.zipWith<Nat, Nat, Nat>(
        List.tabulate<Nat>(11, func i = i),
        List.tabulate<Nat>(10, func i = i),
        func(i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, List.tabulate<Nat>(10, func i = i * i))
      )
    ),
    Suite.test(
      "small-list-empty-left",
      List.zipWith<Nat, Nat, Nat>(
        null,
        List.tabulate<Nat>(10, func i = i),
        func(i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, null : List.List<Nat>)
      )
    ),
    Suite.test(
      "small-list-empty-right",
      List.zipWith<Nat, Nat, Nat>(
        List.tabulate<Nat>(10, func i = i),
        null,
        func(i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, null : List.List<Nat>)
      )
    ),
    Suite.test(
      "small-list-both-empty",
      List.zipWith<Nat, Nat, Nat>(
        null,
        null,
        func(i, j) { i * j }
      ),
      M.equals(
        T.list(T.natTestable, null : List.List<Nat>)
      )
    )
  ]
);

let zip = Suite.suite(
  "zip",
  [
    Suite.test(
      "small-list-equal-len",
      List.zip<Nat, Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(10, func i = i)
      ),
      M.equals(
        T.list(
          T.tuple2Testable(T.natTestable, T.natTestable),
          List.tabulate<(Nat, Nat)>(10, func i = (i, i))
        )
      )
    ),
    Suite.test(
      "small-list-shorter",
      List.zip<Nat, Nat>(
        List.tabulate<Nat>(10, func i = i),
        List.tabulate<Nat>(11, func i = i)
      ),
      M.equals(
        T.list(
          T.tuple2Testable(T.natTestable, T.natTestable),
          List.tabulate<(Nat, Nat)>(10, func i = (i, i))
        )
      )
    ),
    Suite.test(
      "small-list-longer",
      List.zip<Nat, Nat>(
        List.tabulate<Nat>(11, func i = i),
        List.tabulate<Nat>(10, func i = i)
      ),
      M.equals(
        T.list(
          T.tuple2Testable(T.natTestable, T.natTestable),
          List.tabulate<(Nat, Nat)>(10, func i = (i, i))
        )
      )
    ),
    Suite.test(
      "small-list-empty-left",
      List.zip<Nat, Nat>(
        null,
        List.tabulate<Nat>(10, func i = i)
      ),
      M.equals(
        T.list(
          T.tuple2Testable(T.natTestable, T.natTestable),
          null : List.List<(Nat, Nat)>
        )
      )
    ),
    Suite.test(
      "small-list-empty-right",
      List.zip<Nat, Nat>(
        List.tabulate<Nat>(10, func i = i),
        null
      ),
      M.equals(
        T.list(
          T.tuple2Testable(T.natTestable, T.natTestable),
          null : List.List<(Nat, Nat)>
        )
      )
    ),
    Suite.test(
      "small-list-both-empty",
      List.zip<Nat, Nat>(
        null,
        null
      ),
      M.equals(
        T.list(
          T.tuple2Testable(T.natTestable, T.natTestable),
          null : List.List<(Nat, Nat)>
        )
      )
    )
  ]
);

let split = Suite.suite(
  "split",
  [
    Suite.test(
      "split-zero-nonempty",
      List.split<Nat>(List.tabulate<Nat>(10, func i = i), 0),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (
            null : List.List<Nat>,
            List.tabulate<Nat>(10, func i = i)
          )
        )
      )
    ),

    Suite.test(
      "split-zero-empty",
      List.split<Nat>(null, 0),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (
            null : List.List<Nat>,
            null : List.List<Nat>
          )
        )
      )
    ),

    Suite.test(
      "split-nonzero-empty",
      List.split<Nat>(null, 15),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (
            null : List.List<Nat>,
            null : List.List<Nat>
          )
        )
      )
    ),

    Suite.test(
      "split-too-few",
      List.split<Nat>(List.tabulate<Nat>(10, func i = i), 15),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (
            List.tabulate<Nat>(10, func i = i),
            null : List.List<Nat>
          )
        )
      )
    ),

    Suite.test(
      "split-too-many",
      List.split<Nat>(List.tabulate<Nat>(15, func i = i), 10),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (
            List.tabulate<Nat>(10, func i = i),
            List.tabulate<Nat>(5, func i = 10 + i)
          )
        )
      )
    ),

    Suite.test(
      "split-one",
      List.split<Nat>(List.tabulate<Nat>(15, func i = i), 1),
      M.equals(
        T.tuple2(
          T.listTestable(T.natTestable),
          T.listTestable(T.natTestable),
          (
            List.tabulate<Nat>(1, func i = i),
            List.tabulate<Nat>(14, func i = 1 + i)
          )
        )
      )
    ),

  ]
);

let chunks = Suite.suite(
  "chunks",
  [
    Suite.test(
      "five-even-split",
      List.chunks<Nat>(List.tabulate<Nat>(10, func i = i), 5),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (
            List.tabulate<List.List<Nat>>(
              2,
              func i {
                List.tabulate<Nat>(5, func j = i * 5 + j)
              }
            )
          )
        )
      )
    ),
    Suite.test(
      "five-remainder",
      List.chunks<Nat>(List.tabulate<Nat>(13, func i = i), 5),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (
            List.tabulate<List.List<Nat>>(
              (13 + 4) / 5,
              func i {
                List.tabulate<Nat>(if (i < 13 / 5) 5 else 13 % 5, func j = i * 5 + j)
              }
            )
          )
        )
      )
    ),
    Suite.test(
      "five-too-few",
      List.chunks<Nat>(List.tabulate<Nat>(3, func i = i), 5),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (
            List.tabulate<List.List<Nat>>(
              1,
              func i {
                List.tabulate<Nat>(3, func j = i * 5 + j)
              }
            )
          )
        )
      )
    ),
    /*Suite.test(
      "split-zero",
      List.chunks<Nat>(0,
        List.tabulate<Nat>(5, func i = i),
      ),
      M.equals(
        T.list(
          T.listTestable(T.natTestable),
          (null : List.List<List.List<Nat>>))
      )),*/
  ]
);

let fromIter = Suite.suite(
  "fromIter",
  [
    Suite.test(
      "small",
      List.fromIter<Nat>(Nat.range(0, 100)),
      M.equals(
        T.list(
          T.natTestable,
          List.tabulate<Nat>(100, func i = i)
        )
      )
    ),
    Suite.test(
      "large",
      List.fromIter<Nat>(Nat.range(0, 100_000)) |> List.size _,
      M.equals(T.nat 100_000)
    )
  ]
);

Suite.run(
  Suite.suite(
    "List",
    [
      mapResult,
      repeat,
      tabulate,
      concat,
      isEmpty,
      push,
      last,
      pop,
      size,
      get,
      reverse,
      forEach,
      map,
      filter,
      partition,
      filterMap,
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
      chunks,
      fromIter
    ]
  )
)
