package com.pomadchin.day6

import scala.io.Source
import scala.annotation.tailrec
import com.pomadchin.util.CforMacros.cfor

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
        c0 match
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

    part2rec(initState, d).map(_._2).sum

  import scala.collection.mutable
  def part2nf(input: List[Int], d: Int): Long =
    val state: mutable.Map[Int, Long] = mutable.Map()
    input.foreach { i => state.put(i, state.get(i).getOrElse(0L) + 1L) }

    cfor(0)(_ < d, _ + 1) { i =>
      val c0 = state.get(0)
      state.remove(0)

      cfor(1)(_ < 9, _ + 1) { j =>
        state.get(j).foreach { c =>
          state.put(j - 1, c)
          state.remove(j)
        }
      }
      c0 match
        case Some(c0) =>
          state.put(6, state.get(6).getOrElse(0L) + c0)
          state.put(8, c0)

        case _ =>
    }
    state.map(_._2).sum

  def part2nfa(input: List[Int], d: Int): Long =
    // position means the state
    val a: Array[Long] = Array.fill(9)(-1) // -1 means no element is inside
    input.foreach { i => a(i) = math.max(0, a(i)) + 1L }

    cfor(0)(_ < d, _ + 1) { i =>
      val c0 = a(0)
      // erase c0 if necessary
      if (c0 != -1) a(0) = -1
      // shift elements to the left
      cfor(1)(_ < 9, _ + 1) { j =>
        a(j - 1) = a(j)
        // don't forget to erase it's previous position
        a(j) = -1
      }
      // if there is c0, adjust the array
      if (c0 > 0)
        // fill in 6
        a(6) = math.max(0, a(6)) + c0
        // add 8
        a(8) = c0
    }

    // we can fold, but i'm using foreach here
    var accumulator = 0L
    a.foreach { accumulator += math.max(0, _) }
    accumulator
