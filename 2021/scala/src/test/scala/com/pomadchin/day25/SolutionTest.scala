package com.pomadchin.day25

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day25/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 58) }
  test("Q1") { assertEquals(part1(input), 453) }
