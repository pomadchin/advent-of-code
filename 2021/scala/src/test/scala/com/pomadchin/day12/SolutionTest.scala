package com.pomadchin.day12

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day12/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 226) }
  test("Q1") { assertEquals(part1(input), 5157) }
  test("Q2Example") { assertEquals(part2(inputExample), 3509) }
  test("Q2") { assertEquals(part2(input), 144309) }
