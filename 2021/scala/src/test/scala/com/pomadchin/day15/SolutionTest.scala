package com.pomadchin.day15

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day15/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 40) }
  test("Q1") { assertEquals(part1(input), 388) }
  test("Q2Example") { assertEquals(part2(inputExample), 315) }
  test("Q2") { assertEquals(part2(input), 2819) }
