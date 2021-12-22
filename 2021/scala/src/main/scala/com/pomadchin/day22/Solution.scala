package com.pomadchin.day22

import scala.io.Source
import scala.collection.mutable

// the idea is to build a tree
// and compute its size
sealed trait Cuboid:
  def size: Long
  def intersection(o: Cuboid): Cuboid

  def union(o: Cuboid): Cuboid = CuboidUnion(this, o)
  def diff(o: Cuboid): Cuboid  = CuboidDifference(this, o)

case object CuboidEmpty extends Cuboid:
  def size: Long                      = 0L
  def intersection(o: Cuboid): Cuboid = CuboidEmpty

case class CuboidUnion(l: Cuboid, r: Cuboid) extends Cuboid:
  // l + r - (l & r)
  def size: Long = l.size + r.size - l.intersection(r).size
  def intersection(o: Cuboid): Cuboid =
    (l.intersection(o), r.intersection(o)) match
      case (CuboidEmpty, CuboidEmpty) => CuboidEmpty
      case (li, CuboidEmpty)          => li
      case (CuboidEmpty, ri)          => ri
      case (li, ri)                   => li.union(ri)

case class CuboidDifference(l: Cuboid, r: Cuboid) extends Cuboid:
  // l - (l & r)
  def size: Long = l.size - (l.intersection(r).size)
  def intersection(o: Cuboid): Cuboid =
    l.intersection(o) match
      case CuboidEmpty => CuboidEmpty
      case li          => li.diff(r)

case class Cuboid3D(xmin: Long, ymin: Long, zmin: Long, xmax: Long, ymax: Long, zmax: Long) extends Cuboid:
  def width: Long  = xmax - xmin
  def height: Long = ymax - ymin
  def depth: Long  = zmax - zmin
  def size: Long   = (width + 1L) * (height + 1L) * (depth + 1L)

  def xs: Seq[Long] = xmin to xmax
  def ys: Seq[Long] = ymin to ymax
  def zs: Seq[Long] = zmin to zmax

  def intersection(o: Cuboid): Cuboid =
    o match
      case o: Cuboid3D =>
        val xminNew = math.max(xmin, o.xmin)
        val yminNew = math.max(ymin, o.ymin)
        val zminNew = math.max(zmin, o.zmin)
        val xmaxNew = math.min(xmax, o.xmax)
        val ymaxNew = math.min(ymax, o.ymax)
        val zmaxNew = math.min(zmax, o.zmax)

        if xminNew <= xmaxNew && yminNew <= ymaxNew && zminNew <= zmaxNew then Cuboid3D(xminNew, yminNew, zminNew, xmaxNew, ymaxNew, zmaxNew)
        else CuboidEmpty
      case _ => o.intersection(o)

object Cuboid3D:
  def apply(x: (Long, Long), y: (Long, Long), z: (Long, Long)): Cuboid3D = Cuboid3D(x._1, y._1, z._1, x._2, y._2, z._2)

object Solution:
  opaque type Point3D = (Long, Long, Long)
  object Point3D:
    def apply(t: (Long, Long, Long)): Point3D = t

  def readInput(path: String = "src/main/resources/day22/puzzle1.txt"): List[(Boolean, Cuboid3D)] =
    Source
      .fromFile(path)
      .getLines
      .map { str =>
        val List(sws, cs) = str.split(" ").toList
        val List((xmin, xmax), (ymin, ymax), (zmin, zmax)) = cs.split(",").toList.map { str =>
          val List(f, t) = str.split("=").last.split("\\..").toList.map(_.toLong)
          (f, t)
        }

        val sw =
          sws match
            case "on" => true
            case _    => false

        (sw, Cuboid3D(xmin, ymin, zmin, xmax, ymax, zmax))
      }
      .toList

  // dummy bruteforce
  def part1bf(input: List[(Boolean, Cuboid3D)]): Int =
    val map                      = mutable.Map[Point3D, Boolean]()
    def filter(c: Long): Boolean = c >= -50 && c <= 50

    input.foreach { (sw, c) =>
      for
        x <- c.xs
        y <- c.ys
        z <- c.zs
        if filter(x) && filter(y) && filter(z)
      yield map += (Point3D(x, y, z) -> sw)
    }

    map.toList.filter(_._2).length

  // x=-50..50,y=-50..50,z=-50..50
  val bounds = Cuboid3D(-50, -50, -50, 50, 50, 50)

  def foldLeft(input: List[(Boolean, Cuboid3D)]): Cuboid =
    input.foldLeft[Cuboid](CuboidEmpty) { case (a, (sw, c)) => if sw then a.union(c) else a.diff(c) }

  def part1(input: List[(Boolean, Cuboid3D)]): Long =
    foldLeft(input).intersection(bounds).size

  def part2(input: List[(Boolean, Cuboid3D)]): Long =
    foldLeft(input).size
