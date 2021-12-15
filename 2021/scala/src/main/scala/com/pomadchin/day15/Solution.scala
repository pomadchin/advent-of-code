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

  def readInput(path: String = "src/main/resources/day15/puzzle1.txt", tiled: Boolean = false): (Table, EdgeWeightedDigraph) =
    val stable = Table(
      Source
        .fromFile(path)
        .getLines
        .toList
        .map(_.map(_.asDigit))
    )

    val table =
      if tiled then
        val t = 5
        Table((0 until (t * stable.rows)).map { r =>
          (0 until (t * stable.cols)).map { c =>
            ((stable.getSafe(r, c) + c / stable.cols + r / stable.cols - 1) % 9) - 1
          }
        })
      else stable

    // add extra two edges =>
    val G = new EdgeWeightedDigraph(table.tableSize + 2)

    // extra (vritual) graph nodes indices
    val top    = table.tableSize
    val bottom = top + 1

    // first and the last real nodes in the graph
    val first = 0
    val last  = top - 1

    // add the top vertex
    G.addEdge(DirectedEdge(top, first, table.get(0)))
    // add the bottom vertex
    G.addEdge(DirectedEdge(last, bottom, table.get(last)))

    // build the rest of the graph
    (0 until table.rows).foreach { r =>
      (0 until table.cols).foreach { c =>
        val from = table.index(r, c)
        // add all nodes into the graph the current element is linked to
        table.adj(r, c).map(table.index).foreach { to => G.addEdge(DirectedEdge(from, to, table.get(to))) }
      }
    }

    (table, G)

  def dijkstra(table: Table, G: EdgeWeightedDigraph): Double =
    // array of visits
    val marked = Array.ofDim[Boolean](G.getV)
    // stores (edge weight, cumulative dist)
    val distTo = Array.fill[(Double, Double)](G.getV)((Double.MaxValue, Double.MaxValue))

    // should be an indexed PQ to be more mem efficient
    var pq = mutable.PriorityQueue.empty[(Int, Double)](Ordering.by[(Int, Double), Double](-_._2))

    val top    = table.tableSize
    val bottom = top + 1
    // first and the last real nodes in the graph
    val first = 0
    val last  = top - 1

    distTo(top) = (0, 0)

    pq.enqueue(top -> distTo(0)._2)

    def relax(edge: DirectedEdge): Unit =
      val (from, to) = edge.from -> edge.to
      if distTo(to)._2 > distTo(from)._2 + edge.weight then
        distTo(to) = (edge.weight, distTo(from)._2 + edge.weight)
        pq.enqueue(to -> distTo(to)._2)

    while pq.nonEmpty do G.adjList(pq.dequeue._1).foreach(relax)

    val dist = distTo(last)
    dist._2 - dist._1

  def part1(table: Table, G: EdgeWeightedDigraph) =
    dijkstra(table, G)

  def part2(table: Table, G: EdgeWeightedDigraph) =
    dijkstra(table, G)
