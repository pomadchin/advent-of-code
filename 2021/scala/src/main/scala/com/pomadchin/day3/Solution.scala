package com.pomadchin.day3

import com.pomadchin.util.CforMacros.cfor

import scala.io.Source

/**
 * I went hard and abused cfor loop
 */
object Solution:
  val R                              = 2
  val shift                          = '0'
  def charAt(s: String, i: Int): Int = if (i < s.length) s.charAt(i) - shift else -1

  def readInput(path: String = "src/main/resources/day3/puzzle1.txt"): Array[String] =
    Source
      .fromFile(path)
      .getLines
      .toArray

  // go radix like, all strings are of the same length
  // we can go linear time
  def part1(a: Array[String]): Int =
    val W = a(0).length
    val N = a.length

    // most common bit in the corresponding position
    val sb: StringBuilder = new StringBuilder()

    cfor(0)(_ < W, _ + 1) { d =>
      val counts: Array[Int] = Array.ofDim(R + 1)

      // compute frequences
      cfor(0)(_ < N, _ + 1) { i =>
        counts(charAt(a(i), d) + 1) += 1
      }

      // counts contains freqs of 0s and 1s
      if (counts(1) > counts(2)) sb.append("0")
      else sb.append("1")
    }

    val res      = sb.toString
    val (gr, er) = binToDec(res) -> binToDecInverted(res)

    gr * er

  def part2(a: Array[String]): Int =
    val aux    = Array.ofDim[String](a.length)
    val (o, _) = part2msd(a, aux, 0, a.length - 1, 0, _ > _)
    val (c, _) = part2msd(a, aux, 0, a.length - 1, 0, _ <= _)
    val od     = binToDec(a(o))
    val oc     = binToDec(a(c))

    od * oc

  // the idea to go down msd like, recursively
  // selecting always the smaller subarray
  def part2msd(a: Array[String], aux: Array[String], lo: Int, hi: Int, d: Int, cmp: (Int, Int) => Boolean): (Int, Int) =
    if (lo < hi) {
      val counts = Array.ofDim[Int](R + 2) // take care of the end of string, do we need it though?

      // compute counts
      cfor(lo)(_ <= hi, _ + 1) { i => counts(charAt(a(i), d) + 2) += 1 }

      val countsStats = counts.clone

      // compute cumulatatives
      cfor(0)(_ < R + 1, _ + 1) { r => counts(r + 1) += counts(r) }

      // fill in the aux array
      cfor(lo)(_ <= hi, _ + 1) { i =>
        val cidx = charAt(a(i), d) + 1 // shift to the right due to +2 in counts
        aux(counts(cidx)) = a(i)
        counts(cidx) += 1
      }

      // fill in the original array
      cfor(lo)(_ <= hi, _ + 1) { i =>
        a(i) = aux(i - lo)
      }

      if (cmp(countsStats(2), countsStats(3))) part2msd(a, aux, lo + counts(0), lo + counts(1) - 1, d + 1, cmp)
      else part2msd(a, aux, lo + counts(1), lo + counts(2) - 1, d + 1, cmp)
    } else (lo, hi)

  def part2way(a: Array[String]): Int =
    val aux = Array.ofDim[String](a.length)
    part2msd2way(a, aux, 0, a.length - 1, 0).map(a.apply).map(binToDec).product

  // the idea to go down msd like, recursively
  // selecting always the smaller subarray
  def part2msd2way(a: Array[String], aux: Array[String], lo: Int, hi: Int, d: Int): List[Int] =
    if (lo < hi) {
      val counts = Array.ofDim[Int](R + 2) // take care of the end of string, do we need it though?

      // compute counts
      cfor(lo)(_ <= hi, _ + 1) { i => counts(charAt(a(i), d) + 2) += 1 }

      val countsStats = counts.clone

      // compute cumulatatives
      cfor(0)(_ < R + 1, _ + 1) { r => counts(r + 1) += counts(r) }

      // fill in the aux array
      cfor(lo)(_ <= hi, _ + 1) { i =>
        val cidx = charAt(a(i), d) + 1 // shift to the right due to +2 in counts
        aux(counts(cidx)) = a(i)
        counts(cidx) += 1
      }

      // fill in the original array
      cfor(lo)(_ <= hi, _ + 1) { i => a(i) = aux(i - lo) }

      // "most significant" bits
      val ms =
        if (countsStats(2) > countsStats(3)) part2msd2way(a, aux, lo + counts(0), lo + counts(1) - 1, d + 1)
        else part2msd2way(a, aux, lo + counts(1), lo + counts(2) - 1, d + 1)

      // "least significant" bits
      val ls =
        if (countsStats(2) <= countsStats(3)) part2msd2way(a, aux, lo + counts(0), lo + counts(1) - 1, d + 1)
        else part2msd2way(a, aux, lo + counts(1), lo + counts(2) - 1, d + 1)

      // truncated ms list
      val tms = if (ms.size > 1) ms.tail else ms
      ls.head :: tms

    } else lo :: Nil // always keep pointer to the last subarray reached

  // I randomly decided to practice lsd sort there, btw, Scala loops are a mess
  def lsdsort(a: Array[String]): Array[String] =
    val W                  = a(0).length
    val N                  = a.length
    val R                  = 2
    val shift              = '0'
    val aux: Array[String] = Array.ofDim(N)

    // most common bit in the corresponding position
    // val sb: StringBuilder = new StringBuilder()

    // in the order of the least significant char
    // start with the last char
    cfor(W - 1)(_ >= 0, _ - 1) { d =>
      val counts: Array[Int] = Array.ofDim(R + 1)

      // compute frequences
      cfor(0)(_ < N, _ + 1) { i =>
        counts(a(i).charAt(d) - shift + 1) += 1
      }

      // compute cumulatatives
      cfor(0)(_ < R - 1, _ + 1) { r =>
        counts(r + 1) += counts(r)
      }

      // fill in the aux array
      cfor(0)(_ < N, _ + 1) { i =>
        val cidx = charAt(a(i), d)
        aux(counts(cidx)) = a(i)
        counts(cidx) += 1
      }

      // fill in the init array
      cfor(0)(_ < N, _ + 1) { i =>
        a(i) = aux(i)
      }
    }

    a

  // res * 2 + current pos
  def binToDec(str: String): Int =
    var res = 0
    cfor(0)(_ < str.length, _ + 1) { i => res = res * 2 + charAt(str, i) }
    res

  def binToDecInverted(str: String): Int =
    var res = 0;
    cfor(0)(_ < str.length, _ + 1) { i => res = res * 2 + charAt(str, i) ^ 1 }
    res

  def binToDecFl(str: String): Int =
    str.map(_ - shift).foldLeft(0) { case (a, c) => a * 2 + c }

  def binToDecFlInverted(str: String): Int =
    str.map(_ - shift).foldLeft(0) { case (a, c) => a * 2 + c ^ 1 }

  def part1f(input: List[String]) =
    val gr = input.transpose.map { _.groupBy(identity).toList.map(_._2).maxBy(_.length).head }.mkString
    binToDecFl(gr) * binToDecFlInverted(gr)

  def part2f(input: List[String]) =
    def iter(rows: List[String], col: Int, j: Int): String =
      rows match
        // one string => reached the goal
        case List(h) => h
        case _       =>
          // group by col
          // sort by the group (size, char), so 1 is always in the second position
          // the smaller is 0, the larger group is 1
          val next = rows.groupBy(_(col)).map { (c, seq) => (seq.size, c) -> seq }.toSeq.sortBy(_._1).map(_._2)(j)
          iter(next, col + 1, j)

    (0 to 1).map(iter(input, 0, _)).map(binToDecFl).product
