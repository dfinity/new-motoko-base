import Random "../src/Random";
import Nat64 "../src/Nat64";
import Nat8 "../src/Nat8";
import Nat "../src/Nat";
import Int "../src/Int";
import Float "../src/Float";
import Bool "../src/Bool";
import Array "../src/Array";
import Iter "../src/Iter";
import { suite; test; expect } = "mo:test";

suite(
  "Random.fast()",
  func() {
    test(
      "bool()",
      func() {
        let random = Random.fast(0);
        let expected = [false, false, false, true, true, false, true, true, false, false];
        expect.array(Array.tabulate<Bool>(10, func _ = random.bool()), Bool.toText, Bool.equal).equal(expected)
      }
    );
    test(
      "nat8()",
      func() {
        let random = Random.fast(0);
        let expected : [Nat8] = [27, 58, 135, 48, 175, 107, 232, 146, 65, 96];
        expect.array(Array.tabulate<Nat8>(10, func _ = random.nat8()), Nat8.toText, Nat8.equal).equal(expected)
      }
    );

    test(
      "bool() has approximately uniform distribution",
      func() {
        let random = Random.fast(0);
        var trueCount = 0;
        let trials = 10000;
        for (_ in Nat.range(0, trials - 1)) {
          if (random.bool()) trueCount += 1
        };
        let ratio = Float.fromInt(trueCount) / Float.fromInt(trials);
        assert ratio > 0.49 and ratio < 0.51
      }
    )
  }
)
