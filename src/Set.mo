/// Original: `OrderedSet.mo`

import Pure "pure/Set";
import Iter "Iter";
import Order "Order";
import { nyi = todo } "Debug";

module {

  type Set<T> = { var pure : Pure.Set<T> };

  public func toPure<T>(set : Set<T>) : Pure.Set<T> = set.pure;

  public func fromPure<T>(set : Pure.Set<T>) : Set<T> = { var pure = set };

  public func clone<T>(set : Set<T>) : Set<T> = { var pure = set.pure };

  public func new<T>() : Set<T> = { var pure = Pure.new() };

  public func isEmpty<T>(set : Set<T>) : Bool {
    todo()
  };

  public func size<T>(set : Set<T>) : Nat {
    todo()
  };

  public func contains<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Bool {
    todo()
  };

  public func put<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : () {
    todo()
  };

  public func delete<T>(s : Set<T>, item : T, compare : (T, T) -> Order.Order) : Bool {
    todo()
  };

  public func max<T>(s : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(s : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func toIter<T>(set : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func toIterRev<T>(s : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func fromIter<T>(iter : Iter.Iter<T>, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func union<T>(s1 : Set<T>, s2 : Set<T>) : Set<T> {
    todo()
  };

  public func intersect<T>(s1 : Set<T>, s2 : Set<T>) : Set<T> {
    todo()
  };

  public func diff<T>(s1 : Set<T>, s2 : Set<T>) : Set<T> {
    todo()
  };

  public func map<T1, T2>(s : Set<T1>, f : T1 -> T2) : Set<T2> {
    todo()
  };

  public func filterMap<T1, T2>(s : Set<T1>, f : T1 -> ?T2) : Set<T2> {
    todo()
  };

  public func isSubset<T>(s1 : Set<T>, s2 : Set<T>) : Bool {
    todo()
  };

  public func equal<T>(s1 : Set<T>, s2 : Set<T>) : Bool {
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

  public func all<T>(s : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(s : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func assertValid(s : Set<Any>) : () {
    todo()
  };

}
