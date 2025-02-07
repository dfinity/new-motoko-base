/// Original: `OrderedMap.mo`

import Order "../Order";
import Iter "../Iter";
import Types "../Types";
import Runtime "../Runtime";
import { todo } "../Debug"; //DELETE ME

module {

  public type Map<K, V> = Types.Immutable.Map<K, V>;
  public type Tree<K, V> = Types.Immutable.Tree<K, V>;

  public func empty<K, V>() : Map<K, V> {
    Internal.empty<K, V>();
  };


  public func isEmpty<K, V>(map : Map<K, V>) : Bool {
    map.size == 0
  };

  /// Determine the size of the map as the number of key-value entries.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/immutable/Map";
  /// import Nat "mo:base/Nat";
  /// import Iter "mo:base/Iter";
  /// import Debug "mo:base/Debug";
  ///
  /// let map = natMap.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]));
  ///
  /// Debug.print(debug_show(natMap.size(map)));
  /// // 3
  /// ```
  ///
  /// Runtime: `O(n)`.
  /// Space: `O(1)`.
  public func size<K, V>(map : Map<K, V>) : Nat
    = map.size;


  /// Test whether the map `map`, ordered by `compare` contains any binding for the given `key`.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/OrderedMap";
  /// import Nat "mo:base/Nat";
  /// import Iter "mo:base/Iter";
  /// import Debug "mo:base/Debug";
  ///
  /// let map = natMap.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]), Nat.compare);
  ///
  /// Debug.print(debug_show natMap.contains(map, 1)); // => true
  /// Debug.print(debug_show natMap.contains(map, 42)); // => false
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(1)`.
  /// where `n` denotes the number of key-value entries stored in the map and
  /// assuming that the `compare` function implements an `O(1)` comparison.
  public func containsKey<K, V>(map : Map<K, V>, compare : (K, K) -> Types.Order, key : K) : Bool
    = Internal.contains(map.root, compare, key);

  /// Given, `map` ordered by `compare`, return the value associated with key `key` if present and `null` otherwise.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/immutable/Map";
  /// import Nat "mo:base/Nat";
  /// import Iter "mo:base/Iter";
  /// import Debug "mo:base/Debug";
  ///
  /// let map = natMap.fromIter<Text>(Iter.fromArray([(0, "Zero"), (2, "Two"), (1, "One")]), Nat.compare);
  ///
  /// Debug.print(debug_show(natMap.get(map, Nat.compare, 1)));
  /// Debug.print(debug_show(natMap.get(map, Nat.compare, 42)));
  ///
  /// // ?"One"
  /// // null
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(1)`.
  /// where `n` denotes the number of key-value entries stored in the map and
  /// assuming that the `compare` function implements an `O(1)` comparison.
  public func get<K, V>(map : Map<K, V>, compare : (K, K) -> Types.Order, key : K) : ?V
    = Internal.get(map.root, compare, key);

  /// Given `map` ordered by `compare`, add a mapping from `key` to `value`. Overwrites any existing entry with key `key`.
  /// Returns a modified map.
  ///
  /// Example:
  /// ```motoko
  /// import Map "mo:base/immutable/Map";
  /// import Nat "mo:base/Nat";
  /// import Iter "mo:base/Iter";
  /// import Debug "mo:base/Debug";
  ///
  /// var map = Map.empty<Nat, Text>();
  ///
  /// map := natMap.add(map, Nat.compare, 0, "Zero");
  /// map := natMap.add(map, Nat.compare, 2, "Two");
  /// map := natMap.add(map, Nat.compare, 1, "One");
  ///
  /// Debug.print(debug_show(Iter.toArray(map.entries(map))));
  ///
  /// // [(0, "Zero"), (1, "One"), (2, "Two")]
  /// ```
  ///
  /// Runtime: `O(log(n))`.
  /// Space: `O(log(n))`.
  /// where `n` denotes the number of key-value entries stored in the map and
  /// assuming that the `compare` function implements an `O(1)` comparison.
  ///
  /// Note: The returned map shares with the `m` most of the tree nodes.
  /// Garbage collecting one of maps (e.g. after an assignment `m := Map.add(m, cmp, k, v)`)
  /// causes collecting `O(log(n))` nodes.
  public func add<K, V>(map : Map<K, V>, compare : (K, K) -> Types.Order, key : K, value : V) : Map<K, V> {
    put(map, compare, key, value).0
  };

  /// @deprecated: do we want to call put replace or exchange?
  public func put<K, V>(map : Map<K, V>, compare : (K, K) -> Types.Order, key : K, value : V) : (Map<K, V>, ?V) {
     switch (Internal.replace(map.root, compare, key, value)) {
        case (t, null) { ({root = t; size = map.size + 1}, null) };
        case (t, v)    { ({root = t; size = map.size}, v)}
      }
   };


  public func delete<K, V>(map : Map<K, V>, compare : (K, K) -> Types.Order, key : K) : Map<K, V> {
    todo()
  };

  public func take<K, V>(map : Map<K, V>, compare : (K, K) -> Types.Order, key : K) : (Map<K, V>, ?V) {
    todo()
  };

  public func maxEntry<K, V>(map : Map<K, V>) : ?(K, V) {
    todo()
  };

  public func minEntry<K, V>(map : Map<K, V>) : ?(K, V) {
    todo()
  };

  public func entries<K, V>(map : Map<K, V>) : Types.Iter<(K, V)> {
    todo()
  };

  public func reverseEntries<K, V>(map : Map<K, V>) : Types.Iter<(K, V)> {
    todo()
  };

  public func keys<K, V>(map : Map<K, V>) : Types.Iter<K> {
    todo()
  };

  public func values<K, V>(map : Map<K, V>) : Types.Iter<V> {
    todo()
  };

  public func fromIter<K, V>(iter : Types.Iter<(K, V)>, compare : (K, K) -> Types.Order) : Map<K, V> {
    todo()
  };

  public func map<K, V1, V2>(map : Map<K, V1>, f : (K, V1) -> V2) : Map<K, V2> {
    todo()
  };

  public func foldLeft<K, V, A>(
    map : Map<K, V>,
    base : A,
    combine : (A, K, V) -> A
  ) : A {
    todo()
  };

  public func foldRight<K, V, A>(
    map : Map<K, V>,
    base : A,
    combine : (K, V, A) -> A
  ) : A {
    todo()
  };

  public func all<K, V>(map : Map<K, V>, pred : (K, V) -> Bool) : Bool {
    todo()
  };

  public func any<K, V>(map : Map<K, V>, pred : (K, V) -> Bool) : Bool {
    todo()
  };

  public func filterMap<K, V1, V2>(map : Map<K, V1>, f : (K, V1) -> ?V2) : Map<K, V2> {
    todo()
  };

  public func assertValid<K, V>(map : Map<K, V>, compare : (K, K) -> Types.Order) : () {
    todo()
  };

  public func toText<K, V>(set : Map<K, V>, kf : K -> Text, vf : V -> Text) : Text {
    todo()
  };



  module Internal {

    public func empty<K, V>() : Map<K, V> {
      { size = 0; root = #leaf }
    };

    public func fromIter<K, V>(i : Types.Iter<(K,V)>, compare : (K, K) -> Types.Order) : Map<K, V> {
      var map = #leaf : Tree<K, V>;
      var size = 0;
      for(val in i) {
        map := put(map, compare, val.0, val.1);
        size += 1;
      };
      {root = map; size}
    };

    type List<T> = ?(T, List<T>); // TODO: revisit later

    type IterRep<K, V> = List<{ #tr : Tree<K, V>; #xy : (K, V) }>;

    public func iter<K, V>(map : Tree<K, V>, direction : { #fwd; #bwd }) : Types.Iter<(K, V)> {
      let turnLeftFirst : MapTraverser<K, V> = func(l, x, y, r, ts) {
        ?(#tr(l), ?(#xy(x, y), ?(#tr(r), ts)))
      };

      let turnRightFirst : MapTraverser<K, V> = func(l, x, y, r, ts) {
        ?(#tr(r), ?(#xy(x, y), ?(#tr(l), ts)))
      };

      switch direction {
        case (#fwd) IterMap(map, turnLeftFirst);
        case (#bwd) IterMap(map, turnRightFirst)
      }
    };

    type MapTraverser<K, V> = (Tree<K, V>, K, V, Tree<K, V>, IterRep<K, V>) -> IterRep<K, V>;

    class IterMap<K, V>(tree : Tree<K, V>, mapTraverser : MapTraverser<K, V>) {
      var trees : IterRep<K, V> = ?(#tr(tree), null);
      public func next() : ?(K, V) {
        switch (trees) {
          case (null) { null };
          case (?(#tr(#leaf), ts)) {
            trees := ts;
            next()
          };
          case (?(#xy(xy), ts)) {
            trees := ts;
            ?xy
          };
          case (?(#tr(#red(l, x, y, r)), ts)) {
            trees := mapTraverser(l, x, y, r, ts);
            next()
          };
          case (?(#tr(#black(l, x, y, r)), ts)) {
            trees := mapTraverser(l, x, y, r, ts);
            next()
          }
        }
      }
    };

    public func map<K, V1, V2>(map : Map<K, V1>, f : (K, V1) -> V2) : Map<K, V2> {
      func mapRec(m : Tree<K, V1>) : Tree<K, V2> {
        switch m {
          case (#leaf) { #leaf };
          case (#red(l, x, y, r)) {
            #red(mapRec l, x, f(x, y), mapRec r)
          };
          case (#black(l, x, y, r)) {
            #black(mapRec l, x, f(x, y), mapRec r)
          }
        }
      };
      { size = map.size; root = mapRec(map.root) }
    };

    public func foldLeft<Key, Value, Accum>(
      map : Tree<Key, Value>,
      base : Accum,
      combine : (Accum, Key, Value) -> Accum
    ) : Accum {
      switch (map) {
        case (#leaf) { base };
        case (#red(l, k, v, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(left, k, v);
          foldLeft(r, middle, combine)
        };
        case (#black(l, k, v, r)) {
          let left = foldLeft(l, base, combine);
          let middle = combine(left, k, v);
          foldLeft(r, middle, combine)
        }
      }
    };

    public func foldRight<Key, Value, Accum>(
      map : Tree<Key, Value>,
      base : Accum,
      combine : (Key, Value, Accum) -> Accum
    ) : Accum {
      switch (map) {
        case (#leaf) { base };
        case (#red(l, k, v, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(k, v, right);
          foldRight(l, middle, combine)
        };
        case (#black(l, k, v, r)) {
          let right = foldRight(r, base, combine);
          let middle = combine(k, v, right);
          foldRight(l, middle, combine)
        }
      }
    };

    public func mapFilter<K, V1, V2>(map : Map<K, V1>, compare : (K, K) -> Types.Order, f : (K, V1) -> ?V2) : Map<K, V2> {
      var size = 0;
      func combine(acc : Tree<K, V2>, key : K, value1 : V1) : Tree<K, V2> {
        switch (f(key, value1)) {
          case null { acc };
          case (?value2) {
            size += 1;
            put(acc, compare, key, value2)
          }
        }
      };
      { root = foldLeft(map.root, #leaf, combine); size }
    };

    public func get<K, V>(t : Tree<K, V>, compare : (K, K) -> Types.Order, x : K) : ?V {
      switch t {
        case (#red(l, x1, y1, r)) {
          switch (compare(x, x1)) {
            case (#less) { get(l, compare, x) };
            case (#equal) { ?y1 };
            case (#greater) { get(r, compare, x) }
          }
        };
        case (#black(l, x1, y1, r)) {
          switch (compare(x, x1)) {
            case (#less) { get(l, compare, x) };
            case (#equal) { ?y1 };
            case (#greater) { get(r, compare, x) }
          }
        };
        case (#leaf) { null }
      }
    };

    public func contains<K, V>(m : Tree<K, V>, compare : (K, K) -> Types.Order, key : K) : Bool {
      switch (get(m, compare, key)) {
        case(null) { false }; 
        case(_)    { true } 
      }
    };

    public func maxEntry<K, V>(m : Tree<K, V>) : ?(K, V) {
      func rightmost(m : Tree<K, V>) : (K, V) {
        switch m {
          case (#red(_, k, v, #leaf))   { (k, v) };
          case (#red(_, _, _, r))       { rightmost(r) };
          case (#black(_, k, v, #leaf)) { (k, v) };
          case (#black(_, _, _, r))     { rightmost(r) };
          case (#leaf)                  { Runtime.trap "OrderedMap.impossible" }
        }
      };
      switch m {
        case (#leaf) { null };
        case (_)     { ?rightmost(m) }
      }
    };

    public func minEntry<K, V>(m : Tree<K, V>) : ?(K, V) {
      func leftmost(m : Tree<K, V>) : (K, V) {
        switch m {
          case (#red(#leaf, k, v, _))   { (k, v) };
          case (#red(l, _, _, _))       { leftmost(l) };
          case (#black(#leaf, k, v, _)) { (k, v) };
          case (#black(l, _, _, _))     { leftmost(l)};
          case (#leaf)                  { Runtime.trap "OrderedMap.impossible" }
        }
      };
      switch m {
        case (#leaf) { null };
        case (_)     { ?leftmost(m) }
      }
    };

    public func all<K, V>(m : Tree<K, V>, pred : (K, V) -> Bool) : Bool {
      switch m {
        case (#red(l, k, v, r)) {
          pred(k, v) and all(l, pred) and all(r, pred)
        };
        case (#black(l, k, v, r)) {
          pred(k, v) and all(l, pred) and all(r, pred)
        };
        case (#leaf) { true }
      }
    };

    public func some<K, V>(m : Tree<K, V>, pred : (K, V) -> Bool) : Bool {
      switch m {
        case (#red(l, k, v, r)) {
          pred(k, v) or some(l, pred) or some(r, pred)
        };
        case (#black(l, k, v, r)) {
          pred(k, v) or some(l, pred) or some(r, pred)
        };
        case (#leaf) { false }
      }
    };

    func redden<K, V>(t : Tree<K, V>) : Tree<K, V> {
      switch t {
        case (#black (l, x, y, r)) {
          (#red (l, x, y, r))
        };
        case _ {
          Runtime.trap "OrderedMap.red"
        }
      }
    };

    func lbalance<K, V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (#red(#red(l1, x1, y1, r1), x2, y2, r2), r) {
          #red(
            #black(l1, x1, y1, r1),
            x2,
            y2,
            #black(r2, x, y, r)
          )
        };
        case (#red(l1, x1, y1, #red(l2, x2, y2, r2)), r) {
          #red(
            #black(l1, x1, y1, l2),
            x2,
            y2,
            #black(r2, x, y, r)
          )
        };
        case _ {
          #black(left, x, y, right)
        }
      }
    };

    func rbalance<K, V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (l, #red(l1, x1, y1, #red(l2, x2, y2, r2))) {
          #red(
            #black(l, x, y, l1),
            x1,
            y1,
            #black(l2, x2, y2, r2)
          )
        };
        case (l, #red(#red(l1, x1, y1, r1), x2, y2, r2)) {
          #red(
            #black(l, x, y, l1),
            x1,
            y1,
            #black(r1, x2, y2, r2)
          )
        };
        case _ {
          #black(left, x, y, right)
        }
      }
    };

    type ClashResolver<A> = { old : A; new : A } -> A;

    func insertWith<K, V>(
      m : Tree<K, V>,
      compare : (K, K) -> Types.Order,
      key : K,
      val : V,
      onClash : ClashResolver<V>
    ) : Tree<K, V> {
      func ins(tree : Tree<K, V>) : Tree<K, V> {
        switch tree {
          case (#black(left, x, y, right)) {
            switch (compare(key, x)) {
              case (#less) {
                lbalance(ins left, x, y, right)
              };
              case (#greater) {
                rbalance(left, x, y, ins right)
              };
              case (#equal) {
                let newVal = onClash({ new = val; old = y });
                #black(left, key, newVal, right)
              }
            }
          };
          case (#red(left, x, y, right)) {
            switch (compare(key, x)) {
              case (#less) {
                #red(ins left, x, y, right)
              };
              case (#greater) {
                #red(left, x, y, ins right)
              };
              case (#equal) {
                let newVal = onClash { new = val; old = y };
                #red(left, key, newVal, right)
              }
            }
          };
          case (#leaf) {
            #red(#leaf, key, val, #leaf)
          }
        }
      };
      switch (ins m) {
        case (#red(left, x, y, right)) {
          #black(left, x, y, right)
        };
        case other { other }
      }
    };

    public func replace<K, V>(
      m : Tree<K, V>,
      compare : (K, K) -> Types.Order,
      key : K,
      val : V
    ) : (Tree<K, V>, ?V) {
      var oldVal : ?V = null;
      func onClash(clash : { old : V; new : V }) : V {
        oldVal := ?clash.old;
        clash.new
      };
      let res = insertWith(m, compare, key, val, onClash);
      (res, oldVal)
    };

    public func put<K, V>(
      m : Tree<K, V>,
      compare : (K, K) -> Types.Order,
      key : K,
      val : V
    ) : Tree<K, V> = replace(m, compare, key, val).0;

    func balLeft<K, V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (#red(l1, x1, y1, r1), r) {
          #red(
            #black(l1, x1, y1, r1),
            x,
            y,
            r
          )
        };
        case (_, #black(l2, x2, y2, r2)) {
          rbalance(left, x, y, #red(l2, x2, y2, r2))
        };
        case (_, #red(#black(l2, x2, y2, r2), x3, y3, r3)) {
          #red(
            #black(left, x, y, l2),
            x2,
            y2,
            rbalance(r2, x3, y3, redden r3)
          )
        };
        case _ { Runtime.trap "balLeft" }
      }
    };

    func balRight<K, V>(left : Tree<K, V>, x : K, y : V, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (l, #red(l1, x1, y1, r1)) {
          #red(
            l,
            x,
            y,
            #black(l1, x1, y1, r1)
          )
        };
        case (#black(l1, x1, y1, r1), r) {
          lbalance(#red(l1, x1, y1, r1), x, y, r)
        };
        case (#red(l1, x1, y1, #black(l2, x2, y2, r2)), r3) {
          #red(
            lbalance(redden l1, x1, y1, l2),
            x2,
            y2,
            #black(r2, x, y, r3)
          )
        };
        case _ { Runtime.trap "balRight" }
      }
    };

    func append<K, V>(left : Tree<K, V>, right : Tree<K, V>) : Tree<K, V> {
      switch (left, right) {
        case (#leaf, _) { right };
        case (_, #leaf) { left };
        case (
          #red(l1, x1, y1, r1),
          #red(l2, x2, y2, r2)
        ) {
          switch (append(r1, l2)) {
            case (#red(l3, x3, y3, r3)) {
              #red(
                #red(l1, x1, y1, l3),
                x3,
                y3,
                #red(r3, x2, y2, r2)
              )
            };
            case r1l2 {
              #red(l1, x1, y1, #red(r1l2, x2, y2, r2))
            }
          }
        };
        case (t1, #red(l2, x2, y2, r2)) {
          #red(append(t1, l2), x2, y2, r2)
        };
        case (#red(l1, x1, y1, r1), t2) {
          #red(l1, x1, y1, append(r1, t2))
        };
        case (#black(l1, x1, y1, r1), #black(l2, x2, y2, r2)) {
          switch (append(r1, l2)) {
            case (#red(l3, x3, y3, r3)) {
              #red(
                #black(l1, x1, y1, l3),
                x3,
                y3,
                #black(r3, x2, y2, r2)
              )
            };
            case r1l2 {
              balLeft(
                l1,
                x1,
                y1,
                #black(r1l2, x2, y2, r2)
              )
            }
          }
        }
      }
    };

    public func delete<K, V>(m : Tree<K, V>, compare : (K, K) -> Types.Order, key : K) : Tree<K, V>
      = remove(m, compare, key).0;

    public func remove<K, V>(tree : Tree<K, V>, compare : (K, K) -> Types.Order, x : K) : (Tree<K, V>, ?V) {
      var y0 : ?V = null;
      func delNode(left : Tree<K, V>, x1 : K, y1 : V, right : Tree<K, V>) : Tree<K, V> {
        switch (compare(x, x1)) {
          case (#less) {
            let newLeft = del left;
            switch left {
              case (#black(_, _, _, _)) {
                balLeft(newLeft, x1, y1, right)
              };
              case _ {
                #red(newLeft, x1, y1, right)
              }
            }
          };
          case (#greater) {
            let newRight = del right;
            switch right {
              case (#black(_, _, _, _)) {
                balRight(left, x1, y1, newRight)
              };
              case _ {
                #red(left, x1, y1, newRight)
              }
            }
          };
          case (#equal) {
            y0 := ?y1;
            append(left, right)
          }
        }
      };
      func del(tree : Tree<K, V>) : Tree<K, V> {
        switch tree {
          case (#red(left, x, y, right)) {
            delNode(left, x, y, right)
          };
          case (#black(left, x, y, right)) {
            delNode(left, x, y, right)
          };
          case (#leaf) {
            tree
          }
        }
      };
      switch (del(tree)) {
        case (#red(left, x, y, right)) {
          (#black(left, x, y, right), y0)
        };
        case other { (other, y0) }
      }
    };

    // Test helper
    public func validate<K, V>(rbMap : Map<K, V>, comp : (K, K) -> Types.Order) {
      ignore blackDepth(rbMap.root, comp)
    };

    func blackDepth<K, V>(node : Tree<K, V>, comp : (K, K) -> Types.Order) : Nat {
      func checkNode(left : Tree<K, V>, key : K, right : Tree<K, V>) : Nat {
        checkKey(left, func(x : K) : Bool { comp(x, key) == #less });
        checkKey(right, func(x : K) : Bool { comp(x, key) == #greater });
        let leftBlacks = blackDepth(left, comp);
        let rightBlacks = blackDepth(right, comp);
        assert (leftBlacks == rightBlacks);
        leftBlacks
      };
      switch node {
        case (#leaf) 0;
        case (#red(left, key, _, right)) {
          let leftBlacks = checkNode(left, key, right);
          assert (not isRed(left));
          assert (not isRed(right));
          leftBlacks
        };
        case (#black(left, key, _, right)) {
          checkNode(left, key, right) + 1
        }
      }
    };

    func isRed<K, V>(node : Tree<K, V>) : Bool {
      switch node {
        case (#red(_, _, _, _)) true;
        case _ false
      }
    };

    func checkKey<K, V>(node : Tree<K, V>, isValid : K -> Bool) {
      switch node {
        case (#leaf) {};
        case (#red(_, key, _, _)) {
          assert (isValid(key))
        };
        case (#black(_, key, _, _)) {
          assert (isValid(key))
        }
      }
    };
  };


}
