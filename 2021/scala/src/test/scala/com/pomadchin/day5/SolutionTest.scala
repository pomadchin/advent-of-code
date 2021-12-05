package com.pomadchin.day5

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input        = readInput()
  lazy val inputExample = readInput("src/main/resources/day5/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 5) }
  test("Q1") { assertEquals(part1(input), 4873) }
  test("Q2Example") { assertEquals(part2(inputExample), 12) }
  test("Q2") { assertEquals(part2(input), 19472) }
  test("Q1Example**") { assertEquals(part1nf(inputExample.iterator), 5) }
  test("Q1**") { assertEquals(part1nf(input.iterator), 4873) }
  test("Q2Example**") { assertEquals(part2nf(inputExample.iterator), 12) }
  test("Q2**") { assertEquals(part2nf(input.iterator), 19472) }
