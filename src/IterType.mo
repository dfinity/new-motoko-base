/// The built-in iterator type

// This is separate from `Iter.mo` to break cyclic module definitions

module {

  public type Iter<T> = { next : () -> ?T };

}
