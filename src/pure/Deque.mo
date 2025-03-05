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
    public func pop() : Idle<T> = if (size == 0) self else Idle(stacks.pop(), size - 1 : Nat)
  };

  /// Stores information about operations that happen during rebalancing but which have not become part of the old state that is being rebalanced.
  class Current<T>(ext : List<T>, extSize : Nat, old : Stacks<T>, targetSize : Nat) {
    debug assert List.size(ext) == extSize;

    public func push(t : T) : Current<T> = Current(?(t, ext), 1 + extSize, old, targetSize);
    public func pop() : (T, Current<T>) = switch (ext) {
      case (?(h, t)) (h, Current(t, extSize - 1 : Nat, old, targetSize));
      case (null) (old.unsafeFirst(), Current(null, extSize, old.pop(), targetSize - 1 : Nat))
    }
  };

  type States<T> = {
    direction : Direction;
    bigState : BigState<T>;
    smallState : SmallState<T>
  };

  type Direction = { #left; #right };

  type BigState<T> = {
    #big1 : (Current<T>, Stacks<T>, List<T>, Nat);
    #big2 : CommonState<T>
  };

  type SmallState<T> = {
    #small1 : (Current<T>, Stacks<T>, List<T>);
    #small2 : (Current<T>, List<T>, Stacks<T>, List<T>, Nat);
    #small3 : CommonState<T>
  };

  type CommonState<T> = {
    #copy : (Current<T>, List<T>, List<T>, Nat);
    #idle : (Current<T>, Idle<T>)
  };

  type List<T> = Types.Pure.List<T>
}
