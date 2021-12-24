package com.pomadchin.day24

import scala.io.Source
import scala.collection.mutable
import scala.util.Try
import scala.util.Success

object Solution:
  def readInput(path: String = "src/main/resources/day24/puzzle1.txt"): List[List[Expr]] =
    Source
      .fromFile(path)
      .getLines
      .grouped(18)
      .toList
      .map { g =>
        g.toList.flatMap { s =>
          s.split(" ").toList match
            case List(op, a) =>
              op match
                case "inp" => Some(Input(ExprValue(a)))
                case _     => None

            case List(op, a, b) =>
              op match
                case "add" => Some(Add(ExprValue(a), ExprValue(b)))
                case "mul" => Some(Mul(ExprValue(a), ExprValue(b)))
                case "div" => Some(Div(ExprValue(a), ExprValue(b)))
                case "mod" => Some(Mod(ExprValue(a), ExprValue(b)))
                case "eql" => Some(Eql(ExprValue(a), ExprValue(b)))
                case _     => None

            case _ => None
        }
      }

  def boolToInt(b: Boolean): Int = if b then 0 else 1

  // inp a - Read an input value and write it to variable a.
  // add a b - Add the value of a to the value of b, then store the result in variable a.
  // mul a b - Multiply the value of a by the value of b, then store the result in variable a.
  // div a b - Divide the value of a by the value of b, truncate the result to an integer, then store the result in variable a. (Here, "truncate" means to round the value toward zero.)
  // mod a b - Divide the value of a by the value of b, then store the remainder in variable a. (This is also called the modulo operation.)
  // eql a b - If the value of a and b are equal, then store the value 1 in variable a. Otherwise, store the value 0 in variable a.

  sealed trait Expr
  case class Input(a: ExprValue)             extends Expr
  case class Add(a: ExprValue, b: ExprValue) extends Expr
  case class Mul(a: ExprValue, b: ExprValue) extends Expr
  case class Div(a: ExprValue, b: ExprValue) extends Expr
  case class Mod(a: ExprValue, b: ExprValue) extends Expr
  case class Eql(a: ExprValue, b: ExprValue) extends Expr

  sealed trait ExprValue
  case class Ref(a: String) extends ExprValue:
    override def toString: String = a
  case class Value(a: Int) extends ExprValue:
    override def toString: String = a.toString

  object ExprValue:
    def apply(s: String): ExprValue =
      Try(s.toInt) match
        case Success(v) => Value(v)
        case _          => Ref(s)

  opaque type State = Map[String, Long]
  object State:
    def apply(m: Map[String, Long]): State = m
    def init: State                        = apply(Map("x" -> 0, "y" -> 0, "z" -> 0, "w" -> 0))

  extension (s: State)
    def Z: Long      = s("z")
    def isZ: Boolean = Z == 0L

  opaque type MutableState = mutable.Map[String, Long]
  object MutableState:
    def apply(m: mutable.Map[String, Long]): MutableState = m
    def init: MutableState =
      val m = mutable.Map[String, Long]()
      m.put("x", 0)
      m.put("y", 0)
      m.put("z", 0)
      m.put("w", 0)
      apply(m)

  extension (s: MutableState)
    def Z: Long      = s("z")
    def isZ: Boolean = Z == 0L

  def evalExpr(e: Expr, s: State, in: Int): State =
    e match
      case Input(Ref(a))         => s + (a -> in)
      case Add(Ref(a), Value(b)) => s + (a -> (s(a) + b))
      case Add(Ref(a), Ref(b))   => s + (a -> (s(a) + s(b)))
      case Mul(Ref(a), Value(b)) => s + (a -> (s(a) * b))
      case Mul(Ref(a), Ref(b))   => s + (a -> (s(a) * s(b)))
      case Div(Ref(a), Value(b)) => s + (a -> (s(a) / b))
      case Div(Ref(a), Ref(b))   => s + (a -> (s(a) / s(b)))
      case Mod(Ref(a), Value(b)) => s + (a -> (s(a) % b))
      case Mod(Ref(a), Ref(b))   => s + (a -> (s(a) % s(b)))
      case Eql(Ref(a), Value(b)) => s + (a -> boolToInt(s(a) == b))
      case Eql(Ref(a), Ref(b))   => s + (a -> boolToInt(s(a) == s(b)))

  def evalExpr(e: Expr, s: MutableState, in: Int): Unit =
    e match
      case Input(Ref(a))         => s.update(a, in)
      case Add(Ref(a), Value(b)) => s.update(a, (s(a) + b))
      case Add(Ref(a), Ref(b))   => s.update(a, (s(a) + s(b)))
      case Mul(Ref(a), Value(b)) => s.update(a, (s(a) * b))
      case Mul(Ref(a), Ref(b))   => s.update(a, (s(a) * s(b)))
      case Div(Ref(a), Value(b)) => s.update(a, (s(a) / b))
      case Div(Ref(a), Ref(b))   => s.update(a, (s(a) / s(b)))
      case Mod(Ref(a), Value(b)) => s.update(a, (s(a) % b))
      case Mod(Ref(a), Ref(b))   => s.update(a, (s(a) % s(b)))
      case Eql(Ref(a), Value(b)) => s.update(a, boolToInt(s(a) == b))
      case Eql(Ref(a), Ref(b))   => s.update(a, boolToInt(s(a) == s(b)))

  def evalBlock(block: List[Expr], s: State, in: Int): State =
    block.foldLeft(s)((s, e) => evalExpr(e, s, in))

  def evalBlock(block: List[Expr], s: MutableState, in: Int): Unit =
    block.foreach(e => evalExpr(e, s, in))

  def execute(prog: List[List[Expr]], inputs: Seq[Int]): Long =
    var result = 0L
    // not by me, discovered this beatiful approach to executing the machine code quickly
    // my approach with mutable state didn't quite work out, due to complexity of computations
    // here we can memoize what is the result for the specific state & input
    val memo = mutable.Map.empty[(Int, State), Boolean]
    def eval(num: Long, block: Int, s: State): Boolean =
      if (block > 14) false
      else if memo.contains(block, s) then memo((block, s))
      else if block == 14 then
        memo((block, s)) = false
        if (s.isZ)
          result = num
          memo((block, s)) = true

        memo((block, s))
      else if s.Z > 26 * 26 * 26 * 26 * 26 then false
      else
        var result = false
        for x <- inputs do
          var res = evalBlock(prog(block), s, x)
          result ||= eval(num = num * 10 + x, block + 1, res)

        // memo result for a speicif input
        memo((block, s)) = result
        result

    eval(0, 0, State.init)
    result

  def part1(input: List[List[Expr]]): Long =
    execute(input, 9 to 1 by -1)

  def part2(input: List[List[Expr]]): Long =
    execute(input, 1 to 9 by 1)
