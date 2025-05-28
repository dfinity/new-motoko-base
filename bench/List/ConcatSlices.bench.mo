import Bench "mo:bench";

import List "../../src/List";
import Nat "../../src/Nat";
import Runtime "../../src/Runtime";
import Iter "../../src/Iter";

module {
  public func init() : Bench.Bench {
    let bench = Bench.Bench();

    bench.name("Create list from two slices");
    bench.description("Create two lists of size given in the column, create a new list by concatenating middle halves of each list. Each row is a different concatenation method.");

    bench.rows([
      "List.concatSlices",
      "List.fromIter . Iter.concat . List.range",
      "List.addCount_ . List.values_from_",
      "List.addCount . List.valuesFrom"
    ]);
    bench.cols([
      "1000",
      "100000",
      "1000000"
    ]);

    bench.runner(
      func(row, col) {
        let ?size = Nat.fromText(col) else Runtime.trap("Invalid size");
        let start = size / 4;
        let end = size - start : Nat;
        let count = end - start : Nat;
        let list1 = List.repeat<Nat>(1, size);
        let list2 = List.repeat<Nat>(2, size);
        let result : List.List<Nat> = switch row {
          case "List.concatSlices" {
            List.concatSlices([(list1, start, end), (list2, start, end)])
          };
          case "List.fromIter . Iter.concat . List.range" {
            List.fromIter(Iter.concat(List.range(list1, start, end), List.range(list2, start, end)))
          };
          case "List.addCount_ . List.values_from_" {
            let list = List.empty<Nat>();
            List.addCount_(list, List.values_from_(start, list1), count);
            List.addCount_(list, List.values_from_(start, list2), count);
            list
          };
          case "List.addCount . List.valuesFrom" {
            let list = List.empty<Nat>();
            List.addCount(list, List.valuesFrom(list1, start), count);
            List.addCount(list, List.valuesFrom(list2, start), count);
            list
          };
          case _ Runtime.unreachable()
        };
        assert List.size(result) == count * 2;
        // Uncomment to check that the result is correct
        // var i = 0;
        // while (i < List.size(result)) {
        //   if (i < count) {
        //     assert List.get(result, i) == 1
        //   } else {
        //     assert List.get(result, i) == 2
        //   };
        //   i += 1
        // }
      }
    );

    bench
  }
}
