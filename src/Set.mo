/// An imperative set based on order/comparison of the elements.
/// The set data structure type is stable and can be used for orthogonal persistence.
///
/// Example:
/// ```motoko
/// import Set "mo:base/Set";
/// import Nat "mo:base/Nat";
///
/// persistent actor {
///   let userIds = Set.empty<Nat>();
///   Set.add(userIds, Nat.compare, 1);
///   Set.add(userIds, Nat.compare, 2);
///   Set.add(userIds, Nat.compare, 3);
/// }
/// ```
///
/// The internal implementation is a B-tree with order 32.
///
/// Performance:
/// * Runtime: `O(log(n))` worst case cost per insertion, removal, and retrieval operation.
/// * Space: `O(n)` for storing the entire set.
/// `n` denotes the number of elements stored in the set.

// Data structure implementation is courtesy of Byron Becker.
// Source: https://github.com/canscale/StableHeapBTreeMap
// Copyright (c) 2022 Byron Becker.
// Distributed under Apache 2.0 license.
// With adjustments by the Motoko team.

// import Immutable "immutable/Set";
import IterType "type/Iter";
import Order "Order";
import VarArray "VarArray";
import Runtime "Runtime";
// import Stack "Stack";
import Option "Option";
import { todo } "Debug";
import BTreeHelper "internal/BTreeHelper";

