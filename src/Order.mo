/// Utilities for `Order` (comparison between two values).

import Types "Types";
import { todo } "Debug";

module {

  /// A type to represent an order.
  public type Order = Types.Order;

  /// Check if an order is #less.
  public func isLess(order : Order) : Bool {
    switch order {
      case (#less) { true };
      case _ { false }
    }
  };

  /// Check if an order is #equal.
  public func isEqual(order : Order) : Bool {
    switch order {
      case (#equal) { true };
      case _ { false }
    }
  };

  /// Check if an order is #greater.
  public func isGreater(order : Order) : Bool {
    switch order {
      case (#greater) { true };
      case _ { false }
    }
  };

  /// Returns true if only if  `order1` and `order2` are the same.
  public func equal(order1 : Order, order2 : Order) : Bool {
    switch (order1, order2) {
      case (#less, #less) { true };
      case (#equal, #equal) { true };
      case (#greater, #greater) { true };
      case _ { false }
    }
  };

  /// Returns an iterator that yields all possible `Order` values:
  /// `#less`, `#equal`, `#greater`.
  public func allValues() : Types.Iter<Order> {
    type State = {
      #start;
      #less;
      #equal;
      #greater;
      #end
    };
    var state : State = #start;
    {
      next = func() : ?Order {
        switch state {
          case (#start) { state := #less; ?#less };
          case (#less) { state := #equal; ?#equal };
          case (#equal) { state := #greater; ?#greater };
          case (#greater) { state := #end; null };
          case (#end) { null }
        }
      }
    }
  }

}
