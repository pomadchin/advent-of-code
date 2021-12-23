package com.pomadchin.day24

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day24/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
