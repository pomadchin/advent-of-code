package com.pomadchin.day9

class SolutionTest extends munit.FunSuite:
  import Solution.*
  val input        = readInput()
  val inputExample = readInput("src/main/resources/day9/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 15) }
  test("Q1") { assertEquals(part1(input), 502) }
  test("Q2Example") { assertEquals(part2(inputExample), 1134) }
  test("Q2") { assertEquals(part2(input), 1330560) }
