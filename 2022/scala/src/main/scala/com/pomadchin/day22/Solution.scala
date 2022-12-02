package com.pomadchin.day22

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day22/puzzle1.txt"): Iterator[String] =
    Source
      .fromFile(path)
      .getLines

  def part1(input: Iterator[String]): Unit = ()

  def part2(input: Iterator[String]): Unit = ()
