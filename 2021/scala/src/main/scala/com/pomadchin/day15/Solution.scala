package com.pomadchin.day15

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day15/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