module {
  let btreeOrder = 32; // Should be >= 4 and <= 512.

  public type Node<T> = {
    #leaf : Leaf<T>;
    #internal : Internal<T>
  };

  public type Data<T> = {
    elements : [var ?T];
    var count : Nat
  };

  public type Internal<T> = {
    data : Data<T>;
    children : [var ?Node<T>]
  };

  public type Leaf<T> = {
    data : Data<T>
  };

  public type Set<T> = {
    var root : Node<T>;
    var size : Nat
  };

  // /// Convert the mutable set to an immutable set.
  // ///
  // /// Example:
  // /// ```motoko
  // /// import Set "mo:base/Set";
  // /// import ImmutableSet "mo:base/immutable/Set";
  // /// import Nat "mo:base/Nat";
  // ///
  // /// persistent actor {
  // ///   let mutableSet = Set.empty<Nat>();
  // ///   Set.add(mutableSet, Nat.compare, 1);
  // ///   Set.add(mutableSet, Nat.compare, 2);
  // ///   Set.add(mutableSet, Nat.compare, 3);
  // ///   let immutableSet = Set.freeze(mutableSet);
  // ///   assert(ImmutableSet.contains(immutableSet, 1));
  // /// }
  // /// ```
  // ///
  // /// Runtime: `O(n * log(n))`.
  // /// Space: `O(n)` retained memory plus garbage, see the note below.
  // /// where `n` denotes the number of elements stored in the set and
  // /// assuming that the `compare` function implements an `O(1)` comparison.
  // ///
  // /// Note: Creates `O(n * log(n))` temporary objects that will be collected as garbage.
  // public func freeze<T>(set : Set<T>, compare : (T, T) -> Order.Order) : Immutable.Set<T> {
  //   ImmutableSet.fromIter(values(set), compare);
  // };

  // /// Convert an immutable set to a mutable set.
  // ///
  // /// Example:
  // /// ```motoko
  // /// import ImmutableSet "mo:base/immutable/Set";
  // /// import Set "mo:base/Set";
  // /// import Nat "mo:base/Nat";
  // ///
  // /// persistent actor {
  // ///   var immutableSet = ImmutableSet.empty<Nat>();
  // ///   immutableSet := ImmutableSet.add(immutableSet, Nat.compare, 1);
  // ///   immutableSet := ImmutableSet.add(immutableSet, Nat.compare, 2);
  // ///   immutableSet := ImmutableSet.add(immutableSet, Nat.compare, 3);
  // ///   let mutableSet = Set.thaw(immutableSet);
  // //    assert(Set.contains(mutableSet, 1));
  // /// }
  // /// ```
  // ///
  // /// Runtime: `O(n * log(n))`.
  // /// Space: `O(n)`.
  // /// where `n` denotes the number of elements stored in the set and
  // /// assuming that the `compare` function implements an `O(1)` comparison.
  // public func thaw<T>(set : Immutable.Set<T>, compare : (T, T) -> Order.Order) : Set<T> {
  //   fromIter(ImmutableSet.values(set), compare)
  // };

  /// Create a copy of the mutable set.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let originalSet = Set.empty<Nat>();
  ///   Set.add(originalSet, Nat.compare, 1);
  ///   Set.add(originalSet, Nat.compare, 2);
  ///   Set.add(originalSet, Nat.compare, 3);
  ///   let clonedSet = Set.clone(originalSet);
  /// }
  /// ```
  ///
  /// Runtime: `O(n)`.
  /// Space: `O(n)`.
  /// where `n` denotes the number of elements stored in the set.
  public func clone<T>(set : Set<T>) : Set<T> {
    {
      var root = cloneNode(set.root);
      var size = set.size
    }
  };

  /// Create a new empty mutable set.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let set = Set.empty<Nat>();
  ///   Debug.print(Nat.toText(Set.size(set))); // prints `0`
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func empty<T>() : Set<T> {
    {
      var root = #leaf({
        data = {
          elements = VarArray.tabulate<?T>(btreeOrder - 1, func(index) { null });
          var count = 0
        }
      });
      var size = 0
    }
  };

  /// Create a new mutable set with a single element.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let cities = Set.singleton<Text>("Zurich");
  ///   Debug.print(debug_show(Set.size(cities))); // prints `1`
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func singleton<T>(element : T) : Set<T> {
    {
      var root = #leaf({
        data = {
          elements = VarArray.tabulate<?T>(
            btreeOrder - 1,
            func(index) {
              if (index == 0) {
                ?element
              } else {
                null
              }
            }
          );
          var count = 1
        }
      });
      var size = 1
    }
  };

  /// Remove all the elements from the set.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let cities = Set.empty<Text>();
  ///   Set.add(cities, Text.compare, "Zurich");
  ///   Set.add(cities, Text.compare, "San Francisco");
  ///   Set.add(cities, Text.compare, "London");
  ///   Debug.print(debug_show(Set.size(cities))); // prints `3`
  ///
  ///   Set.clear(cities);
  ///   Debug.print(debug_show(Set.size(cities))); // prints `0`
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func clear<T>(set : Set<T>) {
    let emptySet = empty<T>();
    set.root := emptySet.root;
    set.size := 0
  };

  /// Determines whether a set is empty.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let set = Set.empty<Text>();
  ///   Set.add(set, Nat.compare, 1);
  ///   Set.add(set, Nat.compare, 2);
  ///   Set.add(set, Nat.compare, 3);
  ///
  ///   Debug.print(debug_show(Set.isEmpty(set))); // prints `false`
  ///   Set.clear(set);
  ///   Debug.print(debug_show(Set.isEmpty(set))); // prints `true`
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func isEmpty<T>(set : Set<T>) : Bool {
    set.size == 0
  };

  /// Return the number of elements in a set.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let set = Set.empty<Nat>();
  ///   Set.add(set, Nat.compare, 1);
  ///   Set.add(set, Nat.compare, 2);
  ///   Set.add(set, Nat.compare, 3);
  ///
  ///   Debug.print(Nat.toText(Set.size(set))); // prints `3`
  /// }
  /// ```
  ///
  /// Runtime: `O(1)`.
  /// Space: `O(1)`.
  public func size<T>(set : Set<T>) : Nat {
    set.size
  };

  /// Test whether two imperative sets are equal.
  /// Both sets have to be constructed by the same comparison function.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let set1 = Set.empty<Nat>();
  ///   Set.add(set1, Nat.compare, 1);
  ///   Set.add(set1, Nat.compare, 2);
  ///   Set.add(set1, Nat.compare, 3);
  ///   let set2 = Set.clone(set1);
  ///
  ///   assert(Set.equal(set1, set2, Nat.equal));
  /// }
  /// ```
  ///
  /// Runtime: `O(n)`.
  /// Space: `O(1)`.
  public func equal<T>(set1 : Set<T>, set2 : Set<T>, equal : (T, T) -> Bool) : Bool {
    let iterator1 = values(set1);
    let iterator2 = values(set2);
    loop {
      let next1 = iterator1.next();
      let next2 = iterator2.next();
      switch (next1, next2) {
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

  /// Tests whether the set contains the provided element.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  /// import Bool "mo:base/Bool";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let set = Set.empty<Nat>();
  ///   Set.add(set, Nat.compare, 1);
  ///   Set.add(set, Nat.compare, 2);
  ///   Set.add(set, Nat.compare, 3);
  ///
  ///   Debug.print(Bool.toText(Set.contains(set, Nat.compare, 1))); // prints `true`
  ///   Debug.print(Bool.toText(Set.contains(set, Nat.compare, 4))); // prints `false`
  /// }
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(1)`.
  /// where `n` denotes the number of elements stored in the set and
  /// assuming that the `compare` function implements an `O(1)` comparison.
  public func contains<T>(set : Set<T>, compare : (T, T) -> Order.Order, element : T) : Bool {
    switch (set.root) {
      case (#internal(internalNode)) {
        containsInInternal(internalNode, compare, element)
      };
      case (#leaf(leafNode)) { containsInLeaf(leafNode, compare, element) }
    }
  };

  /// Insert a new element in the set.
  /// Traps if the element is already present in the set.
  ///
  /// Example:
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  ///
  /// persistent actor {
  ///   let set = Set.empty<Nat>();
  ///   Set.add(set, Nat.compare, 1);
  ///   Set.add(set, Nat.compare, 2);
  ///   Set.add(set, Nat.compare, 3);
  /// }
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(log(n))`.
  /// where `n` denotes the number of elements stored in the set and
  /// assuming that the `compare` function implements an `O(1)` comparison.
  public func add<T>(set : Set<T>, compare : (T, T) -> Order.Order, element : T) {
    let insertResult = switch (set.root) {
      case (#leaf(leafNode)) {
        leafInsertHelper<T>(leafNode, btreeOrder, compare, element)
      };
      case (#internal(internalNode)) {
        internalInsertHelper<T>(internalNode, btreeOrder, compare, element)
      }
    };

    switch (insertResult) {
      case (#inserted) {
        // if inserted an element that was not previously there, increment the tree size counter
        set.size += 1
      };
      case (#existent) {
        Runtime.trap("Element is already present")
      };
      case (#promote({ element = promotedElement; leftChild; rightChild })) {
        set.root := #internal({
          data = {
            elements = VarArray.tabulate<?T>(
              btreeOrder - 1,
              func(i) {
                if (i == 0) { ?promotedElement } else { null }
              }
            );
            var count = 1
          };
          children = VarArray.tabulate<?(Node<T>)>(
            btreeOrder,
            func(i) {
              if (i == 0) { ?leftChild } else if (i == 1) { ?rightChild } else {
                null
              }
            }
          )
        });
        // promotion always comes from inserting a new element, so increment the tree size counter
        set.size += 1
      }
    }
  };

  /// Delete an existing element in the set.
  /// Traps if the element does not exist in the set.
  ///
  /// ```motoko
  /// import Set "mo:base/Set";
  /// import Nat "mo:base/Nat";
  /// import Debug "mo:base/Debug";
  ///
  /// persistent actor {
  ///   let set = Set.empty<Nat>();
  ///   Set.add(set, Nat.compare, 1);
  ///   Set.add(set, Nat.compare, 2);
  ///   Set.add(set, Nat.compare, 3);
  ///
  ///   Set.delete(set, Nat.compare, 1);
  ///   Debug.print(debug_show(Set.contains(set, Nat.compare, 1))); // prints `false`.
  /// }
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(log(n))` including garbage, see below.
  /// where `n` denotes the number of elements stored in the set and
  /// assuming that the `compare` function implements an `O(1)` comparison.
  ///
  /// Note: Creates `O(log(n))` objects that will be collected as garbage.
  public func delete<T>(set : Set<T>, compare : (T, T) -> Order.Order, element : T) {
    let deleted = switch (set.root) {
      case (#leaf(leafNode)) {
        // TODO: think about how this can be optimized so don't have to do two steps (search and then insert)?
        switch (NodeUtil.getElementIndex<T>(leafNode.data, compare, element)) {
          case (#elementFound(deleteIndex)) {
            leafNode.data.count -= 1;
            ignore BTreeHelper.deleteAndShift<T>(leafNode.data.elements, deleteIndex);
            set.size -= 1;
            true
          };
          case _ { false }
        }
      };
      case (#internal(internalNode)) {
        let deletedElement = switch (internalDeleteHelper(internalNode, btreeOrder, compare, element, false)) {
          case (#deleted) { true };
          case (#inexistent) { false };
          case (#mergeChild({ internalChild })) {
            if (internalChild.data.count > 0) {
              set.root := #internal(internalChild)
            }
            // This case will be hit if the BTree has order == 4
            // In this case, the internalChild has no keys (last key was merged with new child), so need to promote that merged child (its only child)
            else {
              set.root := switch (internalChild.children[0]) {
                case (?node) { node };
                case null {
                  Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Map.delete(), element deletion failed, due to a null replacement node error")
                }
              }
            };
            true
          }
        };
        if (deletedElement) {
          // if deleted an element from the BTree, decrement the size
          set.size -= 1
        };
        deletedElement
      }
    };
    if (not deleted) {
      Runtime.trap("Element is not present")
    }
  };

  public func max<T>(set : Set<T>) : ?T {
    todo()
  };

  public func min<T>(set : Set<T>) : ?T {
    todo()
  };

  public func values<T>(set : Set<T>) : IterType.Iter<T> {
    todo()
  };

  public func reverseValues<T>(set : Set<T>) : IterType.Iter<T> {
    todo()
  };

  public func fromIter<T>(iter : IterType.Iter<T>, compare : (T, T) -> Order.Order) : Set<T> {
    todo()
  };

  public func isSubset<T>(set1 : Set<T>, set2 : Set<T>) : Bool {
    todo()
  };

  public func union<T>(set1 : Set<T>, set2 : Set<T>) : Set<T> {
    todo()
  };

  public func intersect<T>(set1 : Set<T>, set2 : Set<T>) : Set<T> {
    todo()
  };

  public func diff<T>(set1 : Set<T>, set2 : Set<T>) : Set<T> {
    todo()
  };

  public func forEach<T>(set : Set<T>, f : T -> ()) {
    todo()
  };

  public func filter<T>(set : Set<T>, compare : (T, T) -> Order.Order, f : T -> Bool) : Set<T> {
    todo()
  };

  public func map<T1, T2>(set : Set<T1>, compare : (T2, T2) -> Order.Order, f : T1 -> T2) : Set<T2> {
    todo()
  };

  public func filterMap<T1, T2>(set : Set<T1>, compare : (T2, T2) -> Order.Order, f : T1 -> ?T2) : Set<T2> {
    todo()
  };

  public func foldLeft<T, A>(
    set : Set<T>,
    base : A,
    combine : (A, T) -> A
  ) : A {
    todo()
  };

  public func foldRight<T, A>(
    set : Set<T>,
    base : A,
    combine : (A, T) -> A
  ) : A {
    todo()
  };

  public func join<T>(set : IterType.Iter<Set<T>>) : Set<T> {
    todo()
  };

  public func flatten<T>(set : Set<Set<T>>) : Set<T> {
    todo()
  };

  public func all<T>(set : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func any<T>(set : Set<T>, pred : T -> Bool) : Bool {
    todo()
  };

  public func assertValid<T>(set : Set<T>, compare : (T, T) -> Order.Order) : () {
    // todo()
  };

  public func toText<T>(set : Set<T>, f : T -> Text) : Text {
    todo()
  };

  public func compare<T>(set1 : Set<T>, set2 : Set<T>, compare : (T, T) -> Order.Order) : Order.Order {
    todo()
  };

  // This type is used to signal to the parent calling context what happened in the level below
  type IntermediateInternalDeleteResult<T> = {
    // element was deleted
    #deleted;
    // element was absent
    #inexistent;
    // deleted an element, but was unable to successfully borrow and rebalance at the previous level without merging children
    // the internalChild is the merged child that needs to be rebalanced at the next level up in the BTree
    #mergeChild : {
      internalChild : Internal<T>
    }
  };

  func internalDeleteHelper<T>(internalNode : Internal<T>, order : Nat, compare : (T, T) -> Order.Order, deleteElement : T, skipNode : Bool) : IntermediateInternalDeleteResult<T> {
    let minElements = NodeUtil.minElementsFromOrder(order);
    let elementIndex = NodeUtil.getElementIndex<T>(internalNode.data, compare, deleteElement);

    // match on both the result of the node binary search, and if this node level should be skipped even if the key is found (internal kv replacement case)
    switch (elementIndex, skipNode) {
      // if element is found in the internal node
      case (#elementFound(deleteIndex), false) {
        if (Option.isNull(internalNode.data.elements[deleteIndex])) {
          Runtime.trap("Bug in Set.internalDeleteHelper")
        };
        // TODO: (optimization) replace with deletion in one step without having to retrieve the maxKey first
        let replaceElement = NodeUtil.getMaxElement(internalNode.children[deleteIndex]);
        internalNode.data.elements[deleteIndex] := ?replaceElement;
        switch (internalDeleteHelper(internalNode, order, compare, replaceElement, true)) {
          case (#deleted) { #deleted };
          case (#inexistent) { #inexistent };
          case (#mergeChild({ internalChild })) {
            #mergeChild({ internalChild; deletedElement = deleteElement })
          }
        }
      };
      // if element is not found in the internal node OR the key is found, but skipping this node (because deleting the in order precessor i.e. replacement kv)
      // in both cases need to descend and traverse to find the kv to delete
      case ((#elementFound(_), true) or (#notFound(_), _)) {
        let childIndex = switch (elementIndex) {
          case (#elementFound(replacedSkipKeyIndex)) { replacedSkipKeyIndex };
          case (#notFound(childIndex)) { childIndex }
        };
        let child = switch (internalNode.children[childIndex]) {
          case (?c) { c };
          case null {
            Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Set.internalDeleteHelper, child index of #keyFound or #notfound is null")
          }
        };
        switch (child) {
          // if child is internal
          case (#internal(internalChild)) {
            switch (internalDeleteHelper(internalChild, order, compare, deleteElement, false), childIndex == 0) {
              // if value was successfully deleted and no additional tree re-balancing is needed, return the deleted value
              case (#deleted, _) { #deleted };
              case (#inexistent, _) { #inexistent };
              // if internalChild needs rebalancing and pulling child is left most
              case (#mergeChild({ internalChild }), true) {
                // try to pull left-most key and child from right sibling
                switch (NodeUtil.borrowFromInternalSibling(internalNode.children, childIndex + 1, #successor)) {
                  // if can pull up sibling kv and child
                  case (#borrowed({ deletedSiblingElement; child })) {
                    NodeUtil.rotateBorrowedElementsAndChildFromSibling(
                      internalNode,
                      childIndex,
                      deletedSiblingElement,
                      child,
                      internalChild,
                      #right
                    );
                    #deleted
                  };
                  // unable to pull from sibling, need to merge with right sibling and push down parent
                  case (#notEnoughElements(sibling)) {
                    // get the parent kv that will be pushed down the the child
                    let elementsToBePushedToChild = ?BTreeHelper.deleteAndShift(internalNode.data.elements, 0);
                    internalNode.data.count -= 1;
                    // merge the children and push down the parent
                    let newChild = NodeUtil.mergeChildrenAndPushDownParent<T>(internalChild, elementsToBePushedToChild, sibling);
                    // update children of the parent
                    internalNode.children[0] := ?#internal(newChild);
                    ignore ?BTreeHelper.deleteAndShift(internalNode.children, 1);

                    if (internalNode.data.count < minElements) {
                      #mergeChild({ internalChild = internalNode })
                    } else {
                      #deleted
                    }
                  }
                }
              };
              // if internalChild needs rebalancing and pulling child is > 0, so a left sibling exists
              case (#mergeChild({ internalChild }), false) {
                // try to pull right-most key and its child directly from left sibling
                switch (NodeUtil.borrowFromInternalSibling(internalNode.children, childIndex - 1 : Nat, #predecessor)) {
                  case (#borrowed({ deletedSiblingElement; child })) {
                    NodeUtil.rotateBorrowedElementsAndChildFromSibling(
                      internalNode,
                      childIndex - 1 : Nat,
                      deletedSiblingElement,
                      child,
                      internalChild,
                      #left
                    );
                    #deleted
                  };
                  // unable to pull from left sibling
                  case (#notEnoughElements(leftSibling)) {
                    // if child is not last index, try to pull from the right child
                    if (childIndex < internalNode.data.count) {
                      switch (NodeUtil.borrowFromInternalSibling(internalNode.children, childIndex, #successor)) {
                        // if can pull up sibling kv and child
                        case (#borrowed({ deletedSiblingElement; child })) {
                          NodeUtil.rotateBorrowedElementsAndChildFromSibling(
                            internalNode,
                            childIndex,
                            deletedSiblingElement,
                            child,
                            internalChild,
                            #right
                          );
                          return #deleted
                        };
                        // if cannot borrow, from left or right, merge (see below)
                        case _ {}
                      }
                    };

                    // get the parent kv that will be pushed down the the child
                    let kvPairToBePushedToChild = ?BTreeHelper.deleteAndShift(internalNode.data.elements, childIndex - 1 : Nat);
                    internalNode.data.count -= 1;
                    // merge it the children and push down the parent
                    let newChild = NodeUtil.mergeChildrenAndPushDownParent(leftSibling, kvPairToBePushedToChild, internalChild);

                    // update children of the parent
                    internalNode.children[childIndex - 1] := ?#internal(newChild);
                    ignore ?BTreeHelper.deleteAndShift(internalNode.children, childIndex);

                    if (internalNode.data.count < minElements) {
                      #mergeChild({ internalChild = internalNode })
                    } else {
                      #deleted
                    }
                  }
                }
              }
            }
          };
          // if child is leaf
          case (#leaf(leafChild)) {
            switch (leafDeleteHelper(leafChild, order, compare, deleteElement), childIndex == 0) {
              case (#deleted, _) { #deleted };
              case (#inexistent, _) { #inexistent };
              // if delete child is left most, try to borrow from right child
              case (#mergeLeafData({ leafDeleteIndex }), true) {
                switch (NodeUtil.borrowFromRightLeafChild(internalNode.children, childIndex)) {
                  case (?borrowedElement) {
                    let elementToBePushedToChild = internalNode.data.elements[childIndex];
                    internalNode.data.elements[childIndex] := ?borrowedElement;

                    ignore BTreeHelper.insertAtPostionAndDeleteAtPosition<T>(leafChild.data.elements, elementToBePushedToChild, leafChild.data.count - 1, leafDeleteIndex);
                    #deleted
                  };

                  case null {
                    // can't borrow from right child, delete from leaf and merge with right child and parent kv, then push down into new leaf
                    let rightChild = switch (internalNode.children[childIndex + 1]) {
                      case (?#leaf(rc)) { rc };
                      case _ {
                        Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Map.internalDeleteHelper, if trying to borrow from right leaf child is null, rightChild index cannot be null or internal")
                      }
                    };
                    let mergedLeaf = mergeParentWithLeftRightChildLeafNodesAndDelete(
                      internalNode.data.elements[childIndex],
                      leafChild,
                      rightChild,
                      leafDeleteIndex,
                      #left
                    );
                    // delete the left most internal node kv, since was merging from a deletion in left most child (0) and the parent kv was pushed into the mergedLeaf
                    ignore BTreeHelper.deleteAndShift<T>(internalNode.data.elements, 0);
                    // update internal node children
                    BTreeHelper.replaceTwoWithElementAndShift<Node<T>>(internalNode.children, #leaf(mergedLeaf), 0);
                    internalNode.data.count -= 1;

                    if (internalNode.data.count < minElements) {
                      #mergeChild({
                        internalChild = internalNode
                      })
                    } else {
                      #deleted
                    }

                  }
                }
              };
              // if delete child is middle or right most, try to borrow from left child
              case (#mergeLeafData({ leafDeleteIndex }), false) {
                // if delete child is right most, try to borrow from left child
                switch (NodeUtil.borrowFromLeftLeafChild(internalNode.children, childIndex)) {
                  case (?borrowedElement) {
                    let elementToBePushedToChild = internalNode.data.elements[childIndex - 1];
                    internalNode.data.elements[childIndex - 1] := ?borrowedElement;
                    ignore BTreeHelper.insertAtPostionAndDeleteAtPosition<T>(leafChild.data.elements, elementToBePushedToChild, 0, leafDeleteIndex);
                    #deleted
                  };
                  case null {
                    // if delete child is in the middle, try to borrow from right child
                    if (childIndex < internalNode.data.count) {
                      // try to borrow from right
                      switch (NodeUtil.borrowFromRightLeafChild(internalNode.children, childIndex)) {
                        case (?borrowedElement) {
                          let kvPairToBePushedToChild = internalNode.data.elements[childIndex];
                          internalNode.data.elements[childIndex] := ?borrowedElement;
                          // insert the successor at the very last element
                          ignore BTreeHelper.insertAtPostionAndDeleteAtPosition<T>(leafChild.data.elements, kvPairToBePushedToChild, leafChild.data.count - 1, leafDeleteIndex);
                          return #deleted
                        };
                        // if cannot borrow, from left or right, merge (see below)
                        case _ {}
                      }
                    };

                    // can't borrow from left child, delete from leaf and merge with left child and parent kv, then push down into new leaf
                    let leftChild = switch (internalNode.children[childIndex - 1]) {
                      case (?#leaf(lc)) { lc };
                      case _ {
                        Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Map.internalDeleteHelper, if trying to borrow from left leaf child is null, then left child index must not be null or internal")
                      }
                    };
                    let mergedLeaf = mergeParentWithLeftRightChildLeafNodesAndDelete(
                      internalNode.data.elements[childIndex - 1],
                      leftChild,
                      leafChild,
                      leafDeleteIndex,
                      #right
                    );
                    // delete the right most internal node kv, since was merging from a deletion in the right most child and the parent kv was pushed into the mergedLeaf
                    ignore BTreeHelper.deleteAndShift<T>(internalNode.data.elements, childIndex - 1);
                    // update internal node children
                    BTreeHelper.replaceTwoWithElementAndShift<Node<T>>(internalNode.children, #leaf(mergedLeaf), childIndex - 1);
                    internalNode.data.count -= 1;

                    if (internalNode.data.count < minElements) {
                      #mergeChild({
                        internalChild = internalNode
                      })
                    } else {
                      #deleted
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  };

  // This type is used to signal to the parent calling context what happened in the level below
  type IntermediateLeafDeleteResult<T> = {
    // element was deleted
    #deleted;
    // element was absent
    #inexistent;
    // leaf had the minimum number of elements when deleting, so returns the leaf node's data and the index of the key that will be deleted
    #mergeLeafData : {
      data : Data<T>;
      leafDeleteIndex : Nat
    }
  };

  func leafDeleteHelper<T>(leafNode : Leaf<T>, order : Nat, compare : (T, T) -> Order.Order, deleteElement : T) : IntermediateLeafDeleteResult<T> {
    let minElements = NodeUtil.minElementsFromOrder(order);

    switch (NodeUtil.getElementIndex<T>(leafNode.data, compare, deleteElement)) {
      case (#elementFound(deleteIndex)) {
        if (leafNode.data.count > minElements) {
          leafNode.data.count -= 1;
          ignore BTreeHelper.deleteAndShift<T>(leafNode.data.elements, deleteIndex);
          #deleted
        } else {
          #mergeLeafData({
            data = leafNode.data;
            leafDeleteIndex = deleteIndex
          })
        }
      };
      case (#notFound(_)) {
        #inexistent
      }
    }
  };

  func containsInInternal<T>(internalNode : Internal<T>, compare : (T, T) -> Order.Order, element : T) : Bool {
    switch (NodeUtil.getElementIndex<T>(internalNode.data, compare, element)) {
      case (#elementFound(index)) {
        true
      };
      case (#notFound(index)) {
        switch (internalNode.children[index]) {
          // expects the child to be there, otherwise there's a bug in binary search or the tree is invalid
          case null { Runtime.trap("Internal bug: Set.containsInInternal") };
          case (?#leaf(leafNode)) { containsInLeaf(leafNode, compare, element) };
          case (?#internal(internalNode)) {
            containsInInternal(internalNode, compare, element)
          }
        }
      }
    }
  };

  func containsInLeaf<T>(leafNode : Leaf<T>, compare : (T, T) -> Order.Order, element : T) : Bool {
    switch (NodeUtil.getElementIndex<T>(leafNode.data, compare, element)) {
      case (#elementFound(index)) {
        true
      };
      case _ false
    }
  };

  type DeletionSide = { #left; #right };

  func mergeParentWithLeftRightChildLeafNodesAndDelete<T>(
    parentElement : ?T,
    leftChild : Leaf<T>,
    rightChild : Leaf<T>,
    deleteIndex : Nat,
    deletionSide : DeletionSide
  ) : Leaf<T> {
    let count = leftChild.data.count * 2;
    let (elements, _) = BTreeHelper.mergeParentWithChildrenAndDelete<T>(
      parentElement,
      leftChild.data.count,
      leftChild.data.elements,
      rightChild.data.elements,
      deleteIndex,
      deletionSide
    );
    ({
      data = {
        elements;
        var count = count
      }
    })
  };

  // This type is used to signal to the parent calling context what happened in the level below
  type IntermediateInsertResult<T> = {
    // element was inserted
    #inserted;
    // element was alreay present
    #existent;
    // child was full when inserting, so returns the promoted element and the split left and right child
    #promote : {
      element : T;
      leftChild : Node<T>;
      rightChild : Node<T>
    }
  };

  // Helper for inserting into a leaf node
  func leafInsertHelper<T>(leafNode : Leaf<T>, order : Nat, compare : (T, T) -> Order.Order, insertedElement : T) : (IntermediateInsertResult<T>) {
    // Perform binary search to see if the element exists in the node
    switch (NodeUtil.getElementIndex<T>(leafNode.data, compare, insertedElement)) {
      case (#elementFound(insertIndex)) {
        let previous = leafNode.data.elements[insertIndex];
        leafNode.data.elements[insertIndex] := ?insertedElement;
        switch (previous) {
          case (?_) { #existent };
          case null { Runtime.trap("Bug in Set.leafInsertHelper") }; // the binary search already found an element, so this case should never happen
        }
      };
      case (#notFound(insertIndex)) {
        // Note: BTree will always have an order >= 4, so this will never have negative Nat overflow
        let maxElements : Nat = order - 1;
        // If the leaf is full, insert, split the node, and promote the middle element
        if (leafNode.data.count >= maxElements) {
          let (leftElements, promotedParentElement, rightElements) = BTreeHelper.insertOneAtIndexAndSplitArray(
            leafNode.data.elements,
            insertedElement,
            insertIndex
          );

          let leftCount = order / 2;
          let rightCount : Nat = if (order % 2 == 0) { leftCount - 1 } else {
            leftCount
          };

          (
            #promote({
              element = promotedParentElement;
              leftChild = createLeaf<T>(leftElements, leftCount);
              rightChild = createLeaf<T>(rightElements, rightCount)
            })
          )
        }
        // Otherwise, insert at the specified index (shifting elements over if necessary)
        else {
          NodeUtil.insertAtIndexOfNonFullNodeData<T>(leafNode.data, ?insertedElement, insertIndex);
          #inserted
        }
      }
    }
  };

  // Helper for inserting into an internal node
  func internalInsertHelper<T>(internalNode : Internal<T>, order : Nat, compare : (T, T) -> Order.Order, insertElement : T) : IntermediateInsertResult<T> {
    switch (NodeUtil.getElementIndex<T>(internalNode.data, compare, insertElement)) {
      case (#elementFound(insertIndex)) {
        let previous = internalNode.data.elements[insertIndex];
        internalNode.data.elements[insertIndex] := ?insertElement;
        switch (previous) {
          case (?_) { #existent };
          case null {
            Runtime.trap("Bug in Set.internalInsertHelper, element found")
          }; // the binary search already found an element, so this case should never happen
        }
      };
      case (#notFound(insertIndex)) {
        let insertResult = switch (internalNode.children[insertIndex]) {
          case null {
            Runtime.trap("Bug in Set.internalInsertHelper, not found")
          };
          case (?#leaf(leafNode)) {
            leafInsertHelper(leafNode, order, compare, insertElement)
          };
          case (?#internal(internalChildNode)) {
            internalInsertHelper(internalChildNode, order, compare, insertElement)
          }
        };

        switch (insertResult) {
          case (#inserted) #inserted;
          case (#existent) #existent;
          case (#promote({ element = promotedElement; leftChild; rightChild })) {
            // Note: BTree will always have an order >= 4, so this will never have negative Nat overflow
            let maxElements : Nat = order - 1;
            // if current internal node is full, need to split the internal node
            if (internalNode.data.count >= maxElements) {
              // insert and split internal elements, determine new promotion target element
              let (leftElements, promotedParentElement, rightElements) = BTreeHelper.insertOneAtIndexAndSplitArray(
                internalNode.data.elements,
                promotedElement,
                insertIndex
              );

              // calculate the element count in the left elements and the element count in the right elements
              let leftCount = order / 2;
              let rightCount : Nat = if (order % 2 == 0) { leftCount - 1 } else {
                leftCount
              };

              // split internal children
              let (leftChildren, rightChildren) = NodeUtil.splitChildrenInTwoWithRebalances<T>(
                internalNode.children,
                insertIndex,
                leftChild,
                rightChild
              );

              // send the element to be promoted, as well as the internal children left and right split
              #promote({
                element = promotedParentElement;
                leftChild = #internal({
                  data = { elements = leftElements; var count = leftCount };
                  children = leftChildren
                });
                rightChild = #internal({
                  data = { elements = rightElements; var count = rightCount };
                  children = rightChildren
                })
              })
            } else {
              // insert the new elements into the internal node
              NodeUtil.insertAtIndexOfNonFullNodeData(internalNode.data, ?promotedElement, insertIndex);
              // split and re-insert the single child that needs rebalancing
              NodeUtil.insertRebalancedChild(internalNode.children, insertIndex, leftChild, rightChild);
              #inserted
            }
          }
        }
      }
    }
  };

  func createLeaf<T>(elements : [var ?T], count : Nat) : Node<T> {
    #leaf({
      data = {
        elements;
        var count
      }
    })
  };

  // Additional functionality compared to original source.
  func cloneNode<T>(node : Node<T>) : Node<T> {
    switch node {
      case (#leaf _) { node };
      case (#internal { data; children }) {
        let clonedElements = VarArray.map<?T, ?T>(data.elements, func element { element });
        let clonedData = {
          elements = clonedElements;
          var count = data.count
        };
        let clonedChildren = VarArray.map<?Node<T>, ?Node<T>>(
          children,
          func child {
            switch child {
              case null null;
              case (?childNode) ?cloneNode(childNode)
            }
          }
        );
        # internal({
          data = clonedData;
          children = clonedChildren
        })
      }
    }
  };

  module BinarySearch {
    public type SearchResult = {
      #elementFound : Nat;
      #notFound : Nat
    };

    /// Searches an array for a specific element, returning the index it occurs at if #elementFound, or the child/insert index it may occur at
    /// if #notFound. This is used when determining if a element exists in an internal or leaf node, where an element should be inserted in a
    /// leaf node, or which child of an internal node a element could be in.
    ///
    /// Note: This function expects a mutable, nullable, array of elements in sorted order, where all nulls appear at the end of the array.
    /// This function may trap if a null element appears before any elements. It also expects a maxIndex, which is the right-most index (bound)
    /// from which to begin the binary search (the left most bound is expected to be 0)
    ///
    /// Parameters:
    ///
    /// * array - the sorted array that the binary search is performed upon
    /// * compare - the comparator used to perform the search
    /// * searchElement - the element being compared against in the search
    /// * maxIndex - the right-most index (bound) from which to begin the search
    public func binarySearchNode<T>(array : [var ?T], compare : (T, T) -> Order.Order, searchElement : T, maxIndex : Nat) : SearchResult {
      // TODO: get rid of this check?
      // Trap if array is size 0 (should not happen)
      if (array.size() == 0) {
        assert false
      };

      // if all elements in the array are null (i.e. first element is null), return #notFound(0)
      if (maxIndex == 0) {
        return #notFound(0)
      };

      // Initialize search from first to last index
      var left : Nat = 0;
      var right = maxIndex; // maxIndex does not necessarily mean array.size() - 1
      // Search the array
      while (left < right) {
        let middle = (left + right) / 2;
        switch (array[middle]) {
          case null { assert false };
          case (?element) {
            switch (compare(searchElement, element)) {
              // If the element is present at the middle itself
              case (#equal) { return #elementFound(middle) };
              // If element is greater than mid, it can only be present in left subarray
              case (#greater) { left := middle + 1 };
              // If element is smaller than mid, it can only be present in right subarray
              case (#less) {
                right := if (middle == 0) { 0 } else { middle - 1 }
              }
            }
          }
        }
      };

      if (left == array.size()) {
        return #notFound(left)
      };

      // left == right
      switch (array[left]) {
        // inserting at end of array
        case null { #notFound(left) };
        case (?element) {
          switch (compare(searchElement, element)) {
            // if left is the searched element
            case (#equal) { #elementFound(left) };
            // if the element is not found, return notFound and the insert location
            case (#greater) { #notFound(left + 1) };
            case (#less) { #notFound(left) }
          }
        }
      }
    }
  };

  module NodeUtil {
    /// Inserts element at the given index into a non-full leaf node
    public func insertAtIndexOfNonFullNodeData<T>(data : Data<T>, element : ?T, insertIndex : Nat) {
      let currentLastElementIndex : Nat = if (data.count == 0) { 0 } else {
        data.count - 1
      };
      BTreeHelper.insertAtPosition<T>(data.elements, element, insertIndex, currentLastElementIndex);

      // increment the count of data in this node since just inserted an element
      data.count += 1
    };

    /// Inserts two rebalanced (split) child halves into a non-full array of children.
    public func insertRebalancedChild<T>(children : [var ?Node<T>], rebalancedChildIndex : Nat, leftChildInsert : Node<T>, rightChildInsert : Node<T>) {
      // Note: BTree will always have an order >= 4, so this will never have negative Nat overflow
      var j : Nat = children.size() - 2;

      // This is just a sanity check to ensure the children aren't already full (should split promote otherwise)
      // TODO: Remove this check once confident
      if (Option.isSome(children[j + 1])) { assert false };

      // Iterate backwards over the array and shift each element over to the right by one until the rebalancedChildIndex is hit
      while (j > rebalancedChildIndex) {
        children[j + 1] := children[j];
        j -= 1
      };

      // Insert both the left and right rebalanced children (replacing the pre-split child)
      children[j] := ?leftChildInsert;
      children[j + 1] := ?rightChildInsert
    };

    /// Used when splitting the children of an internal node
    ///
    /// Takes in the rebalanced child index, as well as both halves of the rebalanced child and splits the children, inserting the left and right child halves appropriately
    ///
    /// For more context, see the documentation for the splitArrayAndInsertTwo method in ArrayUtils.mo
    public func splitChildrenInTwoWithRebalances<T>(
      children : [var ?Node<T>],
      rebalancedChildIndex : Nat,
      leftChildInsert : Node<T>,
      rightChildInsert : Node<T>
    ) : ([var ?Node<T>], [var ?Node<T>]) {
      BTreeHelper.splitArrayAndInsertTwo<Node<T>>(children, rebalancedChildIndex, leftChildInsert, rightChildInsert)
    };

    /// Helper used to get the element index of of a element within a node
    ///
    /// for more, see the BinarySearch.binarySearchNode() documentation
    public func getElementIndex<T>(data : Data<T>, compare : (T, T) -> Order.Order, element : T) : BinarySearch.SearchResult {
      BinarySearch.binarySearchNode<T>(data.elements, compare, element, data.count)
    };

    // calculates a BTree Node's minimum allowed elements given the order of the BTree
    public func minElementsFromOrder(order : Nat) : Nat {
      if (order % 2 == 0) { order / 2 - 1 } else { order / 2 }
    };

    // Given a node, get the maximum element (right most leaf element)
    public func getMaxElement<T>(node : ?Node<T>) : T {
      switch (node) {
        case (?#leaf({ data })) {
          switch (data.elements[data.count - 1]) {
            case null {
              Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Set.NodeUtil.getMaxElement, data cannot have more elements than it's count")
            };
            case (?element) { element }
          }
        };
        case (?#internal({ data; children })) {
          getMaxElement(children[data.count])
        };
        case null {
          Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Set.NodeUtil.getMaxElement, the node provided cannot be null")
        }
      }
    };

    type InorderBorrowType = {
      #predecessor;
      #successor
    };

    // attempts to retrieve the in max element of the child leaf node directly to the left if the node will allow it
    // returns the deleted max element if able to retrieve, null if not able
    //
    // mutates the predecessing node's elements
    public func borrowFromLeftLeafChild<T>(children : [var ?Node<T>], ofChildIndex : Nat) : ?T {
      let predecessorIndex : Nat = ofChildIndex - 1;
      borrowFromLeafChild(children, predecessorIndex, #predecessor)
    };

    // attempts to retrieve the in max element of the child leaf node directly to the right if the node will allow it
    // returns the deleted max element if able to retrieve, null if not able
    //
    // mutates the predecessing node's elements
    public func borrowFromRightLeafChild<T>(children : [var ?Node<T>], ofChildIndex : Nat) : ?T {
      borrowFromLeafChild(children, ofChildIndex + 1, #successor)
    };

    func borrowFromLeafChild<T>(children : [var ?Node<T>], borrowChildIndex : Nat, childSide : InorderBorrowType) : ?T {
      let minElements = minElementsFromOrder(children.size());

      switch (children[borrowChildIndex]) {
        case (?#leaf({ data })) {
          if (data.count > minElements) {
            // able to borrow an element from this child, so decrement the count of elements
            data.count -= 1; // Since enforce order >= 4, there will always be at least 1 element per node
            switch (childSide) {
              case (#predecessor) {
                let deletedElement = data.elements[data.count];
                data.elements[data.count] := null;
                deletedElement
              };
              case (#successor) {
                ?BTreeHelper.deleteAndShift(data.elements, 0)
              }
            }
          } else { null }
        };
        case _ {
          Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Set.NodeUtil.borrowFromLeafChild, the node at the borrow child index cannot be null or internal")
        }
      }
    };

    type InternalBorrowResult<T> = {
      #borrowed : InternalBorrow<T>;
      #notEnoughElements : Internal<T>
    };

    type InternalBorrow<T> = {
      deletedSiblingElement : ?T;
      child : ?Node<T>
    };

    // Attempts to borrow an element and child from an internal sibling node
    public func borrowFromInternalSibling<T>(children : [var ?Node<T>], borrowChildIndex : Nat, borrowType : InorderBorrowType) : InternalBorrowResult<T> {
      let minElements = minElementsFromOrder(children.size());

      switch (children[borrowChildIndex]) {
        case (?#internal({ data; children })) {
          if (data.count > minElements) {
            data.count -= 1;
            switch (borrowType) {
              case (#predecessor) {
                let deletedSiblingElement = data.elements[data.count];
                data.elements[data.count] := null;
                let child = children[data.count + 1];
                children[data.count + 1] := null;
                #borrowed({
                  deletedSiblingElement;
                  child
                })
              };
              case (#successor) {
                #borrowed({
                  deletedSiblingElement = ?BTreeHelper.deleteAndShift(data.elements, 0);
                  child = ?BTreeHelper.deleteAndShift(children, 0)
                })
              }
            }
          } else { #notEnoughElements({ data; children }) }
        };
        case _ {
          Runtime.trap("UNREACHABLE_ERROR: file a bug report! In Set.NodeUtil.borrowFromInternalSibling from internal sibling, the child at the borrow index cannot be null or a leaf")
        }
      }
    };

    type SiblingSide = { #left; #right };

    // Rotates the borrowed elements and child from sibling side of the internal node to the internal child recipient
    public func rotateBorrowedElementsAndChildFromSibling<T>(
      internalNode : Internal<T>,
      parentRotateIndex : Nat,
      borrowedSiblingElement : ?T,
      borrowedSiblingChild : ?Node<T>,
      internalChildRecipient : Internal<T>,
      siblingSide : SiblingSide
    ) {
      // if borrowing from the left, the rotated element and child will always be inserted first
      // if borrowing from the right, the rotated element and child will always be inserted last
      let (elementIndex, childIndex) = switch (siblingSide) {
        case (#left) { (0, 0) };
        case (#right) {
          (internalChildRecipient.data.count, internalChildRecipient.data.count + 1)
        }
      };

      // get the parent element that will be pushed down the the child
      let elementToBePushedToChild = internalNode.data.elements[parentRotateIndex];
      // replace the parent with the sibling element
      internalNode.data.elements[parentRotateIndex] := borrowedSiblingElement;
      // push the element and child down into the internalChild
      insertAtIndexOfNonFullNodeData<T>(internalChildRecipient.data, elementToBePushedToChild, elementIndex);

      BTreeHelper.insertAtPosition<Node<T>>(internalChildRecipient.children, borrowedSiblingChild, childIndex, internalChildRecipient.data.count)
    };

    // Merges the elements and children of two internal nodes, pushing the parent element in between the right and left halves
    public func mergeChildrenAndPushDownParent<T>(leftChild : Internal<T>, parentElement : ?T, rightChild : Internal<T>) : Internal<T> {
      {
        data = mergeData<T>(leftChild.data, parentElement, rightChild.data);
        children = mergeChildren(leftChild.children, rightChild.children)
      }
    };

    func mergeData<T>(leftData : Data<T>, parentElement : ?T, rightData : Data<T>) : Data<T> {
      assert leftData.count <= minElementsFromOrder(leftData.elements.size() + 1);
      assert rightData.count <= minElementsFromOrder(rightData.elements.size() + 1);

      let mergedElements = VarArray.repeat<?T>(null, leftData.elements.size());
      var i = 0;
      while (i < leftData.count) {
        mergedElements[i] := leftData.elements[i];
        i += 1
      };

      mergedElements[i] := parentElement;
      i += 1;

      var j = 0;
      while (j < rightData.count) {
        mergedElements[i] := rightData.elements[j];
        i += 1;
        j += 1
      };

      {
        elements = mergedElements;
        var count = leftData.count + 1 + rightData.count
      }
    };

    func mergeChildren<T>(leftChildren : [var ?Node<T>], rightChildren : [var ?Node<T>]) : [var ?Node<T>] {
      let mergedChildren = VarArray.repeat<?Node<T>>(null, leftChildren.size());
      var i = 0;

      while (Option.isSome(leftChildren[i])) {
        mergedChildren[i] := leftChildren[i];
        i += 1
      };

      var j = 0;
      while (Option.isSome(rightChildren[j])) {
        mergedChildren[i] := rightChildren[j];
        i += 1;
        j += 1
      };

      mergedChildren
    }
  }
}
