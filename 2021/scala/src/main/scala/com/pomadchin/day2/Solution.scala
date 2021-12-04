package com.pomadchin.day2

import scala.io.Source

object Solution:
  type Position = String
  val FORWARD = "forward"
  val UP      = "up"
  val DOWN    = "down"

  def readInput: Iterator[(Position, Int)] =
    Source
      .fromFile("src/main/resources/day2/puzzle1.txt")
      .getLines
      .map(_.split("\\W+").toList)
      .map { case List(f, s) => (f, s.toInt) }

  def calculate(input: Iterator[(Position, Int)]): Int =
    val (x, y) = input.foldLeft(0 -> 0) { case ((ax, ay), (pos, v)) =>
      val x = pos match
        case FORWARD => v
        case _       => 0

      val y = pos match
        case UP   => -v
        case DOWN => v
        case _    => 0

      (math.max(0, ax + x), math.max(0, ay + y))
    }

    x * y

  def calculatePart2(input: Iterator[(Position, Int)]): Int =
    val (x, y, a) = input.foldLeft((0, 0, 0)) { case ((ax, ay, aa), (pos, v)) =>
      val a = pos match
        case UP   => v
        case DOWN => -v
        case _    => 0

      val (x, y) = pos match
        case FORWARD => (v, aa * -v)
        case _       => (0, 0)

      (math.max(0, ax + x), math.max(0, ay + y), aa + a)
    }

    x * y

  def main(args: Array[String]): Unit =
    println(s"Q1: ${calculate(readInput)}")
    println(s"Q2: ${calculatePart2(readInput)}")
