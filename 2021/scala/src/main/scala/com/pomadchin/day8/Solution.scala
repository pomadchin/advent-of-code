package com.pomadchin.day8

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day8/puzzle1.txt"): Iterator[String] =
    Source
      .fromFile(path)
      .getLines
