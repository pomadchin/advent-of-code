package com.pomadchin.day4

import scala.io.Source
import scala.annotation.tailrec

case class Input(numbers: List[Int], boards: List[Board]):
  def part1: Int =
    @tailrec
    def part1rec(n: List[Int], boards: List[Board]): Int =
      val v       = n.head
      val mboards = boards.map(_.mark(v))
      mboards.find(_.isCompleted) match
        case Some(board) => board.score * v
        case _           => part1rec(n.tail, mboards)

    part1rec(numbers, boards)

  def part2: Int =
    @tailrec
    def part2rec(n: List[Int], boards: List[Board], acc: List[Int]): List[Int] =
      n match
        case Nil => acc
        case v :: tail =>
          val mboards = boards.map(_.mark(v))
          mboards.find(_.isCompleted) match
            case Some(board) => part2rec(tail, mboards.filterNot(_.isCompleted), board.score * v :: acc)
            case _           => part2rec(tail, mboards, acc)

    part2rec(numbers, boards, Nil).head

case class Board(cells: List[List[Int]], marked: List[List[Boolean]]):
  def mark(v: Int)         = copy(marked = cells.zip(marked).map { case (row, mrow) => row.zip(mrow).map { case (c, m) => m || c == v } })
  def score: Int           = cells.zip(marked).flatMap { case (row, mrow) => row.zip(mrow).filterNot(_._2).map(_._1) }.sum
  def isCompleted: Boolean = marked.exists(_.forall(identity)) || marked.transpose.exists(_.forall(identity))

object Solution:
  def readInput: Input =
    val lines =
      Source
        .fromFile("src/main/resources/day4/puzzle1.txt")
        .getLines
        .toArray

    val numbers = lines.head.split(",").map(_.toInt).toList

    val boards =
      lines.tail
        .grouped(6)
        .toList
        .map(_.toList)
        .map { list =>
          val cells = list.map(_.split("\\W+").filter(_.nonEmpty).toList).filter(_.nonEmpty).map(_.map(_.toInt))
          Board(cells, cells.map(_.map(_ => false)))
        }

    Input(numbers, boards)

  def main(args: Array[String]): Unit =
    val input = readInput
    println(s"Q1: ${input.part1}") // 35711
    println(s"Q2: ${input.part2}") // 5586
