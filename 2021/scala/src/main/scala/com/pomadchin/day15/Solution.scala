package com.pomadchin.day15

import scala.io.Source
import scala.collection.mutable

object Solution:
  opaque type Table = Seq[Seq[Int]]
  object Table:
    def apply(s: Seq[Seq[Int]]): Table = s

  extension (t: Table)
    def toSeq: Seq[Seq[Int]]                = t
    def cols: Int                           = toSeq(0).length
    def rows: Int                           = toSeq.length
    def tableSize: Int                      = cols * rows
    def indexToGrid(index: Int): (Int, Int) = row(index) -> col(index)
    def index(row: Int, col: Int): Int      = row * cols + col
    def col(index: Int): Int                = index       % cols
    def row(index: Int): Int                = index / cols
    def get(row: Int, col: Int): Int        = toSeq(row)(col)
    def getSafe(row: Int, col: Int): Int    = toSeq(row % rows)(col % cols)
    def get(index: Int): Int                = toSeq(row(index))(col(index))
    def adj(index: Int): List[(Int, Int)]   = adj(row(index), col(index))
    def adj(row: Int, col: Int): List[(Int, Int)] =
      List((-1, 0), (1, 0), (0, -1), (0, 1))
        .map((dr, dc) => (row + dr, col + dc))
        .filter((r, c) => r >= 0 && r < rows && c >= 0 && c < cols)

  def readInput(path: String = "src/main/resources/day15/puzzle1.txt", tiled: Boolean = false): Table =
    val stable = Table(
      Source
        .fromFile(path)
        .getLines
        .toList
        .map(_.map(_.asDigit))
    )

    val table =
      if tiled then
        val arr = Array.ofDim[Int](stable.rows * 5, stable.cols * 5)
        for {
          x     <- 0 until stable.cols
          y     <- 0 until stable.rows
          gridX <- 0 until 5
          gridY <- 0 until 5
        } yield arr(x + gridX * stable.cols)(y + gridY * stable.rows) = (stable.get(x, y) + gridX + gridY - 1) % 9 + 1
        Table(arr.toIndexedSeq.map(_.toSeq).toSeq)
      else stable

    table

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
