/// Original: `OrderedMap.mo`

import Order "../Order";
import Iter "../Iter";
import { todo } "../Debug";

module {

  public type Map<K, V> = (); // Placeholder

  public func empty<K, V>() : Map<K, V> {
    todo()
  };

  public func isEmpty<K, V>(map : Map<K, V>) : Bool {
    todo()
  };

  public func size<K, V>(map : Map<K, V>) : Nat {
    todo()
  };

  public func containsKey<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K) : Bool {
    todo()
  };

  public func get<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K) : ?V {
    todo()
  };

  public func add<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K, value : V) : Map<K, V> {
    todo()
  };

  public func put<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K, value : V) : (Map<K, V>, ?V) {
    todo()
  };

  public func delete<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K) : Map<K, V> {
    todo()
  };

  public func take<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order, key : K) : (Map<K, V>, ?V) {
    todo()
  };

  public func maxEntry<K, V>(map : Map<K, V>) : ?(K, V) {
    todo()
  };

  public func minEntry<K, V>(map : Map<K, V>) : ?(K, V) {
    todo()
  };

  public func entries<K, V>(map : Map<K, V>) : Iter.Iter<(K, V)> {
    todo()
  };

  public func reverseEntries<K, V>(map : Map<K, V>) : Iter.Iter<(K, V)> {
    todo()
  };

  public func keys<K, V>(map : Map<K, V>) : Iter.Iter<K> {
    todo()
  };

  public func values<K, V>(map : Map<K, V>) : Iter.Iter<V> {
    todo()
  };

  public func fromIter<K, V>(iter : Iter.Iter<(K, V)>, compare : (K, K) -> Order.Order) : Map<K, V> {
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

  public func assertValid<K, V>(map : Map<K, V>, compare : (K, K) -> Order.Order) : () {
    todo()
  };

  public func toText<K, V>(set : Map<K, V>, kf : K -> Text, vf : V -> Text) : Text {
    todo()
  };

}
