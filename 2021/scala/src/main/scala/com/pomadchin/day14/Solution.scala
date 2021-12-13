package com.pomadchin.day14

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day14/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
