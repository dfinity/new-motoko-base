/// An imperative double-ended queue of elements.
/// The queue has two ends, front and back.
/// Elements can be added and removed at the two ends.
///
/// This can be used for different use cases, such as:
/// * Queue (FIFO) by using `pushBack()` and `popFront()`
/// * Stack (LIFO) by using `pushFront()` and `popFront()`.
///
/// Example:
/// ```motoko
/// import Queue "Queue";
/// import Debug "Debug";
///
/// persistent actor {
///   let orders = Queue.empty<Text>();
///   Queue.pushBack(orders, "Antipasta");
///   Queue.pushBack(orders, "Spaghetti");
///   Queue.pushBack(orders, "Bistecca");
///   Queue.pushBack(orders, "Dolce");
///   label iteration loop {
///     switch (Queue.popFront(orders)) {
///       case null { break iteration };
///       case (?description) {
///         Debug.print(description)
///       }
///     }
///   }
///   // prints:
///   // `"Antipasta"`
///   // `"Spaghetti"`
///   // `"Bistecca"`
///   // `"Dolce"`
/// }
/// ```
///
/// The internal implementation is a doubly-linked list.
///
/// Performance:
/// * Runtime: `O(1)` amortized costs, `O(n)` worst case cost per single call.
/// * Space: `O(1)` amortized costs, `O(n)` worst case cost per single call.
/// `n` denotes the number of elements stored in the queue.

import Iter "Iter";
import Order "Order";
import Types "Types";
import Bool "Bool";

