package com.pomadchin.day2

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input        = readInput().toList
  lazy val inputExample = readInput("src/main/resources/day2/example.txt").toList

  test("Q1Example") { assertEquals(part1(inputExample), 15) }
  test("Q1") { assertEquals(part1(input), 9759) }
  test("Q2Example") { assertEquals(part2(inputExample), 12) }
  test("Q2") { assertEquals(part2(input), 12429) }
