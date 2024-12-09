/// Original: `OrderedMap.mo`

import Order "Order";
import { nyi = todo } "Debug";

module {

  type Map<K, V> = (); // Placeholder

  public func containsKey<K, V>(map : Map<K, V>, key : K, compare : (K, K) -> Order.Order) : Bool = todo();

  public func get<K, V>(map : Map<K, V>, key : K, compare : (K, K) -> Order.Order) : ?V = todo();

  public func put<K, V>(map : Map<K, V>, key : K, value : V, compare : (K, K) -> Order.Order) : Bool = todo();

  public func remove<K, V>(map : Map<K, V>, key : K, compare : (K, K) -> Order.Order) : ?V = todo();

  // ...
}
