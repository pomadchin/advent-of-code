package com.pomadchin.day17

class SolutionTest extends munit.FunSuite:
  import Solution.*
  val input        = readInput()
  val inputExample = readInput("src/main/resources/day17/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 45) }
  test("Q1") { assertEquals(part1(input), 5886) }
  test("Q2Example") { assertEquals(part2(inputExample), 112) }
  test("Q2") { assertEquals(part2(input), 1806) }
