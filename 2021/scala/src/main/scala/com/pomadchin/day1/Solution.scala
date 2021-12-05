package com.pomadchin.day1

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day1/puzzle1.txt"): Array[Int] =
    Source
      .fromFile(path)
      .getLines
      .map(_.toInt)
      .toArray

  def part1(a: Array[Int]): Int =
    var (counts, i, prev) = (0, 1, a(0))

    while i < a.length do
      if (a(i) > prev) counts += 1
      prev = a(i)
      i = i + 1

    counts

  def part2(a: Array[Int]): Int =
    var (counts, i, prev) = (0, 1, a.take(3).sum)

    while i < a.length - 2 do
      val next = a(i) + a(i + 1) + a(i + 2)
      if (next > prev) counts += 1
      prev = next
      i = i + 1

    counts

  def part1f(a: Array[Int]): Int =
    a.sliding(2, 1).count(a => a(0) < a(1))

  def part2f(a: Array[Int]): Int =
    a.sliding(3, 1).map(_.sum).sliding(2, 1).count(a => a(0) < a(1))
