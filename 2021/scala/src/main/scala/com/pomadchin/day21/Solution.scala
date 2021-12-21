package com.pomadchin.day21

import scala.io.Source
import scala.annotation.tailrec

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
  def dice: State[Int, Int] = State { i =>
    val v = math.max(1, i % 101); (v, v + 1)
  }

  def roll: State[Int, (Int, Int)] =
    for
      d1 <- dice
      d2 <- dice
      d3 <- dice
    yield (d1 + d2 + d3, d3)

  @tailrec
  def compute(p1: Int, p2: Int, p1score: Int, p2score: Int, step: Int, state: Int): Int =
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

        compute(p1n, p2n, p1scoren, p2scoren, step + 1, p2state)

  def part1(p1: Int, p2: Int): Int =
    compute(p1, p2, 0, 0, 1, 1)
