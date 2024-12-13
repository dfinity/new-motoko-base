/// Original: `OrderedSet.mo`

import Pure "pure/Set";
import Iter "Iter";
import Order "Order";
import { nyi = todo } "Debug";

module {

  type Set<T> = { pure : Pure.Set<T> };

  public func toPure<T>(set : Set<T>) : Pure.Set<T> = set.pure;

  public func fromPure<T>(set : Pure.Set<T>) : Queue<T> = { var pure : set };

  public func clone<T>(set : Set<T>) : Set<T> = { var pure = set.pure };

  public func new<T>() : Queue<T> = fromPure(Pure.new());

  public func isEmpty<T>(queue : Queue<T>) : Bool {
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

  public func delete(s : Set<T>, item : T, compare : (T, T) -> Order.Order) : Bool {
    todo()
  };

  public func max(s : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min(s : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func toIter(set : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func toIterRev(s : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func fromIter(iter : Iter.Iter<T>, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func union(s1 : Set<T>, s2 : Set<T>) : Set<T> {
    todo()
  };

  public func intersect(s1 : Set<T>, s2 : Set<T>) : Set<T> {
    todo()
  };

  public func diff(s1 : Set<T>, s2 : Set<T>) : Set<T> {
    todo()
  };

  public func map<T1, T2>(s : Set<T1>, f : T1 -> T2) : Set<T2> {
    todo()
  };

  public func filterMap<T1, T2>(s : Set<T1>, f : T1 -> ?T2) : Set<T2> {
    todo()
  };

  public func isSubset(s1 : Set<T>, s2 : Set<T>) : Bool {
    todo()
  };

  public func equal(s1 : Set<T>, s2 : Set<T>) : Bool {
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

  public func all(s : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func any(s : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func assertValid(s : Set<T>) : () {
    todo()
  };

}
