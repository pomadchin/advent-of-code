package com.pomadchin.day10

import scala.io.Source

object Solution:

  def readInput(path: String = "src/main/resources/day10/puzzle1.txt"): Iterator[String] =
    Source
      .fromFile(path)
      .getLines

  val scores: Map[Char, Int] = Map(
    ')' -> 3,
    ']' -> 57,
    '}' -> 1197,
    '>' -> 25137
  )

  val matching: Map[Char, Char] = Map(
    ')' -> '(',
    ']' -> '[',
    '}' -> '{',
    '>' -> '<'
  )

  val matchingr: Map[Char, Char] = matching.map((k, v) => (v, k))

  val scoresr: Map[Char, Int] = Map(
    ')' -> 1,
    ']' -> 2,
    '}' -> 3,
    '>' -> 4
  )

  extension (str: String)
    // left is the stack of opening parentheses
    // the right is score
    // non empty stack is always scored 0
    def stackScored: (List[Char], Long) =
      str.foldLeft(List.empty[Char] -> 0L) { case ((acc, score), c) =>
        if score == 0 then
          c match
            // using list as a stack
            case '(' | '[' | '{' | '<' => (c :: acc, score)
            case _ =>
              val op = acc.head
              // skip if closed (no score addition happens)
              if (matching(c) == op) (acc.tail, score)
              // compute scores for everything that is after a non closed parentheses
              else (Nil, scores(c))
        else (acc -> score)
      }

  def part1(input: Iterator[String]): Long =
    input
      .map(_.stackScored)
      .toList
      .map(_._2)
      .sum

  def part2(input: Iterator[String]): Long =
    val res =
      input
        .flatMap { str =>
          val (res, _) = str.stackScored
          if res.nonEmpty then Some(res.foldLeft(0L)((acc, c) => acc * 5 + scoresr(matchingr(c))))
          else None
        }
        .toList
        .sorted
    res(res.length / 2)
