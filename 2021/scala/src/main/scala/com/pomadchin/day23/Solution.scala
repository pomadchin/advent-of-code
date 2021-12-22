package com.pomadchin.day23

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day22/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
