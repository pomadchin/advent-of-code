package com.pomadchin.day23

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day23/example.txt")

  test("Q1Example") {}
  test("Q1") { assertEquals(part1(input), 16157) }
  test("Q2Example") {}
  test("Q2") { assertEquals(part2(input), 43481) }
