/// Utility functions for `Text` values

import Char "Char";
import Iter "Iter";
import Hash "Hash";
import List "functional/List";
import Stack "functional/Stack";
import Prim "mo:⛔";

module {

  public type Text = Prim.Types.Text;

  public let fromChar : (c : Char) -> Text = Prim.charToText;

  public func fromArray(a : [Char]) : Text = fromIter(a.vals());

  public func fromVarArray(a : [var Char]) : Text = fromIter(a.vals());

  public func toIter(t : Text) : Iter.Iter<Char> = t.chars();

  public func toArray(t : Text) : [Char] {
    let cs = t.chars();
    Prim.Array_tabulate<Char>(
      t.size(),
      func _ {
        switch (cs.next()) {
          case (?c) { c };
          case null { Prim.trap("Text.toArray") };
        };
      }
    )
  };

  public func toVarArray(t : Text) : [var Char] {
    let n = t.size();
    if (n == 0) {
      return [var];
    };
    let array = Prim.Array_init<Char>(n, ' ');
    var i = 0;
    for (c in t.chars()) {
      array[i] := c;
      i += 1;
    };
    array
  };

  public func fromIter(cs : Iter.Iter<Char>) : Text {
    var r = "";
    for (c in cs) {
      r #= Prim.charToText(c)
    };
    return r
  };

  public func fromList(cs : List.List<Char>) : Text = fromIter(List.toIter cs);

  public func toList(t : Text) : List.List<Char> {
    var acc : List.List<Char> = null;
    for (c in t.chars()) {
        acc := ?(c, acc)
    };
    List.reverse acc
  };

  public func size(t : Text) : Nat { t.size() };

  public func hash(t : Text) : Hash.Hash {
    var x : Nat32 = 5381;
    for (char in t.chars()) {
      let c : Nat32 = Prim.charToNat32(char);
      x := ((x << 5) +% x) +% c
    };
    return x
  };

  public func concat(t1 : Text, t2 : Text) : Text = t1 # t2;

  public func equal(t1 : Text, t2 : Text) : Bool { t1 == t2 };

  public func notEqual(t1 : Text, t2 : Text) : Bool { t1 != t2 };

  public func less(t1 : Text, t2 : Text) : Bool { t1 < t2 };

  public func lessOrEqual(t1 : Text, t2 : Text) : Bool { t1 <= t2 };

  public func greater(t1 : Text, t2 : Text) : Bool { t1 > t2 };

  public func greaterOrEqual(t1 : Text, t2 : Text) : Bool { t1 >= t2 };

  public func compare(t1 : Text, t2 : Text) : { #less; #equal; #greater } {
    let c = Prim.textCompare(t1, t2);
    if (c < 0) #less else if (c == 0) #equal else #greater
  };

  private func extract(t : Text, i : Nat, j : Nat) : Text {
    let size = t.size();
    if (i == 0 and j == size) return t;
    assert (j <= size);
    let cs = t.chars();
    var r = "";
    var n = i;
    while (n > 0) {
      ignore cs.next();
      n -= 1
    };
    n := j;
    while (n > 0) {
      switch (cs.next()) {
        case null { assert false };
        case (?c) { r #= Prim.charToText(c) }
      };
      n -= 1
    };
    return r
  };

  public func join(sep : Text, ts : Iter.Iter<Text>) : Text {
    var r = "";
    if (sep.size() == 0) {
      for (t in ts) {
        r #= t
      };
      return r
    };
    let next = ts.next;
    switch (next()) {
      case null { return r };
      case (?t) {
        r #= t
      }
    };
    loop {
      switch (next()) {
        case null { return r };
        case (?t) {
          r #= sep;
          r #= t
        }
      }
    }
  };

  public func map(t : Text, f : Char -> Char) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= Prim.charToText(f(c))
    };
    return r
  };

  public func translate(t : Text, f : Char -> Text) : Text {
    var r = "";
    for (c in t.chars()) {
      r #= f(c)
    };
    return r
  };

  public type Pattern = {
    #char : Char;
    #text : Text;
    #predicate : (Char -> Bool)
  };

  private func take(n : Nat, cs : Iter.Iter<Char>) : Iter.Iter<Char> {
    var i = n;
    object {
      public func next() : ?Char {
        if (i == 0) return null;
        i -= 1;
        return cs.next()
      }
    }
  };

  private func empty() : Iter.Iter<Char> {
    object {
      public func next() : ?Char = null
    }
  };

  private type Match = {
    #success;
    #fail : (cs : Iter.Iter<Char>, c : Char);
    #empty : (cs : Iter.Iter<Char>)
  };

  private func sizeOfPattern(pat : Pattern) : Nat {
    switch pat {
      case (#text(t)) { t.size() };
      case (#predicate(_) or #char(_)) { 1 }
    }
  };

  private func matchOfPattern(pat : Pattern) : (cs : Iter.Iter<Char>) -> Match {
    switch pat {
      case (#char(p)) {
        func(cs : Iter.Iter<Char>) : Match {
          switch (cs.next()) {
            case (?c) {
              if (p == c) {
                #success
              } else {
                #fail(empty(), c)
              }
            };
            case null { #empty(empty()) }
          }
        }
      };
      case (#predicate(p)) {
        func(cs : Iter.Iter<Char>) : Match {
          switch (cs.next()) {
            case (?c) {
              if (p(c)) {
                #success
              } else {
                #fail(empty(), c)
              }
            };
            case null { #empty(empty()) }
          }
        }
      };
      case (#text(p)) {
        func(cs : Iter.Iter<Char>) : Match {
          var i = 0;
          let ds = p.chars();
          loop {
            switch (ds.next()) {
              case (?d) {
                switch (cs.next()) {
                  case (?c) {
                    if (c != d) {
                      return #fail(take(i, p.chars()), c)
                    };
                    i += 1
                  };
                  case null {
                    return #empty(take(i, p.chars()))
                  }
                }
              };
              case null { return #success }
            }
          }
        }
      }
    }
  };

  private class CharBuffer(cs : Iter.Iter<Char>) : Iter.Iter<Char> = {

    var stack : Stack.Stack<(Iter.Iter<Char>, Char)> = Stack.Stack();

    public func pushBack(cs0 : Iter.Iter<Char>, c : Char) {
      stack.push((cs0, c))
    };

    public func next() : ?Char {
      switch (stack.peek()) {
        case (?(buff, c)) {
          switch (buff.next()) {
            case null {
              ignore stack.pop();
              return ?c
            };
            case oc {
              return oc
            }
          }
        };
        case null {
          return cs.next()
        }
      }
    }
  };

  public func split(t : Text, p : Pattern) : Iter.Iter<Text> {
    let match = matchOfPattern(p);
    let cs = CharBuffer(t.chars());
    var state = 0;
    var field = "";
    object {
      public func next() : ?Text {
        switch state {
          case (0 or 1) {
            loop {
              switch (match(cs)) {
                case (#success) {
                  let r = field;
                  field := "";
                  state := 1;
                  return ?r
                };
                case (#empty(cs1)) {
                  for (c in cs1) {
                    field #= fromChar(c)
                  };
                  let r = if (state == 0 and field == "") {
                    null
                  } else {
                    ?field
                  };
                  state := 2;
                  return r
                };
                case (#fail(cs1, c)) {
                  cs.pushBack(cs1, c);
                  switch (cs.next()) {
                    case (?ci) {
                      field #= fromChar(ci)
                    };
                    case null {
                      let r = if (state == 0 and field == "") {
                        null
                      } else {
                        ?field
                      };
                      state := 2;
                      return r
                    }
                  }
                }
              }
            }
          };
          case _ { return null }
        }
      }
    }
  };

  public func tokens(t : Text, p : Pattern) : Iter.Iter<Text> {
    let fs = split(t, p);
    object {
      public func next() : ?Text {
        switch (fs.next()) {
          case (?"") { next() };
          case ot { ot }
        }
      }
    }
  };

  public func contains(t : Text, p : Pattern) : Bool {
    let match = matchOfPattern(p);
    let cs = CharBuffer(t.chars());
    loop {
      switch (match(cs)) {
        case (#success) {
          return true
        };
        case (#empty(_cs1)) {
          return false
        };
        case (#fail(cs1, c)) {
          cs.pushBack(cs1, c);
          switch (cs.next()) {
            case null {
              return false
            };
            case _ {}; // continue
          }
        }
      }
    }
  };

  public func startsWith(t : Text, p : Pattern) : Bool {
    var cs = t.chars();
    let match = matchOfPattern(p);
    switch (match(cs)) {
      case (#success) { true };
      case _ { false }
    }
  };

  public func endsWith(t : Text, p : Pattern) : Bool {
    let s2 = sizeOfPattern(p);
    if (s2 == 0) return true;
    let s1 = t.size();
    if (s2 > s1) return false;
    let match = matchOfPattern(p);
    var cs1 = t.chars();
    var diff : Nat = s1 - s2;
    while (diff > 0) {
      ignore cs1.next();
      diff -= 1
    };
    switch (match(cs1)) {
      case (#success) { true };
      case _ { false }
    }
  };

  public func replace(t : Text, p : Pattern, r : Text) : Text {
    let match = matchOfPattern(p);
    let size = sizeOfPattern(p);
    let cs = CharBuffer(t.chars());
    var res = "";
    label l loop {
      switch (match(cs)) {
        case (#success) {
          res #= r;
          if (size > 0) {
            continue l
          }
        };
        case (#empty(cs1)) {
          for (c1 in cs1) {
            res #= fromChar(c1)
          };
          break l
        };
        case (#fail(cs1, c)) {
          cs.pushBack(cs1, c)
        }
      };
      switch (cs.next()) {
        case null {
          break l
        };
        case (?c1) {
          res #= fromChar(c1)
        }; // continue
      }
    };
    return res
  };

  public func stripStart(t : Text, p : Pattern) : ?Text {
    let s = sizeOfPattern(p);
    if (s == 0) return ?t;
    var cs = t.chars();
    let match = matchOfPattern(p);
    switch (match(cs)) {
      case (#success) return ?fromIter(cs);
      case _ return null
    }
  };

  public func stripEnd(t : Text, p : Pattern) : ?Text {
    let s2 = sizeOfPattern(p);
    if (s2 == 0) return ?t;
    let s1 = t.size();
    if (s2 > s1) return null;
    let match = matchOfPattern(p);
    var cs1 = t.chars();
    var diff : Nat = s1 - s2;
    while (diff > 0) {
      ignore cs1.next();
      diff -= 1
    };
    switch (match(cs1)) {
      case (#success) return ?extract(t, 0, s1 - s2);
      case _ return null
    }
  };

  public func trimStart(t : Text, p : Pattern) : Text {
    let cs = t.chars();
    let size = sizeOfPattern(p);
    if (size == 0) return t;
    var matchSize = 0;
    let match = matchOfPattern(p);
    loop {
      switch (match(cs)) {
        case (#success) {
          matchSize += size
        }; // continue
        case (#empty(cs1)) {
          return if (matchSize == 0) {
            t
          } else {
            fromIter(cs1)
          }
        };
        case (#fail(cs1, c)) {
          return if (matchSize == 0) {
            t
          } else {
            fromIter(cs1) # fromChar(c) # fromIter(cs)
          }
        }
      }
    }
  };

  public func trimEnd(t : Text, p : Pattern) : Text {
    let cs = CharBuffer(t.chars());
    let size = sizeOfPattern(p);
    if (size == 0) return t;
    let match = matchOfPattern(p);
    var matchSize = 0;
    label l loop {
      switch (match(cs)) {
        case (#success) {
          matchSize += size
        }; // continue
        case (#empty(cs1)) {
          switch (cs1.next()) {
            case null break l;
            case (?_) return t
          }
        };
        case (#fail(cs1, c)) {
          matchSize := 0;
          cs.pushBack(cs1, c);
          ignore cs.next()
        }
      }
    };
    extract(t, 0, t.size() - matchSize)
  };

  public func trim(t : Text, p : Pattern) : Text {
    let cs = t.chars();
    let size = sizeOfPattern(p);
    if (size == 0) return t;
    var matchSize = 0;
    let match = matchOfPattern(p);
    loop {
      switch (match(cs)) {
        case (#success) {
          matchSize += size
        }; // continue
        case (#empty(cs1)) {
          return if (matchSize == 0) { t } else { fromIter(cs1) }
        };
        case (#fail(cs1, c)) {
          let start = matchSize;
          let cs2 = CharBuffer(cs);
          cs2.pushBack(cs1, c);
          ignore cs2.next();
          matchSize := 0;
          label l loop {
            switch (match(cs2)) {
              case (#success) {
                matchSize += size
              }; // continue
              case (#empty(_cs3)) {
                switch (cs1.next()) {
                  case null break l;
                  case (?_) return t
                }
              };
              case (#fail(cs3, c1)) {
                matchSize := 0;
                cs2.pushBack(cs3, c1);
                ignore cs2.next()
              }
            }
          };
          return extract(t, start, t.size() - matchSize - start)
        }
      }
    }
  };

  public func compareWith(
    t1 : Text,
    t2 : Text,
    cmp : (Char, Char) -> { #less; #equal; #greater }
  ) : { #less; #equal; #greater } {
    let cs1 = t1.chars();
    let cs2 = t2.chars();
    loop {
      switch (cs1.next(), cs2.next()) {
        case (null, null) { return #equal };
        case (null, ?_) { return #less };
        case (?_, null) { return #greater };
        case (?c1, ?c2) {
          switch (cmp(c1, c2)) {
            case (#equal) {}; // continue
            case other { return other }
          }
        }
      }
    }
  };

  public let encodeUtf8 : Text -> Blob = Prim.encodeUtf8;

  public let decodeUtf8 : Blob -> ?Text = Prim.decodeUtf8;

  public let toLowercase : Text -> Text = Prim.textLowercase;

  public let toUppercase : Text -> Text = Prim.textUppercase;
}