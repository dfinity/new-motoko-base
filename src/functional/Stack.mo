/// Class `Stack<X>` provides a Minimal LIFO stack of elements of type `X`

import List "List";

module {

  public class Stack<T>() {

    var stack : List.List<T> = List.nil<T>();

    public func push(x : T) {
      stack := ?(x, stack)
    };

    public func isEmpty() : Bool {
      List.isNil<T>(stack)
    };

    public func peek() : ?T {
      switch stack {
        case null { null };
        case (?(h, _)) { ?h }
      }
    };

    public func pop() : ?T {
      switch stack {
        case null { null };
        case (?(h, t)) { stack := t; ?h }
      }
    }
  }
}