package com.pomadchin.day20

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day20/example.txt")

  test("Q1Example") { assertEquals(part1.tupled(inputExample), 35) }
  test("Q1") { assertEquals(part1.tupled(input), 4873) }
  test("Q2Example") { assertEquals(part2.tupled(inputExample), 3351) }
  test("Q2") { assertEquals(part2.tupled(input), 16394) }
