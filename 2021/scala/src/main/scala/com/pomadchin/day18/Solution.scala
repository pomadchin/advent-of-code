package com.pomadchin.day18

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day18/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
