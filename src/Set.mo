/// Original: `OrderedSet.mo`

import Order "Order";
import { nyi = todo } "Debug";

module {
  type Set<T> = (); // Placeholder

  public func contains<T>(set : Set<T>, item : T, compare : (T, T) -> Order.Order) : Bool = todo();

  public func get<T>(set : Set<T>, index : Nat, compare : (T, T) -> Order.Order) : T = todo();

  // ...
}
