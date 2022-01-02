package com.pomadchin.day2

import scala.io.Source

object Solution:
  // rec scehemes solution
  import cats.{Functor, Monoid}
  import cats.syntax.monoid.*
  import higherkindness.droste.{scheme, Algebra, Coalgebra}
  import higherkindness.droste.data.Fix
  import higherkindness.droste.data.list.*

  // a higher kinded list
  // we actually have ListF, so we don't need these case classes here
  sealed trait DirectionF[+A, +B]
  case class DirectionConsF[A, B](head: A, tail: B) extends DirectionF[A, B]
  case class StopF()                                extends DirectionF[Nothing, Nothing]

  // however, for the practice purposes, I decided to define them all here
  given [T]: Functor[DirectionF[T, *]] =
    new Functor[DirectionF[T, *]]:
      def map[A, B](fa: DirectionF[T, A])(f: A => B): DirectionF[T, B] =
        fa match
          case DirectionConsF(h, t) => new DirectionConsF(h, f(t))
          case StopF()              => new StopF()

  // build up the rec structure from List
  // it is possible to use ListF instead
  // ana builds the rec structure from the other rec structure
  def fromListCoalgebra[A] = Coalgebra[DirectionF[A, *], List[A]] {
    case head :: tail => DirectionConsF(head, tail)
    case Nil          => StopF()
  }

  case class CoordsState(x: Int, y: Int):
    def res: Int = x * y

  given Monoid[CoordsState] = new Monoid[CoordsState]:
    def empty                                                = CoordsState(0, 0)
    def combine(x: CoordsState, y: CoordsState): CoordsState = CoordsState(x.x + y.x, x.y + y.y)

  def accumulateAlgebraFunction = Algebra[DirectionF[(Position, Int), *], CoordsState => CoordsState] {
    // t is the state func in this case
    case DirectionConsF((pos, v), t) =>
      state =>
        val x = pos match
          case FORWARD => v
          case _       => 0

        val y = pos match
          case UP   => -v
          case DOWN => v
          case _    => 0

        CoordsState(state.x + x, state.y + y) |+| t(state)

    case StopF() => identity
  }

  def accumulateAlgebra = Algebra[DirectionF[(Position, Int), *], CoordsState] {
    case DirectionConsF((pos, v), t) =>
      val x = pos match
        case FORWARD => v
        case _       => 0

      val y = pos match
        case UP   => -v
        case DOWN => v
        case _    => 0

      val state = CoordsState(x, y)

      state |+| t

    case StopF() => summon[Monoid[CoordsState]].empty
  }

  // cata recurisvely goes recursively applies algebra to every next element
  // the result is the folded (left) accumulator
  def accumulateListFAlgebra = Algebra[ListF[(Position, Int), *], CoordsState] {
    case ConsF((pos, v), t) =>
      val x = pos match
        case FORWARD => v
        case _       => 0

      val y = pos match
        case UP   => -v
        case DOWN => v
        case _    => 0

      val state = CoordsState(x, y)

      state |+| t

    case NilF => summon[Monoid[CoordsState]].empty
  }

  def part1rec(input: List[(Position, Int)]): Int =
    scheme.hylo(accumulateAlgebra, fromListCoalgebra).apply(input).res

  def part1rec2(input: List[(Position, Int)]): Int =
    scheme.hylo(accumulateListFAlgebra, ListF.fromScalaListCoalgebra).apply(input).res

  type Position = String
  val FORWARD = "forward"
  val UP      = "up"
  val DOWN    = "down"

  def readInput(path: String = "src/main/resources/day2/puzzle1.txt"): Iterator[(Position, Int)] =
    Source
      .fromFile(path)
      .getLines
      .map(_.split("\\W+").toList)
      .flatMap {
        case List(f, s) => Option((f, s.toInt))
        case _          => None
      }

  def part1(input: Iterator[(Position, Int)]): Int =
    val (x, y) = input.foldLeft(0 -> 0) { case ((ax, ay), (pos, v)) =>
      val x = pos match
        case FORWARD => v
        case _       => 0

      val y = pos match
        case UP   => -v
        case DOWN => v
        case _    => 0

      (math.max(0, ax + x), math.max(0, ay + y))
    }

    x * y

  def part2(input: Iterator[(Position, Int)]): Int =
    val (x, y, a) = input.foldLeft((0, 0, 0)) { case ((ax, ay, aa), (pos, v)) =>
      val a = pos match
        case UP   => v
        case DOWN => -v
        case _    => 0

      val (x, y) = pos match
        case FORWARD => (v, aa * -v)
        case _       => (0, 0)

      (math.max(0, ax + x), math.max(0, ay + y), aa + a)
    }

    x * y
