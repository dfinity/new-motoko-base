/// Original: `Deque.mo`

import Iter "IterType";
import Functional "functional/Queue";
import Order "Order";
import { todo } "Debug";

module {

  public type Queue<T> = { var functional : Functional.Queue<T> };

  public func toFunctional<T>(queue : Queue<T>) : Functional.Queue<T> = queue.functional;

  public func fromFunctional<T>(queue : Functional.Queue<T>) : Queue<T> {
    { var functional = queue }
  };

  public func empty<T>() : Queue<T> = { var functional = Functional.empty() };

  public func singleton<T>(item : T) : Queue<T> {
    { var functional = Functional.singleton(item) }
  };

  public func clone<T>(queue : Queue<T>) : Queue<T> = { var functional = queue.functional };

  public func isEmpty<T>(queue : Queue<T>) : Bool {
    todo()
  };

  public func size<T>(queue : Queue<T>) : Nat {
    todo()
  };

  public func contains<T>(queue : Queue<T>, item : T) : Bool {
    todo()
  };

  public func peekFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func peekBack<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func push<T>(queue : Queue<T>, element : T) : () {
    todo()
  };

  public func pop<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func pushFront<T>(queue : Queue<T>, element : T) : () {
    todo()
  };

  public func pushBack<T>(queue : Queue<T>, element : T) : () {
    todo()
  };

  public func popFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func popBack<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    todo()
  };

  public func values<T>(queue : Queue<T>) : Iter.Iter<T> {
    todo()
  };

  public func all<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    todo()
  };

  public func forEach<T>(queue : Queue<T>, f : T -> ()) {
    todo()
  };

  public func map<T1, T2>(queue : Queue<T1>, f : T1 -> T2) : Queue<T2> {
    todo()
  };

  public func filter<T>(queue : Queue<T>, f : T -> Bool) : Queue<T> {
    todo()
  };

  public func filterMap<T, U>(queue : Queue<T>, f : T -> ?U) : Queue<U> {
    todo()
  };

  public func equal<T>(queue1 : Queue<T>, queue2 : Queue<T>) : Bool {
    todo()
  };

  public func toText<T>(queue : Queue<T>, f : T -> Text) : Text {
    todo()
  };

  public func compare<T>(queue1 : Queue<T>, queue2 : Queue<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

}