module {
  public type Queue<T> = Types.Queue.Queue<T>;

  type Node<T> = Types.Queue.Node<T>;

  // public func toPure<T>(queue : Queue<T>) : PureQueue.Queue<T> = queue.pure;

  // public func fromPure<T>(queue : PureQueue.Queue<T>) : Queue<T> {
  //   { var pure = queue }
  // };

  /// Create a new empty mutable double-ended queue.
  ///
  /// Example:
  /// ```motoko
  /// import Queue "mo:base/Queue";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let queue = Queue.empty<Text>();
  ///   Debug.print(Nat.toText(Queue.size(queue))); // prints `0`
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func empty<T>() : Queue<T> {
    { var front = null; var back = null; var size = 0 }
  };

  public func singleton<T>(element : T) : Queue<T> {
    let queue = empty<T>();
    pushBack(queue, element);
    queue
  };

  public func clear<T>(queue : Queue<T>) {
    queue.front := null;
    queue.back := null;
    queue.size := 0
  };

  public func clone<T>(queue : Queue<T>) : Queue<T> {
    let copy = empty<T>();
    for (element in values(queue)) {
      pushBack(copy, element)
    };
    copy
  };

  public func size<T>(queue : Queue<T>) : Nat {
    queue.size
  };

  public func isEmpty<T>(queue : Queue<T>) : Bool {
    queue.size == 0
  };

  public func contains<T>(queue : Queue<T>, equals : (T, T) -> Bool, element : T) : Bool {
    for (existing in values(queue)) {
      if (equals(existing, element)) {
        return true
      }
    };
    false
  };

  public func peekFront<T>(queue : Queue<T>) : ?T {
    switch (queue.front) {
      case null null;
      case (?node) ?node.value
    }
  };

  public func peekBack<T>(queue : Queue<T>) : ?T {
    switch (queue.back) {
      case null null;
      case (?node) ?node.value
    }
  };

  public func pushFront<T>(queue : Queue<T>, element : T) {
    let node : Node<T> = {
      value = element;
      var next = queue.front;
      var previous = null
    };
    switch (queue.front) {
      case null {};
      case (?first) first.previous := ?node
    };
    queue.front := ?node;
    switch (queue.back) {
      case null {};
      case (?_) queue.back := ?node
    };
    queue.size += 1
  };

  public func pushBack<T>(queue : Queue<T>, element : T) {
    let node : Node<T> = {
      value = element;
      var next = null;
      var previous = queue.back
    };
    switch (queue.back) {
      case null {};
      case (?last) last.next := ?node
    };
    queue.back := ?node;
    switch (queue.front) {
      case null {};
      case (?_) queue.front := ?node
    };
    queue.size += 1
  };

  public func popFront<T>(queue : Queue<T>) : ?T {
    switch (queue.front) {
      case null null;
      case (?first) {
        queue.front := first.next;
        switch (queue.front) {
          case null { queue.back := null };
          case (?newFirst) { newFirst.previous := null }
        };
        queue.size -= 1;
        ?first.value
      }
    }
  };

  public func popBack<T>(queue : Queue<T>) : ?T {
    switch (queue.back) {
      case null null;
      case (?last) {
        queue.back := last.previous;
        switch (queue.back) {
          case null { queue.front := null };
          case (?newLast) { newLast.next := null }
        };
        queue.size -= 1;
        ?last.value
      }
    }
  };

  public func fromIter<T>(iter : Iter.Iter<T>) : Queue<T> {
    let queue = empty<T>();
    for (element in iter) {
      pushBack(queue, element)
    };
    queue
  };

  public func values<T>(queue : Queue<T>) : Iter.Iter<T> {
    object {
      var current = queue.front;

      public func next() : ?T {
        switch (current) {
          case null null;
          case (?node) {
            current := node.next;
            ?node.value
          }
        }
      }
    }
  };

  public func all<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    for (element in values(queue)) {
      if (not predicate(element)) {
        return false
      }
    };
    true
  };

  public func any<T>(queue : Queue<T>, predicate : T -> Bool) : Bool {
    for (element in values(queue)) {
      if (predicate(element)) {
        return true
      }
    };
    false
  };

  public func forEach<T>(queue : Queue<T>, operation : T -> ()) {
    for (element in values(queue)) {
      operation(element)
    }
  };

  public func map<T, U>(queue : Queue<T>, project : T -> U) : Queue<U> {
    let result = empty<U>();
    for (element in values(queue)) {
      pushBack(result, project(element))
    };
    result
  };

  public func filter<T>(queue : Queue<T>, criterion : T -> Bool) : Queue<T> {
    let result = empty<T>();
    for (element in values(queue)) {
      if (criterion(element)) {
        pushBack(result, element)
      }
    };
    result
  };

  public func filterMap<T, U>(queue : Queue<T>, project : T -> ?U) : Queue<U> {
    let result = empty<U>();
    for (element in values(queue)) {
      switch (project(element)) {
        case null {};
        case (?newElement) pushBack(result, newElement)
      }
    };
    result
  };

  public func equal<T>(queue1 : Queue<T>, queue2 : Queue<T>, equal : (T, T) -> Bool) : Bool {
    if (size(queue1) != size(queue2)) {
      return false
    };
    let iterator1 = values(queue1);
    let iterator2 = values(queue2);
    loop {
      let element1 = iterator1.next();
      let element2 = iterator2.next();
      switch (element1, element2) {
        case (null, null) {
          return true
        };
        case (?element1, ?element2) {
          if (not equal(element1, element2)) {
            return false
          }
        };
        case _ { return false }
      }
    }
  };

  public func toText<T>(queue : Queue<T>, format : T -> Text) : Text {
    var text = "(";
    var sep = "";
    for (element in values(queue)) {
      text #= sep # format(element);
      sep := ", "
    };
    text #= ")";
    text
  };

  public func compare<T>(queue1 : Queue<T>, queue2 : Queue<T>, compare : (T, T) -> Order.Order) : Order.Order {
    let iterator1 = values(queue1);
    let iterator2 = values(queue2);
    loop {
      switch (iterator1.next(), iterator2.next()) {
        case (null, null) return #equal;
        case (null, _) return #less;
        case (_, null) return #greater;
        case (?element1, ?element2) {
          let comparison = compare(element1, element2);
          if (comparison != #equal) {
            return comparison
          }
        }
      }
    }
  }
}
