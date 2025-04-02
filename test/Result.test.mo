import Result "../src/Result";
import Int "../src/Int";
import Nat "../src/Nat";
import Text "../src/Text";
import { suite; test; expect } "mo:test";

func makeNatural(x : Int) : Result.Result<Nat, Text> = if (x >= 0) {
  #ok(Int.abs(x))
} else { #err(Int.toText(x) # " is not a natural number.") };

func largerThan10(x : Nat) : Result.Result<Nat, Text> = if (x > 10) { #ok(x) } else {
  #err(Int.toText(x) # " is not larger than 10.")
};

suite(
  "equal",
  func() {
    test(
      "ok values equal",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(#ok(123), #ok(123), Nat.equal, Text.equal)
        ).isTrue()
      }
    );

    test(
      "ok values not equal",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(#ok(123), #ok(456), Nat.equal, Text.equal)
        ).isFalse()
      }
    );

    test(
      "err values equal",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(#err("error"), #err("error"), Nat.equal, Text.equal)
        ).isTrue()
      }
    );

    test(
      "err values not equal",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(#err("error1"), #err("error2"), Nat.equal, Text.equal)
        ).isFalse()
      }
    );

    test(
      "ok and err not equal",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(#ok(123), #err("error"), Nat.equal, Text.equal)
        ).isFalse()
      }
    )
  }
);

suite(
  "compare",
  func() {
    test(
      "ok values equal",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#ok(123), #ok(123), Int.compare, Text.compare) == #equal
        ).isTrue()
      }
    );

    test(
      "ok values less",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#ok(123), #ok(456), Int.compare, Text.compare) == #less
        ).isTrue()
      }
    );

    test(
      "ok values greater",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#ok(456), #ok(123), Int.compare, Text.compare) == #greater
        ).isTrue()
      }
    );

    test(
      "err values equal",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#err("error"), #err("error"), Int.compare, Text.compare) == #equal
        ).isTrue()
      }
    );

    test(
      "err values less",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#err("a"), #err("b"), Int.compare, Text.compare) == #less
        ).isTrue()
      }
    );

    test(
      "err values greater",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#err("b"), #err("a"), Int.compare, Text.compare) == #greater
        ).isTrue()
      }
    );

    test(
      "ok greater than err",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#ok(123), #err("error"), Int.compare, Text.compare) == #greater
        ).isTrue()
      }
    );

    test(
      "err less than ok",
      func() {
        expect.bool(
          Result.compare<Nat, Text>(#err("error"), #ok(123), Int.compare, Text.compare) == #less
        ).isTrue()
      }
    )
  }
);

