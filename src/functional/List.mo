/// Purely-functional, singly-linked lists.

import Array "Array";
import Iter "IterType";
import Option "Option";
import Order "Order";
import Result "Result";

module {
  public type List<T> = ?(T, List<T>);

  public func nil<T>() : List<T> = null;

  public func isNil<T>(l : List<T>) : Bool = l == null;

  public func push<T>(x : T, l : List<T>) : List<T> = ?(x, l);

  public func last<T>(l : List<T>) : ?T {
    switch l {
      case null { null };
      case (?(x, null)) { ?x };
      case (?(_, t)) { last<T>(t) }
    }
  };

  public func pop<T>(l : List<T>) : (?T, List<T>) {
    switch l {
      case null { (null, null) };
      case (?(h, t)) { (?h, t) }
    }
  };

  public func size<T>(l : List<T>) : Nat {
    func rec(l : List<T>, n : Nat) : Nat {
      switch l {
        case null { n };
        case (?(_, t)) { rec(t, n + 1) }
      }
    };
    rec(l, 0)
  };
  public func get<T>(l : List<T>, n : Nat) : ?T {
    switch (n, l) {
      case (_, null) { null };
      case (0, (?(h, _))) { ?h };
      case (_, (?(_, t))) { get<T>(t, n - 1) }
    }
  };

  public func reverse<T>(l : List<T>) : List<T> {
    func rec(l : List<T>, r : List<T>) : List<T> {
      switch l {
        case null { r };
        case (?(h, t)) { rec(t, ?(h, r)) }
      }
    };
    rec(l, null)
  };

  public func iterate<T>(l : List<T>, f : T -> ()) {
    switch l {
      case null { () };
      case (?(h, t)) { f(h); iterate<T>(t, f) }
    }
  };

  public func map<T, U>(l : List<T>, f : T -> U) : List<U> {
    switch l {
      case null { null };
      case (?(h, t)) { ?(f(h), map<T, U>(t, f)) }
    }
  };

  public func filter<T>(l : List<T>, f : T -> Bool) : List<T> {
    switch l {
      case null { null };
      case (?(h, t)) {
        if (f(h)) {
          ?(h, filter<T>(t, f))
        } else {
          filter<T>(t, f)
        }
      }
    }
  };

  public func partition<T>(l : List<T>, f : T -> Bool) : (List<T>, List<T>) {
    switch l {
      case null { (null, null) };
      case (?(h, t)) {
        if (f(h)) {
          let (l, r) = partition<T>(t, f);
          (?(h, l), r)
        } else {
          let (l, r) = partition<T>(t, f);
          (l, ?(h, r))
        }
      }
    }
  };

  public func mapFilter<T, U>(l : List<T>, f : T -> ?U) : List<U> {
    switch l {
      case null { null };
      case (?(h, t)) {
        switch (f(h)) {
          case null { mapFilter<T, U>(t, f) };
          case (?h_) { ?(h_, mapFilter<T, U>(t, f)) }
        }
      }
    }
  };

  public func mapResult<T, R, E>(xs : List<T>, f : T -> Result.Result<R, E>) : Result.Result<List<R>, E> {
    func go(xs : List<T>, acc : List<R>) : Result.Result<List<R>, E> {
      switch xs {
        case null { #ok(acc) };
        case (?(head, tail)) {
          switch (f(head)) {
            case (#err(err)) { #err(err) };
            case (#ok(ok)) { go(tail, ?(ok, acc)) }
          }
        }
      }
    };
    Result.mapOk(go(xs, null), func(xs : List<R>) : List<R> = reverse(xs))
  };

  func revAppend<T>(l : List<T>, m : List<T>) : List<T> {
    switch l {
      case null { m };
      case (?(h, t)) { revAppend(t, ?(h, m)) }
    }
  };

  public func append<T>(l : List<T>, m : List<T>) : List<T> {
    revAppend(reverse(l), m)
  };

  public func flatten<T>(l : List<List<T>>) : List<T> {
    foldLeft<List<T>, List<T>>(l, null, func(a, b) { append<T>(a, b) })
  };

  public func take<T>(l : List<T>, n : Nat) : List<T> {
    switch (l, n) {
      case (_, 0) { null };
      case (null, _) { null };
      case (?(h, t), m) { ?(h, take<T>(t, m - 1)) }
    }
  };

  public func drop<T>(l : List<T>, n : Nat) : List<T> {
    switch (l, n) {
      case (l_, 0) { l_ };
      case (null, _) { null };
      case ((?(_, t)), m) { drop<T>(t, m - 1) }
    }
  };

  public func foldLeft<T, S>(list : List<T>, base : S, combine : (S, T) -> S) : S {
    switch list {
      case null { base };
      case (?(h, t)) { foldLeft(t, combine(base, h), combine) }
    }
  };

  public func foldRight<T, S>(list : List<T>, base : S, combine : (T, S) -> S) : S {
    switch list {
      case null { base };
      case (?(h, t)) { combine(h, foldRight<T, S>(t, base, combine)) }
    }
  };

  public func find<T>(l : List<T>, f : T -> Bool) : ?T {
    switch l {
      case null { null };
      case (?(h, t)) { if (f(h)) { ?h } else { find<T>(t, f) } }
    }
  };

  public func some<T>(l : List<T>, f : T -> Bool) : Bool {
    switch l {
      case null { false };
      case (?(h, t)) { f(h) or some<T>(t, f) }
    }
  };

  public func all<T>(l : List<T>, f : T -> Bool) : Bool {
    switch l {
      case null { true };
      case (?(h, t)) { f(h) and all<T>(t, f) }
    }
  };

  public func merge<T>(l1 : List<T>, l2 : List<T>, lessThanOrEqual : (T, T) -> Bool) : List<T> {
    switch (l1, l2) {
      case (null, _) { l2 };
      case (_, null) { l1 };
      case (?(h1, t1), ?(h2, t2)) {
        if (lessThanOrEqual(h1, h2)) {
          ?(h1, merge<T>(t1, l2, lessThanOrEqual))
        } else {
          ?(h2, merge<T>(l1, t2, lessThanOrEqual))
        }
      }
    }
  };

  private func compareAux<T>(l1 : List<T>, l2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
    switch (l1, l2) {
      case (null, null) { #equal };
      case (null, _) { #less };
      case (_, null) { #greater };
      case (?(h1, t1), ?(h2, t2)) {
        switch (compare(h1, h2)) {
          case (#equal) { compareAux<T>(t1, t2, compare) };
          case other { other }
        }
      }
    }
  };

  public func compare<T>(l1 : List<T>, l2 : List<T>, compare : (T, T) -> Order.Order) : Order.Order {
     compareAux<T>(l1, l2, compare);
  };

  private func equalAux<T>(l1 : List<T>, l2 : List<T>, equal : (T, T) -> Bool) : Bool {
    switch (l1, l2) {
      case (?(h1, t1), ?(h2, t2)) {
        equal(h1, h2) and equalAux<T>(t1, t2, equal)
      };
      case (null, null) { true };
      case _ { false };
    }
  };
  public func equal<T>(l1 : List<T>, l2 : List<T>, equal : (T, T) -> Bool) : Bool {
    equalAux<T>(l1, l2, equal);
  };

  public func tabulate<T>(n : Nat, f : Nat -> T) : List<T> {
    var i = 0;
    var l : List<T> = null;
    while (i < n) {
      l := ?(f(i), l);
      i += 1
    };
    reverse(l)
  };

  public func make<T>(x : T) : List<T> = ?(x, null);

  public func replicate<T>(n : Nat, x : T) : List<T> {
    var i = 0;
    var l : List<T> = null;
    while (i < n) {
      l := ?(x, l);
      i += 1
    };
    l
  };

  public func zip<T, U>(xs : List<T>, ys : List<U>) : List<(T, U)> = zipWith<T, U, (T, U)>(xs, ys, func(x, y) { (x, y) });

  public func zipWith<T, U, V>(
    xs : List<T>,
    ys : List<U>,
    f : (T, U) -> V
  ) : List<V> {
    switch (pop<T>(xs)) {
      case (null, _) { null };
      case (?x, xt) {
        switch (pop<U>(ys)) {
          case (null, _) { null };
          case (?y, yt) {
            push<V>(f(x, y), zipWith<T, U, V>(xt, yt, f))
          }
        }
      }
    }
  };

  public func split<T>(n : Nat, xs : List<T>) : (List<T>, List<T>) {
    if (n == 0) { (null, xs) } else {
      func rec(n : Nat, xs : List<T>) : (List<T>, List<T>) {
        switch (pop<T>(xs)) {
          case (null, _) { (null, null) };
          case (?h, t) {
            if (n == 1) { (make<T>(h), t) } else {
              let (l, r) = rec(n - 1, t);
              (push<T>(h, l), r)
            }
          }
        }
      };
      rec(n, xs)
    }
  };

  public func chunks<T>(n : Nat, xs : List<T>) : List<List<T>> {
    let (l, r) = split<T>(n, xs);
    if (isNil<T>(l)) {
      null
    } else {
      push<List<T>>(l, chunks<T>(n, r))
    }
  };

  public func fromArray<T>(xs : [T]) : List<T> {
    Array.foldRight<T, List<T>>(
      xs,
      null,
      func(x : T, ys : List<T>) : List<T> {
        push<T>(x, ys)
      }
    )
  };

  public func fromVarArray<T>(xs : [var T]) : List<T> = fromArray<T>(Array.freeze<T>(xs));

  public func toArray<T>(xs : List<T>) : [T] {
    let length = size<T>(xs);
    var list = xs;
    Array.tabulate<T>(
      length,
      func(i) {
        let popped = pop<T>(list);
        list := popped.1;
        switch (popped.0) {
          case null { loop { assert false } };
          case (?x) x
        }
      }
    )
  };

  public func toVarArray<T>(xs : List<T>) : [var T] = Array.thaw<T>(toArray<T>(xs));

  public func toIter<T>(xs : List<T>) : Iter.Iter<T> {
    var state = xs;
    object {
      public func next() : ?T = switch state {
        case (?(hd, tl)) { state := tl; ?hd };
        case _ null
      }
    }
  }

}