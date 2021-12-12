package com.pomadchin.day13

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day13/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
