// Original: `Deque.mo`

import Pure "pure/Queue";
import { nyi = todo } "Debug";

module {

  public type Queue<T> = { var pure : Pure.Queue<T> };

  public func toPure<T>(queue : Queue) : Pure.Queue = Queue.pure;

  public func fromPure<T>(queue : Pure.Queue<T>) : Queue<T> = {
    var pure : queue
  };

  public func new<T>() : Queue<T> = fromPure(Pure.new());

  public func clone<T>(queue : Queue<T>) : Queue<T> = { var pure : queue.pure };

  public func isEmpty<T>(queue : Queue<T>) : Bool {
    todo()
  };

  public func size<T>(queue : Queue<T>) : Nat {
    todo()
  };

  public func peekFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func peekBack<T>(queue : Queue<T>) : ?T {
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

}
