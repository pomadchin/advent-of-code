package com.pomadchin.day1

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input = readInput()

  test("Q1") { assertEquals(part1(input), 1557) }
  test("Q1*") { assertEquals(part1f(input), 1557) }
  test("Q2") { assertEquals(part2(input), 1608) }
  test("Q2*") { assertEquals(part2f(input), 1608) }
