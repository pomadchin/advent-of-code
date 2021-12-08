package com.pomadchin.day8

import scala.io.Source

object Solution:

  type Notes  = List[String]
  type Result = List[String]

  def readInput(path: String = "src/main/resources/day8/puzzle1.txt"): Iterator[(Notes, Result)] =
    Source
      .fromFile(path)
      .getLines
      .map(_.split(" \\| ").toList.map(_.split("\\W+").toList))
      .flatMap {
        case l :: r :: Nil => Option(l -> r)
        case _             => None
      }

  def part1(input: Iterator[(Notes, Result)]): Int =
    input
      .map(_._2)
      .foldLeft(Map[Set[Char], Int]()) { (acc, list) =>
        list
          .map { l =>
            l.size match
              // add all 8s, 4s, 7s, and 1s, we can idenitfy them by length
              case 7 | 4 | 3 | 2 => l.toSet
              case _             => Set()
          }
          .foldLeft(acc) { case (acc, e) =>
            acc.get(e) match
              // if there is such entry in the set
              case Some(count)     => acc + (e -> (count + 1))
              case _ if e.nonEmpty => acc + (e -> 1)
              // do nothing with empty sets
              case _ => acc
          }
      }
      .map(_._2)
      .sum

  import scala.collection.mutable
  def part2(input: Iterator[(Notes, Result)]): Int =
    input.map { (l, r) =>
      val map = new mutable.HashMap[Int, Set[Char]]()
      // lenght 7 == 8
      // length 3 == 7
      // length 4 == 4
      // length 2 == 1

      // length 5 => 5 / 3 / 2
      // contains 7 (completely) == 3
      // part of 4 (- 1 5 - 4 = 1) == 5
      // * find 5 ~ (5 - (4 - 1)) = 0 // map(4).diff(map(1)).subsetOf(l)
      // really we do (4 - 1) first, and only 5 contains this diff
      // because 3 and 5 are already there (set.length = 2) == 2

      // length 6 => 9 / 6 / 0
      // contains only one symbol of 1 == 6 ((set - 1).length = set - 1)
      // completely contains 4 == 9
      // because 6 and 9 are found == 0

      // initial keys
      l.foreach { l =>
        l.size match
          case 7 => map.put(8, l.toSet)
          case 4 => map.put(4, l.toSet)
          case 3 => map.put(7, l.toSet)
          case 2 => map.put(1, l.toSet)
          case _ =>
      }

      // finding all of length 5
      val l5 = l.filter(_.size == 5).map(_.toSet)
      // find 3 ~ completely contains 7
      l5.find { l => map(7).subsetOf(l) } match
        case Some(l) => map.put(3, l)
        case _       =>
      // find 5 ~ (5 - (4 - 1 - 1)) = 0
      // really we do (4 - 1) first, and only 5 contains this diff
      l5.find { l => map(4).diff(map(1)).subsetOf(l) } match
        case Some(l) => map.put(5, l)
        case _       =>
      // find 2 ~ the last str from the list
      l5.find(l => l != map(5) && l != map(3)) match
        case Some(l) => map.put(2, l)
        case _       =>

      // finding all length 6
      val l6 = l.filter(_.size == 6).map(_.toSet)
      // find 6 ~ contains only one symbol of 1
      l6.find { l => l.diff(map(1)).size == (l.size - 1) } match
        case Some(l) => map.put(6, l)
        case _       =>
      // find 9 ~ completely contains 4
      l6.find { l => map(4).subsetOf(l) } match
        case Some(l) => map.put(9, l)
        case _       =>
      // find 0 ~ the last str from the list
      l6.find(l => l != map(6) && l != map(9)) match
        case Some(l) => map.put(0, l)
        case _       =>

      // reverse map
      val mapr = map.map { case (k, v) => (v, k) }

      strToInt(r.map { d => mapr(d.toSet) }.mkString)
    }.sum

  def part2f(input: Iterator[(Notes, Result)]): Int =
    input.map { (l, r) =>
      // lenght 7 == 8
      // length 3 == 7
      // length 4 == 4
      // length 2 == 1

      // length 5 => 5 / 3 / 2
      // contains 7 (completely) == 3
      // part of 4 (- 1 5 - 4 = 1) == 5
      // * find 5 ~ (5 - (4 - 1)) = 0 // map(4).diff(map(1)).subsetOf(l)
      // really we do (4 - 1) first, and only 5 contains this diff
      // because 3 and 5 are already there (set.length = 2) == 2

      // length 6 => 9 / 6 / 0
      // contains only one symbol of 1 == 6 ((set - 1).length = set - 1)
      // completely contains 4 == 9
      // because 6 and 9 are found == 0

      // initial keys
      val map = l.foldLeft(Map[Int, Set[Char]]()) { (acc, l) =>
        l.size match
          case 7 => acc + (8 -> l.toSet)
          case 4 => acc + (4 -> l.toSet)
          case 3 => acc + (7 -> l.toSet)
          case 2 => acc + (1 -> l.toSet)
          case _ => acc
      }

      // finding all of length 5
      val l5 = l.filter(_.size == 5).map(_.toSet)

      // find 3 and 5
      val map53 = l5.foldLeft(map) { (acc, l) =>
        if (map(7).subsetOf(l)) acc + (3 -> l)
        else if (map(4).diff(map(1)).subsetOf(l)) acc + (5 -> l)
        else acc
      }
      // find2 2
      val map5 = l5.foldLeft(map53) { (acc, l) =>
        if (l != acc(5) && l != acc(3)) acc + (2 -> l)
        else acc
      }

      // finding all length 6
      val l6 = l.filter(_.size == 6).map(_.toSet)
      // find 6 and 9
      val map69 = l6.foldLeft(map5) { (acc, l) =>
        if (l.diff(map(1)).size == (l.size - 1)) acc + (6 -> l)
        else if (map(4).subsetOf(l)) acc + (9 -> l)
        else acc
      }
      // find 0
      val map6 = l6.foldLeft(map69) { (acc, l) =>
        if (l != acc(6) && l != acc(9)) acc + (0 -> l)
        else acc
      }

      // reverse map
      val mapr = map6.map { (k, v) => (v, k) }

      strToInt(r.map { d => mapr(d.toSet) }.mkString)
    }.sum

  def strToInt(str: String, digits: Int = 4): Int =
    ((str.length - 1) to 0 by -1)
      .map { i => math.pow(10, i).toInt }
      .zip(str.toList.map(_.asDigit))
      .map(_ * _)
      .sum
