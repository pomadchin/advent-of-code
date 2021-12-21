package com.pomadchin.day21

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day21/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
