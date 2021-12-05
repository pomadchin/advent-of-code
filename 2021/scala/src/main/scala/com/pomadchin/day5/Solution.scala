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
    def x: Int            = p._1
    def y: Int            = p._2

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

  def readInput =
    Source
      .fromFile("src/main/resources/day5/puzzle1.txt")
      .getLines
      .map(_.split(" -> ").toList.map(_.split(",").toList.map(_.toInt)))
      .map { case List(List(x1, y1), List(x2, y2)) => Line(Point(x1, y1), Point(x2, y2)) }
      .toList

  def main(args: Array[String]): Unit =
    val input = readInput
    println(s"Q1: ${part1(input)}") // 4873
    println(s"Q2: ${part2(input)}") // 21536
