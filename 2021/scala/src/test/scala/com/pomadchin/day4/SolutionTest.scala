package com.pomadchin.day4

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input = readInput()

  test("Q1") { assertEquals(input.part1, 35711) }
  test("Q2") { assertEquals(input.part2, 5586) }
