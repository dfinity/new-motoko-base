/// Original: `Deque.mo`

import Iter "IterType";
import Immutable "immutable/Queue";
import Order "Order";
import { todo } "Debug";

module {

  public type Queue<T> = { var immutable : Immutable.Queue<T> };

  public func freeze<T>(queue : Queue<T>) : Immutable.Queue<T> = queue.immutable;

  public func thaw<T>(queue : Immutable.Queue<T>) : Queue<T> {
    { var immutable = queue }
  };

  public func empty<T>() : Queue<T> = { var immutable = Immutable.empty() };

  public func singleton<T>(item : T) : Queue<T> {
    { var immutable = Immutable.singleton(item) }
  };

  public func clone<T>(queue : Queue<T>) : Queue<T> = { var immutable = queue.immutable };

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

  public func values<T>(queue : Queue<T>) : Iter.Iter<T> {
    todo()
  };

  public func toText<T>(queue : Queue<T>, f : T -> Text) : Text {
    todo()
  };

}
