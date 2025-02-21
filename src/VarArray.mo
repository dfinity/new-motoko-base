/// Mutable array utilities.

import Types "Types";
import Order "Order";
import Result "Result";
import Option "Option";
import Prim "mo:⛔";

module {

  /// Creates an empty mutable array (equivalent to `[var]`).
  public func empty<T>() : [var T] = [var];

  /// Creates a mutable array containing `item` repeated `size` times.
  ///
  /// ```motoko include=import
  /// let array = VarArray.repeat<Nat>("Echo", 3);
  /// assert array == [var "Echo", "Echo", "Echo"];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func repeat<T>(item : T, size : Nat) : [var T] = Prim.Array_init<T>(size, item);

  /// Duplicates `array`, returning a shallow copy of the original.
  ///
  /// ```motoko include=import
  /// let array1 = [var 1, 2, 3];
  /// let array2 = VarArray.clone<Nat>(array1);
  /// array2[0] := 0;
  /// assert array1 == [var 1, 2, 3];
  /// assert array2 = [var 0, 2, 3];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  public func clone<T>(array : [var T]) : [var T] {
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

  /// Creates an immutable array of size `size`. Each element at index i
  /// is created by applying `generator` to i.
  ///
  /// ```motoko include=import
  /// let array : [var Nat] = VarArray.tabulate<Nat>(4, func i = i * 2);
  /// assert array == [var 0, 2, 4, 6];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `generator` runs in O(1) time and space.
  public func tabulate<T>(size : Nat, generator : Nat -> T) : [var T] {
    if (size == 0) {
      return [var]
    };
    let first = generator(0);
    let array = Prim.Array_init<T>(size, first);
    array[0] := first;
    var index = 1;
    while (index < size) {
      array[index] := generator(index);
      index += 1
    };
    array
  };

  /// Tests if two arrays contain equal values (i.e. they represent the same
  /// list of elements). Uses `equal` to compare elements in the arrays.
  ///
  /// ```motoko include=import
  /// // Use the equal function from the Nat module to compare Nats
  /// import {equal} "mo:base/Nat";
  ///
  /// let array1 = [var 0, 1, 2, 3];
  /// let array2 = [var 0, 1, 2, 3];
  /// VarArray.equal(array1, array2, equal)
  /// ```
  ///
  /// Runtime: O(size1 + size2)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func equal<T>(array1 : [var T], array2 : [var T], equal : (T, T) -> Bool) : Bool {
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
  /// let array = [var 1, 9, 4, 8];
  /// VarArray.find<Nat>(array, func x = x > 8)
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func find<T>(array : [var T], predicate : T -> Bool) : ?T {
    for (element in array.values()) {
      if (predicate element) {
        return ?element
      }
    };
    null
  };

  /// Create a new mutable array by concatenating the values of `array1` and `array2`.
  /// Note that `Array.append` copies its arguments and has linear complexity.
  ///
  /// ```motoko include=import
  /// let array1 = [var 1, 2, 3];
  /// let array2 = [var 4, 5, 6];
  /// VarArray.concat<Nat>(array1, array2)
  /// ```
  /// Runtime: O(size1 + size2)
  ///
  /// Space: O(size1 + size2)
  public func concat<T>(array1 : [var T], array2 : [var T]) : [var T] {
    let size1 = array1.size();
    let size2 = array2.size();
    tabulate<T>(
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

  /// Sorts the elements in a mutable array according to `compare`.
  /// Sort is deterministic and stable.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [var 4, 2, 6];
  /// VarArray.sort(array, Nat.compare)
  /// ```
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sort<T>(array : [var T], compare : (T, T) -> Order.Order) : [var T] {
    let newArray = clone(array);
    sortInPlace(newArray, compare);
    newArray
  };

  /// Sorts the elements in a mutable array in place according to `compare`.
  /// Sort is deterministic and stable.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [var 4, 2, 6];
  /// VarArray.sortInPlace(array, Nat.compare);
  /// assert array == [var 2, 4, 6];
  /// ```
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sortInPlace<T>(array : [var T], compare : (T, T) -> Order.Order) : () {
    // Stable merge sort in a bottom-up iterative style. Same algorithm as the sort in Buffer.
    let size = array.size();
    if (size == 0) {
      return
    };
    let scratchSpace = Prim.Array_init<T>(size, array[0]);

    let sizeDec = size - 1 : Nat;
    var currSize = 1; // current size of the subarrays being merged
    // when the current size == size, the array has been merged into a single sorted array
    while (currSize < size) {
      var leftStart = 0; // selects the current left subarray being merged
      while (leftStart < sizeDec) {
        let mid : Nat = if (leftStart + currSize - 1 : Nat < sizeDec) {
          leftStart + currSize - 1
        } else { sizeDec };
        let rightEnd : Nat = if (leftStart + (2 * currSize) - 1 : Nat < sizeDec) {
          leftStart + (2 * currSize) - 1
        } else { sizeDec };

        // Merge subarrays elements[leftStart...mid] and elements[mid+1...rightEnd]
        var left = leftStart;
        var right = mid + 1;
        var nextSorted = leftStart;
        while (left < mid + 1 and right < rightEnd + 1) {
          let leftElement = array[left];
          let rightElement = array[right];
          switch (compare(leftElement, rightElement)) {
            case (#less or #equal) {
              scratchSpace[nextSorted] := leftElement;
              left += 1
            };
            case (#greater) {
              scratchSpace[nextSorted] := rightElement;
              right += 1
            }
          };
          nextSorted += 1
        };
        while (left < mid + 1) {
          scratchSpace[nextSorted] := array[left];
          nextSorted += 1;
          left += 1
        };
        while (right < rightEnd + 1) {
          scratchSpace[nextSorted] := array[right];
          nextSorted += 1;
          right += 1
        };

        // Copy over merged elements
        var i = leftStart;
        while (i < rightEnd + 1) {
          array[i] := scratchSpace[i];
          i += 1
        };

        leftStart += 2 * currSize
      };
      currSize *= 2
    }
  };

  /// Creates a new mutable array by reversing the order of elements in `array`.
  ///
  /// ```motoko include=import
  ///
  /// let array = [var 10, 11, 12];
  ///
  /// VarArray.reverse(array)
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func reverse<T>(array : [var T]) : [var T] {
    let size = array.size();
    tabulate<T>(size, func i = array[size - i - 1])
  };

  /// Reverses the order of elements in a mutable array in place.
  ///
  /// ```motoko include=import
  /// let array = [var 10, 11, 12];
  /// VarArray.reverseInPlace(array);
  /// assert array == [var 12, 11, 10];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  public func reverseInPlace<T>(array : [var T]) : () {
    let size = array.size();
    if (size == 0) {
      return
    };
    var i = 0;
    var j = (size - 1) : Nat;
    while (i < j) {
      let temp = array[i];
      array[i] := array[j];
      array[j] := temp;
      i += 1;
      j -= 1
    }
  };

  /// Calls `f` with each element in `array`.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  /// import Debug "mo:base/Debug";
  ///
  /// let array = [var 0, 1, 2, 3];
  /// VarArray.forEach<Nat>(array, func(x) {
  ///   Debug.print(debug_show x)
  /// })
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEach<T>(array : [var T], f : T -> ()) {
    for (item in array.values()) {
      f(item)
    }
  };

  /// Creates a new mutable array by applying `f` to each element in `array`. `f` "maps"
  /// each element it is applied to of type `X` to an element of type `Y`.
  /// Retains original ordering of elements.
  ///
  /// ```motoko include=import
  ///
  /// let array = [var 0, 1, 2, 3];
  /// VarArray.map<Nat, Nat>(array, func x = x * 3)
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func map<T, R>(array : [var T], f : T -> R) : [var R] {
    tabulate<R>(
      array.size(),
      func(index) {
        f(array[index])
      }
    )
  };

  /// Applies `f` to each element of `array` in place,
  /// retaining the original ordering of elements.
  ///
  /// ```motoko include=import
  ///
  /// let array = [var 0, 1, 2, 3];
  /// VarArray.mapInPlace<Nat>(array, func x = x * 3)
  /// assert array == [0, 2, 4, 6];
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func mapInPlace<T>(array : [var T], f : T -> T) {
    var index = 0;
    let size = array.size();
    while (index < size) {
      array[index] := f(array[index]);
      index += 1
    }
  };

  /// Creates a new mutable array by applying `predicate` to every element
  /// in `array`, retaining the elements for which `predicate` returns true.
  ///
  /// ```motoko include=import
  /// let array = [var 4, 2, 6, 1, 5];
  /// let evenElements = VarArray.filter<Nat>(array, func x = x % 2 == 0);
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func filter<T>(array : [var T], f : T -> Bool) : [var T] {
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
    tabulate<T>(
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
  /// let array = [var 4, 2, 0, 1];
  /// let newArray =
  ///   VarArray.filterMap<Nat, Text>( // mapping from Nat to Text values
  ///     array,
  ///     func x = if (x == 0) { null } else { ?toText(100 / x) } // can't divide by 0, so return null
  ///   );
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func filterMap<T, R>(array : [var T], f : T -> ?R) : [var R] {
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
    tabulate<R>(
      count,
      func _ {
        while (Option.isNull(options[nextSome])) {
          nextSome += 1
        };
        nextSome += 1;
        switch (options[nextSome - 1]) {
          case (?element) element;
          case null {
            Prim.trap "VarArray.filterMap(): malformed array"
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
  /// let array = [var 4, 3, 2, 1, 0];
  /// // divide 100 by every element in the array
  /// VarArray.mapResult<Nat, Nat, Text>(array, func x {
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
  public func mapResult<T, R, E>(array : [var T], f : T -> Result.Result<R, E>) : Result.Result<[var R], E> {
    let size = array.size();

    var error : ?Result.Result<[var R], E> = null;
    let results = tabulate<?R>(
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
                  Prim.trap "VarArray.mapResults(): malformed array"
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
  public func mapEntries<T, R>(array : [var T], f : (T, Nat) -> R) : [var R] {
    tabulate<R>(array.size(), func i = f(array[i], i))
  };

  /// Creates a new array by applying `k` to each element in `array`,
  /// and concatenating the resulting arrays in order.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [var 1, 2, 3, 4];
  /// VarArray.flatMap<Nat, Int>(array, func x = [x, -x])
  ///
  /// ```
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `k` runs in O(1) time and space.
  public func flatMap<T, R>(array : [var T], k : T -> Types.Iter<R>) : [var R] {
    var flatSize = 0;
    let arrays = Prim.Array_tabulate<[var R]>(
      array.size(),
      func i {
        let subArray = fromIter<R>(k(array[i])); // TODO: optimize
        flatSize += subArray.size();
        subArray
      }
    );

    // could replace with a call to flatten,
    // but it would require an extra pass (to compute `flatSize`)
    var outer = 0;
    var inner = 0;
    tabulate<R>(
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
  /// let array = [var 4, 2, 0, 1];
  /// let sum =
  ///   VarArray.foldLeft<Nat, Nat>(
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
  public func foldLeft<T, A>(array : [var T], base : A, combine : (A, T) -> A) : A {
    var acc = base;
    for (element in array.values()) {
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
  /// let bookTitle = VarArray.foldRight<Nat, Text>(array, "", func(x, acc) = toText(x) # acc);
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `combine` runs in O(1) time and space.
  public func foldRight<T, A>(array : [var T], base : A, combine : (T, A) -> A) : A {
    var acc = base;
    let size = array.size();
    var i = size;
    while (i > 0) {
      i -= 1;
      acc := combine(array[i], acc)
    };
    acc
  };

  /// Combines an iterator of mutable arrays into a single mutable array. Retains the original
  /// ordering of the elements.
  ///
  /// Consider using `VarArray.flatten()` where possible for better performance.
  ///
  /// ```motoko include=import
  ///
  /// let arrays = [[var 0, 1, 2], [var 2, 3], [var], [var 4]];
  /// VarArray.join<Nat>(VarArray.fromIter(arrays)) // => [var 0, 1, 2, 2, 3, 4]
  /// ```
  ///
  /// Runtime: O(number of elements in array)
  ///
  /// Space: O(number of elements in array)
  public func join<T>(arrays : Types.Iter<[var T]>) : [var T] {
    flatten<T>(fromIter(arrays))
  };

  /// Combines a mutable array of mutable arrays into a single mutable array. Retains the original
  /// ordering of the elements.
  ///
  /// This has better performance compared to `VarArray.flatten()`.
  ///
  /// ```motoko include=import
  ///
  /// let arrays = [var [var 0, 1, 2], [var 2, 3], [var], [var 4]];
  /// VarArray.flatten<Nat>(arrays) // => [var 0, 1, 2, 2, 3, 4]
  /// ```
  ///
  /// Runtime: O(number of elements in array)
  ///
  /// Space: O(number of elements in array)
  public func flatten<T>(arrays : [var [var T]]) : [var T] {
    var flatSize = 0;
    for (subArray in arrays.values()) {
      flatSize += subArray.size()
    };

    var outer = 0;
    var inner = 0;
    tabulate<T>(
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

  /// Create an array containing a single value.
  ///
  /// ```motoko include=import
  /// let array = VarArray.singleton(2);
  /// assert array == [var 2];
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func singleton<T>(element : T) : [var T] = [var element];

  /// Returns the size of a mutable array. Equivalent to `array.size()`.
  public func size<T>(array : [var T]) : Nat = array.size();

  /// Returns whether a mutable array is empty, i.e. contains zero elements.
  public func isEmpty<T>(array : [var T]) : Bool = array.size() == 0;

  /// Converts an iterator to a mutable array.
  public func fromIter<T>(iter : Types.Iter<T>) : [var T] {
    var list : Types.Pure.List<T> = null;
    var size = 0;
    label l loop {
      switch (iter.next()) {
        case (?element) {
          list := ?(element, list);
          size += 1
        };
        case null { break l }
      }
    };
    if (size == 0) { return [var] };
    let array = Prim.Array_init<T>(
      size,
      switch list {
        case (?(h, _)) h;
        case null {
          Prim.trap("VarArray.fromIter(): unreachable")
        }
      }
    );
    var i = size;
    while (i > 0) {
      i -= 1;
      switch list {
        case (?(h, t)) {
          array[i] := h;
          list := t
        };
        case null {
          Prim.trap("VarArray.fromIter(): unreachable")
        }
      }
    };
    array
  };

  /// Returns an iterator (`Iter`) over the indices of `array`.
  /// An iterator provides a single method `next()`, which returns
  /// indices in order, or `null` when out of index to iterate over.
  ///
  /// NOTE: You can also use `array.keys()` instead of this function. See example
  /// below.
  ///
  /// ```motoko include=import
  /// let array = [var 10, 11, 12];
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
  public func keys<T>(array : [var T]) : Types.Iter<Nat> = array.keys();

  /// Iterator provides a single method `next()`, which returns
  /// elements in order, or `null` when out of elements to iterate over.
  ///
  /// Note: You can also use `array.values()` instead of this function. See example
  /// below.
  ///
  /// ```motoko include=import
  /// let array = [var 10, 11, 12];
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
  public func values<T>(array : [var T]) : Types.Iter<T> = array.values();

  /// Iterator provides a single method `next()`, which returns
  /// pairs of (index, element) in order, or `null` when out of elements to iterate over.
  ///
  /// ```motoko include=import
  /// let array = [var 10, 11, 12];
  ///
  /// var sum = 0;
  /// for ((index, element) in Array.enumerate(array)) {
  ///   sum += element;
  /// };
  /// sum // => 33
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func enumerate<T>(array : [var T]) : Types.Iter<(Nat, T)> = object {
    let size = array.size();
    var index = 0;
    public func next() : ?(Nat, T) {
      if (index > size) {
        return null
      };
      let i = index;
      index += 1;
      ?(i, array[i])
    }
  };

  /// Returns true if all elements in `array` satisfy the predicate function.
  ///
  /// ```motoko include=import
  /// let array = [var 1, 2, 3, 4];
  /// VarArray.all<Nat>(array, func x = x > 0) // => true
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func all<T>(array : [var T], predicate : T -> Bool) : Bool {
    for (element in array.values()) {
      if (not predicate(element)) {
        return false
      }
    };
    true
  };

  /// Returns true if any element in `array` satisfies the predicate function.
  ///
  /// ```motoko include=import
  /// let array = [var 1, 2, 3, 4];
  /// VarArray.any<Nat>(array, func x = x > 3) // => true
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func any<T>(array : [var T], predicate : T -> Bool) : Bool {
    for (element in array.values()) {
      if (predicate(element)) {
        return true
      }
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
  /// let subArray = VarArray.subArray<Nat>(array, 2, 3);
  /// ```
  /// Runtime: O(length)
  ///
  /// Space: O(length)
  public func subArray<T>(array : [var T], start : Nat, length : Nat) : [var T] {
    if (start + length > array.size()) { Prim.trap("Array.subArray()") };
    tabulate<T>(length, func i = array[start + i])
  };

  /// Returns the index of the first `element` in the `array`.
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = [var 'c', 'o', 'f', 'f', 'e', 'e'];
  /// assert VarArray.indexOf<Char>('c', array, Char.equal) == ?0;
  /// assert VarArray.indexOf<Char>('f', array, Char.equal) == ?2;
  /// assert VarArray.indexOf<Char>('g', array, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size())
  ///
  /// Space: O(1)
  public func indexOf<T>(element : T, array : [var T], equal : (T, T) -> Bool) : ?Nat = nextIndexOf<T>(element, array, 0, equal);

  /// Returns the index of the next occurence of `element` in the `array` starting from the `from` index (inclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = [var 'c', 'o', 'f', 'f', 'e', 'e'];
  /// assert VarArray.nextIndexOf<Char>('c', array, 0, Char.equal) == ?0;
  /// assert VarArray.nextIndexOf<Char>('f', array, 0, Char.equal) == ?2;
  /// assert VarArray.nextIndexOf<Char>('f', array, 2, Char.equal) == ?2;
  /// assert VarArray.nextIndexOf<Char>('f', array, 3, Char.equal) == ?3;
  /// assert VarArray.nextIndexOf<Char>('f', array, 4, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size())
  ///
  /// Space: O(1)
  public func nextIndexOf<T>(element : T, array : [var T], fromInclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
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
  /// let array = [var 'c', 'o', 'f', 'f', 'e', 'e'];
  /// assert VarArray.lastIndexOf<Char>('c', array, Char.equal) == ?0;
  /// assert VarArray.lastIndexOf<Char>('f', array, Char.equal) == ?3;
  /// assert VarArray.lastIndexOf<Char>('e', array, Char.equal) == ?5;
  /// assert VarArray.lastIndexOf<Char>('g', array, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size())
  ///
  /// Space: O(1)
  public func lastIndexOf<T>(element : T, array : [var T], equal : (T, T) -> Bool) : ?Nat = prevIndexOf<T>(element, array, array.size(), equal);

  /// Returns the index of the previous occurence of `element` in the `array` starting from the `from` index (exclusive).
  ///
  /// ```motoko include=import
  /// import Char "mo:base/Char";
  /// let array = [var 'c', 'o', 'f', 'f', 'e', 'e'];
  /// assert VarArray.prevIndexOf<Char>('c', array, array.size(), Char.equal) == ?0;
  /// assert VarArray.prevIndexOf<Char>('e', array, array.size(), Char.equal) == ?5;
  /// assert VarArray.prevIndexOf<Char>('e', array, 5, Char.equal) == ?4;
  /// assert VarArray.prevIndexOf<Char>('e', array, 4, Char.equal) == null;
  /// ```
  ///
  /// Runtime: O(array.size());
  /// Space: O(1);
  public func prevIndexOf<T>(element : T, array : [var T], fromExclusive : Nat, equal : (T, T) -> Bool) : ?Nat {
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
  /// let array = [var 1, 2, 3, 4, 5];
  /// let s = VarArray.range<Nat>(array, 3, array.size());
  /// assert s.next() == ?4;
  /// assert s.next() == ?5;
  /// assert s.next() == null;
  ///
  /// let s = Array.range<Nat>(array, 0, 0);
  /// assert s.next() == null;
  /// ```
  ///
  /// Runtime: O(1)
  ///
  /// Space: O(1)
  public func range<T>(array : [var T], fromInclusive : Int, toExclusive : Int) : Types.Iter<T> {
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

  /// Converts the mutable array to its textual representation using `f` to convert each element to `Text`.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  /// let array = [var 1, 2, 3];
  /// VarArray.toText<Nat>(array, Nat.toText) // => "[var 1, 2, 3]"
  /// ```
  ///
  /// Runtime: O(size)
  ///
  /// Space: O(size)
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func toText<T>(array : [var T], f : T -> Text) : Text {
    let size = array.size();
    if (size == 0) { return "[var]" };
    var text = "[var ";
    var i = 0;
    while (i < size) {
      if (i != 0) {
        text #= ", "
      };
      text #= f(array[i]);
      i += 1
    };
    text #= "]";
    text
  };

  /// Compares two mutable arrays using the provided comparison function for elements.
  /// Returns #less, #equal, or #greater if `array1` is less than, equal to,
  /// or greater than `array2` respectively.
  ///
  /// If arrays have different sizes but all elements up to the shorter length are equal,
  /// the shorter array is considered #less than the longer array.
  ///
  /// ```motoko include=import
  /// import Nat "mo:base/Nat";
  /// let array1 = [var 1, 2, 3];
  /// let array2 = [var 1, 2, 4];
  /// VarArray.compare<Nat>(array1, array2, Nat.compare) // => #less
  ///
  /// let array3 = [var 1, 2];
  /// let array4 = [var 1, 2, 3];
  /// VarArray.compare<Nat>(array3, array4, Nat.compare) // => #less (shorter array)
  /// ```
  ///
  /// Runtime: O(min(size1, size2))
  ///
  /// Space: O(1)
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func compare<T>(array1 : [var T], array2 : [var T], compare : (T, T) -> Order.Order) : Order.Order {
    let size1 = array1.size();
    let size2 = array2.size();
    var i = 0;
    let minSize = if (size1 < size2) { size1 } else { size2 };
    while (i < minSize) {
      switch (compare(array1[i], array2[i])) {
        case (#less) { return #less };
        case (#greater) { return #greater };
        case (#equal) { i += 1 }
      }
    };
    if (size1 < size2) { #less } else if (size1 > size2) { #greater } else {
      #equal
    }
  };

}
