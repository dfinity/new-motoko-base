/// Based on [Real-Time Double-Ended Queue Verified (Proof Pearl)](https://drops.dagstuhl.de/storage/00lipics/lipics-vol268-itp2023/LIPIcs.ITP.2023.29/LIPIcs.ITP.2023.29.pdf)
import Types "../Types";
import List "List";
import Option "../Option";

module {
  public type Deque<T> = {
    #empty;
    #one : T;
    #two : (T, T);
    #three : (T, T, T);
    #idles : (Idle<T>, Idle<T>);
    #rebal : States<T>
  };

  class Stacks<T>(left : List<T>, right : List<T>) = self {
    public func push(t : T) : Stacks<T> = Stacks(List.push(left, t), right);

    // pop (Stack (x # left) right) = Stack left right
    // pop (Stack [] (x # right)) = Stack [] right
    // pop (Stack [] []) = Stack [] []
    public func pop() : Stacks<T> = switch (left, right) {
      case (?(_, leftTail), _) Stacks(leftTail, right);
      case (null, ?(_, rightTail)) Stacks(null, rightTail);
      case (null, null) self; // avoids allocation
    };

    public func first() : ?T = switch (left) {
      case (?(h, _)) ?h;
      case (null) do ? { right!.0 }
    };

    // todo: try avoid
    public func unsafeFirst() : T = switch (left) {
      case (?(h, _)) h;
      case (null) Option.unwrap(right).0
    };

    public func isEmpty() : Bool = List.isEmpty(left) and List.isEmpty(right);

    public func size() : Nat = List.size(left) + List.size(right)
  };

  /// Represents an end of the deque that is not in a rebalancing process.
  class Idle<T>(stacks : Stacks<T>, size : Nat) = self {
    debug assert stacks.size() == size;

    public func push(t : T) : Idle<T> = Idle(stacks.push(t), 1 + size);
    public func pop() : (T, Idle<T>) = (stacks.unsafeFirst(), Idle(stacks.pop(), size - 1 : Nat))
  };

  /// Stores information about operations that happen during rebalancing but which have not become part of the old state that is being rebalanced.
  class Current<T>(_this : (ext : List<T>, extSize : Nat, old : Stacks<T>, targetSize : Nat)) {
    public let this = _this;
    let (ext, extSize, old, targetSize) = _this;

    debug assert List.size(ext) == extSize;

    public func push(t : T) : Current<T> = Current(?(t, ext), 1 + extSize, old, targetSize);
    public func pop() : (T, Current<T>) = switch (ext) {
      case (?(h, t)) (h, Current(t, extSize - 1 : Nat, old, targetSize));
      case (null) (old.unsafeFirst(), Current(null, extSize, old.pop(), targetSize - 1 : Nat))
    }
  };

  type BigState<T> = {
    #big1 : (Current<T>, Stacks<T>, List<T>, Nat);
    #big2 : CommonState<T>
  };

  module BigState {
    public func push<T>(big : BigState<T>, t : T) : BigState<T> = switch big {
      case (#big1(cur, big, aux, n)) #big1(cur.push(t), big, aux, n);
      case (#big2(state)) #big2(CommonState.push(state, t))
    };

    public func pop<T>(big : BigState<T>) : (T, BigState<T>) = switch big {
      case (#big1(cur, big, aux, n)) {
        let (x, cur2) = cur.pop();
        (x, #big1(cur2, big, aux, n))
      };
      case (#big2(state)) {
        let (x, state2) = CommonState.pop(state);
        (x, #big2(state2))
      }
    };

    public func step<T>(big : BigState<T>) : BigState<T> = switch big {
      case (#big1(cur, big, aux, n)) if (n == 0)
      #big2(CommonState.norm(#copy(cur, aux, null, 0))) else
      #big1(cur, big.pop(), ?(big.unsafeFirst(), aux), n - 1 : Nat);
      case (#big2(state)) #big2(CommonState.step(state))
    }
  };

  type SmallState<T> = {
    #small1 : (Current<T>, Stacks<T>, List<T>);
    #small2 : (Current<T>, List<T>, Stacks<T>, List<T>, Nat);
    #small3 : CommonState<T>
  };

  module SmallState {
    public func push<T>(state : SmallState<T>, t : T) : SmallState<T> = switch state {
      case (#small1(cur, small, aux)) #small1(cur.push(t), small, aux);
      case (#small2(cur, aux, big, new, n)) #small2(cur.push(t), aux, big, new, n);
      case (#small3(common)) #small3(CommonState.push(common, t))
    };

    public func pop<T>(state : SmallState<T>) : (T, SmallState<T>) = switch state {
      case (#small1(cur0, small, aux)) {
        let (t, cur) = cur0.pop();
        (t, #small1(cur, small, aux))
      };
      case (#small2(cur0, aux, big, new, n)) {
        let (t, cur) = cur0.pop();
        (t, #small2(cur, aux, big, new, n))
      };
      case (#small3(common0)) {
        let (t, common) = CommonState.pop(common0);
        (t, #small3(common))
      }
    };

    public func step<T>(state : SmallState<T>) : SmallState<T> = switch state {
      case (#small1(cur, small, aux)) {
        if (small.isEmpty()) #small1(cur, small, aux) else #small1(cur, small.pop(), ?(small.unsafeFirst(), aux))
      };
      case (#small2(cur, aux, big, new, n)) {
        if (big.isEmpty()) #small3(CommonState.norm(#copy(cur, aux, new, n))) else #small2(cur, aux, big.pop(), ?(big.unsafeFirst(), new), 1 + n)
      };
      case (#small3(common)) #small3(CommonState.step(common))
    }
  };

  type CopyState<T> = { #copy : (Current<T>, List<T>, List<T>, Nat) };

  type CommonState<T> = CopyState<T> or { #idle : (Current<T>, Idle<T>) };

  module CommonState {
    public func step<T>(common : CommonState<T>) : CommonState<T> = switch common {
      case (#copy(cur, aux, new, n)) {
        let (_, _, _, targetSize) = cur.this;
        norm(if (n < targetSize) #copy(cur, unsafeTail(aux), ?(unsafeHead(aux), new), 1 + n) else #copy(cur, aux, new, n))
      };
      case (#idle(_, _)) common
    };

    public func norm<T>(copy : CopyState<T>) : CommonState<T> {
      let #copy(cur, _, new, n) = copy;
      let (ext, extSize, _, targetSize) = cur.this;
      if (targetSize <= n) #idle(cur, (Idle(Stacks<T>(ext, new), extSize + n))) else copy
    };

    public func push<T>(common : CommonState<T>, t : T) : CommonState<T> = switch common {
      case (#copy(cur, aux, new, n)) #copy(cur.push(t), aux, new, n);
      case (#idle(cur, idle)) #idle(cur.push(t), idle.push(t)) // yes, push to both
    };

    public func pop<T>(common : CommonState<T>) : (T, CommonState<T>) = switch common {
      case (#copy(cur, aux, new, n)) {
        let (t, cur2) = cur.pop();
        (t, norm(#copy(cur2, aux, new, n)))
      };
      case (#idle(cur, idle)) {
        let (t, idle2) = idle.pop();
        (t, #idle(cur.pop().1, idle2)) // todo: in the paper: `fst (pop cur)` but that is an element...
      }
    }
  };

  type States<T> = (
    direction : Direction,
    bigState : BigState<T>,
    smallState : SmallState<T>
  );

  module States {
    public func step<T>(states : States<T>) : States<T> = switch states {
      case (dir, #big1(currentB, big, auxB, 0), #small1(currentS, _, auxS)) {
        (dir, BigState.step(#big1(currentB, big, auxB, 0)), #small2(currentS, auxS, big, null, 0))
      };
      case (dir, big, small) (dir, BigState.step(big), SmallState.step(small))
    }
  };

  type Direction = { #left; #right };

  type List<T> = Types.Pure.List<T>;
  func unsafeHead<T>(l : List<T>) : T = Option.unwrap(l).0; // todo: avoid
  func unsafeTail<T>(l : List<T>) : List<T> = Option.unwrap(l).1 // todo: avoid
}
