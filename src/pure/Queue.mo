// Original: `Deque.mo`

import Iter "../Iter";
import Stack "Stack";
import { nyi = todo } "../Debug";

module {
  public type Queue<T> = (Stack.Stack<T>, Stack.Stack<T>);

  public func new<T>() : Queue<T> {
    todo()
  };

  public func isEmpty(queue : Queue<Any>) : Bool {
    todo()
  };

  public func size(queue : Queue<Any>) : Nat {
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

  public func pushFront<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  public func pushBack<T>(queue : Queue<T>, element : T) : Queue<T> {
    todo()
  };

  public func popFront<T>(queue : Queue<T>) : ?(T, Queue<T>) {
    todo()
  };

  public func popBack<T>(queue : Queue<T>) : ?(Queue<T>, T) {
    todo()
  };

  public func toIter<T>(queue : Queue<T>) : Iter.Iter<T> = vals(queue);

  public func vals<T>(queue : Queue<T>) : Iter.Iter<T> {
    todo()
  };

  public func equal<T>(queue1 : Queue<T>, queue2 : Queue<T>) : Bool {
    todo()
  };

  public func toText<T>(queue : Queue<T>, f : T -> Text) : Text {
    todo()
  };

}
