package com.pomadchin.day16

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day16/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines
