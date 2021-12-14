package com.pomadchin.day14

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day14/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample, 10), 1588L) }
  test("Q1") { assertEquals(part1(input, 10), 2584L) }
  test("Q1*") { assertEquals(part1f(input, 10), 2584L) }
  test("Q2Example") { assertEquals(part1(inputExample, 40), 2188189693529L) }
  test("Q2") { assertEquals(part1(input, 40), 3816397135460L) }
  test("Q2*") { assertEquals(part1f(input, 40), 3816397135460L) }
