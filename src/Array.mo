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
import Prim "mo:⛔";
import { todo } "Debug";

module {

  /// Create an empty array (equivalent to `[]`).
  public func empty<T>() : [T] = [];

  /// Create an array with `size` copies of the initial value.
  ///
  /// ```motoko include=import
  /// let array = Array.init<Nat>(4, 2);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func init<T>(size : Nat, initValue : T) : [T] = todo();

  /// Create an immutable array of size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// let array : [Nat] = Array.generate<Nat>(4, func i = i * 2);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `generator` runs in O(1) time and space.
  public func generate<T>(size : Nat, generator : Nat -> T) : [T] = Prim.Array_tabulate<T>(size, generator);

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
    todo()
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
    todo()
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
    todo()
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
    todo()
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
    todo()
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
    todo()
  };

  /// Calls `f` with each element in `array`.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  /// import Debug "mo:base/Debug";
  ///
  /// let array = [0, 1, 2, 3];
  /// Array.forEach<Nat>(array, func (x) {
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
    todo()
  };

  /// Creates a new array by applying `f` to each element in `array`. `f` "maps"
  /// each element it is applied to of type `X` to an element of type `Y`.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  ///
  /// let array = [0, 1, 2, 3];
  /// Array.map<Nat, Nat>(array, func x = x * 3)
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func map<T, Y>(array : [T], f : T -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i]));

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
    todo()
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
  public func filterMap<T, Y>(array : [T], f : T -> ?Y) : [Y] {
    todo()
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
  public func mapResult<T, Y, E>(array : [T], f : T -> Result.Result<Y, E>) : Result.Result<[Y], E> {
    todo()
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
  public func mapEntries<T, Y>(array : [T], f : (T, Nat) -> Y) : [Y] = Prim.Array_tabulate<Y>(array.size(), func i = f(array[i], i));

  /// Creates a new array by applying `k` to each element in `array`,
  /// and concatenating the resulting arrays in order. This operation
  /// is similar to what in other functional languages is known as monadic bind.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [1, 2, 3, 4];
  /// Array.chain<Nat, Int>(array, func x = [x, -x])
  ///
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `k` runs in O(1) time and space.
  public func chain<T, Y>(array : [T], k : T -> [Y]) : [Y] {
    todo()
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
    todo()
  };

  // FIXME the type arguments are reverse order from Buffer
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
    todo()
  };

  /// Flattens the array of arrays into a single array. Retains the original
  /// ordering of the elements.
  ///
  /// ```motoko include=import
  ///
  /// let arrays = [[0, 1, 2], [2, 3], [], [4]];
  /// Array.flatten<Nat>(arrays)
  /// ```
  ///
  /// Runtime: O(number of elements in array)
  ///
  /// Space: O(number of elements in array)
  public func flatten<T>(arrays : Iter.Iter<[T]>) : [T] {
    todo()
  };

  /// Create an array containing a single value.
  ///
  /// ```motoko include=import
  /// Array.singleton(2)
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func singleton<T>(element : T) : [T] = [element];

  public func size<T>(array : [T]) : Nat = array.size();

  public func isEmpty<T>(array : [T]) : Bool = array.size() == 0;

  public func fromIter<T>(iter : Iter.Iter<T>) : [T] {
    todo()
  };

  /// Returns an Iterator (`Iter`) over the indices of `array`.
  /// Iterator provides a single method `next()`, which returns
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

  public func all<T>(array : [T], predicate : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(array : [T], predicate : T -> Bool) : Bool {
    todo()
  };

  /// Returns a new subarray from the given array provided the start index and length of elements in the subarray
  ///
  /// Limitations: Traps if the start index + length is greater than the size of the array
  ///
  /// ```motoko include=import
  ///
  /// let array = [1,2,3,4,5];
  /// let subArray = Array.subArray<Nat>(array, 2, 3);
  /// ```
  /// Runtime: O(length)
  ///
  /// Space: O(length)
  public func subArray<T>(array : [T], start : Nat, length : Nat) : [T] {
    todo()
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
    todo()
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
    todo()
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
    todo()
  };

  /// Returns a new subarray of given length from the beginning or end of the given array
  ///
  /// Returns the entire array if the length is greater than the size of the array
  ///
  /// ```motoko include=import
  /// let array = [1, 2, 3, 4, 5];
  /// assert Array.take(array, 2) == [1, 2];
  /// assert Array.take(array, -2) == [4, 5];
  /// assert Array.take(array, 10) == [1, 2, 3, 4, 5];
  /// assert Array.take(array, -99) == [1, 2, 3, 4, 5];
  /// ```
  /// Runtime: O(length)
  ///
  /// Space: O(length)
  public func toText<T>(array : [T], f : T -> Text) : Text {
    todo()
  };

  public func compare<T>(array1 : [T], array2 : [T], compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

}
