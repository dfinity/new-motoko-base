/// Resizable array with `O(sqrt(n))` memory overhead.
/// Static type `List` that can be declared `stable`.
/// For the `List` class see the file Class.mo.
///
/// This implementation is adapted with permission from the `vector` Mops package created by Research AG.
///
/// Copyright: 2023 MR Research AG
/// Main author: Andrii Stepanov
/// Contributors: Timo Hanke (timohanke), Andy Gura (andygura), react0r-com

import PureList "pure/List";
import Prim "mo:⛔";
import Nat32 "Nat32";
import Array "Array";
import Iter "Iter";
import Nat "Nat";
import Order "Order";
import Option "Option";
import VarArray "VarArray";
import Types "Types";

module {
  /// `List<T>` provides a mutable list of elements of type `T`.
  /// Based on the paper "Resizable Arrays in Optimal Time and Space" by Brodnik, Carlsson, Demaine, Munro and Sedgewick (1999).
  /// Since this is internally a two-dimensional array the access times for put and get operations
  /// will naturally be 2x slower than Buffer and Array. However, Array is not resizable and Buffer
  /// has `O(size)` memory waste.
  public type List<T> = Types.List<T>;

  let INTERNAL_ERROR = "List: internal error";

  /// Creates a new empty List for elements of type T.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.new<Nat>(); // Creates a new List
  /// ```
  public func empty<T>() : List<T> = {
    var blocks = [var [var]];
    var blockIndex = 1;
    var elementIndex = 0
  };

  /// Returns a new list with capacity and size 1, containing `element`.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list = List.make<Nat>(1);
  /// List.toText<Nat>(list, Nat.toText); // => "[1]"
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func singleton<T>(element : T) : List<T> = repeat(element, 1);

  /// Create a List with `size` copies of the initial value.
  ///
  /// ```
  /// let list = List.repeat<Nat>(2, 4); // [2, 2, 2, 2]
  /// ```
  ///
  /// Runtime: `O(size)`
  public func repeat<T>(initValue : T, size : Nat) : List<T> {
    let (blockIndex, elementIndex) = locate(size);

    let blocks = new_index_block_length(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));
    let data_blocks = VarArray.repeat<[var ?T]>([var], blocks);
    var i = 1;
    while (i < blockIndex) {
      data_blocks[i] := VarArray.repeat<?T>(?initValue, data_block_size(i));
      i += 1
    };
    if (elementIndex != 0 and blockIndex < blocks) {
      let block = VarArray.repeat<?T>(null, data_block_size(i));
      var j = 0;
      while (j < elementIndex) {
        block[j] := ?initValue;
        j += 1
      };
      data_blocks[i] := block
    };

    {
      var blocks = data_blocks;
      var blockIndex = blockIndex;
      var elementIndex = elementIndex
    }
  };

  /// Converts a mutable `List` to a purely functional `PureList`.
  ///
  /// Example:
  /// ```motoko
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  /// let pureList = List.toPure<Nat>(list); // converts to immutable PureList
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func toPure<T>(list : List<T>) : PureList.List<T> {
    PureList.fromIter(values(list)) // TODO: optimize
  };

  /// Converts a purely functional `List` to a mutable `List`.
  ///
  /// Example:
  /// ```motoko
  /// import PureList "mo:base/pure/List";
  ///
  /// let pureList = PureList.fromArray<Nat>([1, 2, 3]);
  /// let list = List.fromPure<Nat>(pureList); // converts to mutable List
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  public func fromPure<T>(pure : PureList.List<T>) : List<T> {
    let list = empty<T>();
    PureList.forEach<T>(pure, func(x) = add(list, x));
    list
  };

  /// Add to list `count` copies of the initial value.
  ///
  /// ```
  /// let list = List.repeat<Nat>(2, 4); // [2, 2, 2, 2]
  /// List.addRepeat(list, 2, 1); // [2, 2, 2, 2, 1, 1]
  /// ```
  ///
  /// Runtime: `O(count)`
  public func addRepeat<T>(list : List<T>, initValue : T, count : Nat) {
    let (blockIndex, elementIndex) = locate(size(list) + count);
    let blocks = new_index_block_length(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));

    let old_blocks = list.blocks.size();
    if (old_blocks < blocks) {
      let old_data_blocks = list.blocks;
      list.blocks := VarArray.repeat<[var ?T]>([var], blocks);
      var i = 0;
      while (i < old_blocks) {
        list.blocks[i] := old_data_blocks[i];
        i += 1
      }
    };

    var cnt = count;
    while (cnt > 0) {
      let db_size = data_block_size(list.blockIndex);
      if (list.elementIndex == 0 and db_size <= cnt) {
        list.blocks[list.blockIndex] := VarArray.repeat<?T>(?initValue, db_size);
        cnt -= db_size;
        list.blockIndex += 1
      } else {
        if (list.blocks[list.blockIndex].size() == 0) {
          list.blocks[list.blockIndex] := VarArray.repeat<?T>(null, db_size)
        };
        let from = list.elementIndex;
        let to = Nat.min(list.elementIndex + cnt, db_size);

        let block = list.blocks[list.blockIndex];
        var i = from;
        while (i < to) {
          block[i] := ?initValue;
          i += 1
        };

        list.elementIndex := to;
        if (list.elementIndex == db_size) {
          list.elementIndex := 0;
          list.blockIndex += 1
        };
        cnt -= to - from
      }
    }
  };

  /// Resets the list to size 0, de-referencing all elements.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  /// List.clear(list); // list is now empty
  /// List.toArray(list) // => []
  /// ```
  ///
  /// Runtime: `O(1)`
  public func clear<T>(list : List<T>) {
    list.blocks := [var [var]];
    list.blockIndex := 1;
    list.elementIndex := 0
  };

  /// Returns a copy of a List, with the same size.
  ///
  /// Example:
  /// ```motoko
  ///
  /// list.add(1);
  ///
  /// let clone = List.clone(list);
  /// List.toArray(clone); // => [1]
  /// ```
  ///
  /// Runtime: `O(size)`
  public func clone<T>(list : List<T>) : List<T> = {
    var blocks = VarArray.tabulate<[var ?T]>(
      list.blocks.size(),
      func(i) = VarArray.tabulate<?T>(
        list.blocks[i].size(),
        func(j) = list.blocks[i][j]
      )
    );
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex
  };

  /// Creates and returns a new list, populated with the results of calling a provided function on every element in the provided list
  ///
  /// Example:
  /// ```motoko
  ///
  /// list.add(1);
  ///
  /// let t = List.map<Nat, Text>(list, Nat.toText);
  /// List.toArray(t); // => ["1"]
  /// ```
  ///
  /// Runtime: `O(size)`
  public func map<T, R>(list : List<T>, f : T -> R) : List<R> = {
    var blocks = VarArray.tabulate<[var ?R]>(
      list.blocks.size(),
      func(i) {
        let db = list.blocks[i];
        VarArray.tabulate<?R>(
          db.size(),
          func(j) = switch (db[j]) {
            case (?item) ?f(item);
            case (null) null
          }
        )
      }
    );
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex
  };

  /// Returns a new list containing only the elements from `list` for which the predicate returns true.
  ///
  /// Example:
  /// ```motoko
  /// let list = List.fromArray<Nat>([1, 2, 3, 4]);
  /// let evenNumbers = List.filter<Nat>(list, func x = x % 2 == 0);
  /// List.toArray(evenNumbers); // => [2, 4]
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func filter<T>(list : List<T>, predicate : T -> Bool) : List<T> {
    let filtered = empty<T>();
    forEach<T>(
      list,
      func(x) {
        if (predicate(x)) add(filtered, x)
      }
    );
    filtered
  };

  /// Returns a new list containing all elements from `list` for which the function returns ?element.
  /// Discards all elements for which the function returns null.
  ///
  /// Example:
  /// ```motoko
  /// let list = List.fromArray<Nat>([1, 2, 3, 4]);
  /// let doubled = List.filterMap<Nat, Nat>(list, func x = if (x % 2 == 0) ?x * 2 else null);
  /// List.toArray(doubled); // => [4, 8]
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func filterMap<T, R>(list : List<T>, f : T -> ?R) : List<R> {
    let filtered = empty<R>();
    forEach<T>(
      list,
      func(x) {
        switch (f(x)) {
          case (?y) add(filtered, y);
          case null {}
        }
      }
    );
    filtered
  };

  /// Returns the current number of elements in the list.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.size(list) // => 0
  /// ```
  ///
  /// Runtime: `O(1)` (with some internal calculations)
  public func size<T>(list : List<T>) : Nat {
    let d = Nat32.fromNat(list.blockIndex);
    let i = Nat32.fromNat(list.elementIndex);

    // We call all data blocks of the same capacity an "epoch". We number the epochs 0,1,2,...
    // A data block is in epoch e iff the data block has capacity 2 ** e.
    // Each epoch starting with epoch 1 spans exactly two super blocks.
    // Super block s falls in epoch ceil(s/2).

    // epoch of last data block
    // e = 32 - lz
    let lz = Nat32.bitcountLeadingZero(d / 3);

    // capacity of all prior epochs combined
    // capacity_before_e = 2 * 4 ** (e - 1) - 1

    // data blocks in all prior epochs combined
    // blocks_before_e = 3 * 2 ** (e - 1) - 2

    // then size = d * 2 ** e + i - c
    // where c = blocks_before_e * 2 ** e - capacity_before_e

    // there can be overflows, but the result is without overflows, so use addWrap and subWrap
    // we don't erase bits by >>, so to use <>> is ok
    Nat32.toNat((d -% (1 <>> lz)) <>> lz +% i)
  };

  func data_block_size(blockIndex : Nat) : Nat {
    // formula for the size of given blockIndex
    // don't call it for blockIndex == 0
    Nat32.toNat(1 <>> Nat32.bitcountLeadingZero(Nat32.fromNat(blockIndex) / 3))
  };

  func new_index_block_length(blockIndex : Nat32) : Nat {
    if (blockIndex <= 1) 2 else {
      let s = 30 - Nat32.bitcountLeadingZero(blockIndex);
      Nat32.toNat(((blockIndex >> s) +% 1) << s)
    }
  };

  func grow_index_block_if_needed<T>(list : List<T>) {
    if (list.blocks.size() == list.blockIndex) {
      let new_blocks = VarArray.repeat<[var ?T]>([var], new_index_block_length(Nat32.bitcountLeadingZero(Nat32.fromNat(list.blockIndex))));
      var i = 0;
      while (i < list.blockIndex) {
        new_blocks[i] := list.blocks[i];
        i += 1
      };
      list.blocks := new_blocks
    }
  };

  func shrink_index_block_if_needed<T>(list : List<T>) {
    let blockIndex = Nat32.fromNat(list.blockIndex);
    // kind of index of the first block in the super block
    if ((blockIndex << Nat32.bitcountLeadingZero(blockIndex)) << 2 == 0) {
      let new_length = new_index_block_length(blockIndex);
      if (new_length < list.blocks.size()) {
        let new_blocks = VarArray.repeat<[var ?T]>([var], new_length);
        var i = 0;
        while (i < new_length) {
          new_blocks[i] := list.blocks[i];
          i += 1
        };
        list.blocks := new_blocks
      }
    }
  };

  /// Adds a single element to the end of a List,
  /// allocating a new internal data block if needed,
  /// and resizing the internal index block if needed.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 0); // add 0 to list
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.toArray(list) // => [0, 1, 2, 3]
  /// ```
  ///
  /// Amortized Runtime: `O(1)`, Worst Case Runtime: `O(sqrt(n))`
  public func add<T>(list : List<T>, element : T) {
    var elementIndex = list.elementIndex;
    if (elementIndex == 0) {
      grow_index_block_if_needed(list);
      let blockIndex = list.blockIndex;

      // When removing last we keep one more data block, so can be not empty
      if (list.blocks[blockIndex].size() == 0) {
        list.blocks[blockIndex] := VarArray.repeat<?T>(
          null,
          data_block_size(blockIndex)
        )
      }
    };

    let last_data_block = list.blocks[list.blockIndex];

    last_data_block[elementIndex] := ?element;

    elementIndex += 1;
    if (elementIndex == last_data_block.size()) {
      elementIndex := 0;
      list.blockIndex += 1
    };
    list.elementIndex := elementIndex
  };

  /// Removes and returns the last item in the list or `null` if
  /// the list is empty.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.removeLast(list); // => ?11
  /// ```
  ///
  /// Amortized Runtime: `O(1)`, Worst Case Runtime: `O(sqrt(n))`
  ///
  /// Amortized Space: `O(1)`, Worst Case Space: `O(sqrt(n))`
  public func removeLast<T>(list : List<T>) : ?T {
    var elementIndex = list.elementIndex;
    if (elementIndex == 0) {
      shrink_index_block_if_needed(list);

      var blockIndex = list.blockIndex;
      if (blockIndex == 1) {
        return null
      };
      blockIndex -= 1;
      elementIndex := list.blocks[blockIndex].size();

      // Keep one totally empty block when removing
      if (blockIndex + 2 < list.blocks.size()) {
        if (list.blocks[blockIndex + 2].size() == 0) {
          list.blocks[blockIndex + 2] := [var]
        }
      };
      list.blockIndex := blockIndex
    };
    elementIndex -= 1;

    var last_data_block = list.blocks[list.blockIndex];

    let element = last_data_block[elementIndex];
    last_data_block[elementIndex] := null;

    list.elementIndex := elementIndex;
    return element
  };

  func locate(index : Nat) : (Nat, Nat) {
    // see comments in tests
    let i = Nat32.fromNat(index);
    let lz = Nat32.bitcountLeadingZero(i);
    let lz2 = lz >> 1;
    if (lz & 1 == 0) {
      (Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2)), Nat32.toNat(i & (0xFFFF >> lz2)))
    } else {
      (Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2)), Nat32.toNat(i & (0x7FFF >> lz2)))
    }
  };

  /// Returns the element at index `index`. Indexing is zero-based.
  /// Traps if `index >= size`, error message may not be descriptive.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.get(list, 0); // => 10
  /// ```
  ///
  /// Runtime: `O(1)`
  public func get<T>(list : List<T>, index : Nat) : T {
    // inlined version of:
    //   let (a,b) = locate(index);
    //   switch(list.blocks[a][b]) {
    //     case (?element) element;
    //     case (null) Prim.trap "";
    //   };
    let i = Nat32.fromNat(index);
    let lz = Nat32.bitcountLeadingZero(i);
    let lz2 = lz >> 1;
    switch (
      if (lz & 1 == 0) {
        list.blocks[Nat32.toNat(((i << lz2) >> 16) ^ (0x10000 >> lz2))][Nat32.toNat(i & (0xFFFF >> lz2))]
      } else {
        list.blocks[Nat32.toNat(((i << lz2) >> 15) ^ (0x18000 >> lz2))][Nat32.toNat(i & (0x7FFF >> lz2))]
      }
    ) {
      case (?result) return result;
      case (_) Prim.trap "List index out of bounds in get"
    }
  };

  /// Returns the element at index `index` as an option.
  /// Returns `null` when `index >= size`. Indexing is zero-based.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// let x = List.getOpt(list, 0); // => ?10
  /// let y = List.getOpt(list, 2); // => null
  /// ```
  ///
  /// Runtime: `O(1)`
  public func getOpt<T>(list : List<T>, index : Nat) : ?T {
    let (a, b) = locate(index);
    if (a < list.blockIndex or list.elementIndex != 0 and a == list.blockIndex) {
      list.blocks[a][b]
    } else {
      null
    }
  };

  /// Overwrites the current element at `index` with `element`. Traps if
  /// `index` >= size. Indexing is zero-based.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 10);
  /// List.put(list, 0, 20); // overwrites 10 at index 0 with 20
  /// List.toArray(list) // => [20]
  /// ```
  ///
  /// Runtime: `O(1)`
  public func put<T>(list : List<T>, index : Nat, value : T) {
    let (a, b) = locate(index);
    if (a < list.blockIndex or a == list.blockIndex and b < list.elementIndex) {
      list.blocks[a][b] := ?value
    } else Prim.trap "List index out of bounds in put"
  };

  /// Sorts the elements in the list according to `compare`.
  /// Sort is deterministic, stable, and in-place.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 3);
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.sort(list, Nat.compare);
  /// List.toArray(list) // => [1, 2, 3]
  /// ```
  ///
  /// Runtime: O(size * log(size))
  ///
  /// Space: O(size)
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func sort<T>(list : List<T>, compare : (T, T) -> Order.Order) {
    if (size(list) < 2) return;
    let arr = toVarArray(list);
    VarArray.sortInPlace(arr, compare);
    for (i in arr.keys()) {
      put(list, i, arr[i])
    }
  };

  /// Finds the first index of `element` in `list` using equality of elements defined
  /// by `equal`. Returns `null` if `element` is not found.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.new<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// List.indexOf<Nat>(3, list, Nat.equal); // => ?2
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `equal` runs in `O(1)` time and space.
  public func indexOf<T>(list : List<T>, equal : (T, T) -> Bool, element : T) : ?Nat {
    // inlining would save 10 instructions per entry
    firstIndexWhere<T>(list, func(x) = equal(element, x))
  };

  /// Finds the last index of `element` in `list` using equality of elements defined
  /// by `equal`. Returns `null` if `element` is not found.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.new<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  /// List.add(list, 2);
  /// List.add(list, 2);
  ///
  /// List.lastIndexOf<Nat>(2, list, Nat.equal); // => ?5
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `equal` runs in `O(1)` time and space.
  public func lastIndexOf<T>(list : List<T>, equal : (T, T) -> Bool, element : T) : ?Nat {
    // inlining would save 10 instructions per entry
    lastIndexWhere<T>(list, func(x) = equal(element, x))
  };

  /// Finds the index of the first element in `list` for which `predicate` is true.
  /// Returns `null` if no such element is found.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.new<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// List.firstIndexWhere<Nat>(list, func(i) { i % 2 == 0 }); // => ?1
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `predicate` runs in `O(1)` time and space.
  public func firstIndexWhere<T>(list : List<T>, predicate : T -> Bool) : ?Nat {
    let blocks = list.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    var size = 0;
    var db : [var ?T] = [var];
    var i = 0;

    loop {
      if (elementIndex == size) {
        blockIndex += 1;
        if (blockIndex >= blocks) return null;
        db := list.blocks[blockIndex];
        size := db.size();
        if (size == 0) return null;
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) if (predicate(x)) return ?i;
        case (_) return null
      };
      elementIndex += 1;
      i += 1
    }
  };

  /// Finds the index of the last element in `list` for which `predicate` is true.
  /// Returns `null` if no such element is found.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.new<Nat>();
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// List.lastIndexWhere<Nat>(list, func(i) { i % 2 == 0 }); // => ?3
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// *Runtime and space assumes that `predicate` runs in `O(1)` time and space.
  public func lastIndexWhere<T>(list : List<T>, predicate : T -> Bool) : ?Nat {
    var i = size(list);
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex;
    var db : [var ?T] = if (blockIndex < list.blocks.size()) {
      list.blocks[blockIndex]
    } else { [var] };

    loop {
      if (blockIndex == 1) {
        return null
      };
      if (elementIndex == 0) {
        blockIndex -= 1;
        db := list.blocks[blockIndex];
        elementIndex := db.size() - 1
      } else {
        elementIndex -= 1
      };
      switch (db[elementIndex]) {
        case (?x) {
          i -= 1;
          if (predicate(x)) return ?i
        };
        case (_) Prim.trap(INTERNAL_ERROR)
      }
    }
  };

  /// Returns true iff every element in `list` satisfies `predicate`.
  /// In particular, if `list` is empty the function returns `true`.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// List.all<Nat>(list, func x { x > 1 }); // => true
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func all<T>(list : List<T>, predicate : T -> Bool) : Bool {
    not any<T>(list, func(x) : Bool = not predicate(x))
  };

  /// Returns true iff some element in `list` satisfies `predicate`.
  /// In particular, if `list` is empty the function returns `false`.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 2);
  /// List.add(list, 3);
  /// List.add(list, 4);
  ///
  /// List.any<Nat>(list, func x { x > 3 }); // => true
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `predicate` runs in O(1) time and space.
  public func any<T>(list : List<T>, predicate : T -> Bool) : Bool {
    switch (firstIndexWhere(list, predicate)) {
      case (null) false;
      case (_) true
    }
  };

  /// Returns an Iterator (`Iter`) over the elements of a List.
  /// Iterator provides a single method `next()`, which returns
  /// elements in order, or `null` when out of elements to iterate over.
  ///
  /// ```
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  ///
  /// var sum = 0;
  /// for (element in List.values(list)) {
  ///   sum += element;
  /// };
  /// sum // => 33
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  public func values<T>(list : List<T>) : Iter.Iter<T> = values_(list);

  /// Returns an Iterator (`Iter`) over the items, i.e. pairs of value and index of a List.
  /// Iterator provides a single method `next()`, which returns
  /// elements in order, or `null` when out of elements to iterate over.
  ///
  /// ```
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  /// Iter.toArray(List.entries(list)); // [(10, 0), (11, 1), (12, 2)]
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  ///
  /// Warning: Allocates memory on the heap to store ?(T, Nat).
  public func entries<T>(list : List<T>) : Iter.Iter<(T, Nat)> = object {
    let blocks = list.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    var size = 0;
    var db : [var ?T] = [var];
    var i = 0;

    public func next() : ?(T, Nat) {
      if (elementIndex == size) {
        blockIndex += 1;
        if (blockIndex >= blocks) return null;
        db := list.blocks[blockIndex];
        size := db.size();
        if (size == 0) return null;
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          let ret = ?(x, i);
          elementIndex += 1;
          i += 1;
          return ret
        };
        case (_) return null
      }
    }
  };

  /// Returns an Iterator (`Iter`) over the elements of a List in reverse order.
  /// Iterator provides a single method `next()`, which returns
  /// elements in reverse order, or `null` when out of elements to iterate over.
  ///
  /// ```
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  ///
  /// var sum = 0;
  /// for (element in List.valuesRev(list)) {
  ///   sum += element;
  /// };
  /// sum // => 33
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  public func valuesRev<T>(list : List<T>) : Iter.Iter<T> = object {
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex;
    var db : [var ?T] = if (blockIndex < list.blocks.size()) {
      list.blocks[blockIndex]
    } else { [var] };

    public func next() : ?T {
      if (blockIndex == 1) {
        return null
      };
      if (elementIndex == 0) {
        blockIndex -= 1;
        db := list.blocks[blockIndex];
        elementIndex := db.size() - 1
      } else {
        elementIndex -= 1
      };

      db[elementIndex]
    }
  };

  /// Returns an Iterator (`Iter`) over the items in reverse order, i.e. pairs of value and index of a List.
  /// Iterator provides a single method `next()`, which returns
  /// elements in reverse order, or `null` when out of elements to iterate over.
  ///
  /// ```
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  /// Iter.toArray(List.entries(list)); // [(12, 0), (11, 1), (10, 2)]
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  ///
  /// Warning: Allocates memory on the heap to store ?(T, Nat).
  public func entriesRev<T>(list : List<T>) : Iter.Iter<(T, Nat)> = object {
    var i = size(list);
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex;
    var db : [var ?T] = if (blockIndex < list.blocks.size()) {
      list.blocks[blockIndex]
    } else { [var] };

    public func next() : ?(T, Nat) {
      if (blockIndex == 1) {
        return null
      };
      if (elementIndex == 0) {
        blockIndex -= 1;
        db := list.blocks[blockIndex];
        elementIndex := db.size() - 1
      } else {
        elementIndex -= 1
      };
      switch (db[elementIndex]) {
        case (?x) {
          i -= 1;
          return ?(x, i)
        };
        case (_) Prim.trap(INTERNAL_ERROR)
      }
    }
  };

  /// Returns an Iterator (`Iter`) over the keys (indices) of a List.
  /// Iterator provides a single method `next()`, which returns
  /// elements in order, or `null` when out of elements to iterate over.
  ///
  /// ```
  ///
  /// List.add(list, 10);
  /// List.add(list, 11);
  /// List.add(list, 12);
  /// Iter.toArray(List.values(list)); // [0, 1, 2]
  /// ```
  ///
  /// Note: This does not create a snapshot. If the returned iterator is not consumed at once,
  /// and instead the consumption of the iterator is interleaved with other operations on the
  /// List, then this may lead to unexpected results.
  ///
  /// Runtime: `O(1)`
  public func keys<T>(list : List<T>) : Iter.Iter<Nat> = Nat.range(0, size(list));

  /// Creates a List containing elements from `iter`.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [1, 1, 1];
  /// let iter = array.vals();
  ///
  /// let list = List.fromIter<Nat>(iter); // => [1, 1, 1]
  /// ```
  ///
  /// Runtime: `O(size)`
  public func fromIter<T>(iter : Iter.Iter<T>) : List<T> {
    let list = empty<T>();
    for (element in iter) add(list, element);
    list
  };

  /// Adds elements to a List from `iter`.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [1, 1, 1];
  /// let iter = array.vals();
  /// let list = List.repeat<Nat>(2, 1);
  ///
  /// let list = List.addAll<Nat>(list, iter); // => [2, 1, 1, 1]
  /// ```
  ///
  /// Runtime: `O(size)`, where n is the size of iter.
  public func addAll<T>(list : List<T>, iter : Iter.Iter<T>) {
    for (element in iter) add(list, element)
  };

  /// Creates an immutable array containing elements from a List.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  ///
  /// List.toArray<Nat>(list); // => [1, 2, 3]
  ///
  /// ```
  ///
  /// Runtime: `O(size)`
  public func toArray<T>(list : List<T>) : [T] = Array.tabulate<T>(size(list), values_(list).unsafe_next_i);

  private func values_<T>(list : List<T>) : {
    next : () -> ?T;
    unsafe_next : () -> T;
    unsafe_next_i : Nat -> T
  } = object {
    let blocks = list.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    var db_size = 0;
    var db : [var ?T] = [var];

    public func next() : ?T {
      if (elementIndex == db_size) {
        blockIndex += 1;
        if (blockIndex >= blocks) return null;
        db := list.blocks[blockIndex];
        db_size := db.size();
        if (db_size == 0) return null;
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          elementIndex += 1;
          return ?x
        };
        case (_) return null
      }
    };

    // version of next() without option type
    // inlined version of
    //   public func unsafe_next() : T = {
    //     let ?x = next() else Prim.trap(INTERNAL_ERROR);
    //     x;
    //   };
    public func unsafe_next() : T {
      if (elementIndex == db_size) {
        blockIndex += 1;
        if (blockIndex >= blocks) Prim.trap(INTERNAL_ERROR);
        db := list.blocks[blockIndex];
        db_size := db.size();
        if (db_size == 0) Prim.trap(INTERNAL_ERROR);
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          elementIndex += 1;
          return x
        };
        case (_) Prim.trap(INTERNAL_ERROR)
      }
    };

    // version of next() without option type and throw-away argument
    // inlined version of
    //   public func unsafe_next_(i : Nat) : T = unsafe_next();
    public func unsafe_next_i(i : Nat) : T {
      if (elementIndex == db_size) {
        blockIndex += 1;
        if (blockIndex >= blocks) Prim.trap(INTERNAL_ERROR);
        db := list.blocks[blockIndex];
        db_size := db.size();
        if (db_size == 0) Prim.trap(INTERNAL_ERROR);
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          elementIndex += 1;
          return x
        };
        case (_) Prim.trap(INTERNAL_ERROR)
      }
    }
  };

  /// Creates a List containing elements from an Array.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [2, 3];
  ///
  /// let list = List.fromArray<Nat>(array); // => [2, 3]
  /// ```
  ///
  /// Runtime: `O(size)`
  public func fromArray<T>(array : [T]) : List<T> {
    let (blockIndex, elementIndex) = locate(array.size());

    let blocks = new_index_block_length(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));
    let data_blocks = VarArray.repeat<[var ?T]>([var], blocks);
    var i = 1;
    var pos = 0;

    func make_block(len : Nat, fill : Nat) : [var ?T] {
      let block = VarArray.repeat<?T>(null, len);
      var j = 0;
      while (j < fill) {
        block[j] := ?array[pos];
        j += 1;
        pos += 1
      };
      block
    };

    while (i < blockIndex) {
      let len = data_block_size(i);
      data_blocks[i] := make_block(len, len);
      i += 1
    };
    if (elementIndex != 0 and blockIndex < blocks) {
      data_blocks[i] := make_block(data_block_size(i), elementIndex)
    };

    {
      var blocks = data_blocks;
      var blockIndex = blockIndex;
      var elementIndex = elementIndex
    };

  };

  /// Creates a mutable Array containing elements from a List.
  ///
  /// Example:
  /// ```motoko
  ///
  /// List.add(list, 1);
  /// List.add(list, 2);
  /// List.add(list, 3);
  ///
  /// List.toVarArray<Nat>(list); // => [1, 2, 3]
  ///
  /// ```
  ///
  /// Runtime: `O(size)`
  public func toVarArray<T>(list : List<T>) : [var T] {
    let s = size(list);
    if (s == 0) return [var];
    let arr = VarArray.repeat<T>(Option.unwrap(first(list)), s);
    var i = 0;
    let next = values_(list).unsafe_next;
    while (i < s) {
      arr[i] := next();
      i += 1
    };
    arr
  };

  /// Creates a List containing elements from a mutable Array.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let array = [var 2, 3];
  ///
  /// let list = List.fromVarArray<Nat>(array); // => [2, 3]
  /// ```
  ///
  /// Runtime: `O(size)`
  public func fromVarArray<T>(array : [var T]) : List<T> {
    let (blockIndex, elementIndex) = locate(array.size());

    let blocks = new_index_block_length(Nat32.fromNat(if (elementIndex == 0) { blockIndex - 1 } else blockIndex));
    let data_blocks = VarArray.repeat<[var ?T]>([var], blocks);
    var i = 1;
    var pos = 0;

    func make_block(len : Nat, fill : Nat) : [var ?T] {
      let block = VarArray.repeat<?T>(null, len);
      var j = 0;
      while (j < fill) {
        block[j] := ?array[pos];
        j += 1;
        pos += 1
      };
      block
    };

    while (i < blockIndex) {
      let len = data_block_size(i);
      data_blocks[i] := make_block(len, len);
      i += 1
    };
    if (elementIndex != 0 and blockIndex < blocks) {
      data_blocks[i] := make_block(data_block_size(i), elementIndex)
    };

    {
      var blocks = data_blocks;
      var blockIndex = blockIndex;
      var elementIndex = elementIndex
    };

  };

  /// Returns the first element of `list`  is empty.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.repeat<Nat>(1, 10);
  ///
  /// List.first(list); // => ?1
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func first<T>(list : List<T>) : ?T {
    list.blocks[1][0]
  };

  /// Returns the last element of `list`. Traps if `list` is empty.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.last(list); // => 3
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func last<T>(list : List<T>) : ?T {
    let e = list.elementIndex;
    if (e > 0) {
      switch (list.blocks[list.blockIndex][e - 1]) {
        case null { Prim.trap(INTERNAL_ERROR) };
        case e { return e }
      }
    };
    list.blocks[list.blockIndex - 1][0]
  };

  /// Applies `f` to each element in `list`.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.forEach<Nat>(list, func(x) {
  ///   Debug.print(Nat.toText(x)); // prints each element in list
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEach<T>(list : List<T>, f : T -> ()) {
    let blocks = list.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    var size = 0;
    var db : [var ?T] = [var];

    loop {
      if (elementIndex == size) {
        blockIndex += 1;
        if (blockIndex >= blocks) return;
        db := list.blocks[blockIndex];
        size := db.size();
        if (size == 0) return;
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          f(x);
          elementIndex += 1
        };
        case (_) return
      }
    }
  };

  /// Applies `f` to each item `(i, x)` in `list` where `i` is the key
  /// and `x` is the value.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.forEachEntry<Nat>(list, func (i,x) {
  ///   // prints each item (i,x) in list
  ///   Debug.print(Nat.toText(i) # Nat.toText(x));
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEachEntry<T>(list : List<T>, f : (Nat, T) -> ()) {
    /* Inlined version of
      let o = object {
        var i = 0;
        public func fx(x : T) { f(i, x); i += 1; };
      };
      iterate<T>(list, o.fx);
    */
    let blocks = list.blocks.size();
    var blockIndex = 0;
    var elementIndex = 0;
    var size = 0;
    var db : [var ?T] = [var];
    var i = 0;

    loop {
      if (elementIndex == size) {
        blockIndex += 1;
        if (blockIndex >= blocks) return;
        db := list.blocks[blockIndex];
        size := db.size();
        if (size == 0) return;
        elementIndex := 0
      };
      switch (db[elementIndex]) {
        case (?x) {
          f(i, x);
          elementIndex += 1;
          i += 1
        };
        case (_) return
      }
    }
  };

  /// Like `forEachEntryRev` but iterates through the list in reverse order,
  /// from end to beginning.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.forEachEntryRev<Nat>(list, func (i,x) {
  ///   // prints each item (i,x) in list
  ///   Debug.print(Nat.toText(i) # Nat.toText(x));
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEachEntryRev<T>(list : List<T>, f : (Nat, T) -> ()) {
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex;
    var db : [var ?T] = if (blockIndex < list.blocks.size()) {
      list.blocks[blockIndex]
    } else { [var] };
    var i = size(list);

    loop {
      if (blockIndex == 1) {
        return
      };
      if (elementIndex == 0) {
        blockIndex -= 1;
        db := list.blocks[blockIndex];
        elementIndex := db.size() - 1
      } else {
        elementIndex -= 1
      };
      i -= 1;
      switch (db[elementIndex]) {
        case (?x) f(i, x);
        case (_) Prim.trap(INTERNAL_ERROR)
      }
    }
  };

  /// Applies `f` to each element in `list` in reverse order.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// let list = List.fromArray<Nat>([1, 2, 3]);
  ///
  /// List.forEachRev<Nat>(list, func (x) {
  ///   Debug.print(Nat.toText(x)); // prints each element in list in reverse order
  /// });
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `f` runs in O(1) time and space.
  public func forEachRev<T>(list : List<T>, f : T -> ()) {
    var blockIndex = list.blockIndex;
    var elementIndex = list.elementIndex;
    var db : [var ?T] = if (blockIndex < list.blocks.size()) {
      list.blocks[blockIndex]
    } else { [var] };

    loop {
      if (blockIndex == 1) {
        return
      };
      if (elementIndex == 0) {
        blockIndex -= 1;
        db := list.blocks[blockIndex];
        elementIndex := db.size() - 1
      } else {
        elementIndex -= 1
      };
      switch (db[elementIndex]) {
        case (?x) f(x);
        case (_) Prim.trap(INTERNAL_ERROR)
      }
    }
  };

  /// Returns true if List contains element with respect to equality
  /// defined by `equal`.
  ///
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// List.add(list, 2);
  /// List.add(list, 0);
  /// List.add(list, 3);
  ///
  /// List.contains<Nat>(list, Nat.equal, 2); // => true
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func contains<T>(list : List<T>, equal : (T, T) -> Bool, element : T) : Bool {
    Option.isSome(indexOf(list, equal, element))
  };

  /// Finds the greatest element in `list` defined by `compare`.
  /// Returns `null` if `list` is empty.
  ///
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// List.add(list, 1);
  /// List.add(list, 2);
  ///
  /// List.max<Nat>(list, Nat.compare); // => ?2
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func max<T>(list : List<T>, compare : (T, T) -> Order.Order) : ?T {
    if (size(list) == 0) return null;

    var maxSoFar = get(list, 0);
    forEach<T>(
      list,
      func(x) = switch (compare(x, maxSoFar)) {
        case (#greater) maxSoFar := x;
        case _ {}
      }
    );

    return ?maxSoFar
  };

  /// Finds the least element in `list` defined by `compare`.
  /// Returns `null` if `list` is empty.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// List.add(list, 1);
  /// List.add(list, 2);
  ///
  /// List.min<Nat>(list, Nat.compare); // => ?1
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func min<T>(list : List<T>, compare : (T, T) -> Order.Order) : ?T {
    if (size(list) == 0) return null;

    var minSoFar = get(list, 0);
    forEach<T>(
      list,
      func(x) = switch (compare(x, minSoFar)) {
        case (#less) minSoFar := x;
        case _ {}
      }
    );

    return ?minSoFar
  };

  /// Defines equality for two lists, using `equal` to recursively compare elements in the
  /// lists. Returns true iff the two lists are of the same size, and `equal`
  /// evaluates to true for every pair of elements in the two lists of the same
  /// index.
  ///
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list1 = List.fromArray<Nat>([1,2]);
  /// let list2 = List.new<Nat>();
  /// list2.add(1);
  /// list2.add(2);
  ///
  /// List.equal<Nat>(list1, list2, Nat.equal); // => true
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `equal` runs in O(1) time and space.
  public func equal<T>(list1 : List<T>, list2 : List<T>, equal : (T, T) -> Bool) : Bool {
    let size1 = size(list1);

    if (size1 != size(list2)) return false;

    let next1 = values_(list1).unsafe_next;
    let next2 = values_(list2).unsafe_next;
    var i = 0;
    while (i < size1) {
      if (not equal(next1(), next2())) return false;
      i += 1
    };

    return true
  };

  /// Defines comparison for two lists, using `compare` to recursively compare elements in the
  /// lists. Comparison is defined lexicographically.
  ///
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list1 = List.fromArray<Nat>([1,2]);
  /// let list2 = List.new<Nat>();
  /// list2.add(1);
  /// list2.add(2);
  ///
  /// List.compare<Nat>(list1, list2, Nat.compare); // => #less
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `compare` runs in O(1) time and space.
  public func compare<T>(list1 : List<T>, list2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
    let size1 = size(list1);
    let size2 = size(list2);
    let minSize = if (size1 < size2) { size1 } else { size2 };

    let next1 = values_(list1).unsafe_next;
    let next2 = values_(list2).unsafe_next;
    var i = 0;
    while (i < minSize) {
      switch (compare(next1(), next2())) {
        case (#less) return #less;
        case (#greater) return #greater;
        case _ {}
      };
      i += 1
    };

    return Nat.compare(size1, size2)
  };

  /// Creates a textual representation of `list`, using `toText` to recursively
  /// convert the elements into Text.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3,4]);
  ///
  /// List.toText<Nat>(list, Nat.toText); // => "[1, 2, 3, 4]"
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(size)`
  ///
  /// *Runtime and space assumes that `toText` runs in O(1) time and space.
  public func toText<T>(list : List<T>, f : T -> Text) : Text {
    let vsize : Int = size(list);
    let next = values_(list).unsafe_next;
    var i = 0;
    var text = "";
    while (i < vsize - 1) {
      text := text # f(next()) # ", "; // Text implemented as rope
      i += 1
    };
    if (vsize > 0) {
      // avoid the trailing comma
      text := text # f(get<T>(list, i))
    };

    "[" # text # "]"
  };

  /// Collapses the elements in `list` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// left to right.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// List.foldLeft<Text, Nat>(list, "", func (acc, x) { acc # Nat.toText(x)}); // => "123"
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `combine` runs in O(1)` time and space.
  public func foldLeft<A, T>(list : List<T>, base : A, combine : (A, T) -> A) : A {
    var accumulation = base;

    forEach<T>(
      list,
      func(x) = accumulation := combine(accumulation, x)
    );

    accumulation
  };

  /// Collapses the elements in `list` into a single value by starting with `base`
  /// and progessively combining elements into `base` with `combine`. Iteration runs
  /// right to left.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// List.foldRight<Nat, Text>(list, "", func (x, acc) { Nat.toText(x) # acc }); // => "123"
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  ///
  /// *Runtime and space assumes that `combine` runs in O(1)` time and space.
  public func foldRight<T, A>(list : List<T>, base : A, combine : (T, A) -> A) : A {
    var accumulation = base;

    forEachRev<T>(
      list,
      func(x) = accumulation := combine(x, accumulation)
    );

    accumulation
  };

  /// Reverses the order of elements in `list` by overwriting in place.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// List.reverseInPlace<Nat>(list);
  /// List.toText<Nat>(list, Nat.toText); // => "[3, 2, 1]"
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func reverseInPlace<T>(list : List<T>) {
    let vsize = size(list);
    if (vsize == 0) return;

    var i = 0;
    var j = vsize - 1 : Nat;
    var temp = get(list, 0);
    while (i < vsize / 2) {
      temp := get(list, j);
      put(list, j, get(list, i));
      put(list, i, temp);
      i += 1;
      j -= 1
    }
  };

  /// Returns a new List with the elements from `list` in reverse order.
  ///
  /// Example:
  /// ```motoko
  ///
  /// import Nat "mo:base/Nat";
  ///
  /// let list = List.fromArray<Nat>([1,2,3]);
  ///
  /// let rlist = List.reverse<Nat>(list);
  /// List.toText<Nat>(rlist, Nat.toText); // => "[3, 2, 1]"
  /// ```
  ///
  /// Runtime: `O(size)`
  ///
  /// Space: `O(1)`
  public func reverse<T>(list : List<T>) : List<T> {
    let rlist = empty<T>();

    forEachRev<T>(
      list,
      func(x) = add(rlist, x)
    );

    rlist
  };

  /// Returns true if and only if the list is empty.
  ///
  /// Example:
  /// ```motoko
  ///
  /// let list = List.fromArray<Nat>([2,0,3]);
  /// List.isEmpty<Nat>(list); // => false
  /// ```
  ///
  /// Runtime: `O(1)`
  ///
  /// Space: `O(1)`
  public func isEmpty<T>(list : List<T>) : Bool {
    list.blockIndex == 1 and list.elementIndex == 0
  }
}
