/// Original: `Deque.mo`

import Iter "../Iter";
import Stack "Stack";
import { todo } "../Debug";

module {
  public type Queue<T> = (Stack.Stack<T>, Stack.Stack<T>);

  public func empty<T>() : Queue<T> {
    todo()
  };

  public func singleton<T>(item : T) : Queue<T> {
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

  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    todo()
  };

  public func values<T>(queue : Queue<T>) : Iter.Iter<T> {
    todo()
  };

  public func equal<T>(queue1 : Queue<T>, queue2 : Queue<T>) : Bool {
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

  public func toText<T>(queue : Queue<T>, f : T -> Text) : Text {
    todo()
  };

}
