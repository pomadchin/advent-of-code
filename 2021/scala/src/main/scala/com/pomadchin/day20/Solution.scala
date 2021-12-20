package com.pomadchin.day20

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day20/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
