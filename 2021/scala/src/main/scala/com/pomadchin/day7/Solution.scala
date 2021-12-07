package com.pomadchin.day7

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day7/puzzle1.txt"): List[Int] =
    Source
      .fromFile(path)
      .getLines
      .flatMap(_.split(",").map(_.toInt))
      .toList
      .sorted

  def part1(numbers: List[Int]): Int =
    // could be brute forced but we can compute the optimal position ahead of time - it is right in the middle
    val median = numbers(numbers.size / 2)
    // numbers.map { n => math.abs(n - median) }.sum
    numbers.foldLeft(0)((acc, n) => acc + math.abs(n - median))

  def part2(numbers: List[Int]): Int =
    // the min of all moves, pretty slow
    (numbers.min to numbers.max).map { m => // how to find it?
      // compute moves and the sum of moves
      numbers.map { n => math.abs(n - m) }.map { z => z * (z + 1) / 2 }.sum
    }.min

  def part2optimized(numbers: List[Int]): Int =
    // the target is the average of the sum (mean)
    val mean = numbers.sum / numbers.length
    // numbers.map { n => math.abs(n - mean) }.map { z => z * (z + 1) / 2 }.sum
    numbers.map(n => math.abs(n - mean)).foldLeft(0)((acc, z) => acc + z * (z + 1) / 2)
