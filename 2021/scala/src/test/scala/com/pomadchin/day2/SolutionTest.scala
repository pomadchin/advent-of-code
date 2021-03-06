package com.pomadchin.day2

class SolutionTest extends munit.FunSuite:
  import Solution.*
  lazy val input = readInput().toList

  test("Q1") { assertEquals(part1(input.iterator), 1636725) }
  test("Q2") { assertEquals(part2(input.iterator), 1872757425) }
