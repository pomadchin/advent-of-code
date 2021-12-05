package com.pomadchin.day5

import scala.io.Source

object Solution:
  extension (f: Int) def range(t: Int) = f to t by (if (f < t) 1 else -1)

  opaque type Point = (Int, Int)
  object Point:
    def apply(t: (Int, Int)): Point  = t
    def apply(x: Int, y: Int): Point = x -> y

  extension (p: Point)
    def tupled: (Int, Int) = p
    def x: Int             = p._1
    def y: Int             = p._2

  opaque type Line = (Point, Point)
  object Line:
    def apply(t: (Point, Point)): Line        = t
    def apply(start: Point, end: Point): Line = (start, end)

  extension (l: Line)
    def start: Point          = l._1
    def end: Point            = l._2
    def isHorizontal: Boolean = l.start.x == l.end.x
    def isVertical: Boolean   = l.start.y == l.end.y
    def points(withDiagonal: Boolean): IterableOnce[Point] =
      val ((x1, y1), (x2, y2)) = l
      if (isHorizontal) y1.range(y2).view.map(Point(x1, _))
      else if (isVertical) x1.range(x2).view.map(Point(_, y1))
      // zip works, since we have only "correct" lines
      // every point of which lies on a grid
      else if (withDiagonal)(x1.range(x2)).lazyZip(y1.range(y2)).map(Point(_))
      else Iterator.empty

  def counts(lines: List[Line], withDiagonal: Boolean): Int =
    lines
      .flatMap(_.points(withDiagonal))
      .groupBy(identity)
      .filter(_._2.length > 1)
      .size

  def part1(lines: List[Line]): Int = counts(lines, false)
  def part2(lines: List[Line]): Int = counts(lines, true)

  // let's go mutable, as an exercise
  // map over all lines
  // filter the dictionary of (point, counts)
  // all values of counts > 1 are of interest to us
  import scala.collection.mutable
  def countsMap(lines: Iterator[Line], withDiagonal: Boolean = false) = {
    val m: mutable.Map[Point, Int] = new mutable.HashMap()
    var accumulator                = 0
    lines.foreach { line =>
      val ((x1, y1), (x2, y2)) = line
      var (xi, yi)             = (x1, y1)

      // traversal direction
      // inc forward, back or stay (in vertical / horizontal case)
      val stepx = if (x1 < x2) 1 else if (x1 > x2) -1 else 0
      val stepy = if (y1 < y2) 1 else if (y1 > y2) -1 else 0

      // diffenrent while stop conditions based on the loop direction
      def cmpx(a: Int, b: Int): Boolean = if (x1 < x2) a <= b else a >= b
      def cmpy(a: Int, b: Int): Boolean = if (y1 < y2) a <= b else a >= b

      if ((line.isVertical || line.isHorizontal) || withDiagonal)
        // in a single while loop fill in the hashmap
        // x and ys are incremented always, since we have only "correct" lines
        // every point of which lies on a grid
        while cmpx(xi, x2) && cmpy(yi, y2) do
          val p = Point(xi, yi)
          val c = m.get(p).getOrElse(0)
          m.put(p, c + 1)
          yi += stepy
          xi += stepx

    }

    // fold map into accumulator, but I'm using foreach
    m.foreach { (_, value) => if (value > 1) accumulator += 1 }
    accumulator
  }

  def part1nf(lines: Iterator[Line]): Int = countsMap(lines)
  def part2nf(lines: Iterator[Line]): Int = countsMap(lines, true)

  def readInput(path: String = "src/main/resources/day5/puzzle1.txt"): List[Line] =
    Source
      .fromFile(path)
      .getLines
      .map(_.split(" -> ").toList.map(_.split(",").toList.map(_.toInt)))
      .flatMap {
        case List(List(x1, y1), List(x2, y2)) => Option(Line(Point(x1, y1), Point(x2, y2)))
        case _                                => None
      }
      .toList
