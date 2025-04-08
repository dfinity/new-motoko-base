# Changelog

## Next

* Add `isReplicated : () -> Bool` to `InternetComputer` (#213).
* Add `burn : <system>Nat -> Nat` to `Cycles` (#228).
* Add `isEmpty : _ -> Bool` to `Blob` and `Text` (#263).
* Fix bug in `Iter.step()` (#???).
* Fix bug in `Array.enumerate()` and `VarArray.enumerate()` (#???).
* Fix argument order for `Result.compare()` and `Result.equal()` (#???).
* Adjust `Random` representation to allow persistence in stable memory (#???).

## 0.3.0

* Rename `List.push()` to `pushFront()` and `List.pop()` to `popFront()` (#???).

## 0.2.2

* Add range functions to `Random.crypto()` (#215).
* Add `isRetryPossible : Error -> Bool` to `Error` (#211).

## 0.2.1

* Cleanups in `pure/List` test, fixes and docstrings in `pure/Queue`
* Bump `motoko-matchers` to 1.3.1

## 0.2.0

* Make `replyDeadline` an optional return type

## 0.1.1

* Update readme

## 0.1.0

* Initial release
