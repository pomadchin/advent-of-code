package com.pomadchin.day15

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input         = readInput()
  def inputExample  = readInput("src/main/resources/day15/example.txt")
  def input2Example = readInput("src/main/resources/day15/example.txt", true)

  test("Q1Example") { assertEquals(part1.tupled(inputExample), 40d) }
  test("Q1") { assertEquals(part1.tupled(input), 388d) }
// test("Q2Example") { println(part2.tupled(input2Example)) }
// test("Q2") {}
