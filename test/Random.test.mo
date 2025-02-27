import Random "../src/Random";
import Int "../src/Int";
import Nat "../src/Nat";
import Nat8 "../src/Nat8";
import Nat64 "../src/Nat64";
import Float "../src/Float";
import Bool "../src/Bool";
import Array "../src/Array";
import { suite; test; expect } = "mo:test";

suite(
  "Random.fast()",
  func() {
    test(
      "bool(), seed = 0",
      func() {
        let random = Random.fast(0);
        let expected = [false, false, false, true, true, false, true, true, false, false];
        expect.array(Array.tabulate<Bool>(10, func _ = random.bool()), Bool.toText, Bool.equal).equal(expected)
      }
    );
    test(
      "bool(), seed = 123456789",
      func() {
        let random = Random.fast(123456789);
        let expected = [false, false, true, false, true, false, false, true, true, false];
        expect.array(Array.tabulate<Bool>(10, func _ = random.bool()), Bool.toText, Bool.equal).equal(expected)
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
    );
    test(
      "nat8(), seed = 0",
      func() {
        let random = Random.fast(0);
        let expected : [Nat8] = [27, 58, 135, 48, 175, 107, 232, 146, 65, 96];
        expect.array(Array.tabulate<Nat8>(10, func _ = random.nat8()), Nat8.toText, Nat8.equal).equal(expected)
      }
    );
    test(
      "nat8(), seed = 123456789",
      func() {
        let random = Random.fast(123456789);
        let expected : [Nat8] = [41, 152, 30, 100, 244, 79, 22, 249, 53, 2];
        expect.array(Array.tabulate<Nat8>(10, func _ = random.nat8()), Nat8.toText, Nat8.equal).equal(expected)
      }
    );
    test(
      "nat64(), seed = 0",
      func() {
        let random = Random.fast(0);
        let expected : [Nat64] = [
          1962029230844536978,
          4710990486257585978,
          11259543268084528885,
          7033394001090926866,
          15486745063885072907
        ];
        expect.array(Array.tabulate<Nat64>(5, func _ = random.nat64()), Nat64.toText, Nat64.equal).equal(expected)
      }
    );
    test(
      "nat64(), seed = 123456789",
      func() {
        let random = Random.fast(123456789);
        let expected : [Nat64] = [
          2997178970959451897,
          3819629392862388853,
          8480465938905851716,
          17030162763326561265,
          439678832541472697
        ];
        expect.array(Array.tabulate<Nat64>(5, func _ = random.nat64()), Nat64.toText, Nat64.equal).equal(expected)
      }
    );
    test(
      "nat64() has approximately uniform distribution",
      func() {
        let random = Random.fast(0);
        let trials = 10000;
        var sum = 0;
        for (_ in Nat.range(0, trials - 1)) {
          sum += Nat64.toNat(random.nat64())
        };
        let avg = sum / trials;
        let expectedAvg = Nat64.toNat(Nat64.maxValue) / 2;
        assert Int.abs(avg - expectedAvg : Int) < expectedAvg / 20
      }
    );
    test(
      "nat64Range() returns values within range",
      func() {
        let random = Random.fast(0);
        let from : Nat64 = 1_000_000;
        let toExclusive : Nat64 = 2_000_000;
        for (_ in Nat.range(0, 1000)) {
          let val = random.nat64Range(from, toExclusive);
          assert val >= from and val < toExclusive
        }
      }
    );
    test(
      "natRange() returns values within range",
      func() {
        let random = Random.fast(0);
        let from = 1000;
        let toExclusive = 2000;
        for (_ in Nat.range(0, 1000)) {
          let val = random.natRange(from, toExclusive);
          assert val >= from and val < toExclusive
        }
      }
    );
    test(
      "intRange() returns values within range",
      func() {
        let random = Random.fast(0);
        let from = -1000;
        let toExclusive = 1000;
        for (_ in Nat.range(0, 1000)) {
          let val = random.intRange(from, toExclusive);
          assert val >= from and val < toExclusive
        }
      }
    );
  }
)
