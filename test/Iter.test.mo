import Iter "../src/Iter";
import Array "../src/Array";
import Nat "../src/Nat";
import Int "../src/Int";
import Debug "../src/Debug";

Debug.print("Iter");

do {
  Debug.print("  forEach");

  let xs = ["a", "b", "c", "d", "e", "f"];

  var y = "";
  var z = 0;

  Iter.forEach<(Nat, Text)>(
    Iter.enumerate(xs.values()),
    func(i, x) {
      y := y # x;
      z += i
    }
  );

  assert (y == "abcdef");
  assert (z == 15)
};

do {
  Debug.print("  map");

  let isEven = func(x : Int) : Bool {
    x % 2 == 0
  };

  let _actual = Iter.map<Nat, Bool>([1, 2, 3].values(), isEven);
  let actual = [var true, false, true];
  Iter.forEach<(Nat, Bool)>(Iter.enumerate(_actual), func(i, x) { actual[i] := x });

  let expected = [false, true, false];

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  filter");

  let isOdd = func(x : Int) : Bool {
    x % 2 == 1
  };

  let _actual = Iter.filter<Nat>([1, 2, 3].values(), isOdd);
  let actual = [var 0, 0];
  Iter.forEach<(Nat, Nat)>(Iter.enumerate(_actual), func(i, x) { actual[i] := x });

  let expected = [1, 3];

  assert (Array.fromVarArray(actual) == expected)
};

do {
  Debug.print("  singleton");

  let x = 1;
  let y = Iter.singleton<Nat>(x);

  switch (y.next()) {
    case null { assert false };
    case (?z) { assert (x == z) }
  }
};

do {
  Debug.print("  infinite");

  let x = 1;
  let y = Iter.infinite<Nat>(x);

  for (_ in Nat.range(0, 10000)) {
    switch (y.next()) {
      case null { assert false };
      case (?z) { assert (x == z) }
    }
  }
};

do {
  Debug.print("  fromArray");

  let expected = [1, 2, 3];
  let _actual = Iter.fromArray<Nat>(expected);
  let actual = [var 0, 0, 0];

  Iter.forEach<(Nat, Nat)>(Iter.enumerate(_actual), func(i, x) { actual[i] := x });

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  fromVarArray");

  let expected = [var 1, 2, 3];
  let _actual = Iter.fromVarArray<Nat>(expected);
  let actual = [var 0, 0, 0];

  Iter.forEach<(Nat, Nat)>(Iter.enumerate(_actual), func(i, x) { actual[i] := x });

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toArray");

  let expected = [1, 2, 3];
  let actual = Iter.toArray<Nat>(expected.values());

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toVarArray");

  let expected = [var 1, 2, 3];
  let actual = Iter.toVarArray<Nat>(expected.values());

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  sort");

  let input : [Nat] = [4, 3, 1, 2, 5];
  let expected : [Nat] = [1, 2, 3, 4, 5];
  let actual = Iter.toArray(Iter.sort<Nat>(input.values(), Nat.compare));
  assert Array.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 })
};

do {
  Debug.print("  Array range");

  let input : [Nat] = [4, 3, 1, 2, 5];

  let sEmpty = Array.range(input, 0, 0);
  assert sEmpty.next() == null;

  let sPrefix = Array.range(input, 0, 1);
  assert sPrefix.next() == ?4;
  assert sPrefix.next() == null;

  let sSuffix = Array.range(input, 4, 5);
  assert sSuffix.next() == ?5;
  assert sSuffix.next() == null;

  let sInfix = Array.range(input, 3, 4);
  assert sInfix.next() == ?2;
  assert sInfix.next() == null;

  let sFull = Array.range(input, 0, input.size());
  assert sFull.next() == ?4;
  assert sFull.next() == ?3;
  assert sFull.next() == ?1;
  assert sFull.next() == ?2;
  assert sFull.next() == ?5;
  assert sFull.next() == null;

  let sEmptier = Array.range(input, input.size(), input.size());
  assert sEmptier.next() == null;

  // Negative indices
  let sNegStart = Array.range(input, -2, 5); // Should get [2,5]
  assert sNegStart.next() == ?2;
  assert sNegStart.next() == ?5;
  assert sNegStart.next() == null;

  let sNegEnd = Array.range(input, 0, -2); // Should get [4,3,1]
  assert sNegEnd.next() == ?4;
  assert sNegEnd.next() == ?3;
  assert sNegEnd.next() == ?1;
  assert sNegEnd.next() == null;

  let sNegBoth = Array.range(input, -3, -1); // Should get [1,2]
  assert sNegBoth.next() == ?1;
  assert sNegBoth.next() == ?2;
  assert sNegBoth.next() == null;

  // Out-of-bounds handling
  let sOobStart = Array.range(input, -10, 2); // Should clamp to [0,2]
  assert sOobStart.next() == ?4;
  assert sOobStart.next() == ?3;
  assert sOobStart.next() == null;

  let sOobEnd = Array.range(input, 3, 10); // Should clamp to [3,5]
  assert sOobEnd.next() == ?2;
  assert sOobEnd.next() == ?5;
  assert sOobEnd.next() == null;

  // Empty slices
  let sStartEqualsEnd = Array.range(input, 2, 2);
  assert sStartEqualsEnd.next() == null;

  let sStartGreaterThanEnd = Array.range(input, 3, 2);
  assert sStartGreaterThanEnd.next() == null
};

do {
  Debug.print("  repeat");

  // Basic repeat functionality
  let iter1 = Iter.repeat<Char>('a', 3);
  assert (?'a' == iter1.next());
  assert (?'a' == iter1.next());
  assert (?'a' == iter1.next());
  assert (null == iter1.next());

  // Count of 0 returns empty iterator
  let iter2 = Iter.repeat<Nat>(1, 0);
  assert (null == iter2.next());

  // Count of 1 returns singleton iterator
  let iter3 = Iter.repeat<Bool>(true, 1);
  assert (?true == iter3.next());
  assert (null == iter3.next())
};

do {
  Debug.print("  reverse");

  // Basic reverse functionality
  let array1 = [1, 2, 3, 4];
  let iter1 = Iter.reverse(array1.values());
  assert (?4 == iter1.next());
  assert (?3 == iter1.next());
  assert (?2 == iter1.next());
  assert (?1 == iter1.next());
  assert (null == iter1.next());

  // Empty array remains empty
  let array2 = ([] : [Nat]);
  let iter2 = Iter.reverse(array2.values());
  assert (null == iter2.next());

  // Single element array remains unchanged
  let array3 = ['a'];
  let iter3 = Iter.reverse(array3.values());
  assert (?'a' == iter3.next());
  assert (null == iter3.next())
}
