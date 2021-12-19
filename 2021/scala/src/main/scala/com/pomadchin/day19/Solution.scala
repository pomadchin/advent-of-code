package com.pomadchin.day19

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day19/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
