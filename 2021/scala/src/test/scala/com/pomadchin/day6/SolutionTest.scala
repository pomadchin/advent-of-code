package com.pomadchin.day6

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input        = readInput()
  lazy val inputExample = readInput("src/main/resources/day6/example.txt")

  test("Q1Example") { assertEquals(Solution.part1(inputExample, 18), 26) }
  test("Q1") { assertEquals(Solution.part1(input, 80), 351188) }
  test("Q2Example") { assertEquals(Solution.part2(inputExample, 18), 26L) }
  test("Q1viaQ2") { assertEquals(Solution.part2(input, 80), 351188L) }
  test("Q2") { assertEquals(Solution.part2(input, 256), 1595779846729L) }
