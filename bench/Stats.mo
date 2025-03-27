import Debug "../src/Debug";
import InternetComputer "../src/InternetComputer";
import List "../src/List";
import Nat "../src/Nat";
import Nat64 "../src/Nat64";

module {
  public type Stats = {
    name : Text;
    var list : List.List<Nat>
  };

  public func empty(name : Text) : Stats = {
    name;
    var list = List.empty<Nat>()
  };

  public func record(stats : Stats, op : () -> ()) {
    let instructions = Nat64.toNat(
      InternetComputer.countInstructions(op)
    );
    List.add(stats.list, instructions)
  };

  public func dump(stats : Stats) {
    List.sort(stats.list, Nat.compare);
    let total = List.foldLeft<Nat, Nat>(stats.list, 0, Nat.add);
    let max = List.max<Nat>(stats.list, Nat.compare);
    let avg = total / List.size(stats.list);
    let mean = List.get(stats.list, List.size(stats.list) / 2);
    Debug.print(stats.name # " " # debug_show { mean; max; avg; total })
  };

  public func times(f : () -> (), n : Nat) {
    for (i in Nat.range(0, n)) {
      f()
    }
  }
}
