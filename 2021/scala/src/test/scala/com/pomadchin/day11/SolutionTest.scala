package com.pomadchin.day11

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day11/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample, 100), 1656L) }
  test("Q1") { assertEquals(part1(input, 100), 1729L) }
  test("Q2Example") { assertEquals(part2(inputExample), 195) }
  test("Q2") { assertEquals(part2(input), 237) }
