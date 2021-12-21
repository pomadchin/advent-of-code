package com.pomadchin.day21

import scala.io.Source
import scala.annotation.tailrec
import scala.collection.mutable

case class State[S, A](run: S => (A, S)):
  def map[B](f: A => B): State[S, B] = State(s =>
    val (a, ns) = run(s)
    (f(a), ns)
  )

  def flatMap[B](f: A => State[S, B]): State[S, B] = State(s =>
    val (a, ns) = run(s)
    f(a).run(ns)
  )

object Solution:
  def readInput(path: String = "src/main/resources/day21/puzzle1.txt"): (Int, Int) =
    val List(p1, p2) = Source.fromFile(path).getLines.map(_.split("starting position: ").last.toInt).toList
    (p1, p2)

  // [1, 10]
  def score(i: Int): Int = { val v = i % 10; if (v == 0) 10 else v }

  // [1; 100]
  val dice: State[Int, Int] = State { i =>
    val v = math.max(1, i % 101); (v, v + 1)
  }

  def roll: State[Int, (Int, Int)] =
    for
      d1 <- dice
      d2 <- dice
      d3 <- dice
    yield (d1 + d2 + d3, d3)

  @tailrec
  def computeDeterministic(p1: Int, p2: Int, p1score: Int, p2score: Int, step: Int, state: Int): Int =
    if p1score >= 1000 then p2score * (step * 6 - 3)
    else if p2score >= 1000 then p1score * step * 6
    else
      // player 1
      val ((p1points, _), p1state) = roll.run(state)
      val p1n                      = score(p1points + p1)
      val p1scoren                 = p1score + p1n

      if p1scoren >= 1000 then
        // player 1 won immediately
        p2score * (step * 6 - 3)
      else
        // player2
        val ((p2points, _), p2state) = roll.run(p1state)
        val p2n                      = score(p2points + p2)
        val p2scoren                 = p2score + p2n

        computeDeterministic(p1n, p2n, p1scoren, p2scoren, step + 1, p2state)

  // compute all possible rolls of 3
  val allrolls =
    for
      i <- 1 to 3
      j <- 1 to 3
      k <- 1 to 3
    yield i + j + k

  // cache func calls
  val memoizeDirac = mutable.Map.empty[(Int, Int, Int, Int), (Long, Long)]
  def computeDirac(p1: Int, p2: Int, p1score: Int, p2score: Int): (Long, Long) =
    memoizeDirac.getOrElseUpdate(
      (p1, p2, p1score, p2score), {
        if p1score >= 21 then (1, 0)
        else if p2score >= 21 then (0, 1)
        else
          // everytime throw all dice
          allrolls.foldLeft(0L -> 0L) { case ((p1winsa, p2winsa), r) =>
            // compute p1 score first
            var p1n = score(p1 + r)
            // compute the summ score
            var p1scoren = p1score + p1n

            // now do the same but for the p2
            // swap func arguments
            val (p2wins, p1wins) = computeDirac(p2, p1n, p2score, p1scoren)

            (p1winsa + p1wins, p2winsa + p2wins)
          }
      }
    )

  def part1(p1: Int, p2: Int): Int =
    computeDeterministic(p1, p2, 0, 0, 1, 1)

  def part2(p1: Int, p2: Int): Long =
    val (l, r) = computeDirac(p1, p2, 0, 0)
    math.max(l, r)
