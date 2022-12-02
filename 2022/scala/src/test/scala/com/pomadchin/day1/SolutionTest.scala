package com.pomadchin.day1

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input = readInput()
  lazy val inputExample = readInput("src/main/resources/day1/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 24000L) }
  test("Q1") { assertEquals(part1(input), 70613L) }
  test("Q2Example") { assertEquals(part2(inputExample), 45000L) }
  test("Q2") { assertEquals(part2(input), 205805L) }
