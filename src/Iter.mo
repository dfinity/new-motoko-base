/// Utilities for `Iter` (iterator) values

import Order "Order";
import Array "Array";
import VarArray "VarArray";
import { todo } "Debug";

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

  /// Calls a function `f` on every value produced by an iterator and discards
  /// the results. If you're looking to keep these results use `map` instead.
  ///
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// var sum = 0;
  /// Iter.iterate<Nat>(Iter.range(1, 3), func(x, _index) {
  ///   sum += x;
  /// });
  /// assert(6 == sum)
  /// ```
  public func iterate<T>(
    xs : Iter<T>,
    f : (A, Nat) -> ()
  ) {
    var i = 0;
    label l loop {
      switch (xs.next()) {
        case (?next) {
          f(next, i)
        };
        case (null) {
          break l
        }
      };
      i += 1;
      continue l
    }
  };

  /// Consumes an iterator and counts how many elements were produced
  /// (discarding them in the process).
  public func size<T>(xs : Iter<T>) : Nat {
    var len = 0;
    iterate<T>(xs, func(x, i) { len += 1 });
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
  public func map<A, B>(xs : Iter<T>, f : A -> B) : Iter<R> = object {
    public func next() : ?B {
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
  public func filter<T>(xs : Iter<T>, f : A -> Bool) : Iter<T> = object {
    public func next() : ?A {
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
  public func make<T>(x : A) : Iter<T> = object {
    public func next() : ?A {
      ?x
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
      public func next() : ?A {
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
  public func fromArray<T>(xs : [A]) : Iter<T> {
    var ix : Nat = 0;
    let size = xs.size();
    object {
      public func next() : ?A {
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
  public func fromArrayMut<T>(xs : [var A]) : Iter<T> {
    fromArray<T>(Array.fromVarArray<T>(xs))
  };

  /// Consumes an iterator and collects its produced elements in an Array.
  /// ```motoko
  /// import Iter "mo:base/Iter";
  /// let iter = Iter.range(1, 3);
  /// assert([1, 2, 3] == Iter.toArray(iter));
  /// ```
  public func toArray<T>(xs : Iter<T>) : [A] {
    todo()
  };

  /// Like `toArray` but for Arrays with mutable elements.
  public func toVarArray<T>(xs : Iter<T>) : [var A] {
    Array.toVarArray<T>(toArray<T>(xs))
  };

  /// Sorted iterator.  Will iterate over *all* elements to sort them, necessarily.
  public func sort<T>(xs : Iter<T>, compare : (A, A) -> Order.Order) : Iter<T> {
    let a = toVarArray<T>(xs);
    VarArray.sortInPlace<T>(a, compare);
    fromArrayMut<T>(a)
  };

}
