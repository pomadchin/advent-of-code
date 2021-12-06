package com.pomadchin.day6

import scala.io.Source
import scala.annotation.tailrec

object Solution:

  def readInput(path: String = "src/main/resources/day6/puzzle1.txt"): List[Int] =
    Source
      .fromFile(path)
      .getLines
      .flatMap(_.split(",").toList.map(_.toInt))
      .toList

  def part1(input: List[Int], d: Int): Int =
    @tailrec
    def part1rec(state: List[Int], days: Int): List[Int] =
      days match
        case 0 => state
        case _ =>
          val next = state.flatMap {
            case 0 => 6 :: 8 :: Nil
            case i => (i - 1) :: Nil
          }
          part1rec(next, days - 1)

    part1rec(input, d).length

  def part2(input: List[Int], d: Int): Long =
    // state of frequences
    val initState: Map[Int, Long] =
      input
        .groupBy(identity)
        .view
        .mapValues(_.length.toLong)
        .toMap

    @tailrec
    def part2rec(state: Map[Int, Long], days: Int): Map[Int, Long] =
      if (days == 0) state
      else
        val c0 = state.get(0)
        c0 match {
          case Some(c0) =>
            // if there is a zero, decrement all but zero
            val noZerosState = (state - 0).map { (t, c) => (t - 1, c) }
            // set add to 6 all zeros
            // spawn extra states into the 8
            val with68State =
              noZerosState +
                // there can be some 6s in the state already
                (6 -> (noZerosState.get(6).getOrElse(0L) + c0)) +
                (8 -> c0) // there can be no 8s, since we did the substraction before
            part2rec(with68State, days - 1)
          case _ =>
            // if no zeros in the freqs state, decrement all
            part2rec(state.map { (t, c) => (t - 1, c) }, days - 1)
        }

    part2rec(initState, d).map(_._2).sum
