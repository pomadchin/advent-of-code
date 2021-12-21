package com.pomadchin.day21

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day21/example.txt")

  test("Q1Example") { assertEquals(part1.tupled(inputExample), 739785) }
  test("Q1") { assertEquals(part1.tupled(input), 906093) }
  test("Q2Example") {}
  test("Q2") {}
