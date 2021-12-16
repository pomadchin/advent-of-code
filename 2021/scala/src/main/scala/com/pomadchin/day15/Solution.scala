package com.pomadchin.day15

import scala.io.Source
import scala.collection.mutable

object Solution:
  opaque type Table = Seq[Seq[Int]]
  object Table:
    def apply(s: Seq[Seq[Int]]): Table = s

  extension (t: Table)
    def toSeq: Seq[Seq[Int]]              = t
    def cols: Int                         = toSeq(0).length
    def rows: Int                         = toSeq.length
    def tableSize: Int                    = cols * rows
    def index(row: Int, col: Int): Int    = row * cols + col
    def col(index: Int): Int              = index % cols
    def row(index: Int): Int              = index / cols
    def get(row: Int, col: Int): Int      = toSeq(row)(col)
    def getSafe(row: Int, col: Int): Int  = toSeq(row % rows)(col % cols)
    def get(index: Int): Int              = toSeq(row(index))(col(index))
    def adj(index: Int): List[(Int, Int)] = adj(row(index), col(index))
    def adj(row: Int, col: Int): List[(Int, Int)] =
      List((-1, 0), (1, 0), (0, -1), (0, 1))
        .map((dr, dc) => (row + dr, col + dc))
        .filter((r, c) => r >= 0 && r < rows && c >= 0 && c < cols)

  def readInput(path: String = "src/main/resources/day15/puzzle1.txt"): Table =
    Table(
      Source
        .fromFile(path)
        .getLines
        .toList
        .map(_.map(_.asDigit))
    )

  def dijkstra(table: Table): Int =
    val distTo = Array.fill[Int](table.tableSize)(Int.MaxValue)

    // should be an indexed PQ to be more mem efficient
    var pq = mutable.PriorityQueue.empty[(Int, Int)](Ordering[(Int, Int)].reverse)

    // first and the last real nodes in the graph
    val first = 0
    val last  = table.tableSize - 1

    distTo(first) = 0
    pq.enqueue(distTo(first) -> first)

    def relax(from: Int, to: Int): Unit =
      val weight = table.get(to)
      if distTo(to) > distTo(from) + weight then
        distTo(to) = distTo(from) + weight
        pq.enqueue(distTo(to) -> to)

    while pq.nonEmpty do
      val (_, from) = pq.dequeue
      table.adj(from).map(table.index).foreach(relax(from, _))

    distTo(last)

  def part1(table: Table) = dijkstra(table)

  def part2(stable: Table) =
    val arr = Array.ofDim[Int](stable.rows * 5, stable.cols * 5)
    for {
      r  <- 0 until stable.rows
      c  <- 0 until stable.cols
      dr <- 0 until 5
      dc <- 0 until 5
    } do arr(r + dr * stable.rows)(c + dc * stable.cols) = (stable.get(r, c) + dc + dr - 1) % 9 + 1
    dijkstra(Table(arr.toIndexedSeq.map(_.toSeq).toSeq))
