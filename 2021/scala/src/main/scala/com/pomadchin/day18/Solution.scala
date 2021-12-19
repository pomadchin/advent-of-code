package com.pomadchin.day18

import scala.io.Source
import scala.collection.mutable
import scala.annotation.tailrec
import scala.util.chaining.*

// tree can be used as a representation of a snail fish
// [1,2]
// [[1,2],3]
// [9,[8,7]]
// [[1,9],[8,5]]
// [[[[1,2],[3,4]],[[5,6],[7,8]]],9]
sealed trait Tree:
  def add(lv: Int, rv: Int): Tree = Tree.add(this, lv, rv)

  override def toString: String =
    def rec(t: Tree): String = t match
      case Leaf(v)      => v.toString
      case Branch(l, r) => s"[${rec(l)},${rec(r)}]"
    rec(this)

object Tree:
  def add(t: Tree, lv: Int, rv: Int): Tree =
    t match
      case Leaf(v)      => Leaf(lv + v + rv)
      case Branch(l, r) => Branch(add(l, lv, 0), add(r, 0, rv))

case class Leaf(v: Int)             extends Tree
case class Branch(l: Tree, r: Tree) extends Tree

object Solution:
  def parse(s: String): Tree =
    // p is the position
    // it is also the 'left' position
    @tailrec
    def rec(p: Int, stack: List[Char]): Tree =
      s.charAt(p) match
        // if the start of a tree
        // go deeper
        case '[' => rec(p + 1, '[' :: stack)
        // pop the stack in case we close the brace
        case ']'                      => rec(p + 1, stack.tail)
        case ',' if stack.length == 1 =>
          // in case the nested level is 1
          // go down, skip the first [, drop the last (outer) ] as well
          // we split the first
          Branch(parse(s.substring(1, p)), parse(s.substring(p + 1, s.length - 1)))
        // the end of a tree, only works when the stack is empty
        case s if s.isDigit && stack.isEmpty => Leaf(s.asDigit)
        // in all other scan forward
        // i.e. [[1,9],[8,5]]
        // p = 0, stack = [
        // p = 1, stack = [[
        // p = 2, stack = [[ (digit)
        // p = 3, stack = [[ (,)
        // p = 4, stack = [[ (digit)
        // p = 5, stack = [ (pop)
        // p = 6, stack = [ and we found a comma => split into two chunks of the nested level '1'
        // repeat
        case _ => rec(p + 1, stack)

    rec(0, Nil)

  def addition(l: Tree, r: Tree): Tree = reduce(Branch(l, r))

  // * If any pair is nested inside four pairs, the leftmost such pair explodes.
  // * If any regular number is 10 or greater, the leftmost such regular number splits.
  //
  // During reduction, at most one action applies, after which the process returns to the top of the list of actions.
  // For example, if split produces a pair that meets the explode criteria, that pair explodes before other splits occur.
  def reduce(tree: Tree): Tree =
    val (te, exploded) = explode(tree)
    if exploded then reduce(te)
    else
      val (ts, splitted) = split(te)
      if splitted then reduce(ts)
      else ts

  /**
   * To explode a pair, the pair's left value is added to the first regular number to the left of the exploding pair (if any), and the pair's right
   * value is added to the first regular number to the right of the exploding pair (if any). Exploding pairs will always consist of two regular
   * numbers. Then, the entire exploding pair is replaced with the regular number 0.
   */
  def explode(t: Tree): (Tree, Boolean) =
    // traverse through the tree, contains the new tree, left and right value of the leaf to explode, explosion fact
    // [[[[[9,8],1],2],3],4] => [[[[0,9],2],3],4]
    // [[6,[5,[4,[3,2]]]],1] becomes [[6,[5,[7,0]]],3].
    def explode(t: Tree, level: Int, exploded: Boolean): (Tree, Int, Int, Boolean) =
      t match
        case Branch(Leaf(l), Leaf(r)) if level >= 4 && !exploded => (Leaf(0), l, r, true)
        case Branch(l, r)                                        =>
          // visit the left branch first
          val (lt, ll, lr, le) = explode(l, level + 1, exploded)
          // don't explode the right one if the left is already exploded
          val (rt, rl, rr, re) = explode(r, level + 1, le)

          // always propogate ll and rr to the top
          // it is leaf values always on the very bottom
          // letter one of them is 0 and brought to the top along with non zero

          // to the left tree add the left of the right + 0
          // to the right tree add the right of the left + 0
          (Branch(lt.add(0, rl), rt.add(lr, 0)), ll, rr, re)

        case l: Leaf => (l, 0, 0, exploded)

    val (res, _, _, exploded) = explode(t, 0, false)
    (res, exploded)

  // [[[[0,7],4],[15,[0,13]]],[1,1]] =>
  //   * [[[[0,7],4],[[7,8],[0,13]]],[1,1]] =>
  //     * [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]
  def split(t: Tree): (Tree, Boolean) =
    def split(t: Tree, splitted: Boolean): (Tree, Boolean) =
      t match
        case Leaf(v) if v > 9 && !splitted =>
          (Branch(Leaf(math.floor(v.toDouble / 2).toInt), Leaf(math.ceil(v.toDouble / 2).toInt)), true)
        case Branch(l, r) =>
          val (lt, ls) = split(l, splitted)
          val (rt, rs) = split(r, ls)
          Branch(lt, rt) -> rs
        case l: Leaf => (l, splitted)
    split(t, false)

  // For example, the magnitude of [9,1] is 3*9 + 2*1 = 29; the magnitude of [1,9] is 3*1 + 2*9 = 21.
  // Magnitude calculations are recursive: the magnitude of [[9,1],[1,9]] is 3*29 + 2*21 = 129.
  def magnitude(t: Tree): Int =
    t match
      case Branch(l, r) => 3 * magnitude(l) + 2 * magnitude(r)
      case Leaf(v)      => v

  def readInputRaw(path: String = "src/main/resources/day18/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
  def readInput(path: String = "src/main/resources/day18/puzzle1.txt"): Iterator[Tree] =
    readInputRaw(path).map(parse)

  def part1(input: List[Tree]): Int = magnitude(input.reduceLeft(addition))
