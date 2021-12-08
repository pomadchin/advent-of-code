package com.pomadchin.day8

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input         = readInput()
  def inputExample  = readInput("src/main/resources/day8/example.txt")
  def inputExample1 = readInput("src/main/resources/day8/example1.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 26) }
  test("Q1") { assertEquals(part1(input), 349) }
  test("Q2Example1") { assertEquals(part2(inputExample1), 5353) }
  test("Q2Example") { assertEquals(part2(inputExample), 61229) }
  test("Q2") { assertEquals(part2(input), 1070957) }
  test("Q2*") { assertEquals(part2f(input), 1070957) }
