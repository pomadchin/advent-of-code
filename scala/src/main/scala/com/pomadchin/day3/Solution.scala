package com.pomadchin.day3

import com.pomadchin.util.CforMacros.cfor

import scala.io.Source

/** I went hard and abused cfor loop */
object Solution:
  val R = 2
  val shift = '0'
  def charAt(s: String, i: Int): Int = if(i < s.length) s.charAt(i) - shift else -1

  def readInput: Array[String] =
    Source
      .fromFile("src/main/resources/day3/puzzle1.txt")
      .getLines
      .toArray

  // go radix like, all strings are of the same length
  // we can go linear time
  def part1(a: Array[String]): Int =
    val W = a(0).length
    val N = a.length

    // most common bit in the corresponding position
    val sb: StringBuilder = new StringBuilder()
    
    // in the order of the least significant char
    // start with the last char
    cfor(0)(_ < W, _ + 1) { d =>
      val counts: Array[Int] = Array.ofDim(R + 1)

      // compute frequences 
      cfor(0)(_ < N, _ + 1) { i =>
        counts(charAt(a(i), d) + 1) += 1
      }

      // counts contains freqs of 0s and 1s
      if(counts(1) > counts(2)) sb.append("0")
      else sb.append("1")
    }

    val res = sb.toString
    val (gr, er) = binToDec(res) -> binToDecInverted(res)
  
    gr * er


  def part2(a: Array[String]): Int =
    val aux = Array.ofDim[String](a.length)
    val (o, _) = part2msd(a, aux, 0, a.length - 1, 0, _ > _)
    val od = binToDec(a(o))
    val (c, _) = part2msd(a, aux, 0, a.length - 1, 0, _ <= _)
    val oc = binToDec(a(c))

    od * oc

  // the idea to go down msd like, recursively
  // selecting always the smaller subarray 
  def part2msd(a: Array[String], aux: Array[String], lo: Int, hi: Int, d: Int, cmp: (Int, Int) => Boolean): (Int, Int) = 
    if(lo < hi && a.length > 1) {
      val counts = Array.ofDim[Int](R + 2); // take care of the end of string, do we need it though?
      var (i, r) = (0, 0)

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
      
      if(cmp(countsStats(2), countsStats(3))) part2msd(a, aux, lo + counts(0), lo + counts(1) - 1, d + 1, cmp)
      else part2msd(a, aux, lo + counts(1), lo + counts(2) - 1, d + 1, cmp)
    } else (lo, hi)

    

  // I randomly decided to practice lsd sort there, since I forgot it and in Scala loops are a mess
  def lsdsort(a: Array[String]): Array[String] =
    val W = a(0).length
    val N = a.length
    val R = 2
    val shift = '0'
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
    
  def main(args: Array[String]): Unit =
    println(s"Q1: ${part1(readInput)}") // 2003336
    println(s"Q2: ${part2(readInput)}") // 1877139
