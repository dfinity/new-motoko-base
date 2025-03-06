/// Based on [Real-Time Double-Ended Queue Verified (Proof Pearl)](https://drops.dagstuhl.de/storage/00lipics/lipics-vol268-itp2023/LIPIcs.ITP.2023.29/LIPIcs.ITP.2023.29.pdf)
import Types "../Types";
import List "List";
import Option "../Option";
import { trap } "../Runtime";

module {
  public type Deque<T> = {
    #empty;
    #one : T;
    #two : (T, T);
    #three : (T, T, T);
    #idles : (Idle<T>, Idle<T>); // todo: add invariant assert that the sizes are correct
    #rebal : States<T>
  };

  public func pushFront<T>(deque : Deque<T>, element : T) : Deque<T> = switch deque {
    case (#empty) #one(element);
    case (#one(y)) #two(element, y);
    case (#two(y, z)) #three(element, y, z);
    case (#three(a, b, c)) {
      let i1 = (Stacks<T>(?(element, ?(a, null)), null), 2);
      let i2 = (Stacks<T>(?(c, ?(b, null)), null), 2);
      #idles(i1, i2)
    };
    case (#idles(l0, (r, nR))) {
      let (l1, nL1) = Idle.push(l0, element); // enque the element to the left end
      // check if the size invariant still holds
      if (nL1 <= 3 * nR) #idles((l1, nL1), (r, nR)) else {
        // initiate the rebalancing process
        let nL2 = nL1 - nR - 1 : Nat;
        let nR2 = 2 * nL2 + 1;
        let big = #big1(Current(null, 0, l1, nL2), l1, null, nL2);
        let small = #small1(Current(null, 0, r, nR2), r, null);
        let states = (#right, big, small);
        let states6 = States.step(States.step(States.step(States.step(States.step(States.step(states))))));
        #rebal(states6)
      }
    };
    // if the deque is in the middle of a rebalancing process: push the element and advance the rebalancing process by 4 steps
    // move back into the idle state if the rebalancing is done
    case (#rebal((dir, big0, small0))) switch dir {
      case (#left) {
        let small = SmallState.push(small0, element);
        let states4 = States.step(States.step(States.step(States.step((#left, big0, small)))));
        switch states4 {
          case (#left, #big2(#idle(_, big)), #small3(#idle(_, small))) #idles(small, big); // swapped because dir=left
          case _ #rebal(states4)
        }
      };
      case (#right) {
        let big = BigState.push(big0, element);
        let states4 = States.step(States.step(States.step(States.step((#right, big, small0)))));
        switch states4 {
          case (#right, #big2(#idle(_, big)), #small3(#idle(_, small))) #idles(big, small);
          case _ #rebal(states4)
        }
      }
    }
  };

  public func pushBack<T>(deque : Deque<T>, element : T) : Deque<T> = reverse(pushFront(reverse(deque), element));

  // todo: check line by line if correct
  public func popFront<T>(deque : Deque<T>) : ?(T, Deque<T>) = switch deque {
    case (#empty) null;
    case (#one(x)) ?(x, #empty);
    case (#two(x, y)) ?(x, #one(y));
    case (#three(x, y, z)) ?(x, #two(y, z));
    case (#idles(l0, (r0, nR0))) {
      let (x, (l1, nL1)) = Idle.pop(l0);
      if (nR0 <= 3 * nL1) {
        ?(x, #idles((l1, nL1), (r0, nR0)))
      } else if (1 <= nL1) {
        let nL2 = 2 * nL1 + 1;
        let nR2 = nR0 - nL2 - 1 : Nat;
        let small = #small1(Current(null, 0, l1, nL2), l1, null);
        let big = #big1(Current(null, 0, r0, nR2), r0, null, nR2);
        let states = (#left, big, small);
        let states6 = States.step(States.step(States.step(States.step(States.step(States.step(states))))));
        ?(x, #rebal(states6))
      } else {
        ?(x, r0.smallDeque())
      }
    };
    case (#rebal((dir, big0, small0))) switch dir {
      case (#left) {
        let (x, small) = SmallState.pop(small0);
        let states4 = States.step(States.step(States.step(States.step((#left, big0, small)))));
        switch states4 {
          case (#right, #big2(#idle(_, big)), #small3(#idle(_, small))) ?(x, #idles(big, small)); // todo: same as below?
          case _ ?(x, #rebal(states4))
        }
      };
      case (#right) {
        let (x, big) = BigState.pop(big0);
        let states4 = States.step(States.step(States.step(States.step((#right, big, small0)))));
        switch states4 {
          case (#right, #big2(#idle(_, big)), #small3(#idle(_, small))) ?(x, #idles(big, small)); // todo: same as above?
          case _ ?(x, #rebal(states4))
        }
      }
    }
  };

  public func popBack<T>(deque : Deque<T>) : ?(T, Deque<T>) = do ? {
    let (x, deque2) = popFront(reverse(deque))!;
    (x, reverse(deque2))
  };

  // todo: correct? make it public?
  func reverse<T>(deque : Deque<T>) : Deque<T> = switch deque {
    case (#empty) deque;
    case (#one(_)) deque;
    case (#two(x, y)) #two(y, x);
    case (#three(x, y, z)) #three(z, y, x);
    case (#idles(l, r)) #idles(r, l);
    case (#rebal(#left, big, small)) #rebal(#right, big, small);
    case (#rebal(#right, big, small)) #rebal(#left, big, small)
  };

  class Stacks<T>(left : List<T>, right : List<T>) = self {
    public func push(t : T) : Stacks<T> = Stacks(?(t, left), right);

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

    public func size() : Nat = List.size(left) + List.size(right);

    public func smallDeque() : Deque<T> = switch (left, right) {
      case (null, null) #empty;
      case (null, ?(x, null)) #one(x);
      case (?(x, null), null) #one(x);
      case (null, ?(x, ?(y, null))) #two(y, x);
      case (?(x, null), ?(y, null)) #two(y, x);
      case (?(x, ?(y, null)), null) #two(y, x);
      case (null, ?(x, ?(y, ?(z, null)))) #three(z, y, x);
      case (?(x, ?(y, ?(z, null))), null) #three(z, y, x);
      case (?(x, ?(y, null)), ?(z, null)) #three(z, y, x);
      case (?(x, null), ?(y, ?(z, null))) #three(z, y, x);
      case _ (trap "Illegal smallDeque invocation")
    }
  };

  /// Represents an end of the deque that is not in a rebalancing process.
  type Idle<T> = (stacks : Stacks<T>, size : Nat);
  module Idle {
    // debug assert stacks.size() == size; // todo: where to put it?

    public func push<T>((stacks, size) : Idle<T>, t : T) : Idle<T> = (stacks.push(t), 1 + size);
    public func pop<T>((stacks, size) : Idle<T>) : (T, Idle<T>) = (stacks.unsafeFirst(), (stacks.pop(), size - 1 : Nat))
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
      if (targetSize <= n) #idle(cur, (Stacks<T>(ext, new), extSize + n)) else copy
    };

    public func push<T>(common : CommonState<T>, t : T) : CommonState<T> = switch common {
      case (#copy(cur, aux, new, n)) #copy(cur.push(t), aux, new, n);
      case (#idle(cur, idle)) #idle(cur.push(t), Idle.push(idle, t)) // yes, push to both
    };

    public func pop<T>(common : CommonState<T>) : (T, CommonState<T>) = switch common {
      case (#copy(cur, aux, new, n)) {
        let (t, cur2) = cur.pop();
        (t, norm(#copy(cur2, aux, new, n)))
      };
      case (#idle(cur, idle)) {
        let (t, idle2) = Idle.pop(idle);
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
