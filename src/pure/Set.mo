/// Original: `OrderedSet.mo`

import Iter "../Iter";
import Order "../Order";
import { todo } "../Debug";

module {

  public type Set<T> = (); // Placeholder

  public func empty<T>() : Set<T> {
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

  public func add<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func delete<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func max<T>(set : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(set : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func equal<T>(set1 : Set<T>, set2 : Set<T>) : Bool {
    todo()
  };

  public func values<T>(set : Set<T>) : Iter.Iter<T> {
    todo()
  };

  public func reverseValues<T>(set : Set<T>) : Iter.Iter<T> {
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

  public func filter<T>(set : Set<T>, f : T -> Bool) : Set<T> {
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

  public func assertValid(set : Set<Any>) : () {
    todo()
  };

  public func toText<T>(set : Set<T>, f : T -> Text) : Text {
    todo()
  };

}
