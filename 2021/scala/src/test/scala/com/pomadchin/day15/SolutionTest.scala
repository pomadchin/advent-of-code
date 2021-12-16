package com.pomadchin.day15

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input         = readInput()
  def input2        = readInput(tiled = true)
  def inputExample  = readInput("src/main/resources/day15/example.txt")
  def input2Example = readInput("src/main/resources/day15/example.txt", true)

  test("Q1Example") { assertEquals(part1(inputExample), 40) }
  test("Q1") { assertEquals(part1(input), 388) }
  test("Q2Example") { assertEquals(part1(input2Example), 315) }
  test("Q2") { assertEquals(part1(input2), 2819) }
