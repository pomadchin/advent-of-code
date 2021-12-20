package com.pomadchin.day19

class SolutionTest extends munit.FunSuite:
  import Solution.*
  val input        = readInput()
  val inputExample = readInput("src/main/resources/day19/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 79) }
  test("Q1") { assertEquals(part1(input), 496) }
  test("Q2Example") {}
  test("Q2") {}
