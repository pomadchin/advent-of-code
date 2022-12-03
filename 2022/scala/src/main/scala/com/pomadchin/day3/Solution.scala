package com.pomadchin.day3

import scala.io.Source

object Solution:

  val index = ".abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

  opaque type Letter = Char
  object Letter:
    def apply(c: Char): Letter = c

  extension (l: Letter)
    def c: Char       = l
    def priority: Int = index.indexOf(c)

  opaque type Compartments = (Set[Letter], Set[Letter])
  object Compartments:
    def apply(t: (Set[Letter], Set[Letter])): Compartments  = t
    def apply(f: Set[Letter], s: Set[Letter]): Compartments = f -> s

  extension (t: Compartments)
    def tupled: (Set[Letter], Set[Letter]) = t
    def set: Set[Letter]                   = t._1 ++ t._2

  def readInput(path: String = "src/main/resources/day3/puzzle1.txt"): List[Compartments] =
    Source
      .fromFile(path)
      .getLines
      .map(line => line.splitAt(line.length() / 2))
      .map((fst, snd) => Compartments(fst.toSet.map(Letter(_)), snd.toSet.map(Letter(_))))
      .toList

  def part1(input: List[Compartments]): Int =
    input.map((fst, snd) => fst.intersect(snd).map(_.priority).sum).sum

  def part2(input: List[Compartments]): Int =
    input.grouped(3).map(_.toSet.map(_.set).reduce(_.intersect(_)).map(_.priority).sum).sum
