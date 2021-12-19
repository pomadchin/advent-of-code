package com.pomadchin.day18

class SolutionTest extends munit.FunSuite:
  import Solution.*
  def input           = readInput().toList
  def inputExample    = readInput("src/main/resources/day18/example.txt").toList
  def inputExample1   = readInput("src/main/resources/day18/example1.txt").toList
  def inputExample2   = readInput("src/main/resources/day18/example2.txt").toList
  def inputExampleRaw = readInputRaw("src/main/resources/day18/example.txt").toList

  test("parse") { assertEquals(inputExampleRaw, inputExample.map(_.toString)) }
  test("explode") {
    val test1     = parse("[[6,[5,[4,[3,2]]]],1]")
    val expected1 = parse("[[6,[5,[7,0]]],3]")
    assertEquals(explode(test1), expected1 -> true)

    val test2     = parse("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
    val expected2 = parse("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")

    assertEquals(explode(test2), expected2 -> true)
  }
  test("split") {
    val explode1 = explode(parse("[[[[0,7],4],[7,[[8,4],9]]],[1,1]]"))._1
    assertEquals(explode1.toString, "[[[[0,7],4],[15,[0,13]]],[1,1]]")

    val split1 = split(explode1)._1
    assertEquals(split1.toString, "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")

    val split2 = split(split1)._1
    assertEquals(split2.toString, "[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")
  }
  test("Q1Example") { assertEquals(part1(inputExample1), 4140) }
  test("Q1") { assertEquals(part1(input), 4289) }
  test("Q2Example") { assertEquals(part2(inputExample2), 3993) }
  test("Q2") { assertEquals(part2(input), 4807) }
