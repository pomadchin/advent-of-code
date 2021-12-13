package com.pomadchin.day13

import scala.io.Source

object Solution:

  case class Input(coords: Set[(Int, Int)], instructions: List[(String, Int)])

  def readInput(path: String = "src/main/resources/day13/puzzle1.txt"): Input =
    val source = Source.fromFile(path).getLines.toList
    val coords: Set[(Int, Int)] =
      source
        .filter(_.contains(","))
        .map(_.split(",").toList.map(_.toInt))
        .flatMap {
          case List(f, s) => Some(f -> s)
          case _          => None
        }
        .toSet

    val instructions: List[(String, Int)] =
      source
        .filter(_.startsWith("fold along "))
        .map(_.split("fold along ").last.split("=").toList)
        .flatMap {
          case List(f, s) => Some(f -> s.toInt)
          case _          => None
        }

    Input(coords, instructions)

  def part1(input: Input): Int =
    // in the first task we take only the first instruction
    input.instructions
      .take(1)
      .foldLeft(input.coords) { case (acc, i) =>
        i match
          case ("x", v) => acc.map((x, y) => (v - math.abs(v - x), y))
          case ("y", v) => acc.map((x, y) => (x, v - math.abs(v - y)))
          case _        => acc
      }
      .size

  def part2(input: Input) =
    val result = input.instructions
      .foldLeft(input.coords) { case (acc, i) =>
        i match
          case ("x", v) => acc.map((x, y) => (v - math.abs(v - x), y))
          case ("y", v) => acc.map((x, y) => (x, v - math.abs(v - y)))
          case _        => acc
      }
      .toList
      .sorted

    val (minx, miny) = result.head
    val (maxx, maxy) = result.last

    (miny to maxy).map { y => (minx to maxx).map { x => if result.contains(x, y) then "##" else "  " }.mkString }.mkString("\n")
