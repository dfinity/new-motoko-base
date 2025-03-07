/// Based on [Real-Time Double-Ended Queue Verified (Proof Pearl)](https://drops.dagstuhl.de/storage/00lipics/lipics-vol268-itp2023/LIPIcs.ITP.2023.29/LIPIcs.ITP.2023.29.pdf)
import Types "../Types";
import List "List";
import Option "../Option";
import { trap } "../Runtime";

module {
  /// The real-time deque data structure can be in one of the following states:
  ///
  /// - `#empty`: the deque is empty
  /// - `#one`: the deque contains a single element
  /// - `#two`: the deque contains two elements
  /// - `#three`: the deque contains three elements
  /// - `#idles`: the deque is in the idle state, where `l` and `r` are non-empty stacks of elements fulfilling the size invariant
  /// - `#rebal`: the deque is in the rebalancing state
  public type Deque<T> = {
    #empty;
    #one : T;
    #two : (T, T);
    #three : (T, T, T);
    #idles : (Idle<T>, Idle<T>); // todo: add invariant assert that the sizes are correct
    #rebal : States<T>
  };

  public func empty<T>() : Deque<T> = #empty;

  public func isEmpty<T>(deque : Deque<T>) : Bool = switch deque {
    case (#empty) true;
    case _ false
  };

  public func singleton<T>(element : T) : Deque<T> = #one(element);

  public func size<T>(deque : Deque<T>) : Nat = switch deque {
    case (#empty) 0;
    case (#one(_)) 1;
    case (#two(_, _)) 2;
    case (#three(_, _, _)) 3;
    case (#idles((_, n), (_, m))) n + m;
    case (#rebal((_, big, small))) BigState.size(big) + SmallState.size(small)
  };

  public func pushFront<T>(deque : Deque<T>, element : T) : Deque<T> = switch deque {
    case (#empty) #one(element);
    case (#one(y)) #two(element, y);
    case (#two(y, z)) #three(element, y, z);
    case (#three(a, b, c)) {
      let i1 = ((?(element, ?(a, null)), null), 2);
      let i2 = ((?(c, ?(b, null)), null), 2);
      #idles(i1, i2)
    };
    case (#idles(l0, (r, nR))) {
      let (l, nL) = Idle.push(l0, element); // enque the element to the left end
      // check if the size invariant still holds
      if (3 * nR >= nL) #idles((l, nL), (r, nR)) else {
        // initiate the rebalancing process
        let remainedL = nL - nR - 1 : Nat;
        let remainedR = 2 * nR + 1;
        debug assert remainedL + remainedR == nL + nR;
        let big = #big1(Current<T>(null, 0, l, remainedL), l, null, remainedL);
        let small = #small1(Current<T>(null, 0, r, remainedR), r, null);
        let states = (#right, big, small);
        let states6 = States.step(States.step(States.step(States.step(States.step(States.step(states))))));
        #rebal(states6)
      }
    };
    // if the deque is in the middle of a rebalancing process: push the element and advance the rebalancing process by 4 steps
    // move back into the idle state if the rebalancing is done
    case (#rebal((dir, big0, small0))) switch dir {
      case (#right) {
        let big = BigState.push(big0, element);
        let states4 = States.step(States.step(States.step(States.step((#right, big, small0)))));
        debug assert states4.0 == #right;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) #idles(big, small);
          case _ #rebal(states4)
        }
      };
      case (#left) {
        let small = SmallState.push(small0, element);
        let states4 = States.step(States.step(States.step(States.step((#left, big0, small)))));
        debug assert states4.0 == #left;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) #idles(small, big); // swapped because dir=left
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
    case (#idles(l0, (r, nR))) {
      let (x, (l, nL)) = Idle.pop(l0);
      if (3 * nL >= nR) {
        ?(x, #idles((l, nL), (r, nR)))
      } else if (nL >= 1) {
        let remainedL = 2 * nL + 1;
        let remainedR = nR - nL - 1 : Nat;
        debug assert remainedL + remainedR == nL + nR;
        let small = #small1(Current<T>(null, 0, l, remainedL), l, null);
        let big = #big1(Current<T>(null, 0, r, remainedR), r, null, remainedR);
        let states = (#left, big, small);
        let states6 = States.step(States.step(States.step(States.step(States.step(States.step(states))))));
        ?(x, #rebal(states6))
      } else {
        ?(x, Stacks.smallDeque(r))
      }
    };
    case (#rebal((dir, big0, small0))) switch dir {
      case (#left) {
        let (x, small) = SmallState.pop(small0);
        let states4 = States.step(States.step(States.step(States.step((#left, big0, small)))));
        debug assert states4.0 == #left;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) ?(x, #idles(small, big));
          case _ ?(x, #rebal(states4))
        }
      };
      case (#right) {
        let (x, big) = BigState.pop(big0);
        let states4 = States.step(States.step(States.step(States.step((#right, big, small0)))));
        debug assert states4.0 == #right;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) ?(x, #idles(big, small));
          case _ ?(x, #rebal(states4))
        }
      }
    }
  };

  public func popBack<T>(deque : Deque<T>) : ?(T, Deque<T>) = do ? {
    let (x, deque2) = popFront(reverse(deque))!;
    (x, reverse(deque2))
  };

  // todo: make it public?
  func reverse<T>(deque : Deque<T>) : Deque<T> = switch deque {
    case (#empty) deque;
    case (#one(_)) deque;
    case (#two(x, y)) #two(y, x);
    case (#three(x, y, z)) #three(z, y, x);
    case (#idles(l, r)) #idles(r, l);
    case (#rebal(#left, big, small)) #rebal(#right, big, small);
    case (#rebal(#right, big, small)) #rebal(#left, big, small)
  };

  type Stacks<T> = (left : List<T>, right : List<T>);

  module Stacks {
    public func push<T>((left, right) : Stacks<T>, t : T) : Stacks<T> = (?(t, left), right);

    public func pop<T>(stacks : Stacks<T>) : Stacks<T> = switch stacks {
      case (?(_, leftTail), right) (leftTail, right);
      case (null, ?(_, rightTail)) (null, rightTail);
      case (null, null) stacks // avoids allocation
    };

    public func first<T>((left, right) : Stacks<T>) : ?T = switch (left) {
      case (?(h, _)) ?h;
      case (null) do ? { right!.0 }
    };

    // todo: try avoid
    public func unsafeFirst<T>((left, right) : Stacks<T>) : T = switch (left) {
      case (?(h, _)) h;
      case (null) Option.unwrap(right).0
    };

    public func isEmpty<T>((left, right) : Stacks<T>) : Bool = List.isEmpty(left) and List.isEmpty(right);

    public func size<T>((left, right) : Stacks<T>) : Nat = List.size(left) + List.size(right);

    public func smallDeque<T>((left, right) : Stacks<T>) : Deque<T> = switch (left, right) {
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

  /// Represents an end of the deque that is not in a rebalancing process. It is a stack and its size.
  type Idle<T> = (stacks : Stacks<T>, size : Nat);
  module Idle {
    // debug assert stacks.size() == size; // todo: where to put it?

    public func push<T>((stacks, size) : Idle<T>, t : T) : Idle<T> = (Stacks.push(stacks, t), 1 + size);
    public func pop<T>((stacks, size) : Idle<T>) : (T, Idle<T>) = (Stacks.unsafeFirst(stacks), (Stacks.pop(stacks), size - 1 : Nat))
  };

  /// Stores information about operations that happen during rebalancing but which have not become part of the old state that is being rebalanced.
  ///
  /// - `extra`: newly added elements
  /// - `extraSize`: size of `extra`
  /// - `old`: elements contained before the rebalancing process
  /// - `remained`: the number of elements which will be contained after the rebalancing is finished
  class Current<T>(_this : (extra : List<T>, extraSize : Nat, old : Stacks<T>, remained : Nat)) {
    public let this = _this;
    let (extra, extraSize, old, remained) = _this;

    debug assert List.size(extra) == extraSize;

    public func push(t : T) : Current<T> = Current(?(t, extra), 1 + extraSize, old, remained);
    public func pop() : (T, Current<T>) = switch (extra) {
      case (?(h, t)) (h, Current(t, extraSize - 1 : Nat, old, remained));
      case (null) (Stacks.unsafeFirst(old), Current(null, extraSize, Stacks.pop(old), remained - 1 : Nat))
    };

    public func size() : Nat = extraSize + remained
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
      case (#big1(cur, big, aux, n)) {
        if (n == 0) {
          debug assert Stacks.isEmpty(big);
          #big2(CommonState.norm(#copy(cur, aux, null, 0))) // todo: we ignore 'big' here, is that exaclty the size of the big stack?
        } else
        #big1(cur, Stacks.pop(big), ?(Stacks.unsafeFirst(big), aux), n - 1 : Nat) // todo: refactor pop to return the element and the new state
      };
      case (#big2(state)) #big2(CommonState.step(state))
    };

    public func size<T>(big : BigState<T>) : Nat = switch big {
      case (#big1(cur, _, _, _)) cur.size();
      case (#big2(state)) CommonState.size(state)
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
        if (Stacks.isEmpty(small)) #small1(cur, small, aux) else #small1(cur, Stacks.pop(small), ?(Stacks.unsafeFirst(small), aux))
      };
      case (#small2(cur, aux, big, new, n)) {
        if (Stacks.isEmpty(big)) #small3(CommonState.norm(#copy(cur, aux, new, n))) else #small2(cur, aux, Stacks.pop(big), ?(Stacks.unsafeFirst(big), new), 1 + n)
      };
      case (#small3(common)) #small3(CommonState.step(common))
    };

    public func size<T>(state : SmallState<T>) : Nat = switch state {
      case (#small1(cur, _, _)) cur.size();
      case (#small2(cur, _, _, _, _)) cur.size();
      case (#small3(common)) CommonState.size(common)
    }
  };

  type CopyState<T> = { #copy : (Current<T>, List<T>, List<T>, Nat) };

  type CommonState<T> = CopyState<T> or { #idle : (Current<T>, Idle<T>) };

  module CommonState {
    public func step<T>(common : CommonState<T>) : CommonState<T> = switch common {
      case (#copy copy) {
        let (cur, aux, new, moved) = copy;
        let (_, _, _, remained) = cur.this;
        norm(if (moved < remained) #copy(cur, unsafeTail(aux), ?(unsafeHead(aux), new), 1 + moved) else #copy copy)
      };
      case (#idle(_, _)) common
    };

    public func norm<T>(copy : CopyState<T>) : CommonState<T> {
      let #copy(cur, _, new, moved) = copy;
      let (extra, extraSize, _, remained) = cur.this;
      debug assert moved <= remained;
      if (moved >= remained) #idle(cur, ((extra, new), extraSize + moved)) else copy
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
        (t, #idle(cur.pop().1, idle2))
      }
    };

    public func size<T>(common : CommonState<T>) : Nat = switch common {
      case (#copy(cur, aux, _, moved)) cur.size(); // todo: check if correct
      case (#idle(_, (_, size))) size
    }
  };

  type States<T> = (
    direction : Direction,
    bigState : BigState<T>,
    smallState : SmallState<T>
  );

  module States {
    public func step<T>(states : States<T>) : States<T> = switch states {
      case (dir, #big1(_, big, _, 0), #small1(currentS, _, auxS)) {
        (dir, BigState.step(states.1), #small2(currentS, auxS, big, null, 0))
      };
      case (dir, big, small) (dir, BigState.step(big), SmallState.step(small))
    }
  };

  type Direction = { #left; #right };

  type List<T> = Types.Pure.List<T>;
  func unsafeHead<T>(l : List<T>) : T = Option.unwrap(l).0; // todo: avoid
  func unsafeTail<T>(l : List<T>) : List<T> = Option.unwrap(l).1; // todo: avoid
  func undefined<T>() : T = trap "undefined"
}
