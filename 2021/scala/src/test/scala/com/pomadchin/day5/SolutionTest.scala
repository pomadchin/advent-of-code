package com.pomadchin.day5

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input = readInput()

  test("Q1") { assertEquals(part1(input), 4873) }
  test("Q2") { assertEquals(part2(input), 19472) }
