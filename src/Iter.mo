/// Utilities for `Iter` (iterator) values

import Order "Order";
import Array "Array";
import VarArray "VarArray";
import { todo } "Debug";
import Prim "mo:prim";
import Runtime "Runtime";

module {

  /// An iterator that produces values of type `T`. Calling `next` returns
  /// `null` when iteration is finished.
  ///
  /// Iterators are inherently stateful. Calling `next` "consumes" a value from
  /// the Iterator that cannot be put back, so keep that in mind when sharing
  /// iterators between consumers.
  ///
  /// An iterater `i` can be iterated over using
  /// ```
  /// for (x in i) {
  ///   …do something with x…
  /// }
  /// ```
  public type Iter<T> = { next : () -> ?T };

  public func empty<T>() : Iter<T> {
    object {
      public func next() : ?T {
        null
      }
    }
  };

  /// Calls a function `f` on every value produced by an iterator and discards
  /// the results. If you're looking to keep these results use `map` instead.
  ///
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// var sum = 0;
  /// Iter.forEach<Nat>(Iter.range(1, 3), func(x) {
  ///   sum += x;
  /// });
  /// assert(6 == sum)
  /// ```
  public func forEach<T>(
    xs : Iter<T>,
    f : (T) -> ()
  ) {
    label l loop {
      switch (xs.next()) {
        case (?next) {
          f(next)
        };
        case (null) {
          break l
        }
      }
    }
  };

  /// Takes an iterator and returns a new iterator that pairs each element with its index.
  /// The index starts at 0 and increments by 1 for each element.
  ///
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter = Iter.fromArray(["A", "B", "C"]);
  /// let enumerated = Iter.enumerate(iter);
  /// assert(?(0, "A") == enumerated.next());
  /// assert(?(1, "B") == enumerated.next());
  /// assert(?(2, "C") == enumerated.next());
  /// assert(null == enumerated.next());
  /// ```
  public func enumerate<T>(xs : Iter<T>) : Iter<(Nat, T)> {
    object {
      var i = 0;
      public func next() : ?(Nat, T) {
        switch (xs.next()) {
          case (?x) {
            let current = (i, x);
            i += 1;
            ?current
          };
          case null { null }
        }
      }
    }
  };

  /// Consumes an iterator and counts how many elements were produced
  /// (discarding them in the process).
  public func size<T>(xs : Iter<T>) : Nat {
    var len = 0;
    forEach<T>(xs, func(x) { len += 1 });
    len
  };

  /// Takes a function and an iterator and returns a new iterator that lazily applies
  /// the function to every element produced by the argument iterator.
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter = Iter.range(1, 3);
  /// let mappedIter = Iter.map(iter, func (x : Nat) : Nat { x * 2 });
  /// assert(?2 == mappedIter.next());
  /// assert(?4 == mappedIter.next());
  /// assert(?6 == mappedIter.next());
  /// assert(null == mappedIter.next());
  /// ```
  public func map<T, R>(xs : Iter<T>, f : T -> R) : Iter<R> = object {
    public func next() : ?R {
      switch (xs.next()) {
        case (?next) {
          ?f(next)
        };
        case (null) {
          null
        }
      }
    }
  };

  /// Takes a function and an iterator and returns a new iterator that produces
  /// elements from the original iterator if and only if the predicate is true.
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter = Iter.range(1, 3);
  /// let mappedIter = Iter.filter(iter, func (x : Nat) : Bool { x % 2 == 1 });
  /// assert(?1 == mappedIter.next());
  /// assert(?3 == mappedIter.next());
  /// assert(null == mappedIter.next());
  /// ```
  public func filter<T>(xs : Iter<T>, f : T -> Bool) : Iter<T> = object {
    public func next() : ?T {
      loop {
        switch (xs.next()) {
          case (null) {
            return null
          };
          case (?x) {
            if (f(x)) {
              return ?x
            }
          }
        }
      };
      null
    }
  };

  /// Creates an iterator that produces an infinite sequence of `x`.
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter = Iter.make(10);
  /// assert(?10 == iter.next());
  /// assert(?10 == iter.next());
  /// assert(?10 == iter.next());
  /// // ...
  /// ```
  public func infinite<T>(item : T) : Iter<T> = object {
    public func next() : ?T {
      ?item
    }
  };

  /// Takes two iterators and returns a new iterator that produces
  /// elements from the original iterators sequentally.
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter1 = Iter.range(1, 2);
  /// let iter2 = Iter.range(5, 6);
  /// let concatenatedIter = Iter.concat(iter1, iter2);
  /// assert(?1 == concatenatedIter.next());
  /// assert(?2 == concatenatedIter.next());
  /// assert(?5 == concatenatedIter.next());
  /// assert(?6 == concatenatedIter.next());
  /// assert(null == concatenatedIter.next());
  /// ```
  public func concat<T>(a : Iter<T>, b : Iter<T>) : Iter<T> {
    var aEnded : Bool = false;
    object {
      public func next() : ?T {
        if (aEnded) {
          return b.next()
        };
        switch (a.next()) {
          case (?x) ?x;
          case (null) {
            aEnded := true;
            b.next()
          }
        }
      }
    }
  };

  /// Creates an iterator that produces the elements of an Array in ascending index order.
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3]);
  /// assert(?1 == iter.next());
  /// assert(?2 == iter.next());
  /// assert(?3 == iter.next());
  /// assert(null == iter.next());
  /// ```
  public func fromArray<T>(xs : [T]) : Iter<T> {
    var ix : Nat = 0;
    let size = xs.size();
    object {
      public func next() : ?T {
        if (ix >= size) {
          return null
        } else {
          let res = ?(xs[ix]);
          ix += 1;
          return res
        }
      }
    }
  };

  /// Like `fromArray` but for Arrays with mutable elements. Captures
  /// the elements of the Array at the time the iterator is created, so
  /// further modifications won't be reflected in the iterator.
  public func fromVarArray<T>(xs : [var T]) : Iter<T> {
    fromArray<T>(Array.fromVarArray<T>(xs))
  };

  /// Consumes an iterator and collects its produced elements in an Array.
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter = Iter.range(1, 3);
  /// assert([1, 2, 3] == Iter.toArray(iter));
  /// ```
  public func toArray<T>(iter : Iter<T>) : [T] {
    // TODO: Replace implementation. This is just temporay.
    type Node<T> = { value: T; var next: ?Node<T>};
    var first: ?Node<T> = null;
    var last: ?Node<T> = null;
    var count = 0;

    func add(value: T) {
      let node : Node<T> = { value; var next = null };
      switch (last) {
        case null {
          first := ?node;
        };
        case (?previous) {
          previous.next := ?node;
        }
      };
      last := ?node;
      count += 1;
    };

    for (value in iter) {
      add(value);
    };
    if (count == 0) {
      return [];
    };
    var current = first;
    Prim.Array_tabulate<T>(count, func (_) {
      switch (current) {
        case null Runtime.trap("Iter.toArray(): node must not be null");
        case (?node) {
          current := node.next;
          node.value
        }
      }
    });
  };

  /// Like `toArray` but for Arrays with mutable elements.
  public func toVarArray<T>(xs : Iter<T>) : [var T] {
    Array.toVarArray<T>(toArray<T>(xs))
  };

  /// Sorted iterator.  Will iterate over *all* elements to sort them, necessarily.
  public func sort<T>(xs : Iter<T>, compare : (T, T) -> Order.Order) : Iter<T> {
    let a = toVarArray<T>(xs);
    VarArray.sortInPlace<T>(a, compare);
    fromVarArray<T>(a)
  };

}
