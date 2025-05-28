import Bench "mo:bench";

import List "../../src/List";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("List iteration");
    bench.description("");

    bench.rows([
      "while get",
      "List.values_ while unsafe_next",
      "while put",
      "List.values_ while next_set"
    ]);
    bench.cols([
      "1000",
      "100000",
      "1000000"
    ]);

    func onValue(value : Nat) {
      ignore value
    };

    bench.runner(
      func(row, col) {
        let ?size = Nat.fromText(col) else Runtime.trap("Invalid size");
        let list = List.repeat<Nat>(0, size);
        switch row {
          case "while get" {
            var i = 0;
            while (i < size) {
              onValue(List.get(list, i));
              i += 1
            }
          };
          case "List.values_ while unsafe_next" {
            let unsafeIter = List.values_(list);
            var i = 0;
            while (i < size) {
              onValue(unsafeIter.unsafe_next());
              i += 1
            }
          };
          case "while put" {
            var i = 0;
            while (i < size) {
              List.put(list, i, i * 2);
              i += 1
            }
          };
          case "List.values_ while next_set" {
            let unsafeIter = List.values_(list);
            var i = 0;
            while (i < size) {
              unsafeIter.next_set(i * 2);
              i += 1
            }
          };
          case _ Runtime.unreachable()
        }
      }
    );

    bench
  }
}
