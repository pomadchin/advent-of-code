package com.pomadchin.day7

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input        = readInput()
  lazy val inputExample = readInput("src/main/resources/day7/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 37) }
  test("Q1") { assertEquals(part1(input), 336120) }
  test("Q2Example") { assertEquals(part2(inputExample), 168) }
  test("Q2") { assertEquals(part2(input), 96864235) }
  test("Q2optimized") { assertEquals(part2optimized(input), 96864235) }
