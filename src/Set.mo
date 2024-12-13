/// Original: `OrderedSet.mo`

import Pure "pure/Set";
import Iter "Iter";
import Order "Order";
import { nyi = todo } "Debug";

module {

  public type Set<T> = { var pure : Pure.Set<T> };

  public func toPure<T>(set : Set<T>) : Pure.Set<T> = set.pure;

  public func fromPure<T>(set : Pure.Set<T>) : Set<T> = { var pure = set };

  public func clone<T>(set : Set<T>) : Set<T> = { var pure = set.pure };

  public func new<T>() : Set<T> = { var pure = Pure.new() };

  public func isEmpty(set : Set<Any>) : Bool {
    todo()
  };

  public func size(set : Set<Any>) : Nat {
    todo()
  };

  public func contains<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Bool {
    todo()
  };

  public func equal<T>(set1 : Set<T>, set2 : Set<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func insert<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : () {
    todo()
  };

  public func delete<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Bool {
    todo()
  };

  public func max<T>(set : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(set : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func toIter<T>(set : Set<T>) : Iter.Iter<T> {
    vals(set)
  };

  public func vals<T>(set : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func valsRev<T>(set : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func fromIter<T>(iter : Iter.Iter<T>, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func isSubset<T>(set1 : Set<T>, set2 : Set<T>) : Bool {
    todo()
  };

  public func union<T>(set1 : Set<T>, set2 : Set<T>) : Set<T> {
    todo()
  };

  public func intersect<T>(set1 : Set<T>, set2 : Set<T>) : Set<T> {
    todo()
  };

  public func diff<T>(set1 : Set<T>, set2 : Set<T>) : Set<T> {
    todo()
  };

  public func map<T1, T2>(set : Set<T1>, f : T1 -> T2) : Set<T2> {
    todo()
  };

  public func filterMap<T1, T2>(set : Set<T1>, f : T1 -> ?T2) : Set<T2> {
    todo()
  };

  public func foldLeft<T, A>(
    set : Set<T>,
    base : A,
    combine : (A, T) -> A
  ) : A {
    todo()
  };

  public func foldRight<T, A>(
    set : Set<T>,
    base : A,
    combine : (A, T) -> A
  ) : A {
    todo()
  };

  public func all<T>(set : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(set : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func assertValid<T>(set : Set<T>, compare : (T, T) -> Order.Order) : () {
    todo()
  };

  public func toText<T>(set : Set<T>, f : T -> Text) : Text {
    todo()
  };

}
