package com.pomadchin.day22

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input         = readInput()
  def inputExample  = readInput("src/main/resources/day22/example.txt")
  def inputExample1 = readInput("src/main/resources/day22/example1.txt")

  test("Q1Example") { assertEquals(part1(inputExample), 590784L) }
  test("Q1") { assertEquals(part1(input), 596989L) }
  test("Q2Example") { assertEquals(part2(inputExample1), 2758514936282235L) }
  test("Q2") { assertEquals(part2(input), 1160011199157381L) }