suite(
  "mapOk",
  func() {
    test(
      "maps ok value",
      func() {
        expect.bool(
          Result.equal<Text, Text>(
            Result.mapOk<Nat, Text, Text>(#ok(123), Int.toText),
            #ok("123"),
            Text.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "preserves err",
      func() {
        expect.bool(
          Result.equal<Text, Text>(
            Result.mapOk<Nat, Text, Text>(#err("error"), Int.toText),
            #err("error"),
            Text.equal,
            Text.equal
          )
        ).isTrue()
      }
    )
  }
);

suite(
  "mapErr",
  func() {
    test(
      "maps err value",
      func() {
        expect.bool(
          Result.equal<Nat, Nat>(
            Result.mapErr<Nat, Text, Nat>(#err("error"), Text.size),
            #err(5),
            Nat.equal,
            Nat.equal
          )
        ).isTrue()
      }
    );

    test(
      "preserves ok",
      func() {
        expect.bool(
          Result.equal<Nat, Nat>(
            Result.mapErr<Nat, Text, Nat>(#ok(123), Text.size),
            #ok(123),
            Nat.equal,
            Nat.equal
          )
        ).isTrue()
      }
    )
  }
);

suite(
  "fromOption",
  func() {
    test(
      "some to ok",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.fromOption(?123, "error"),
            #ok(123),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "null to err",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.fromOption(null, "error"),
            #err("error"),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    )
  }
);

suite(
  "toOption",
  func() {
    test(
      "ok to some",
      func() {
        expect.bool(
          Result.toOption(#ok(123)) == ?123
        ).isTrue()
      }
    );

    test(
      "err to null",
      func() {
        expect.bool(
          Result.toOption(#err("error")) == null
        ).isTrue()
      }
    )
  }
);

suite(
  "isOk/isErr",
  func() {
    test(
      "isOk true for ok",
      func() {
        expect.bool(Result.isOk(#ok(123))).isTrue()
      }
    );

    test(
      "isOk false for err",
      func() {
        expect.bool(Result.isOk(#err("error"))).isFalse()
      }
    );

    test(
      "isErr true for err",
      func() {
        expect.bool(Result.isErr(#err("error"))).isTrue()
      }
    );

    test(
      "isErr false for ok",
      func() {
        expect.bool(Result.isErr(#ok(123))).isFalse()
      }
    )
  }
);

suite(
  "assertOk/assertErr",
  func() {
    test(
      "assertOk succeeds for ok",
      func() {
        Result.assertOk(#ok(123))
      }
    );

    test(
      "assertErr succeeds for err",
      func() {
        Result.assertErr(#err("error"))
      }
    )
  }
);

suite(
  "fromUpper/toUpper",
  func() {
    test(
      "fromUpper ok",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.fromUpper<Nat, Text>(#Ok(123)),
            #ok(123),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "fromUpper err",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.fromUpper<Nat, Text>(#Err("error")),
            #err("error"),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "toUpper ok",
      func() {
        let result = Result.toUpper<Nat, Text>(#ok(123));
        expect.bool(
          switch (result) {
            case (#Ok(123)) { true };
            case _ { false }
          }
        ).isTrue()
      }
    );

    test(
      "toUpper err",
      func() {
        let result = Result.toUpper<Nat, Text>(#err("error"));
        expect.bool(
          switch (result) {
            case (#Err("error")) { true };
            case _ { false }
          }
        ).isTrue()
      }
    )
  }
);

suite(
  "chain",
  func() {
    test(
      "ok -> ok",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.chain<Nat, Nat, Text>(makeNatural(11), largerThan10),
            #ok(11),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "ok -> err",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.chain<Nat, Nat, Text>(makeNatural(5), largerThan10),
            #err("5 is not larger than 10."),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "err",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.chain<Nat, Nat, Text>(makeNatural(-5), largerThan10),
            #err("-5 is not a natural number."),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    )
  }
);

suite(
  "flatten",
  func() {
    test(
      "ok -> ok",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.flatten<Nat, Text>(#ok(#ok(10))),
            #ok(10),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "err",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.flatten<Nat, Text>(#err("wrong")),
            #err("wrong"),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    );

    test(
      "ok -> err",
      func() {
        expect.bool(
          Result.equal<Nat, Text>(
            Result.flatten<Nat, Text>(#ok(#err("wrong"))),
            #err("wrong"),
            Nat.equal,
            Text.equal
          )
        ).isTrue()
      }
    )
  }
);

suite(
  "forOk",
  func() {
    var counter : Nat = 0;

    test(
      "ok",
      func() {
        Result.forOk(makeNatural(5), func(x : Nat) { counter += x });
        expect.nat(counter).equal(5)
      }
    );

    test(
      "err",
      func() {
        Result.forOk(makeNatural(-10), func(x : Nat) { counter += x });
        expect.nat(counter).equal(5)
      }
    )
  }
);

suite(
  "forErr",
  func() {
    var counter : Nat = 0;

    test(
      "ok",
      func() {
        Result.forErr(#err 5, func(x : Nat) { counter += x });
        expect.nat(counter).equal(5)
      }
    );

    test(
      "err",
      func() {
        Result.forErr(#ok 5, func(x : Nat) { counter += x });
        expect.nat(counter).equal(5)
      }
    )
  }
)
