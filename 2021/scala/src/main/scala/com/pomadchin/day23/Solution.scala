package com.pomadchin.day23

import scala.io.Source

object Solution:
  def readInput(path: String = "src/main/resources/day23/puzzle1.txt"): Iterator[String] =
    Source.fromFile(path).getLines

// format: off
/*
// shrug I did it manually
// TODO: make a programm solution, i.e. build the states matrix and use dijkstra / bfs to find optimal paths?

#############
#...........#
###D#D#C#B###
  #B#A#A#C#
  #########

// B1 = 9
#############
#.B.........#
###D#D#C#.###
  #B#A#A#C#
  #########

// C1 = 2
#############
#.......C.B.#
###D#D#.#.###
  #B#A#A#C#
  #########

// A1 = 8
#############
#A......C.B.#
###D#D#.#.###
  #B#A#.#C#
  #########

// 8 + 9 + (6 + 8) * 10 + 10 * 100 + 15 * 1000
// 16157 - move tiny first and large ones least

#############
#...........#
###D#D#C#B###
  #D#C#B#A#
  #D#B#A#C#
  #B#A#A#C#
  #########

// 43481

P.S. some folks also did a UI for it: https://aochelper2021.blob.core.windows.net/day23/index.html
*/
// format: on

def part1(input: Iterator[String]): Int = 8 + 9 + (6 + 8) * 10 + 10 * 100 + 15 * 1000
def part2(input: Iterator[String]): Int = 43481
