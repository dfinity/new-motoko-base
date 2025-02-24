/// A mutable stack data structure.
/// Elements can be pushed on top of the stack
/// and removed from top of the stack (LIFO).
///
/// Example:
/// ```motoko
/// import Stack "Stack";
/// import Debug "Debug";
///
/// persistent actor {
///   let levels = Stack.empty<Text>();
///   Stack.push(levels, "Inner");
///   Stack.push(levels, "Middle");
///   Stack.push(levels, "Outer");
///   label iteration loop {
///     switch (Stack.pop(levels)) {
///       case null { break iteration };
///       case (?name) {
///         Debug.print(name)
///       }
///     }
///   }
///   // prints:
///   // `Outer`
///   // `Middle`
///   // `Inner`
/// }
/// ```
///
/// The internal implementation is a singly-linked list.
///
/// Performance:
/// * Runtime: `O(1)` for push, pop, and peek operation.
/// * Space: `O(n)`.
/// `n` denotes the number of elements stored on the stack.

import Order "Order";
import Types "Types";

module {
  type Node<T> = Types.Stack.Node<T>;
  public type Stack<T> = Types.Stack<T>;

  // public func toPure<T>(stack : Stack<T>) : Pure.Stack<T> {
  //   todo()
  // };

  // public func fromPure<T>(stack : Pure.Stack<T>) : Stack<T> {
  //   todo()
  // };

  /// Create a new empty mutable stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Text>();
  ///   Debug.print(Nat.toText(Stack.size(stack))); // prints `0`
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func empty<T>() : Stack<T> {
    {
      var top = null;
      var size = 0
    }
  };

  /// Creates a new stack with `size` elements by applying the `generator` function to indices `[0..size-1]`.
  /// Elements are pushed in ascending index order.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  /// import Debug "mo:base/Debug";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let stack = Stack.tabulate<Nat>(3, func(i) { 2 * i });
  ///   for (number in Stack.values(stack)) {
  ///     Debug.print(Nat.toText(number))
  ///   }
  ///   // prints:
  ///   // `4`
  ///   // `2`
  ///   // `0`
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `generator` has O(1) costs.
  public func tabulate<T>(size : Nat, generator : Nat -> T) : Stack<T> {
    let stack = empty<T>();
    var index = 0;
    while (index < size) {
      let element = generator(index);
      push(stack, element);
      index += 1
    };
    stack
  };

  /// Creates a new stack containing a single element.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.singleton<Text>("motoko");
  ///   assert(Stack.peek(stack) ==?"motoko");
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func singleton<T>(element : T) : Stack<T> {
    let stack = empty<T>();
    push(stack, element);
    stack
  };

  /// Removes all elements from the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter<Nat>([1, 2, 3].values());
  ///   Stack.clear(stack);
  ///   assert(Stack.isEmpty(stack));
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func clear<T>(stack : Stack<T>) {
    stack.top := null;
    stack.size := 0
  };

  /// Creates a deep copy of the stack with the same elements in the same order.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let original = Stack.fromIter([1, 2, 3].values());
  ///   let copy = Stack.clone(original);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack.
  public func clone<T>(stack : Stack<T>) : Stack<T> {
    let copy = empty<T>();
    for (element in values(stack)) {
      push(copy, element)
    };
    reverse(copy);
    copy
  };

  /// Returns true if the stack contains no elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   assert(Stack.isEmpty(stack));
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func isEmpty<T>(stack : Stack<T>) : Bool {
    stack.size == 0
  };

  /// Returns the number of elements on the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.size(stack) == 3);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func size<T>(stack : Stack<T>) : Nat {
    stack.size
  };

  /// Returns true if the stack contains the specified element.
  /// Uses the provided equality function to compare elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.contains(stack, 2, Nat.equal));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and assuming
  /// that `equal` has O(1) costs.
  public func contains<T>(stack : Stack<T>, element : T, equal : (T, T) -> Bool) : Bool {
    for (existing in values(stack)) {
      if (equal(existing, element)) {
        return true
      }
    };
    false
  };

  /// Pushes a new element onto the top of the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.empty<Nat>();
  ///   Stack.push(stack, 42);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func push<T>(stack : Stack<T>, value : T) {
    let node = {
      value;
      next = stack.top
    };
    stack.top := ?node;
    stack.size += 1
  };

  /// Returns the top element of the stack without removing it.
  /// Returns null if the stack is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.peek(stack) == ?3);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func peek<T>(stack : Stack<T>) : ?T {
    switch (stack.top) {
      case null null;
      case (?node) ?node.value
    }
  };

  /// Removes and returns the top element of the stack.
  /// Returns null if the stack is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.pop(stack) == ?3);
  /// }
  /// ```
  ///
  /// Runtime: O(1)
  /// Space: O(1)
  public func pop<T>(stack : Stack<T>) : ?T {
    switch (stack.top) {
      case null null;
      case (?node) {
        stack.top := node.next;
        stack.size -= 1;
        ?node.value
      }
    }
  };

  /// Returns the element at the specified position from the top of the stack.
  /// Returns null if position is out of bounds.
  /// Position 0 is the top of the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.get(stack, 1) == ?2);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack.
  public func get<T>(stack : Stack<T>, position : Nat) : ?T {
    var index = 0;
    var current = stack.top;
    while (index < position) {
      switch (current) {
        case null return null;
        case (?node) {
          current := node.next
        }
      };
      index += 1
    };
    switch (current) {
      case null null;
      case (?node) ?node.value
    }
  };

  /// Reverses the order of elements in the stack.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   Stack.reverse(stack);
  ///   // stack now contains [1, 2, 3] (top to bottom)
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack.
  public func reverse<T>(stack : Stack<T>) {
    var last : ?Node<T> = null;
    for (element in values(stack)) {
      last := ?{
        value = element;
        next = last
      }
    };
    stack.top := last
  };

  /// Returns an iterator over the elements in the stack, from top to bottom.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   for (element in Stack.values(stack)) {
  ///     // Iterates: 3, 2, 1
  ///   };
  /// }
  /// ```
  ///
  /// Runtime: O(1) for iterator creation, O(n) for full traversal
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack.
  public func values<T>(stack : Stack<T>) : Types.Iter<T> {
    object {
      var current = stack.top;

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

  /// Returns true if all elements in the stack satisfy the predicate.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([2, 4, 6].values());
  ///   assert(Stack.all(stack, func(n) = n % 2 == 0));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `predicate` has O(1) costs.
  public func all<T>(stack : Stack<T>, predicate : T -> Bool) : Bool {
    for (element in values(stack)) {
      if (not predicate(element)) {
        return false
      }
    };
    true
  };

  /// Returns true if any element in the stack satisfies the predicate.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.any(stack, func(n) = n == 2));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming `predicate` has O(1) costs.
  public func any<T>(stack : Stack<T>, predicate : T -> Bool) : Bool {
    for (element in values(stack)) {
      if (predicate(element)) {
        return true
      }
    };
    false
  };

  /// Applies the operation to each element in the stack, from top to bottom.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   Stack.forEach(stack, func(n) { Debug.print(debug_show(n)) });
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `operation` has O(1) costs.
  public func forEach<T>(stack : Stack<T>, operation : T -> ()) {
    for (element in values(stack)) {
      operation(element)
    }
  };

  /// Creates a new stack by applying the projection function to each element.
  /// Maintains the original order of elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   let doubled = Stack.map(stack, func(n) = n * 2);
  ///   // doubled contains [6, 4, 2] (top to bottom)
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `project` has O(1) costs.
  public func map<T, U>(stack : Stack<T>, project : T -> U) : Stack<U> {
    let result = empty<U>();
    for (element in values(stack)) {
      push(result, project(element))
    };
    reverse(result);
    result
  };

  /// Creates a new stack containing only elements that satisfy the predicate.
  /// Maintains the relative order of elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3, 4].values());
  ///   let evens = Stack.filter(stack, func(n) = n % 2 == 0);
  ///   // evens contains [4, 2] (top to bottom)
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming `predicate` has O(1) costs.
  public func filter<T>(stack : Stack<T>, predicate : T -> Bool) : Stack<T> {
    let result = empty<T>();
    for (element in values(stack)) {
      if (predicate(element)) {
        push(result, element)
      }
    };
    reverse(result);
    result
  };

  /// Creates a new stack by applying the projection function to each element
  /// and keeping only the successful results (where project returns ?value).
  /// Maintains the relative order of elements.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3, 4].values());
  ///   let evenDoubled = Stack.filterMap(stack, func(n) =
  ///     if (n % 2 == 0) ?(n * 2) else null
  ///   );
  ///   // evenDoubled contains [8, 4] (top to bottom)
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `project` has O(1) costs.
  public func filterMap<T, U>(stack : Stack<T>, project : T -> ?U) : Stack<U> {
    let result = empty<U>();
    for (element in values(stack)) {
      switch (project(element)) {
        case null {};
        case (?newElement) {
          push(result, newElement)
        }
      }
    };
    reverse(result);
    result
  };

  /// Compares two stacks for equality using the provided equality function.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let stack1 = Stack.fromIter([1, 2, 3].values());
  ///   let stack2 = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.equal(stack1, stack2, Nat.equal));
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `equal` has O(1) costs.
  public func equal<T>(stack1 : Stack<T>, stack2 : Stack<T>, equal : (T, T) -> Bool) : Bool {
    if (size(stack1) != size(stack2)) {
      return false
    };
    let iterator1 = values(stack1);
    let iterator2 = values(stack2);
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

  /// Creates a new stack from an iterator.
  /// Elements are pushed in iteration order.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   // stack contains [3, 2, 1] (top to bottom)
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of iterated elements.
  public func fromIter<T>(iter : Types.Iter<T>) : Stack<T> {
    let stack = empty<T>();
    for (element in iter) {
      push(stack, element)
    };
    stack
  };

  /// Converts the stack to its string representation using the provided
  /// element formatting function.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let stack = Stack.fromIter([1, 2, 3].values());
  ///   let text = Stack.toText(stack, Nat.toText);
  ///   // text = "stack(3, 2, 1)"
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(n)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `format` has O(1) costs.
  public func toText<T>(stack : Stack<T>, format : T -> Text) : Text {
    var text = "[";
    var sep = "";
    for (element in values(stack)) {
      text #= sep # format(element);
      sep := ", "
    };
    text #= "]";
    text
  };

  /// Compares two stacks lexicographically using the provided comparison function.
  ///
  /// Example:
  /// ```motoko
  /// import Stack "mo:base/Stack";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let stack1 = Stack.fromIter([1, 2].values());
  ///   let stack2 = Stack.fromIter([1, 2, 3].values());
  ///   assert(Stack.compare(stack1, stack2, Nat.compare) == #less);
  /// }
  /// ```
  ///
  /// Runtime: O(n)
  /// Space: O(1)
  /// where `n` denotes the number of elements stored on the stack and
  /// assuming that `compare` has O(1) costs.
  public func compare<T>(stack1 : Stack<T>, stack2 : Stack<T>, compare : (T, T) -> Order.Order) : Order.Order {
    let iterator1 = values(stack1);
    let iterator2 = values(stack2);
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
