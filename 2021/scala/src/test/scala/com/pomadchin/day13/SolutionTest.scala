package com.pomadchin.day13

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input        = readInput()
  def inputExample = readInput("src/main/resources/day13/example.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 17) }
  test("Q1") { assertEquals(part1(input), 751) }
  test("Q2Example") { println(part2(inputExample)) } // prints 0
  test("Q2") { println(part2(input)) }               // prints PGHRKLKL
