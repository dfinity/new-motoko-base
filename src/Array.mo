/// Provides extended utility functions on Arrays.
///
/// Note the difference between mutable and non-mutable arrays below.
///
/// WARNING: If you are looking for a list that can grow and shrink in size,
/// it is recommended you use either the Buffer class or the List class for
/// those purposes. Arrays must be created with a fixed size.
///
/// Import from the base library to use this module.
/// ```motoko name=import
/// import Array "mo:base/Array";
/// ```

import Iter "IterType";
import Order "Order";
import Result "Result";
import VarArray "VarArray";
import Option "Option";
import Prim "mo:⛔";
import { todo } "Debug";

module {

  /// Creates an empty array (equivalent to `[]`).
  public func empty<T>() : [T] = [];

  /// Creates an array containing `item` repeated `size` times.
  ///
  /// ```motoko include=import
  /// let array = Array.repeat<Nat>("Echo", 3);
  /// assert array == [var "Echo", "Echo", "Echo"];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func repeat<T>(item : T, size : Nat) : [T] = Prim.Array_tabulate<T>(size, func _ = item);

  /// Creates an immutable array of size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// let array : [Nat] = Array.tabulate<Nat>(4, func i = i * 2);
  /// assert array == [0, 2, 4, 6];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `generator` runs in O(1) time and space.
  public func tabulate<T>(size : Nat, generator : Nat -> T) : [T] = Prim.Array_tabulate<T>(size, generator);

  /// Transforms a mutable array into an immutable array.
  ///
  /// ```motoko include=import
  ///
  /// let varArray = [var 0, 1, 2];
  /// varArray[2] := 3;
  /// let array = Array.fromVarArray<Nat>(varArray);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func fromVarArray<T>(varArray : [var T]) : [T] = Prim.Array_tabulate<T>(varArray.size(), func i = varArray[i]);

  /// Transforms an immutable array into a mutable array.
  ///
  /// ```motoko include=import
  ///
  /// let array = [0, 1, 2];
  /// let varArray = Array.toVarArray<Nat>(array);
  /// varArray[2] := 3;
  /// varArray
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func toVarArray<T>(array : [T]) : [var T] {
    let size = array.size();
    if (size == 0) {
      return [var]
    };
    let newArray = Prim.Array_init<T>(size, array[0]);
    var i = 0;
    while (i < size) {
      newArray[i] := array[i];
      i += 1
    };
    newArray
  };

  /// Tests if two arrays contain equal values (i.e. they represent the same
  /// list of elements). Uses `equal` to compare elements in the arrays.
  ///
  /// ```motoko include=import
  /// // Use the equal function from the Nat module to compare Nats
  /// import {equal} "mo:base/Nat";
  ///
  /// let array1 = [0, 1, 2, 3];
  /// let array2 = [0, 1, 2, 3];
  /// Array.equal(array1, array2, equal)
  /// ```
  ///
  /// Runtime: O(size1 + size2)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func equal<T>(array1 : [T], array2 : [T], equal : (T, T) -> Bool) : Bool {
    let size1 = array1.size();
    let size2 = array2.size();
    if (size1 != size2) {
      return false
    };
    var i = 0;
    while (i < size1) {
      if (not equal(array1[i], array2[i])) {
        return false
      };
      i += 1
    };
    true
  };

  /// Returns the first value in `array` for which `predicate` returns true.
  /// If no element satisfies the predicate, returns null.
  ///
  /// ```motoko include=import
  /// let array = [1, 9, 4, 8];
  /// Array.find<Nat>(array, func x = x > 8)
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func find<T>(array : [T], predicate : T -> Bool) : ?T {
    for (element in array.vals()) {
      if (predicate element) {
        return ?element
      }
    };
    null
  };

  /// Create a new array by concatenating the values of `array1` and `array2`.
  /// Note that `Array.append` copies its arguments and has linear complexity.
  ///
  /// ```motoko include=import
  /// let array1 = [1, 2, 3];
  /// let array2 = [4, 5, 6];
  /// Array.concat<Nat>(array1, array2)
  /// ```
  /// Runtime: O(size1 + size2)
  ///
  /// Space: O(size1 + size2)
  public func concat<T>(array1 : [T], array2 : [T]) : [T] {
    let size1 = array1.size();
    let size2 = array2.size();
    Prim.Array_tabulate<T>(
      size1 + size2,
      func i {
        if (i < size1) {
          array1[i]
        } else {
          array2[i - size1]
        }
      }
    )
  };

  /// Sorts the elements in the array according to `compare`.
  /// Sort is deterministic and stable.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [4, 2, 6];
  /// Array.sort(array, Nat.compare)
  /// ```
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sort<T>(array : [T], compare : (T, T) -> Order.Order) : [T] {
    let varArray : [var T] = toVarArray(array);
    VarArray.sortInPlace(varArray, compare);
    fromVarArray(varArray)
  };

  /// Creates a new array by reversing the order of elements in `array`.
  ///
  /// ```motoko include=import
  ///
  /// let array = [10, 11, 12];
  ///
  /// Array.reverse(array)
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func reverse<T>(array : [T]) : [T] {
    let size = array.size();
    Prim.Array_tabulate<T>(size, func i = array[size - i - 1])
  };

  /// Calls `f` with each element in `array`.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  /// import Debug "mo:base/Debug";
  ///
  /// let array = [0, 1, 2, 3];
  /// Array.forEach<Nat>(array, func(x) {
  ///   Debug.print(debug_show x)
  /// })
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEach<T>(array : [T], f : T -> ()) {
    for (item in array.vals()) {
      f(item)
    }
  };

  /// Creates a new array by applying `f` to each element in `array`. `f` "maps"
  /// each element it is applied to of type `X` to an element of type `Y`.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  ///
  /// let array1 = [0, 1, 2, 3];
  /// let array2 = Array.map<Nat, Nat>(array1, func x = x * 3)
  /// assert array2 == [0, 2, 4, 6];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func map<T, R>(array : [T], f : T -> R) : [R] = Prim.Array_tabulate<R>(array.size(), func i = f(array[i]));

  /// Creates a new array by applying `predicate` to every element
  /// in `array`, retaining the elements for which `predicate` returns true.
  ///
  /// ```motoko include=import
  /// let array = [4, 2, 6, 1, 5];
  /// let evenElements = Array.filter<Nat>(array, func x = x % 2 == 0);
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func filter<T>(array : [T], f : T -> Bool) : [T] {
    var count = 0;
    let keep = Prim.Array_tabulate<Bool>(
      array.size(),
      func i {
        if (f(array[i])) {
          count += 1;
          true
        } else {
          false
        }
      }
    );
    var nextKeep = 0;
    Prim.Array_tabulate<T>(
      count,
      func _ {
        while (not keep[nextKeep]) {
          nextKeep += 1
        };
        nextKeep += 1;
        array[nextKeep - 1]
      }
    )
  };

  /// Creates a new array by applying `f` to each element in `array`,
  /// and keeping all non-null elements. The ordering is retained.
  ///
  /// ```motoko include=import
  /// import {toText} "mo:base/Nat";
  ///
  /// let array = [4, 2, 0, 1];
  /// let newArray =
  ///   Array.filterMap<Nat, Text>( // mapping from Nat to Text values
  ///     array,
  ///     func x = if (x == 0) { null } else { ?toText(100 / x) } // can't divide by 0, so return null
  ///   );
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func filterMap<T, R>(array : [T], f : T -> ?R) : [R] {
    var count = 0;
    let options = Prim.Array_tabulate<?R>(
      array.size(),
      func i {
        let result = f(array[i]);
        switch (result) {
          case (?element) {
            count += 1;
            result
          };
          case null {
            null
          }
        }
      }
    );

    var nextSome = 0;
    Prim.Array_tabulate<R>(
      count,
      func _ {
        while (Option.isNull(options[nextSome])) {
          nextSome += 1
        };
        nextSome += 1;
        switch (options[nextSome - 1]) {
          case (?element) element;
          case null {
            Prim.trap "Malformed array in filterMap"
          }
        }
      }
    )
  };

  /// Creates a new array by applying `f` to each element in `array`.
  /// If any invocation of `f` produces an `#err`, returns an `#err`. Otherwise
  /// returns an `#ok` containing the new array.
  ///
  /// ```motoko include=import
  /// let array = [4, 3, 2, 1, 0];
  /// // divide 100 by every element in the array
  /// Array.mapResult<Nat, Nat, Text>(array, func x {
  ///   if (x > 0) {
  ///     #ok(100 / x)
  ///   } else {
  ///     #err "Cannot divide by zero"
  ///   }
  /// })
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapResult<T, R, E>(array : [T], f : T -> Result.Result<R, E>) : Result.Result<[R], E> {
    let size = array.size();

    var error : ?Result.Result<[R], E> = null;
    let results = Prim.Array_tabulate<?R>(
      size,
      func i {
        switch (f(array[i])) {
          case (#ok element) {
            ?element
          };
          case (#err e) {
            switch (error) {
              case null {
                // only take the first error
                error := ?(#err e)
              };
              case _ {}
            };
            null
          }
        }
      }
    );

    switch error {
      case null {
        // unpack the option
        #ok(
          map<?R, R>(
            results,
            func element {
              switch element {
                case (?element) {
                  element
                };
                case null {
                  Prim.trap "Malformed array in mapResults"
                }
              }
            }
          )
        )
      };
      case (?error) {
        error
      }
    }
  };

  /// Creates a new array by applying `f` to each element in `array` and its index.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  ///
  /// let array = [10, 10, 10, 10];
  /// Array.mapEntries<Nat, Nat>(array, func (x, i) = i * x)
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapEntries<T, R>(array : [T], f : (T, Nat) -> R) : [R] = Prim.Array_tabulate<R>(array.size(), func i = f(array[i], i));

  /// Creates a new array by applying `k` to each element in `array`,
  /// and concatenating the resulting arrays in order.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [1, 2, 3, 4];
  /// Array.flatMap<Nat, Int>(array, func x = [x, -x])
  ///
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `k` runs in O(1) time and space.
  public func flatMap<T, R>(array : [T], k : T -> Iter.Iter<R>) : [R] {
    var flatSize = 0;
    let arrays = Prim.Array_tabulate<[R]>(
      array.size(),
      func i {
        let subArray = fromIter<R>(k(array[i]));
        flatSize += subArray.size();
        subArray
      }
    );

    // could replace with a call to flatten,
    // but it would require an extra pass (to compute `flatSize`)
    var outer = 0;
    var inner = 0;
    Prim.Array_tabulate<R>(
      flatSize,
      func _ {
        while (inner == arrays[outer].size()) {
          inner := 0;
          outer += 1
        };
        let element = arrays[outer][inner];
        inner += 1;
        element
      }
    )
  };

  /// Collapses the elements in `array` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// ```motoko include=import
  /// import {add} "mo:base/Nat";
  ///
  /// let array = [4, 2, 0, 1];
  /// let sum =
  ///   Array.foldLeft<Nat, Nat>(
  ///     array,
  ///     0, // start the sum at 0
  ///     func(sumSoFar, x) = sumSoFar + x // this entire function can be replaced with `add`!
  ///   );
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldLeft<T, A>(array : [T], base : A, combine : (A, T) -> A) : A {
    var acc = base;
    for (element in array.vals()) {
      acc := combine(acc, element)
    };
    acc
  };

  /// Collapses the elements in `array` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// ```motoko include=import
  /// import {toText} "mo:base/Nat";
  ///
  /// let array = [1, 9, 4, 8];
  /// let bookTitle = Array.foldRight<Nat, Text>(array, "", func(x, acc) = toText(x) # acc);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldRight<T, A>(array : [T], base : A, combine : (T, A) -> A) : A {
    var acc = base;
    let size = array.size();
    var i = size;
    while (i > 0) {
      i -= 1;
      acc := combine(array[i], acc)
    };
    acc
  };

  /// Flattens the iterator of arrays into a single array. Retains the original
  /// ordering of the elements.
  ///
  /// ```motoko include=import
  ///
  /// let arrays = [[0, 1, 2], [2, 3], [], [4]];
  /// Array.flatten<Nat>(Array.fromIter(arrays))) // => [0, 1, 2, 2, 3, 4]
  /// ```
  ///
  /// Runtime: O(number of elements in array)
  ///
  /// Space: O(number of elements in array)
  public func flatten<T>(arrays : Iter.Iter<[T]>) : [T] {
    todo() // New implementation due to using `Iter<[T]>` in place of `[[T]]`, pending `List` data structure
  };

  /// Create an array containing a single value.
  ///
  /// ```motoko include=import
  /// var array = Array.singleton(2);
  /// assert array == [2];
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func singleton<T>(element : T) : [T] = [element];

  /// Returns the size of an array. Equivalent to `array.size()`.
  public func size<T>(array : [T]) : Nat = array.size();

  /// Returns whether an array is empty, i.e. contains zero elements.
  public func isEmpty<T>(array : [T]) : Bool = array.size() == 0;

  /// Converts an iterator to an array.
  public func fromIter<T>(iter : Iter.Iter<T>) : [T] {
    todo() // Pending `List` data structure
  };

  /// Returns an iterator (`Iter`) over the indices of `array`.
  /// An iterator provides a single method `next()`, which returns
  /// indices in order, or `null` when out of index to iterate over.
  ///
  /// NOTE: You can also use `array.keys()` instead of this function. See example
  /// below.
  ///
  /// ```motoko include=import
  ///
  /// let array = [10, 11, 12];
  ///
  /// var sum = 0;
  /// for (element in array.keys()) {
  ///   sum += element;
  /// };
  /// sum
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func keys<T>(array : [T]) : Iter.Iter<Nat> = array.keys();

  /// Iterator provides a single method `next()`, which returns
  /// elements in order, or `null` when out of elements to iterate over.
  ///
  /// NOTE: You can also use `array.values()` instead of this function. See example
  /// below.
  ///
  /// ```motoko include=import
  ///
  /// let array = [10, 11, 12];
  ///
  /// var sum = 0;
  /// for (element in array.values()) {
  ///   sum += element;
  /// };
  /// sum
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func values<T>(array : [T]) : Iter.Iter<T> = array.vals();

  /// Returns true if all elements in `array` satisfy the predicate function.
  ///
  /// ```motoko include=import
  /// let array = [1, 2, 3, 4];
  /// Array.all<Nat>(array, func x = x > 0) // => true
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func all<T>(array : [T], predicate : T -> Bool) : Bool {
    for (element in array.vals()) {
      if (not predicate(element)) {
        return false;
      };
    };
    true
  };

  /// Returns true if any element in `array` satisfies the predicate function.
  ///
  /// ```motoko include=import
  /// let array = [1, 2, 3, 4];
  /// Array.any<Nat>(array, func x = x > 3) // => true
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func any<T>(array : [T], predicate : T -> Bool) : Bool {
    for (element in array.vals()) {
      if (predicate(element)) {
        return true;
      };
    };
    false
  };

  /// Returns a new sub-array from the given array provided the start index and length of elements in the sub-array.
  ///
  /// Limitations: Traps if the start index + length is greater than the size of the array
  ///
  /// ```motoko include=import
  ///
  /// let array = [1, 2, 3, 4, 5];
  /// let subArray = Array.subArray<Nat>(array, 2, 3);
  /// ```
  /// Runtime: O(length)
  ///
  /// Space: O(length)
  public func subArray<T>(array : [T], start : Nat, length : Nat) : [T] {
    if (start + length > array.size()) { Prim.trap("Array.subArray()") };
    Prim.Array_tabulate<T>(length, func i = array[start + i])
  };

  /// Returns the index of the first `element` in the `array`.
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.indexOf<Char>('c', array, Char.equal) == ?0;
  /// assert Array.indexOf<Char>('f', array, Char.equal) == ?2;
  /// assert Array.indexOf<Char>('g', array, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size())
  ///
  /// Space: O(1)
  public func indexOf<T>(element : T, array : [T], equal : (T, T) -> Bool) : ?Nat = nextIndexOf<T>(element, array, 0, equal);

  /// Returns the index of the next occurence of `element` in the `array` starting from the `from` index (inclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.nextIndexOf<Char>('c', array, 0, Char.equal) == ?0;
  /// assert Array.nextIndexOf<Char>('f', array, 0, Char.equal) == ?2;
  /// assert Array.nextIndexOf<Char>('f', array, 2, Char.equal) == ?2;
  /// assert Array.nextIndexOf<Char>('f', array, 3, Char.equal) == ?3;
  /// assert Array.nextIndexOf<Char>('f', array, 4, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size())
  ///
  /// Space: O(1)
  public func nextIndexOf<T>(element : T, array : [T], fromInclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    var index = fromInclusive;
    let size = array.size();
    while (index < size) {
      if (equal(array[index], element)) {
        return ?index
      } else {
        index += 1
      }
    };
    null
  };

  /// Returns the index of the last `element` in the `array`.
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.lastIndexOf<Char>('c', array, Char.equal) == ?0;
  /// assert Array.lastIndexOf<Char>('f', array, Char.equal) == ?3;
  /// assert Array.lastIndexOf<Char>('e', array, Char.equal) == ?5;
  /// assert Array.lastIndexOf<Char>('g', array, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size())
  ///
  /// Space: O(1)
  public func lastIndexOf<T>(element : T, array : [T], equal : (T, T) -> Bool) : ?Nat = prevIndexOf<T>(element, array, array.size(), equal);

  /// Returns the index of the previous occurence of `element` in the `array` starting from the `from` index (exclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = ['c', 'o', 'f', 'f', 'e', 'e'];
  /// assert Array.prevIndexOf<Char>('c', array, array.size(), Char.equal) == ?0;
  /// assert Array.prevIndexOf<Char>('e', array, array.size(), Char.equal) == ?5;
  /// assert Array.prevIndexOf<Char>('e', array, 5, Char.equal) == ?4;
  /// assert Array.prevIndexOf<Char>('e', array, 4, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size());
  /// Space: O(1);
  public func prevIndexOf<T>(element : T, array : [T], fromExclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
    var i = fromExclusive;
    while (i > 0) {
      i -= 1;
      if (equal(array[i], element)) {
        return ?i
      }
    };
    null
  };

  /// Returns an iterator over a slice of the given array.
  ///
  /// ```motoko include=import
  /// let array = [1, 2, 3, 4, 5];
  /// let s = Array.slice<Nat>(array, 3, array.size());
  /// assert s.next() == ?4;
  /// assert s.next() == ?5;
  /// assert s.next() == null;
  ///
  /// let s = Array.slice<Nat>(array, 0, 0);
  /// assert s.next() == null;
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func slice<T>(array : [T], fromInclusive : Int, toExclusive : Int) : Iter.Iter<T> {
    let size = array.size();
    // Convert negative indices to positive and handle bounds
    let startInt = if (fromInclusive < 0) {
      let s = size + fromInclusive;
      if (s < 0) { 0 } else { s }
    } else {
      if (fromInclusive > size) { size } else { fromInclusive }
    };
    let endInt = if (toExclusive < 0) {
      let e = size + toExclusive;
      if (e < 0) { 0 } else { e }
    } else {
      if (toExclusive > size) { size } else { toExclusive }
    };
    // Convert to Nat (values are non-negative due to bounds checking above)
    let start = Prim.abs(startInt);
    let end = Prim.abs(endInt);
    object {
      var pos = start;
      public func next() : ?T {
        if (pos >= end) {
          null
        } else {
          let elem = array[pos];
          pos += 1;
          ?elem
        }
      }
    }
  };

  /// Converts the array to its textual representation using `f` to convert each element to `Text`.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  /// let array = [1, 2, 3];
  /// Array.toText<Nat>(array, Nat.toText) // => "[1, 2, 3]"
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func toText<T>(array : [T], f : T -> Text) : Text {
    let size = array.size();
    if (size == 0) { return "[]" };
    var text = "[";
    var i = 0;
    while (i < size) {
      if (i != 0) {
        text #= ", ";
      };
      text #= f(array[i]);
      i += 1;
    };
    text #= "]";
    text
  };

  /// Compares two arrays using the provided comparison function for elements.
  /// Returns #less, #equal, or #greater if `array1` is less than, equal to,
  /// or greater than `array2` respectively.
  ///
  /// If arrays have different sizes but all elements up to the shorter length are equal,
  /// the shorter array is considered #less than the longer array.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  /// let array1 = [1, 2, 3];
  /// let array2 = [1, 2, 4];
  /// Array.compare<Nat>(array1, array2, Nat.compare) // => #less
  ///
  /// let array3 = [1, 2];
  /// let array4 = [1, 2, 3];
  /// Array.compare<Nat>(array3, array4, Nat.compare) // => #less (shorter array)
  /// ```
  ///
  /// Runtime: O(min(size1, size2))
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func compare<T>(array1 : [T], array2 : [T], compare : (T, T) -> Order.Order) : Order.Order {
    let size1 = array1.size();
    let size2 = array2.size();
    var i = 0;
    let minSize = if (size1 < size2) { size1 } else { size2 };
    while (i < minSize) {
      switch (compare(array1[i], array2[i])) {
        case (#less) { return #less };
        case (#greater) { return #greater };
        case (#equal) { i += 1 };
      };
    };
    if (size1 < size2) { #less }
    else if (size1 > size2) { #greater }
    else { #equal }
  };

}
