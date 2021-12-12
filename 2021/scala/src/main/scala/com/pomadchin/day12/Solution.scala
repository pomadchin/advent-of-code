package com.pomadchin.day12

import scala.io.Source
import scala.collection.mutable
import scala.collection.mutable.ListBuffer

class Digraph:
  import Digraph.*
  // number of edges
  private var E: Int = 0
  // adjacent matrix, vertex -> list of adjacent nodes
  private var adj: mutable.Map[Vertex, mutable.ListBuffer[Vertex]] = mutable.Map()

  def addEdge(from: Vertex, to: Vertex): Digraph =
    if !adj.contains(from) then adj.put(from, mutable.ListBuffer())
    if !adj.contains(to) then adj.put(to, mutable.ListBuffer())
    adj(from) += to
    adj(to) += from
    E += 1
    this

  def adjList(v: Vertex): List[Vertex] = adj.get(v).fold(Nil)(_.toList)

  def vertices: List[Vertex] = adj.keys.toList
  def getV: Int              = adj.keys.size
  def getE: Int              = E

  override def toString: String =
    s"""
       | Digraph {
       |   V = ${getV}
       |   E = ${getE}
       |   adj = ${adj.toString}
       | }
    """.stripMargin

object Digraph:
  // name is the string name of a cave, and big a flag is it a big cave so we can visit it multiple times
  opaque type Vertex = String
  object Vertex:
    def apply(s: String): Vertex = s

  extension (v: Vertex)
    def isBig: Boolean       = v.forall(_.isUpper)
    def isSmall: Boolean     = !isBig
    def isStart: Boolean     = v == StartVertex
    def isEnd: Boolean       = v == EndVertex
    def isTerminal: Boolean  = isStart || isEnd
    def nonTerminal: Boolean = !isTerminal

  val StartVertex = Vertex("start")
  val EndVertex   = Vertex("end")

object DFS:
  import Digraph.*

  def dfs(G: Digraph): Int =
    val marked: mutable.Map[Vertex, Boolean] = mutable.Map()
    val paths: mutable.Set[List[Vertex]]     = mutable.Set()
    dfs(G, List(StartVertex), paths, marked)
    paths.size

  def dfs2(G: Digraph): Int =
    val paths: mutable.Set[List[Vertex]] = mutable.Set()
    dfs2(G, List(StartVertex), paths)
    paths.size

  // clsssic DFS
  private def dfs(G: Digraph, path: List[Vertex], paths: mutable.Set[List[Vertex]], marked: mutable.Map[Vertex, Boolean]): Unit =
    val v = path.head
    // visit
    if (!v.isBig) marked(v) = true
    if (v == EndVertex) paths += path
    else
      G.adjList(v).foreach { w =>
        // visit unvisited
        if marked.get(w).isEmpty || !marked(w) then
          // edgeTo(v) = s
          dfs(G, w :: path, paths, marked)
      }

    // unset
    marked(v) = false

  def smallCavesUnique: List[Vertex] => Boolean = { seq =>
    val d = seq.filterNot(_.isBig)
    d.distinct.size == d.size
  }

  private def dfs2(G: Digraph, path: List[Vertex], paths: mutable.Set[List[Vertex]]): Unit =
    val v = path.head
    if (v == EndVertex) paths += path
    else
      G.adjList(v).foreach { w =>
        // using path here as a marked criteria, not the visit matrix
        // imagine the case when previous path was
        // List(end, A, c, A, c, A, start) -- some path before everything has started
        // List(b, A, c, A, start) -- we went up the stack call and trying the next adjacent to A vertex
        // List(A, b, A, c, A, start) -- it is dfs, going deeper
        // List(c, A, b, A, c, A, start) -- appended c
        // List(A, c, A, b, A, c, A, start) -- appended a to the c
        // List(end, A, c, A, b, A, c, A, start) -- found the path
        // List(b, A, b, A, c, A, start) -- went up the stack call, marked end, A, c - unmarked
        // List(A, b, A, b, A, c, A, start) -- going deeper, adding A which seems fine, we can visit A multiple times
        // List(c, A, b, A, b, A, c, A, start) -- adding c, becuase it is unmarked! - collision; q: how to disambiguate unvisits? a: the easiest way to track visits through the visited paths; in general this approach leads to difficulties in visiting same vertices more than once
        // List(A, c, A, b, A, b, A, c, A, start) -- adding A which seems fine
        // List(end, A, c, A, b, A, b, A, c, A, start) -- we visited more than a single small cave twice - a bad collision result
        if !w.isStart && (w.isBig || !path.contains(w) || smallCavesUnique(path)) then dfs2(G, w :: path, paths)
      }

object Solution:
  import Digraph.*

  def readInput(path: String = "src/main/resources/day12/puzzle1.txt"): Digraph =
    val source =
      Source
        .fromFile(path)
        .getLines
        .map(_.split("-").toList)
        .flatMap {
          case List(f, t) => Option(Vertex(f) -> Vertex(t))
          case _          => None
        }

    source.foldLeft(new Digraph()) { case (acc, (f, t)) => acc.addEdge(f, t) }

  def part1(G: Digraph) =
    DFS.dfs(G)

  def part2(G: Digraph) =
    DFS.dfs2(G)
