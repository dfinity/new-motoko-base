import Iter "../src/Iter";
import Array "../src/Array";
import List "../src/List";
import Nat "../src/Nat";
import Int "../src/Int";
import Debug "../src/Debug";

Debug.print("Iter");

do {
  Debug.print("  forEach");

  let xs = ["a", "b", "c", "d", "e", "f"];

  var y = "";
  var z = 0;

  Iter.forEach<Text>(
    xs.vals(),
    func(x : Text, i : Nat) {
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

  let _actual = Iter.map<Nat, Bool>([1, 2, 3].vals(), isEven);
  let actual = [var true, false, true];
  Iter.iterate<Bool>(_actual, func(x, i) { actual[i] := x });

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

  let _actual = Iter.filter<Nat>([1, 2, 3].vals(), isOdd);
  let actual = [var 0, 0];
  Iter.iterate<Nat>(_actual, func(x, i) { actual[i] := x });

  let expected = [1, 3];

  assert (Array.freeze(actual) == expected)
};

do {
  Debug.print("  make");

  let x = 1;
  let y = Iter.make<Nat>(x);

  switch (y.next()) {
    case null { assert false };
    case (?z) { assert (x == z) }
  }
};

do {
  Debug.print("  fromArray");

  let expected = [1, 2, 3];
  let _actual = Iter.fromArray<Nat>(expected);
  let actual = [var 0, 0, 0];

  Iter.iterate<Nat>(_actual, func(x, i) { actual[i] := x });

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  fromVarArray");

  let expected = [var 1, 2, 3];
  let _actual = Iter.fromVarArray<Nat>(expected);
  let actual = [var 0, 0, 0];

  Iter.forEach<Nat>(_actual, func(x) { actual[i] := x });

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toArray");

  let expected = [1, 2, 3];
  let actual = Iter.toArray<Nat>(expected.vals());

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  toVarArray");

  let expected = [var 1, 2, 3];
  let actual = Iter.toVarArray<Nat>(expected.vals());

  assert (actual.size() == expected.size());

  for (i in actual.keys()) {
    assert (actual[i] == expected[i])
  }
};

do {
  Debug.print("  sort");

  let input : [Nat] = [4, 3, 1, 2, 5];
  let expected : [Nat] = [1, 2, 3, 4, 5];
  let actual = Iter.toArray(Iter.sort<Nat>(input.vals(), Nat.compare));
  assert Array.equal<Nat>(expected, actual, func(x1, x2) { x1 == x2 })
};

do {
  Debug.print("  Array slice");

  let input : [Nat] = [4, 3, 1, 2, 5];

  let sEmpty = Array.slice(input, 0, 0);
  assert sEmpty.next() == null;

  let sPrefix = Array.slice(input, 0, 1);
  assert sPrefix.next() == ?4;
  assert sPrefix.next() == null;

  let sSuffix = Array.slice(input, 4, 5);
  assert sSuffix.next() == ?5;
  assert sSuffix.next() == null;

  let sInfix = Array.slice(input, 3, 4);
  assert sInfix.next() == ?2;
  assert sInfix.next() == null;

  let sFull = Array.slice(input, 0, input.size());
  assert sFull.next() == ?4;
  assert sFull.next() == ?3;
  assert sFull.next() == ?1;
  assert sFull.next() == ?2;
  assert sFull.next() == ?5;
  assert sFull.next() == null;

  let sEmptier = Array.slice(input, input.size(), input.size());
  assert sEmptier.next() == null
}
