/// Contains modules for working with tuples of different sizes.

import Types "Types";

module {

  /// Swaps the elements of a tuple.
  ///
  /// ```motoko
  /// import Tuples "mo:new-base/Tuple";
  /// assert Tuple.Tuple2.swap((1, "hello")) == ("hello", 1);
  /// ```
  public func swap<A, B>((a, b) : (A, B)) : (B, A) = (b, a);

  /// Creates a textual representation of a tuple for debugging purposes.
  ///
  /// ```motoko
  /// import Tuple "mo:new-base/Tuple";
  /// import Nat "mo:new-base/Nat";
  /// assert Tuple.toText((1, "hello"), Nat.toText, func (x: Text): Text = x) == "(1, hello)";
  /// ```
  public func toText<A, B>(t : (A, B), toTextA : A -> Text, toTextB : B -> Text) : Text = "(" # toTextA(t.0) # ", " # toTextB(t.1) # ")";

  /// Creates a textual representation of a 3-tuple for debugging purposes.
  public func toText3<A, B, C>(t : (A, B, C), toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text) : Text = "(" # toTextA(t.0) # ", " # toTextB(t.1) # ", " # toTextC(t.2) # ")";

  /// Creates a textual representation of a 4-tuple for debugging purposes.
  public func toText4<A, B, C, D>(t : (A, B, C, D), toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text, toTextD : D -> Text) : Text = "(" # toTextA(t.0) # ", " # toTextB(t.1) # ", " # toTextC(t.2) # ", " # toTextD(t.3) # ")";

  /// Compares two tuples for equality.
  ///
  /// ```motoko
  /// import Tuple "mo:new-base/Tuple";
  /// import Nat "mo:new-base/Nat";
  /// import Text "mo:new-base/Text";
  /// assert Tuple.equal((1, "hello"), (1, "hello"), Nat.equal, Text.equal);
  /// ```
  public func equal<A, B>(t1 : (A, B), t2 : (A, B), aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool) : Bool = aEqual(t1.0, t2.0) and bEqual(t1.1, t2.1);

  /// Compares two 4-tuples for equality.
  public func equal3<A, B, C>(t1 : (A, B, C), t2 : (A, B, C), aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool) : Bool = aEqual(t1.0, t2.0) and bEqual(t1.1, t2.1) and cEqual(t1.2, t2.2);

  /// Compares two 4-tuples for equality.
  public func equal4<A, B, C, D>(t1 : (A, B, C, D), t2 : (A, B, C, D), aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool, dEqual : (D, D) -> Bool) : Bool = aEqual(t1.0, t2.0) and bEqual(t1.1, t2.1) and cEqual(t1.2, t2.2) and dEqual(t1.3, t2.3);

  /// Compares two tuples lexicographically.
  ///
  /// ```motoko
  /// import Tuple "mo:new-base/Tuple";
  /// import Nat "mo:new-base/Nat";
  /// import Text "mo:new-base/Text";
  /// assert Tuple.compare((1, "hello"), (1, "world"), Nat.compare, Text.compare) == #less;
  /// assert Tuple.compare((1, "hello"), (2, "hello"), Nat.compare, Text.compare) == #less;
  /// assert Tuple.compare((1, "hello"), (1, "hello"), Nat.compare, Text.compare) == #equal;
  /// assert Tuple.compare((2, "hello"), (1, "hello"), Nat.compare, Text.compare) == #greater;
  /// assert Tuple.compare((1, "world"), (1, "hello"), Nat.compare, Text.compare) == #greater;
  /// ```
  public func compare<A, B>(t1 : (A, B), t2 : (A, B), aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order) : Types.Order = switch (aCompare(t1.0, t2.0)) {
    case (#equal) bCompare(t1.1, t2.1);
    case order order
  };

  /// Compares two 3-tuples lexicographically.
  public func compare3<A, B, C>(t1 : (A, B, C), t2 : (A, B, C), aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order) : Types.Order = switch (aCompare(t1.0, t2.0)) {
    case (#equal) {
      switch (bCompare(t1.1, t2.1)) {
        case (#equal) cCompare(t1.2, t2.2);
        case order order
      }
    };
    case order order
  };

  /// Compares two 4-tuples lexicographically.
  public func compare4<A, B, C, D>(t1 : (A, B, C, D), t2 : (A, B, C, D), aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order, dCompare : (D, D) -> Types.Order) : Types.Order = switch (aCompare(t1.0, t2.0)) {
    case (#equal) {
      switch (bCompare(t1.1, t2.1)) {
        case (#equal) {
          switch (cCompare(t1.2, t2.2)) {
            case (#equal) dCompare(t1.3, t2.3);
            case order order
          }
        };
        case order order
      }
    };
    case order order
  };

  /// Creates a `toText` function for a tuple given `toText` functions for its elements.
  public func makeToText<A, B>(toTextA : A -> Text, toTextB : B -> Text) : ((A, B)) -> Text = func t = toText(t, toTextA, toTextB);

  /// Creates a `toText` function for a 3-tuple given `toText` functions for its elements.
  public func makeToText3<A, B, C>(toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text) : ((A, B, C)) -> Text = func t = toText3(t, toTextA, toTextB, toTextC);

  /// Creates a `toText` function for a 4-tuple given `toText` functions for its elements.
  public func makeToText4<A, B, C, D>(toTextA : A -> Text, toTextB : B -> Text, toTextC : C -> Text, toTextD : D -> Text) : ((A, B, C, D)) -> Text = func t = toText4(t, toTextA, toTextB, toTextC, toTextD);

  /// Creates an `equal` function for a tuple given `equal` functions for its elements.
  public func makeEqual<A, B>(aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool) : ((A, B), (A, B)) -> Bool = func(t1, t2) = equal(t1, t2, aEqual, bEqual);

  /// Creates an `equal` function for a 3-tuple given `equal` functions for its elements.
  public func makeEqual3<A, B, C>(aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool) : ((A, B, C), (A, B, C)) -> Bool = func(t1, t2) = equal3(t1, t2, aEqual, bEqual, cEqual);

  /// Creates an `equal` function for a 4-tuple given `equal` functions for its elements.
  public func makeEqual4<A, B, C, D>(aEqual : (A, A) -> Bool, bEqual : (B, B) -> Bool, cEqual : (C, C) -> Bool, dEqual : (D, D) -> Bool) : ((A, B, C, D), (A, B, C, D)) -> Bool = func(t1, t2) = equal4(t1, t2, aEqual, bEqual, cEqual, dEqual);

  /// Creates a `compare` function for a tuple given `compare` functions for its elements.
  public func makeCompare<A, B>(aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order) : ((A, B), (A, B)) -> Types.Order = func(t1, t2) = compare(t1, t2, aCompare, bCompare);

  /// Creates a `compare` function for a 3-tuple given `compare` functions for its elements.
  public func makeCompare3<A, B, C>(aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order) : ((A, B, C), (A, B, C)) -> Types.Order = func(t1, t2) = compare3(t1, t2, aCompare, bCompare, cCompare);

  /// Creates a `compare` function for a 4-tuple given `compare` functions for its elements.
  public func makeCompare4<A, B, C, D>(aCompare : (A, A) -> Types.Order, bCompare : (B, B) -> Types.Order, cCompare : (C, C) -> Types.Order, dCompare : (D, D) -> Types.Order) : ((A, B, C, D), (A, B, C, D)) -> Types.Order = func(t1, t2) = compare4(t1, t2, aCompare, bCompare, cCompare, dCompare)
}
