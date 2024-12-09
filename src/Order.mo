/// Order

module {
  public type Order = {
    #less;
    #equal;
    #greater
  };

  public func isLess(order : Order) : Bool {
    order == #less
  };

  public func isEqual(order : Order) : Bool {
    order == #equal
  };

  public func isGreater(order : Order) : Bool {
    order == #greater
  };

  public func equal(o1 : Order, o2 : Order) : Bool {
    o1 == o2
  };
}
