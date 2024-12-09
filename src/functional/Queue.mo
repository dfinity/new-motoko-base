// Original: `Deque.mo`

import { nyi = todo } "Debug";

module {
  public type Queue<T> = (); // Placeholder

  public func empty<T>() : Queue<T> {
    todo()
  };

  public func isEmpty<T>(queue : Queue<T>) : Bool {
    todo()
  };

  func check<T>(queue : Queue<T>) : Queue<T> {
    todo()
  };

  public func pushFront<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  public func peekFront<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func popFront<T>(queue : Queue<T>) : ?(T, Queue<T>) {
    todo()
  };

  public func pushBack<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  public func peekBack<T>(queue : Queue<T>) : ?T {
    todo()
  };

  public func popBack<T>(queue : Queue<T>) : ?(Queue<T>, T) {
    todo()
  }
}
