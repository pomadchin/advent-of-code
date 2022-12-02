package com.pomadchin.day1

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day1/puzzle1.txt"): List[String] =
    Source
      .fromFile(path)
      .getLines
      .toList

  def elves(iter: List[String]): List[List[String]] =
    iter.foldLeft(List(List.empty[String])) {
      case (head :: tail, str) if !str.trim().isEmpty() => (str.trim() :: head) :: tail
      case (acc, str) if str.trim().isEmpty()           => Nil :: acc
      case (acc, _)                                     => acc
    }

  // sorted counts
  def counts(list: List[List[String]]): List[Long] =
    list.map(_.map(_.toLong).sum).sortBy(-_)

  def part1(list: List[String]): Long =
    counts(elves(list)).head

  def part2(list: List[String]): Long =
    counts(elves(list)).take(3).sum
