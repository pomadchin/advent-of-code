package com.pomadchin.day6

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day6/puzzle1.txt"): Iterator[String] =
    Source
      .fromFile(path)
      .getLines
