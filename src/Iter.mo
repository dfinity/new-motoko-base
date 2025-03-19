/// Utilities for `Iter` (iterator) values.
///
/// Iterators are a way to represent sequences of values that can be lazily produced.
/// They can be used to:
/// - Iterate over collections.
/// - Represent collections that are too large to fit in memory or that are produced incrementally.
/// - Transform collections without creating intermediate collections.
///
/// Iterators are inherently stateful. Calling `next` "consumes" a value from
/// the Iterator that cannot be put back, so keep that in mind when sharing
/// iterators between consumers.
///
/// An iterator `i` can be iterated over using
/// ```motoko
/// for (x in i) {
///   …do something with x…
/// }
/// ```
///
/// Iterators can be:
/// - created from other collections (e.g. using `values` or `keys` function on a `Map`) or from scratch (e.g. using `empty` or `singleton`).
/// - transformed using `map`, `filter`, `concat`, etc. Which can be used to compose several transformations together without materializing intermediate collections.
/// - consumed using `forEach`, `size`, `toArray`, etc.
/// - combined using `concat`.

import Prim "mo:prim";

import Array "Array";
import Order "Order";
import Runtime "Runtime";
import Types "Types";
import VarArray "VarArray";

module {

  /// An iterator that produces values of type `T`. Calling `next` returns
  /// `null` when iteration is finished.
  ///
  /// Iterators are inherently stateful. Calling `next` "consumes" a value from
  /// the Iterator that cannot be put back, so keep that in mind when sharing
  /// iterators between consumers.
  ///
  /// An iterator `i` can be iterated over using
  /// ```
  /// for (x in i) {
  ///   …do something with x…
  /// }
  /// ```
  public type Iter<T> = Types.Iter<T>;

  /// Creates an empty iterator.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// for (x in Iter.empty<Nat>())
  ///   assert false; // This loop body will never run
  /// ```
  public func empty<T>() : Iter<T> {
    object {
      public func next() : ?T {
        null
      }
    }
  };

  /// Creates an iterator that produces a single value.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// var sum = 0;
  /// for (x in Iter.singleton(3))
  ///   sum += x;
  /// assert(3 == sum);
  /// ```
  public func singleton<T>(value : T) : Iter<T> {
    object {
      var state = ?value;
      public func next() : ?T {
        switch state {
          case null null;
          case some {
            state := null;
            some
          }
        }
      }
    }
  };

  /// Calls a function `f` on every value produced by an iterator and discards
  /// the results. If you're looking to keep these results use `map` instead.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// var sum = 0;
  /// Iter.forEach<Nat>([1, 2, 3].values(), func(x) {
  ///   sum += x;
  /// });
  /// assert(6 == sum)
  /// ```
  public func forEach<T>(
    iter : Iter<T>,
    f : (T) -> ()
  ) {
    label l loop {
      switch (iter.next()) {
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
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray(["A", "B", "C"]);
  /// let enumerated = Iter.enumerate(iter);
  /// Array.toArray(enumerated) // => [(0, "A"), (1, "B"), (2, "C")];
  /// ```
  public func enumerate<T>(iter : Iter<T>) : Iter<(Nat, T)> {
    object {
      var i = 0;
      public func next() : ?(Nat, T) {
        switch (iter.next()) {
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

  /// Creates a new iterator that yields every nth element from the original iterator.
  /// If `interval` is 0, returns an empty iterator. If `interval` is 1, returns the original iterator.
  /// For any other positive interval, returns an iterator that skips `interval - 1` elements after each yielded element.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3, 4, 5, 6]);
  /// let steppedIter = Iter.step(iter, 2); // Take every 2nd element
  /// assert(?1 == steppedIter.next());
  /// assert(?3 == steppedIter.next());
  /// assert(?5 == steppedIter.next());
  /// assert(null == steppedIter.next());
  /// ```
  public func step<T>(iter : Iter<T>, n : Nat) : Iter<T> {
    if (n == 0) {
      empty()
    } else if (n == 1) {
      iter
    } else {
      object {
        public func next() : ?T {
          let item = iter.next();
          var i = 1;
          while (i < n) {
            ignore iter.next();
            i += 1
          };
          item
        }
      }
    }
  };

  /// Consumes an iterator and counts how many elements were produced (discarding them in the process).
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = [1, 2, 3].values();
  /// assert(3 == Iter.size(iter));
  /// ```
  public func size<T>(iter : Iter<T>) : Nat {
    var len = 0;
    forEach<T>(iter, func(x) { len += 1 });
    len
  };

  /// Takes a function and an iterator and returns a new iterator that lazily applies
  /// the function to every element produced by the argument iterator.
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = [1, 2, 3].values();
  /// let mappedIter = Iter.map<Nat, Nat>(iter, func (x) = x * 2);
  /// Iter.toArray(mappedIter) // => [2, 4, 6]
  /// ```
  public func map<T, R>(iter : Iter<T>, f : T -> R) : Iter<R> = object {
    public func next() : ?R {
      switch (iter.next()) {
        case (?next) {
          ?f(next)
        };
        case (null) {
          null
        }
      }
    }
  };

  /// Creates a new iterator that only includes elements from the original iterator
  /// for which the predicate function returns true.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = [1, 2, 3, 4, 5].values();
  /// let evenNumbers = Iter.filter<Nat>(iter, func (x) = x % 2 == 0);
  /// Iter.toArray(evenNumbers) // => [2, 4]
  /// ```
  public func filter<T>(iter : Iter<T>, f : T -> Bool) : Iter<T> = object {
    public func next() : ?T {
      loop {
        let ?x = iter.next() else return null;
        if (f x) return ?x
      };
      null
    }
  };

  /// Creates a new iterator by applying a transformation function to each element
  /// of the original iterator. Elements for which the function returns null are
  /// excluded from the result.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = [1, 2, 3].values();
  /// let evenNumbers = Iter.filterMap<Nat, Nat>(iter, func (x) = if (x % 2 == 0) ?x else null);
  /// Iter.toArray(evenNumbers) // => [2]
  /// ```
  public func filterMap<T, R>(iter : Iter<T>, f : T -> ?R) : Iter<R> = object {
    public func next() : ?R {
      loop {
        let ?x = iter.next() else return null;
        switch (f x) {
          case (?r) return ?r;
          case null {} // continue
        }
      }
    }
  };

  /// Flattens an iterator of iterators into a single iterator by concatenating the inner iterators.
  ///
  /// Possible optimization: Use `flatMap` when you need to transform elements before calling `flatten`. Example: use `flatMap(...)` instead of `flatten(map(...))`.
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.flatten([[1, 2].values(), [3].values(), [4, 5, 6].values()].values());
  /// Iter.toArray(iter) // => [1, 2, 3, 4, 5, 6]
  /// ```
  public func flatten<T>(iter : Iter<Iter<T>>) : Iter<T> = object {
    var current : Iter<T> = empty();
    public func next() : ?T {
      loop {
        switch (current.next()) {
          case (?x) return ?x;
          case null {
            let ?next = iter.next() else return null;
            current := next
          }
        }
      }
    }
  };

  /// Transforms every element of an iterator into an iterator and concatenates the results.
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.flatMap<Nat, Nat>([1, 3, 5].values(), func (x) = [x, x + 1].values());
  /// Iter.toArray(iter) // => [1, 2, 3, 4, 5, 6]
  /// ```
  public func flatMap<T, R>(iter : Iter<T>, f : T -> Iter<R>) : Iter<R> = object {
    var current : Iter<R> = empty();
    public func next() : ?R {
      loop {
        switch (current.next()) {
          case (?x) return ?x;
          case null {
            let ?next = iter.next() else return null;
            current := f(next)
          }
        }
      }
    }
  };

  /// Returns a new iterator that yields at most, first `n` elements from the original iterator.
  /// After `n` elements have been produced or the original iterator is exhausted,
  /// subsequent calls to `next()` will return `null`.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3, 4, 5]);
  /// let first3 = Iter.take(iter, 3);
  /// Iter.toArray(first3) // => [1, 2, 3]
  /// ```
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3]);
  /// let first5 = Iter.take(iter, 5);
  /// Iter.toArray(first5) // => [1, 2, 3] only 3 elements in the original iterator
  /// ```
  public func take<T>(iter : Iter<T>, n : Nat) : Iter<T> = object {
    var remaining = n;
    public func next() : ?T {
      if (remaining == 0) return null;
      remaining -= 1;
      iter.next()
    }
  };

  /// Returns a new iterator that yields elements from the original iterator until the predicate function returns false.
  /// The first element for which the predicate returns false is not included in the result.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3, 4, 5, 4, 3, 2, 1]);
  /// let result = Iter.takeWhile<Nat>(iter, func (x) = x < 4);
  /// Iter.toArray(result) // => [1, 2, 3] note the difference between `takeWhile` and `filter`
  /// ```
  public func takeWhile<T>(iter : Iter<T>, f : T -> Bool) : Iter<T> = object {
    var done = false;
    public func next() : ?T {
      if done return null;
      let ?x = iter.next() else return null;
      if (f x) return ?x;
      done := true;
      null
    }
  };

  /// Returns a new iterator that skips the first `n` elements from the original iterator.
  /// If the original iterator has fewer than `n` elements, the result will be an empty iterator.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3, 4, 5]);
  /// let skipped = Iter.drop(iter, 3);
  /// Iter.toArray(skipped) // => [4, 5]
  /// ```
  public func drop<T>(iter : Iter<T>, n : Nat) : Iter<T> = object {
    var remaining = n;
    public func next() : ?T {
      while (remaining > 0) {
        let ?_ = iter.next() else return null;
        remaining -= 1
      };
      iter.next()
    }
  };

  /// Returns a new iterator that skips elements from the original iterator until the predicate function returns false.
  /// The first element for which the predicate returns false is the first element produced by the new iterator.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3, 4, 5, 4, 3, 2, 1]);
  /// let result = Iter.dropWhile<Nat>(iter, func (x) = x < 4);
  /// Iter.toArray(result) // => [4, 5, 4, 3, 2, 1] notice that `takeWhile` and `dropWhile` are complementary
  /// ```
  public func dropWhile<T>(iter : Iter<T>, f : T -> Bool) : Iter<T> = object {
    var dropping = true;
    public func next() : ?T {
      while dropping {
        let ?x = iter.next() else return null;
        if (not f x) {
          dropping := false;
          return ?x
        }
      };
      iter.next()
    }
  };

  /// Zips two iterators into a single iterator that produces pairs of elements.
  /// The resulting iterator will stop producing elements when either of the input iterators is exhausted.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter1 = [1, 2, 3].values();
  /// let iter2 = ["A", "B"].values();
  /// let zipped = Iter.zip(iter1, iter2);
  /// Iter.toArray(zipped) // => [(1, "A"), (2, "B")] note that the third element from iter1 is not included, because iter2 is exhausted
  /// ```
  public func zip<A, B>(a : Iter<A>, b : Iter<B>) : Iter<(A, B)> = object {
    public func next() : ?(A, B) {
      let ?x = a.next() else return null;
      let ?y = b.next() else return null;
      ?(x, y)
    }
  };

  /// Zips three iterators into a single iterator that produces triples of elements.
  /// The resulting iterator will stop producing elements when any of the input iterators is exhausted.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter1 = ["A", "B"].values();
  /// let iter2 = ["1", "2", "3"].values();
  /// let iter3 = ["x", "y", "z", "xd"].values();
  /// let zipped = Iter.zip3(iter1, iter2, iter3);
  /// Iter.toArray(zipped) // => [("A", "1", "x"), ("B", "2", "y")] note that the unmatched elements from iter2 and iter3 are not included
  /// ```
  public func zip3<A, B, C>(a : Iter<A>, b : Iter<B>, c : Iter<C>) : Iter<(A, B, C)> = object {
    public func next() : ?(A, B, C) {
      let ?x = a.next() else return null;
      let ?y = b.next() else return null;
      let ?z = c.next() else return null;
      ?(x, y, z)
    }
  };

  /// Zips two iterators into a single iterator by applying a function to zipped pairs of elements.
  /// The resulting iterator will stop producing elements when either of the input iterators is exhausted.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter1 = ["A", "B"].values();
  /// let iter2 = ["1", "2", "3"].values();
  /// let zipped = Iter.zipWith<Text, Text, Text>(iter1, iter2, func (a, b) = a # b);
  /// Iter.toArray(zipped) // => ["A1", "B2"] note that the third element from iter2 is not included, because iter1 is exhausted
  /// ```
  public func zipWith<A, B, R>(a : Iter<A>, b : Iter<B>, f : (A, B) -> R) : Iter<R> = object {
    public func next() : ?R {
      let ?x = a.next() else return null;
      let ?y = b.next() else return null;
      ?f(x, y)
    }
  };

  /// Zips three iterators into a single iterator by applying a function to zipped triples of elements.
  /// The resulting iterator will stop producing elements when any of the input iterators is exhausted.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter1 = ["A", "B"].values();
  /// let iter2 = ["1", "2", "3"].values();
  /// let iter3 = ["x", "y", "z", "xd"].values();
  /// let zipped = Iter.zipWith3<Text, Text, Text, Text>(iter1, iter2, iter3, func (a, b, c) = a # b # c);
  /// Iter.toArray(zipped) // => ["A1x", "B2y"] note that the unmatched elements from iter2 and iter3 are not included
  /// ```
  public func zipWith3<A, B, C, R>(a : Iter<A>, b : Iter<B>, c : Iter<C>, f : (A, B, C) -> R) : Iter<R> = object {
    public func next() : ?R {
      let ?x = a.next() else return null;
      let ?y = b.next() else return null;
      let ?z = c.next() else return null;
      ?f(x, y, z)
    }
  };

  /// Checks if a predicate function is true for all elements produced by an iterator.
  /// It stops consuming elements from the original iterator as soon as the predicate returns false.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.all<Nat>([1, 2, 3].values(), func (x) = x < 4) // => true
  /// Iter.all<Nat>([1, 2, 3].values(), func (x) = x < 3) // => false
  /// ```
  public func all<T>(iter : Iter<T>, f : T -> Bool) : Bool {
    for (x in iter) {
      if (not f x) return false
    };
    true
  };

  /// Checks if a predicate function is true for any element produced by an iterator.
  /// It stops consuming elements from the original iterator as soon as the predicate returns true.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.any<Nat>([1, 2, 3].values(), func (x) = x == 2) // => true
  /// Iter.any<Nat>([1, 2, 3].values(), func (x) = x == 4) // => false
  /// ```
  public func any<T>(iter : Iter<T>, f : T -> Bool) : Bool {
    for (x in iter) {
      if (f x) return true
    };
    false
  };

  /// Finds the first element produced by an iterator for which a predicate function returns true.
  /// Returns `null` if no such element is found.
  /// It stops consuming elements from the original iterator as soon as the predicate returns true.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.find<Nat>([1, 2, 3, 4].values(), func (x) = x % 2 == 0) // => ?2
  /// ```
  public func find<T>(iter : Iter<T>, f : T -> Bool) : ?T {
    for (x in iter) {
      if (f x) return ?x
    };
    null
  };

  /// Checks if an element is produced by an iterator.
  /// It stops consuming elements from the original iterator as soon as the predicate returns true.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// import Nat "mo:new-base/Nat";
  /// Iter.contains<Nat>([1, 2, 3].values(), Nat.equal, 2) // => true
  /// ```
  public func contains<T>(iter : Iter<T>, equal : (T, T) -> Bool, value : T) : Bool {
    for (x in iter) {
      if (equal(x, value)) return true
    };
    false
  };

  /// Reduces an iterator to a single value by applying a function to each element and an accumulator.
  /// The accumulator is initialized with the `initial` value.
  /// It starts applying the `combine` function starting from the `initial` accumulator value and the first elements produced by the iterator.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.foldLeft<Text>(["A", "B", "C"].values(), "S", func (acc, x) = "(" # acc # x # ")") // => ?"(((SA)B)C)"
  /// ```
  public func foldLeft<T, R>(iter : Iter<T>, initial : R, combine : (R, T) -> R) : R {
    var acc = initial;
    for (x in iter) {
      acc := combine(acc, x)
    };
    acc
  };

  /// Reduces an iterator to a single value by applying a function to each element in reverse order and an accumulator.
  /// The accumulator is initialized with the `initial` value and it is first combined with the last element produced by the iterator.
  /// It starts applying the `combine` function starting from the last elements produced by the iterator.
  ///
  /// **Performance note**: Since this function needs to consume the entire iterator to reverse it,
  /// it has to materialize the entire iterator in memory to get to the last element to start applying the `combine` function.
  /// **Use `foldLeft` or `reduce` when possible to avoid the extra memory overhead**.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.foldRight<Text>(["A", "B", "C"].values(), "S", func (x, acc) = "(" # x # acc # ")") // => ?"(A(B(CS)))"
  /// ```
  public func foldRight<T, R>(iter : Iter<T>, initial : R, combine : (T, R) -> R) : R {
    foldLeft<T, R>(reverse(iter), initial, func(acc, x) = combine(x, acc))
  };

  /// Reduces an iterator to a single value by applying a function to each element, starting with the first elements.
  /// The accumulator is initialized with the first element produced by the iterator.
  /// When the iterator is empty, it returns `null`.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.reduce<Nat>([1, 2, 3].values(), Nat.add) // => ?6
  /// ```
  public func reduce<T>(iter : Iter<T>, combine : (T, T) -> T) : ?T {
    let ?first = iter.next() else return null;
    ?foldLeft(iter, first, combine)
  };

  /// Consumes an iterator and returns the first maximum element produced by the iterator.
  /// If the iterator is empty, it returns `null`.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.max<Nat>([1, 2, 3].values(), Nat.compare) // => ?3
  /// ```
  public func max<T>(iter : Iter<T>, compare : (T, T) -> Order.Order) : ?T {
    reduce<T>(
      iter,
      func(a, b) {
        switch (compare(a, b)) {
          case (#less) b;
          case _ a
        }
      }
    )
  };

  /// Consumes an iterator and returns the first minimum element produced by the iterator.
  /// If the iterator is empty, it returns `null`.
  ///
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// Iter.min<Nat>([1, 2, 3].values(), Nat.compare) // => ?1
  /// ```
  public func min<T>(iter : Iter<T>, compare : (T, T) -> Order.Order) : ?T {
    reduce<T>(
      iter,
      func(a, b) {
        switch (compare(a, b)) {
          case (#greater) b;
          case _ a
        }
      }
    )
  };

  /// Creates an iterator that produces an infinite sequence of `x`.
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
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
  /// import Iter "mo:new-base/Iter";
  /// let iter1 = [1, 2].values();
  /// let iter2 = [5, 6, 7].values();
  /// let concatenatedIter = Iter.concat(iter1, iter2);
  /// Iter.toArray(concatenatedIter) // => [1, 2, 5, 6, 7]
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
  /// import Iter "mo:new-base/Iter";
  /// let iter = Iter.fromArray([1, 2, 3]);
  /// assert(?1 == iter.next());
  /// assert(?2 == iter.next());
  /// assert(?3 == iter.next());
  /// assert(null == iter.next());
  /// ```
  public func fromArray<T>(array : [T]) : Iter<T> = array.vals();

  /// Like `fromArray` but for Arrays with mutable elements. Captures
  /// the elements of the Array at the time the iterator is created, so
  /// further modifications won't be reflected in the iterator.
  public func fromVarArray<T>(array : [var T]) : Iter<T> = array.vals();

  /// Consumes an iterator and collects its produced elements in an Array.
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  /// let iter = [1, 2, 3].values();
  /// assert([1, 2, 3] == Iter.toArray(iter));
  /// ```
  public func toArray<T>(iter : Iter<T>) : [T] {
    // TODO: Replace implementation. This is just temporay.
    type Node<T> = { value : T; var next : ?Node<T> };
    var first : ?Node<T> = null;
    var last : ?Node<T> = null;
    var count = 0;

    func add(value : T) {
      let node : Node<T> = { value; var next = null };
      switch (last) {
        case null {
          first := ?node
        };
        case (?previous) {
          previous.next := ?node
        }
      };
      last := ?node;
      count += 1
    };

    for (value in iter) {
      add(value)
    };
    if (count == 0) {
      return []
    };
    var current = first;
    Prim.Array_tabulate<T>(
      count,
      func(_) {
        switch (current) {
          case null Runtime.trap("Iter.toArray(): node must not be null");
          case (?node) {
            current := node.next;
            node.value
          }
        }
      }
    )
  };

  /// Like `toArray` but for Arrays with mutable elements.
  public func toVarArray<T>(iter : Iter<T>) : [var T] {
    Array.toVarArray<T>(toArray<T>(iter))
  };

  /// Sorted iterator.  Will iterate over *all* elements to sort them, necessarily.
  public func sort<T>(iter : Iter<T>, compare : (T, T) -> Order.Order) : Iter<T> {
    let array = toVarArray<T>(iter);
    VarArray.sortInPlace<T>(array, compare);
    fromVarArray<T>(array)
  };

  /// Creates an iterator that produces a given item a specified number of times.
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  ///
  /// let iter = Iter.repeat<Nat>(3, 2);
  /// assert(?3 == iter.next());
  /// assert(?3 == iter.next());
  /// assert(null == iter.next());
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func repeat<T>(item : T, count : Nat) : Iter<T> = object {
    var remaining = count;
    public func next() : ?T {
      if (remaining == 0) {
        null
      } else {
        remaining -= 1;
        ?item
      }
    }
  };

  /// Creates a new iterator that produces elements from the original iterator in reverse order.
  /// Note: This function needs to consume the entire iterator to reverse it.
  /// ```motoko
  /// import Iter "mo:new-base/Iter";
  ///
  /// let iter = Iter.fromArray([1, 2, 3]);
  /// let reversed = Iter.reverse(iter);
  /// assert(?3 == reversed.next());
  /// assert(?2 == reversed.next());
  /// assert(?1 == reversed.next());
  /// assert(null == reversed.next());
  /// ```
  ///
  /// Runtime: O(n) where n is the number of elements in the iterator
  ///
  /// Space: O(n) where n is the number of elements in the iterator
  public func reverse<T>(iter : Iter<T>) : Iter<T> {
    fromArray(Array.reverse(toArray(iter))) // TODO: optimize
  };

}
