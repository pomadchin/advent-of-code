package com.pomadchin.day3

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input = readInput()

  test("Q1") { assertEquals(part1(input.clone), 2003336) }
  test("Q2") { assertEquals(part2(input.clone), 1877139) }
  test("Q2way") { assertEquals(part2way(input.clone), 1877139) }
  test("Q1*") { assertEquals(part1f(input.clone.toList), 2003336) }
  test("Q2*") { assertEquals(part2f(input.clone.toList), 1877139) }
