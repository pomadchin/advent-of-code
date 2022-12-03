package com.pomadchin.day3

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input        = readInput()
  lazy val inputExample = readInput("src/main/resources/day3/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 157) }
  test("Q1") { assertEquals(part1(input), 8109) }
  test("Q2Example") { assertEquals(part2(inputExample), 70) }
  test("Q2") { assertEquals(part2(input), 2738) }
