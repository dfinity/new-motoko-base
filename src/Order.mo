/// Utilities for `Order` (comparison between two values)

import { todo } "Debug";
import Iter "IterType";

module {

  public type Order = {
    #less;
    #equal;
    #greater
  };

  public func equal(o1 : Order, o2 : Order) : Bool {
    o1 == o2
  };

  public func allValues() : Iter.Iter<Order> {
    todo()
  };

}
