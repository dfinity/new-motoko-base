/// `Text` utilities

import Char "Char";
import Hash "Hash";
import Iter "IterType";
import Order "Order";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  public type Text = Prim.Types.Text;

  public func chars(t : Text) : Iter.Iter<Char> = t.chars();

  public let fromChar : (c : Char) -> Text = Prim.charToText;

  public func fromArray(a : [Char]) : Text = fromIter(a.vals());

  public func fromVarArray(a : [var Char]) : Text = fromIter(a.vals());

  public func toArray(t : Text) : [Char] {
    todo()
  };

  public func toVarArray(t : Text) : [var Char] {
    todo()
  };

  public func fromIter(cs : Iter.Iter<Char>) : Text {
    todo()
  };

  public func size(t : Text) : Nat { t.size() };

  public func hash(t : Text) : Hash.Hash {
    todo()
  };

  public func concat(t1 : Text, t2 : Text) : Text = t1 # t2;

  public func concatAll(ts : [Text]) : Text = todo();

  public func equal(t1 : Text, t2 : Text) : Bool { t1 == t2 };

  public func notEqual(t1 : Text, t2 : Text) : Bool { t1 != t2 };

  public func less(t1 : Text, t2 : Text) : Bool { t1 < t2 };

  public func lessOrEqual(t1 : Text, t2 : Text) : Bool { t1 <= t2 };

  public func greater(t1 : Text, t2 : Text) : Bool { t1 > t2 };

  public func greaterOrEqual(t1 : Text, t2 : Text) : Bool { t1 >= t2 };

  public func compare(t1 : Text, t2 : Text) : Order.Order {
    todo()
  };

  public func join(sep : Text, ts : Iter.Iter<Text>) : Text {
    todo()
  };

  public func map(t : Text, f : Char -> Char) : Text {
    todo()
  };

  public func flatMap(t : Text, f : Char -> Text) : Text {
    todo()
  };

  public type Pattern = {
    #char : Char;
    #text : Text;
    #predicate : (Char -> Bool)
  };

  public func split(t : Text, p : Pattern) : Iter.Iter<Text> {
    todo()
  };

  public func tokens(t : Text, p : Pattern) : Iter.Iter<Text> {
    todo()
  };

  public func contains(t : Text, p : Pattern) : Bool {
    todo()
  };

  public func startsWith(t : Text, p : Pattern) : Bool {
    todo()
  };

  public func endsWith(t : Text, p : Pattern) : Bool {
    todo()
  };

  public func replace(t : Text, p : Pattern, r : Text) : Text {
    todo()
  };

  public func stripStart(t : Text, p : Pattern) : ?Text {
    todo()
  };

  public func stripEnd(t : Text, p : Pattern) : ?Text {
   todo()
  };

  public func trimStart(t : Text, p : Pattern) : Text {
    todo()
  };

  public func trimEnd(t : Text, p : Pattern) : Text {
    todo()
  };

  public func trim(t : Text, p : Pattern) : Text {
    todo()
  };

  public func compareWith(
    t1 : Text,
    t2 : Text,
    cmp : (Char, Char) -> Order.Order
  ) : Order.Order {
    todo()
  };

  public let encodeUtf8 : Text -> Blob = Prim.encodeUtf8;

  public let decodeUtf8 : Blob -> ?Text = Prim.decodeUtf8;

  public let toLower : Text -> Text = Prim.textLowercase;

  public let toUpper : Text -> Text = Prim.textUppercase;

}
