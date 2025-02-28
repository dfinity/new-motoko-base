import Order "../src/Order";
import { test } "mo:test";

test(
  "isLess",
  func() {
    assert (Order.isLess(#less));
    assert (not Order.isLess(#equal));
    assert (not Order.isLess(#greater))
  }
);

test(
  "isEqual",
  func() {
    assert (not Order.isEqual(#less));
    assert (Order.isEqual(#equal));
    assert (not Order.isEqual(#greater))
  }
);

test(
  "isGreater",
  func() {
    assert (not Order.isGreater(#less));
    assert (not Order.isGreater(#equal));
    assert (Order.isGreater(#greater))
  }
);

test(
  "allValues",
  func() {
    let iter = Order.allValues();
    assert (iter.next() == ?#less);
    assert (iter.next() == ?#equal);
    assert (iter.next() == ?#greater);
    assert (iter.next() == null);
    assert (iter.next() == null)
  }
)
