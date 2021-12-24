package com.pomadchin.day24

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input = readInput()

  test("Q1") { assertEquals(part1(input), 96929994293996L) }
  test("Q2") { assertEquals(part2(input), 41811761181141L) }
