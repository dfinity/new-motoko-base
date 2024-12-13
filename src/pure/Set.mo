/// Original: `OrderedSet.mo`

import Iter "../Iter";
import Order "../Order";
import { nyi = todo } "../Debug";

module {

  public type Set<T> = (); // Placeholder

  public func new<T>() : Set<T> {
    todo()
  };

  public func isEmpty<T>(set : Set<T>) : Bool {
    todo()
  };

  public func size<T>(set : Set<T>) : Nat {
    todo()
  };

  public func contains<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Bool {
    todo()
  };

  public func put<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func delete<T>(s : Set<T>, item : T, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func max<T>(s : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(s : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func vals<T>(set : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func valsRev<T>(s : Set<T>) : Iter.Iter<T> {
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

  public func filter<T>(s : Set<T>, f : T -> Bool) : Set<T> {
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
