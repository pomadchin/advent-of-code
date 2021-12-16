package com.pomadchin.day16

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day16/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 31L) }
  test("Q1") { assertEquals(part1(input), 901L) }
  test("Q2Example") { assertEquals(part2(inputExample), 54L) }
  test("Q2") { assertEquals(part2(input), 110434737925L) }
