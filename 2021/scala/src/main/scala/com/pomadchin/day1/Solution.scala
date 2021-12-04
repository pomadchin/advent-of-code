package com.pomadchin.day1

import scala.io.Source

object Solution:
  def readNumbers: Array[Int] =
    Source
      .fromFile("src/main/resources/day1/puzzle1.txt")
      .getLines
      .map(_.toInt)
      .toArray

  def numberOfIncreasesLoop(a: Array[Int]): Int =
    var (counts, i, prev) = (0, 1, a(0))

    while i < a.length do
      if (a(i) > prev) counts += 1
      prev = a(i)
      i = i + 1

    counts

  def numberOfIncreasesLoopWindow(a: Array[Int]): Int =
    var (counts, i, prev) = (0, 1, a.take(3).sum)

    while i < a.length - 2 do
      val next = a(i) + a(i + 1) + a(i + 2)
      if (next > prev) counts += 1
      prev = next
      i = i + 1

    counts

  def numberOfIncreasesSliding(a: Array[Int]): Int =
    a.sliding(2, 1).count(a => a(0) < a(1))

  def numberOfIncreasesSlidingWindow(a: Array[Int]): Int =
    a.sliding(3, 1).map(_.sum).sliding(2, 1).count(a => a(0) < a(1))

  def main(args: Array[String]): Unit =
    val input = readNumbers
    println(s"Q1: ${numberOfIncreasesLoop(input)}")
    println(s"Q1*: ${numberOfIncreasesSliding(input)}")
    println(s"Q2: ${numberOfIncreasesLoopWindow(input)}")
    println(s"Q2*: ${numberOfIncreasesSlidingWindow(input)}")
