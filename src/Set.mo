/// Original: `OrderedSet.mo`

import Immutable "immutable/Set";
import Iter "Iter";
import Order "Order";
import { todo } "Debug";

module {

  public type Set<T> = { var immutable : Immutable.Set<T> };

  public func freeze<T>(set : Set<T>) : Immutable.Set<T> = set.immutable;

  public func thaw<T>(set : Immutable.Set<T>) : Set<T> = { var immutable = set };

  public func clone<T>(set : Set<T>) : Set<T> = { var immutable = set.immutable };

  public func empty<T>() : Set<T> = { var immutable = Immutable.empty() };

  public func singleton<T>() : Set<T> {
    todo()
  };

  public func isEmpty(set : Set<Any>) : Bool {
    todo()
  };

  public func size(set : Set<Any>) : Nat {
    todo()
  };

  public func contains<T>(set : Set<T>, compare : (T, T) -> Order.Order, item : T) : Bool {
    todo()
  };

  public func equal<T>(set1 : Set<T>, set2 : Set<T>, equal : (T, T) -> Bool) : Bool {
    todo()
  };

  public func add<T>(set : Set<T>, compare : (T, T) -> Order.Order, item : T) : () {
    todo()
  };

  public func delete<T>(set : Set<T>, compare : (T, T) -> Order.Order, item : T) : Bool {
    todo()
  };

  public func max<T>(set : Set<T>, compare : (T, T) -> Order.Order) : ?T {
    todo()
  };

  public func min<T>(set : Set<T>, compare : (T, T) -> Order.Order) : ?T {
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

  public func forEach<T>(set : Set<T>, f : T -> ()) {
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

  public func flatten<T>(set : Iter.Iter<Set<T>>) : Set<T> {
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

  public func compare<T>(set1 : Set<T>, set2 : Set<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

}
