package com.pomadchin.day10

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day10/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 26397) }
  test("Q1") { assertEquals(part1(input), 469755) }
  test("Q2Example") { assertEquals(part2(inputExample), 288957L) }
  test("Q2") { assertEquals(part2(input), 2762335572L) }
