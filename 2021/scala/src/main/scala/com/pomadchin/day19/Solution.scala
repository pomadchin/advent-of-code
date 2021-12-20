package com.pomadchin.day19

import scala.io.Source
import scala.collection.mutable
import scala.annotation.tailrec

object Solution:

  // every scanner contains a list of relative to sensor beacon positions
  opaque type Scanner = List[Point3D]
  object Scanner:
    def apply(l: List[Point3D]): Scanner = l
    def empty: Scanner                   = Scanner(List.empty[Point3D])

  extension (s: Scanner)
    def length: Int                = s.length
    def toList: List[Point3D]      = s
    def merge(o: Scanner): Scanner = (toList ++ o.toList).distinct
    // map(_.orientation) produces more points orientations
    // transpose to get make them used across all points
    // i.e.Scanner => List[Scanner]
    // List(a, b) =>
    // List(
    //  List(a1,..., a24),
    //  List(b1, ..., b24)
    // ) =>
    // List(
    //   List(a1, b1),
    //   ...,
    //   List(a24, b24)
    // )
    def orientations: List[Scanner] = toList.map(_.orientations).transpose
    def shift(p: Point3D): Scanner  = toList.map(_ + p)

  opaque type Point3D = (Int, Int, Int)
  object Point3D:
    def apply(t: (Int, Int, Int)): Point3D = t
    def apply(l: List[Int]): Point3D       = apply((l(0), l(1), l(2)))
    def zero: Point3D                      = (0, 0, 0)

  extension (t: Point3D)
    def x: Int = t._1
    def y: Int = t._2
    def z: Int = t._3

    def +(o: Point3D): Point3D = Point3D(t.x + o.x, t.y + o.y, t.z + o.z)
    def -(o: Point3D): Point3D = Point3D(t.x - o.x, t.y - o.y, t.z - o.z)

    // 24 different orientations of each point
    def orientations: List[Point3D] =
      List(
        // format: off
        // fixed z (right) 4
        Point3D((x, y, z)),
        Point3D((-y, x, z)),
        Point3D((-x, -y, z)),
        Point3D((y, -x, z)),
        // fixed -z (right) 4
        Point3D((-x, y, -z)),
        Point3D((y, x, -z)),
        Point3D((x, -y, -z)),
        Point3D((-y, -x, -z)),
        // fixed -z (left) 4
        Point3D((-z, y, x)),
        Point3D((-z, x, -y)),
        Point3D((-z, -y, -x)),
        Point3D((-z, -x, y)),
        // fixed z (left) 4
        Point3D((z, y, -x)),
        Point3D((z, x, y)),
        Point3D((z, -y, x)),
        Point3D((z, -x, -y)),
        // fixed -z (mid) 4
        Point3D((x, -z, y)),
        Point3D((-y, -z, x)),
        Point3D((-x, -z, -y)),
        Point3D((y, -z, -x)),
        // fixed z (mid) 4
        Point3D((x, z, -y)),
        Point3D((-y, z, -x)),
        Point3D((-x, z, y)),
        Point3D((y, z, x))
        // format: on
      )

  // ugly parsing
  def readInput(path: String = "src/main/resources/day19/puzzle1.txt"): List[Scanner] =
    val lines    = Source.fromFile(path).getLines
    val scanners = mutable.ListBuffer[Scanner]()
    val scanner  = mutable.ListBuffer[Point3D]()

    while lines.hasNext do
      val line = lines.next
      if line.nonEmpty && !line.contains("scanner") then scanner += Point3D(line.split(",").toList.map(_.toInt))
      else if line.isEmpty && scanner.nonEmpty then
        scanners += Scanner(scanner.toList)
        scanner.clear

    // add the last scanner into the list
    if scanner.nonEmpty then
      scanners += Scanner(scanner.toList)
      scanner.clear

    scanners.toList

  // normalized - the zero scanner
  // raw - the list of the next to normalize scanners
  // skipped - list of scanner that were skipped during the recursion loop
  // repeat until the skipped list is empty
  @tailrec
  def normalize(raw: List[Scanner], skipped: List[Scanner], normalized: Scanner): Scanner =
    raw match
      case scanner :: tail =>
        scanner.orientations.flatMap { scanner =>
          // it is very expensive to substract everything from the normalized
          normalized
            .flatMap(p0 => scanner.map(p0 - _))
            .groupBy(identity)
            .view
            .mapValues(_.length)
            .find(_._2 >= 12)
            .map(_._1)
            .map(scanner.shift)
        }.headOption match {
          // if can be normalized, remove it from the normalization queue
          case Some(scanner) => normalize(tail, skipped, normalized.merge(scanner))
          // if not normalized - preserve it for a later time
          case _ => normalize(tail, scanner :: skipped, normalized)
        }

      // raw is empty and skipped is non empty, put all skipped into the processing queue
      case Nil if skipped.nonEmpty => normalize(skipped, Nil, normalized)

      // if all queues are empty return the result
      case _ => normalized

  // it is ~x2 faster than normalize
  @tailrec
  def normalize2(raw: List[Scanner], skipped: List[Scanner], shifted: List[Scanner], base: Scanner, normalized: Scanner): Scanner =
    raw match
      case scanner :: tail =>
        scanner.orientations.flatMap { scanner =>
          // it is very expensive to substract everything from the normalized
          base
            .flatMap(p0 => scanner.map(p0 - _))
            .groupBy(identity)
            .view
            .mapValues(_.length)
            .find(_._2 >= 12)
            .map(_._1)
            .map(scanner.shift)
        }.headOption match {
          // if can be normalized, remove it from the normalization queue
          case Some(scanner) => normalize2(tail, skipped, scanner :: shifted, base, normalized.merge(scanner))
          // if not normalized - preserve it for a later time
          case _ => normalize2(tail, scanner :: skipped, shifted, base, normalized)
        }

      // raw is empty and skipped is non empty, put all skipped into the processing queue
      case Nil if skipped.nonEmpty && shifted.nonEmpty => normalize2(skipped, Nil, shifted.tail, shifted.head, normalized)

      case Nil if skipped.nonEmpty => normalize2(skipped, Nil, Nil, normalized, normalized)

      // if all queues are empty return the result
      case _ => normalized

  def part1(scanners: List[Scanner]): Int =
    // normalize(scanners.tail, Nil, scanners.head).length
    normalize2(scanners.tail, Nil, Nil, scanners.head, scanners.head).length

  // manually derive the logic of sensors shifting for 4 example scanners
  def normalizeManual4(scanners: List[Scanner]) =
    // the base scanner
    val scanner0 = scanners(0)
    val scanner1 = scanners(1)
    val scanner2 = scanners(2)
    val scanner3 = scanners(3)
    val scanner4 = scanners(4)

    val pos0 = Point3D.zero

    println("---scanner 1---")
    val (scanner1oriented, pos1) = scanner1.orientations.flatMap { scanner1 =>
      val res = scanner0
        .flatMap(p0 => scanner1.map(p0 - _))
        .groupBy(identity)

      res.view.mapValues(_.length).find(_._2 >= 12).map(_._1).map(scanner1 -> _)
    }.head

    println(pos1)
    println(scanner1oriented.shift(pos1))

    val scanner01 = scanner0.merge(scanner1oriented.shift(pos1))

    println("---scanner 4---")
    val (scanner4oriented, pos4) = scanner4.orientations.flatMap { scanner4 =>
      val res = scanner01
        .flatMap(p0 => scanner4.map(p0 - _))
        .groupBy(identity)

      res.view.mapValues(_.length).find(_._2 >= 12).map(_._1).map(scanner4 -> _)
    }.head

    println(pos4)
    println(scanner4oriented.shift(pos4))

    val scanner014 = scanner01.merge(scanner4oriented.shift(pos4))

    println("---scanner 2---")
    val (scanner2oriented, pos2) = scanner2.orientations.flatMap { scanner2 =>
      val res = scanner014
        .flatMap(p0 => scanner2.map(p0 - _))
        .groupBy(identity)

      res.view.mapValues(_.length).find(_._2 >= 12).map(_._1).map(scanner2 -> _)
    }.head

    println(pos2)
    println(scanner2oriented.shift(pos2))

    val scanner0142 = scanner014.merge(scanner2oriented.shift(pos2))

    println("---scanner 3---")
    val (scanner3oriented, pos3) = scanner3.orientations.flatMap { scanner3 =>
      val res = scanner0142
        .flatMap(p0 => scanner3.map(p0 - _))
        .groupBy(identity)

      res.view.mapValues(_.length).find(_._2 >= 12).map(_._1).map(scanner3 -> _)
    }.head

    println(pos3)
    println(scanner3oriented.shift(pos3))

    val scanner01423 = scanner0142.merge(scanner3oriented.shift(pos3))

    println(scanner01423.length)
