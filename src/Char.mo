/// Utilities for `Char` (character)

import Iter "IterType";
import { todo } "Debug";
import Prim "mo:⛔";

module {

  public type Char = Prim.Types.Char;

  public let toNat32 : (char : Char) -> Nat32 = Prim.charToNat32;

  public let fromNat32 : (nat32 : Nat32) -> Char = Prim.nat32ToChar;

  public let toText : (char : Char) -> Text = Prim.charToText;

  public let toUpper : (char : Char) -> Char = Prim.charToUpper;

  public let toLower : (char : Char) -> Char = Prim.charToLower;

  public func isDigit(char : Char) : Bool {
    Prim.charToNat32(char) -% Prim.charToNat32('0') <= (9 : Nat32)
  };

  public let isWhitespace : (char : Char) -> Bool = Prim.charIsWhitespace;

  public let isLower : (char : Char) -> Bool = Prim.charIsLowercase;

  public let isUpper : (char : Char) -> Bool = Prim.charIsUppercase;

  public let isAlphabetic : (char : Char) -> Bool = Prim.charIsAlphabetic;

  public func equal(a : Char, b : Char) : Bool { a == b };

  public func notEqual(a : Char, b : Char) : Bool { a != b };

  public func less(a : Char, b : Char) : Bool { a < b };

  public func lessOrEqual(a : Char, b : Char) : Bool { a <= b };

  public func greater(a : Char, b : Char) : Bool { a > b };

  public func greaterOrEqual(a : Char, b : Char) : Bool { a >= b };

  public func compare(a : Char, b : Char) : { #less; #equal; #greater } {
    if (a < b) { #less } else if (a == b) { #equal } else { #greater }
  };

  public func allValues() : Iter.Iter<Char> {
    todo()
  };

}
