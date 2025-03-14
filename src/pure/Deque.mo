/// Based on [Real-Time Double-Ended Queue Verified (Proof Pearl)](https://drops.dagstuhl.de/storage/00lipics/lipics-vol268-itp2023/LIPIcs.ITP.2023.29/LIPIcs.ITP.2023.29.pdf)
import Types "../Types";
import List "List";
import Option "../Option";
import { trap } "../Runtime";
import Iter "../Iter";

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
    #idles : (Idle<T>, Idle<T>);
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
    case (#idles((l, nL), (r, nR))) {
      debug assert Stacks.size(l) == nL and Stacks.size(r) == nR;
      nL + nR
    };
    case (#rebal((_, big, small))) BigState.size(big) + SmallState.size(small)
  };

  public func contains<T>(deque : Deque<T>, eq : (T, T) -> Bool, item : T) : Bool = switch deque {
    case (#empty) false;
    case (#one(x)) eq(x, item);
    case (#two(x, y)) eq(x, item) or eq(y, item);
    case (#three(x, y, z)) eq(x, item) or eq(y, item) or eq(z, item);
    case (#idles(l, r)) Idle.contains(l, eq, item) or Idle.contains(r, eq, item); // note that the order of the right stack is reversed, but for the contains operation it does not matter
    case (#rebal(_)) any<T>(deque, func(t : T) = eq(t, item)); // future work: avoid allocation
  };

  public func peekFront<T>(deque : Deque<T>) : ?T = switch deque {
    case (#empty) null;
    case (#one(x)) ?x;
    case (#two(x, _)) ?x;
    case (#three(x, _, _)) ?x;
    case (#idles((l, _), _)) Stacks.first(l);
    case (#rebal(_)) do ? { popFront(deque)!.0 } // future work: avoid allocation
  };

  public func peekBack<T>(deque : Deque<T>) : ?T = switch deque {
    case (#empty) null;
    case (#one(x)) ?x;
    case (#two(_, y)) ?y;
    case (#three(_, _, z)) ?z;
    case (#idles(_, (r, _))) Stacks.first(r);
    case (#rebal(_)) do ? { popBack(deque)!.1 } // future work: avoid allocation
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
      if (3 * nR >= nL) {
        debug assert 3 * nL >= nR;
        #idles((l, nL), (r, nR))
      } else {
        // initiate the rebalancing process
        let targetSizeL = nL - nR - 1 : Nat;
        let targetSizeR = 2 * nR + 1;
        debug assert targetSizeL + targetSizeR == nL + nR;
        let big = #big1(Current.new(l, targetSizeL), l, null, targetSizeL);
        let small = #small1(Current.new(r, targetSizeR), r, null);
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
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(big, small);
            #idles(big, small)
          };
          case _ #rebal(states4)
        }
      };
      case (#left) {
        let small = SmallState.push(small0, element);
        let states4 = States.step(States.step(States.step(States.step((#left, big0, small)))));
        debug assert states4.0 == #left;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(small, big);
            #idles(small, big) // swapped because dir=left
          };
          case _ #rebal(states4)
        }
      }
    }
  };

  public func pushBack<T>(deque : Deque<T>, element : T) : Deque<T> = reverse(pushFront(reverse(deque), element));

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
        let targetSizeL = 2 * nL + 1;
        let targetSizeR = nR - nL - 1 : Nat;
        debug assert targetSizeL + targetSizeR == nL + nR;
        let small = #small1(Current.new(l, targetSizeL), l, null);
        let big = #big1(Current.new(r, targetSizeR), r, null, targetSizeR);
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
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(small, big);
            ?(x, #idles(small, big))
          };
          case _ ?(x, #rebal(states4))
        }
      };
      case (#right) {
        let (x, big) = BigState.pop(big0);
        let states4 = States.step(States.step(States.step(States.step((#right, big, small0)))));
        debug assert states4.0 == #right;
        switch states4 {
          case (_, #big2(#idle(_, big)), #small3(#idle(_, small))) {
            debug assert idlesInvariant(big, small);
            ?(x, #idles(big, small))
          };
          case _ ?(x, #rebal(states4))
        }
      }
    }
  };

  public func popBack<T>(deque : Deque<T>) : ?(Deque<T>, T) = do ? {
    let (x, deque2) = popFront(reverse(deque))!;
    (reverse(deque2), x)
  };

  public func fromIter<T>(iter : Iter.Iter<T>) : Deque<T> {
    var deque = empty<T>();
    Iter.forEach(iter, func(t : T) = deque := pushBack(deque, t));
    deque
  };

  public func values<T>(deque : Deque<T>) : Iter.Iter<T> {
    // future work: iteration using 'popFront' is wasteful, try avoiding extra allocations
    object {
      var current = deque;
      public func next() : ?T {
        switch (popFront(current)) {
          case null null;
          case (?result) {
            current := result.1;
            ?result.0
          }
        }
      }
    }
  };

  public func equal<T>(deque1 : Deque<T>, deque2 : Deque<T>, equality : (T, T) -> Bool) : Bool = switch (popFront deque1, popFront deque2) {
    case (null, null) true;
    case (?((x1, deque1Tail)), ?((x2, deque2Tail))) equality(x1, x2) and equal(deque1Tail, deque2Tail, equality); // Note that this is tail recursive (`and` is expanded to `if`).
    case _ false
  };

  public func all<T>(deque : Deque<T>, predicate : T -> Bool) : Bool = switch deque {
    case (#empty) true;
    case (#one(x)) predicate x;
    case (#two(x, y)) predicate x and predicate y;
    case (#three(x, y, z)) predicate x and predicate y and predicate z;
    case (#idles(((l1, l2), _), ((r1, r2), _))) List.all(l1, predicate) and List.all(l2, predicate) and List.all(r1, predicate) and List.all(r2, predicate); // note that the order of the right stack is reversed, but for the all operation it does not matter
    case (#rebal(_)) {
      // future work: avoid allocation
      for (t in values deque) if (not predicate t) return false;
      return true
    }
  };

  public func any<T>(deque : Deque<T>, predicate : T -> Bool) : Bool = switch deque {
    case (#empty) false;
    case (#one(x)) predicate x;
    case (#two(x, y)) predicate x or predicate y;
    case (#three(x, y, z)) predicate x or predicate y or predicate z;
    case (#idles(((l1, l2), _), ((r1, r2), _))) List.any(l1, predicate) or List.any(l2, predicate) or List.any(r1, predicate) or List.any(r2, predicate); // note that the order of the right stack is reversed, but for the any operation it does not matter
    case (#rebal(_)) {
      // future work: avoid allocation
      for (t in values deque) if (predicate t) return true;
      return false
    }
  };

  public func forEach<T>(deque : Deque<T>, f : T -> ()) = switch deque {
    case (#empty) ();
    case (#one(x)) f x;
    case (#two(x, y)) { f x; f y };
    case (#three(x, y, z)) { f x; f y; f z };
    // Preserve the order when visiting the elements. Note that the #idles case would require reversing the second stack.
    case _ {
      // future work: avoid allocation
      for (t in values deque) f t
    }
  };

  public func map<T1, T2>(deque : Deque<T1>, f : T1 -> T2) : Deque<T2> = switch deque {
    case (#empty) #empty;
    case (#one(x)) #one(f x);
    case (#two(x, y)) #two(f x, f y);
    case (#three(x, y, z)) #three(f x, f y, f z);
    case (#idles(l, r)) #idles(Idle.map(l, f), Idle.map(r, f));
    case (#rebal(_)) {
      // No reason to rebuild the #rebal state.
      // future work: It could be further optimized by building a balanced #idles state directly since we know the sizes.
      var q = empty<T2>();
      for (t in values deque) q := pushBack(q, f t);
      q
    }
  };

  public func filter<T>(deque : Deque<T>, predicate : T -> Bool) : Deque<T> {
    var q = empty<T>();
    for (t in values deque) if (predicate t) q := pushBack(q, t);
    q
  };

  public func filterMap<T, U>(deque : Deque<T>, f : T -> ?U) : Deque<U> {
    var q = empty<U>();
    for (t in values deque) {
      switch (f t) {
        case (?x) q := pushBack(q, x);
        case null ()
      }
    };
    q
  };

  public func toText<T>(deque : Deque<T>, f : T -> Text) : Text {
    var text = "PureQueue[";
    var first = true;
    for (t in values deque) {
      if (first) first := false else text #= ", ";
      text #= f(t)
    };
    text # "]"
  };

  public func reverse<T>(deque : Deque<T>) : Deque<T> = switch deque {
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
      case (null, null) stacks
    };

    public func first<T>((left, right) : Stacks<T>) : ?T = switch (left) {
      case (?(h, _)) ?h;
      case (null) do ? { right!.0 }
    };

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
    };

    public func contains<T>(stacks : Stacks<T>, equal : (T, T) -> Bool, item : T) : Bool = List.contains(stacks.0, equal, item) or List.contains(stacks.1, equal, item);

    public func map<T, U>((left, right) : Stacks<T>, f : T -> U) : Stacks<U> = (List.map(left, f), List.map(right, f))
  };

  /// Represents an end of the deque that is not in a rebalancing process. It is a stack and its size.
  type Idle<T> = (stacks : Stacks<T>, size : Nat);
  module Idle {
    public func push<T>((stacks, size) : Idle<T>, t : T) : Idle<T> = (Stacks.push(stacks, t), 1 + size);
    public func pop<T>((stacks, size) : Idle<T>) : (T, Idle<T>) = (Stacks.unsafeFirst(stacks), (Stacks.pop(stacks), size - 1 : Nat));

    public func contains<T>((stacks, _) : Idle<T>, equal : (T, T) -> Bool, item : T) : Bool = Stacks.contains(stacks, equal, item);

    public func map<T, U>((stacks, size) : Idle<T>, f : T -> U) : Idle<U> = (Stacks.map(stacks, f), size)
  };

  /// Stores information about operations that happen during rebalancing but which have not become part of the old state that is being rebalanced.
  ///
  /// - `extra`: newly added elements
  /// - `extraSize`: size of `extra`
  /// - `old`: elements contained before the rebalancing process
  /// - `targetSize`: the number of elements which will be contained after the rebalancing is finished
  type Current<T> = (extra : List<T>, extraSize : Nat, old : Stacks<T>, targetSize : Nat);

  module Current {
    public func new<T>(old : Stacks<T>, targetSize : Nat) : Current<T> = (null, 0, old, targetSize);

    public func push<T>((extra, extraSize, old, targetSize) : Current<T>, t : T) : Current<T> = (?(t, extra), 1 + extraSize, old, targetSize);

    public func pop<T>((extra, extraSize, old, targetSize) : Current<T>) : (T, Current<T>) = switch (extra) {
      case (?(h, t)) (h, (t, extraSize - 1 : Nat, old, targetSize));
      case (null) (Stacks.unsafeFirst(old), (null, extraSize, Stacks.pop(old), targetSize - 1 : Nat))
    };

    public func size<T>((_, extraSize, _, targetSize) : Current<T>) : Nat = extraSize + targetSize;

    // public func contains<T>((extra, _, old, _) : Current<T>, equal : (T, T) -> Bool, item : T) : Bool = List.contains(extra, equal, item) or Stacks.contains(old, equal, item) // todo: should be limited to the first `targetSize` elements?
  };

  /// The bigger end of the deque during rebalancing. It is used to split the bigger end of the deque into the new big end and a portion to be added to the small end. Can be in one of the following states:
  ///
  /// - `#big1(cur, big, aux, n)`: Initial stage. Using the step function it takes `n`-elements from the `big` stack and puts them to `aux` in reversed order. `#big1(cur, x1 .. xn : bigTail, [], n) ->* #big1(cur, bigTail, xn .. x1, 0)`. The `bigTail` is later given to the `small` end.
  /// - `#big2(common)`: Is used to reverse the elements from the previous phase to restore the original order. `common = #copy(cur, xn .. x1, [], 0) ->* #copy(cur, [], x1 .. xn, n)`.
  type BigState<T> = {
    #big1 : (Current<T>, Stacks<T>, List<T>, Nat);
    #big2 : CommonState<T>
  };

  module BigState {
    public func push<T>(big : BigState<T>, t : T) : BigState<T> = switch big {
      case (#big1(cur, big, aux, n)) #big1(Current.push(cur, t), big, aux, n);
      case (#big2(state)) #big2(CommonState.push(state, t))
    };

    public func pop<T>(big : BigState<T>) : (T, BigState<T>) = switch big {
      case (#big1(cur, big, aux, n)) {
        let (x, cur2) = Current.pop(cur);
        (x, #big1(cur2, big, aux, n))
      };
      case (#big2(state)) {
        let (x, state2) = CommonState.pop(state);
        (x, #big2(state2))
      }
    };

    public func step<T>(big : BigState<T>) : BigState<T> = switch big {
      case (#big1(cur, big, aux, n)) {
        if (n == 0)
        #big2(CommonState.norm(#copy(cur, aux, null, 0))) else
        #big1(cur, Stacks.pop(big), ?(Stacks.unsafeFirst(big), aux), n - 1 : Nat)
      };
      case (#big2(state)) #big2(CommonState.step(state))
    };

    public func size<T>(big : BigState<T>) : Nat = switch big {
      case (#big1(cur, _, _, _)) Current.size(cur);
      case (#big2(state)) CommonState.size(state)
    };

    // public func contains<T>(big : BigState<T>, equal : (T, T) -> Bool, item : T) : Bool = switch big {
    //   case (#big1(cur, big, _, _)) Current.contains(cur, equal, item);
    //   case (#big2(state)) CommonState.contains(state, equal, item)
    // }
  };

  /// The smaller end of the deque during rebalancing. Can be in one of the following states:
  ///
  /// - `#small1(cur, small, aux)`: Initial stage. Using the step function the original elements are reversed. `#small1(cur, s1 .. sn, []) ->* #small1(cur, [], sn .. s1)`, note that `aux` is initially empty, at the end contains the reversed elements from the small stack.
  /// - `#small2(cur, aux, big, new, size)`: Using the step function the newly transfered tail from the bigger end is reversed on top of the `new` list. `#small2(cur, sn .. s1, b1 .. bm, [], 0) ->* #small2(cur, sn .. s1, [], bm .. b1, m)`, note that `aux` is the reversed small stack from the previous phase, `new` is initially empty, `size` corresponds to the size of `new`.
  /// - `#small3(common)`: Is used to reverse the elements from the two previous phases again to get them again in the original order. `#copy(cur, sn .. s1, bm .. b1, m) ->* #copy(cur, [], s1 .. sn : bm .. b1, n + m)`, note that the correct order of the elements from the big stack is reversed.
  type SmallState<T> = {
    #small1 : (Current<T>, Stacks<T>, List<T>);
    #small2 : (Current<T>, List<T>, Stacks<T>, List<T>, Nat);
    #small3 : CommonState<T>
  };

  module SmallState {
    public func push<T>(state : SmallState<T>, t : T) : SmallState<T> = switch state {
      case (#small1(cur, small, aux)) #small1(Current.push(cur, t), small, aux);
      case (#small2(cur, aux, big, new, newN)) #small2(Current.push(cur, t), aux, big, new, newN);
      case (#small3(common)) #small3(CommonState.push(common, t))
    };

    public func pop<T>(state : SmallState<T>) : (T, SmallState<T>) = switch state {
      case (#small1(cur0, small, aux)) {
        let (t, cur) = Current.pop(cur0);
        (t, #small1(cur, small, aux))
      };
      case (#small2(cur0, aux, big, new, newN)) {
        let (t, cur) = Current.pop(cur0);
        (t, #small2(cur, aux, big, new, newN))
      };
      case (#small3(common0)) {
        let (t, common) = CommonState.pop(common0);
        (t, #small3(common))
      }
    };

    public func step<T>(state : SmallState<T>) : SmallState<T> = switch state {
      case (#small1(cur, small, aux)) {
        if (Stacks.isEmpty(small)) state else #small1(cur, Stacks.pop(small), ?(Stacks.unsafeFirst(small), aux))
      };
      case (#small2(cur, aux, big, new, newN)) {
        if (Stacks.isEmpty(big)) #small3(CommonState.norm(#copy(cur, aux, new, newN))) else #small2(cur, aux, Stacks.pop(big), ?(Stacks.unsafeFirst(big), new), 1 + newN)
      };
      case (#small3(common)) #small3(CommonState.step(common))
    };

    public func size<T>(state : SmallState<T>) : Nat = switch state {
      case (#small1(cur, _, _)) Current.size(cur);
      case (#small2(cur, _, _, _, _)) Current.size(cur);
      case (#small3(common)) CommonState.size(common)
    }
  };

  type CopyState<T> = { #copy : (Current<T>, List<T>, List<T>, Nat) };

  /// Represents the last rebalancing phase of both small and big ends of the deque. It is used to reverse the elements from the previous phases to restore the original order. It can be in one of the following states:
  ///
  /// - `#copy(cur, aux, new, sizeOfNew)`: Puts the elements from `aux` in reversed order on top of `new`. `#copy(cur, xn .. x1, new, sizeOfNew) ->* #copy(cur, [], x1 .. xn : new, n + sizeOfNew)`.
  /// - `#idle(cur, idle)`: The rebalancing process is done and the deque is in the idle state.
  type CommonState<T> = CopyState<T> or { #idle : (Current<T>, Idle<T>) };

  module CommonState {
    public func step<T>(common : CommonState<T>) : CommonState<T> = switch common {
      case (#copy copy) {
        let (cur, aux, new, sizeOfNew) = copy;
        let (_, _, _, targetSize) = cur;
        norm(if (sizeOfNew < targetSize) #copy(cur, unsafeTail(aux), ?(unsafeHead(aux), new), 1 + sizeOfNew) else #copy copy)
      };
      case (#idle(_, _)) common
    };

    public func norm<T>(copy : CopyState<T>) : CommonState<T> {
      let #copy(cur, _, new, sizeOfNew) = copy;
      let (extra, extraSize, _, targetSize) = cur;
      debug assert sizeOfNew <= targetSize;
      if (sizeOfNew >= targetSize) {
        #idle(cur, ((extra, new), extraSize + sizeOfNew)) // note: aux can be non-empty, thus ignored here, when the target size decreases after pop operations
      } else copy
    };

    public func push<T>(common : CommonState<T>, t : T) : CommonState<T> = switch common {
      case (#copy(cur, aux, new, sizeOfNew)) #copy(Current.push(cur, t), aux, new, sizeOfNew);
      case (#idle(cur, idle)) #idle(Current.push(cur, t), Idle.push(idle, t)) // yes, push to both
    };

    public func pop<T>(common : CommonState<T>) : (T, CommonState<T>) = switch common {
      case (#copy(cur, aux, new, sizeOfNew)) {
        let (t, cur2) = Current.pop(cur);
        (t, norm(#copy(cur2, aux, new, sizeOfNew)))
      };
      case (#idle(cur, idle)) {
        let (t, idle2) = Idle.pop(idle);
        (t, #idle(Current.pop(cur).1, idle2))
      }
    };

    public func size<T>(common : CommonState<T>) : Nat = switch common {
      case (#copy(cur, _, _, _)) Current.size(cur);
      case (#idle(_, (_, size))) size
    };

    // public func contains<T>(common : CommonState<T>, equal : (T, T) -> Bool, item : T) : Bool = switch common {
    //   case (#copy(cur, aux, _, _)) Current.contains(cur, equal, item) or List.contains(aux, equal, item); // todo: is this correct?
    //   case (#idle(_, idle)) Idle.contains(idle, equal, item)
    // }
  };

  type States<T> = (
    direction : Direction,
    bigState : BigState<T>,
    smallState : SmallState<T>
  );

  module States {
    public func step<T>(states : States<T>) : States<T> = switch states {
      case (dir, #big1(_, bigTail, _, 0), #small1(currentS, _, auxS)) {
        (dir, BigState.step(states.1), #small2(currentS, auxS, bigTail, null, 0))
      };
      case (dir, big, small) (dir, BigState.step(big), SmallState.step(small))
    }
  };

  type Direction = { #left; #right };

  public func idlesInvariant<T>(((l, nL), (r, nR)) : (Idle<T>, Idle<T>)) : Bool = Stacks.size(l) == nL and Stacks.size(r) == nR and 3 * nL >= nR and 3 * nR >= nL;

  type List<T> = Types.Pure.List<T>;
  func unsafeHead<T>(l : List<T>) : T = Option.unwrap(l).0;
  func unsafeTail<T>(l : List<T>) : List<T> = Option.unwrap(l).1
}
