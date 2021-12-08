package com.pomadchin.day9

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day9/puzzle1.txt"): Iterator[String] =
    Source
      .fromFile(path)
      .getLines
