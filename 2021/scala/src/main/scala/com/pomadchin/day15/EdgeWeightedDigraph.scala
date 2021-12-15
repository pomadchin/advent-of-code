package com.pomadchin.day15

import scala.collection.Iterable
import scala.collection.mutable

case class DirectedEdge(from: Int, to: Int, weight: Double):
  def tupled: (Int, Int)        = from -> to
  override def toString: String = s"$from -> $to | $weight"

class EdgeWeightedDigraph(V: Int):
  private var E: Int = 0

  private val adj: mutable.ListBuffer[mutable.ListBuffer[DirectedEdge]] = mutable.ListBuffer()
  // fill in the adj matrix
  (0 until V).foreach(idx => adj += mutable.ListBuffer())

  def getV: Int = V
  def getE: Int = E

  def addEdge(e: DirectedEdge): Unit             = { adj(e.from) += e; E += 1 }
  def adjList(from: Int): Iterable[DirectedEdge] = adj(from)

  override def toString: String =
    s"""
       | Digraph {
       |   V = ${getV}
       |   E = ${getE}
       |   adj = ${adj.toString}
       | }
    """.stripMargin
