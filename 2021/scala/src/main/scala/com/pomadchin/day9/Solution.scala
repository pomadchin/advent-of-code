package com.pomadchin.day9

import com.pomadchin.util.CforMacros.cfor

import scala.io.Source
import scala.collection.mutable
import scala.annotation.tailrec

object Solution:

  type P = (Int, Int)

  opaque type Table = Array[Array[Int]]
  object Table:
    def apply(arr: Array[Array[Int]]): Table = arr

  extension (t: Table)
    def toArray: Array[Array[Int]]            = t
    def get(row: Int, col: Int): Int          = toArray(row)(col)
    def cols: Int                             = toArray(0).length
    def rows: Int                             = toArray.length
    def index(row: Int, col: Int): Int        = row * cols + col
    def col(index: Int): Int                  = index % cols
    def row(index: Int): Int                  = index / cols
    def adj(r: Int, c: Int): List[(Int, Int)] = Solution.adj(r, c, t)

  def readInput(path: String = "src/main/resources/day9/puzzle1.txt"): Table =
    Source
      .fromFile(path)
      .getLines
      .map(_.toCharArray.map(_.asDigit))
      .toArray

  def part1(table: Table): Int =
    val result = mutable.ListBuffer[Int]()

    cfor(0)(_ < table.rows, _ + 1) { r =>
      cfor(0)(_ < table.cols, _ + 1) { c =>
        val v = table.get(r, c)
        if (table.adj(r, c).forall((r, c) => v < table.get(r, c)))
          result += (v + 1)
      }
    }

    result.sum

  def part1f(table: Table): Int =
    val res = (0 until table.rows).flatMap { r =>
      (0 until table.cols).flatMap { c =>
        val v = table.get(r, c)
        if (table.adj(r, c).forall((r, c) => v < table.get(r, c))) Option(v + 1)
        else None
      }
    }
    res.sum

  def part2(table: Table): Int =
    val result = mutable.ListBuffer[Int]() // new mutable.PriorityQueue[Int]()
    val marked = Array.ofDim[Boolean](table.rows, table.cols)

    cfor(0)(_ < table.rows, _ + 1) { r =>
      cfor(0)(_ < table.cols, _ + 1) { c =>
        val v = table.get(r, c)
        if (table.adj(r, c).forall((r, c) => v < table.get(r, c))) {
          val basin = mutable.ListBuffer[Int]()
          // add low point
          basin += v
          def dfs(row: Int, col: Int): Unit =
            // visit the current vertex
            marked(row)(col) = true
            table.adj(row, col).foreach { (ra, ca) =>
              if (!marked(ra)(ca)) {
                val va = table.get(ra, ca)
                if (va < 9) {
                  basin += va
                  dfs(ra, ca)
                }
              }
            }
          // marked(row)(col) = false

          dfs(r, c)
          result += (basin.toList.length)
        }
      }
    }
    result.sortBy(-_).take(3).product
  // (0 until 3).map(_ => result.dequeue).product

  def part2f(table: Table): Int =
    val marked = Array.ofDim[Boolean](table.rows, table.cols)
    val result = (0 until table.rows).flatMap { r =>
      (0 until table.cols).flatMap { c =>
        val v = table.get(r, c)
        if (table.adj(r, c).forall((r, c) => v < table.get(r, c)))
          // not tailrec
          def dfsrec(row: Int, col: Int, acc: List[Int]): List[Int] =
            marked(row)(col) = true
            table.adj(row, col).flatMap { (ra, ca) =>
              if (!marked(ra)(ca)) {
                val va = table.get(ra, ca)
                if (va < 9) dfsrec(ra, ca, va :: acc) else acc
              } else acc
            }
          dfsrec(r, c, v :: Nil).length :: Nil
        else Nil
      }
    }

    result.sortBy(-_).take(3).product

  def part2fbfs(table: Table): Int =
    @tailrec
    def bfs(a: Set[P], marked: Set[P]): Set[(Int, Int)] =
      if a.nonEmpty then
        val next = a.flatMap((r, c) => table.adj(r, c).filter((r, c) => table.get(r, c) < 9).filter(!marked.contains(_)))
        bfs(next, marked ++ next)
      else marked

    val vertices = (0 until table.rows).flatMap { r =>
      (0 until table.cols).flatMap { c =>
        val v = table.get(r, c)
        if (table.adj(r, c).forall((r, c) => v < table.get(r, c))) Option(r -> c)
        else None
      }
    }

    vertices.map(t => bfs(Set(t), Set(t)).size).sortBy(-_).take(3).product

  // unfortunately we don't need diagonals ): TODO: make it immutable
  def adj(r: Int, c: Int, table: Table, diagonal: Boolean = false): List[(Int, Int)] =
    val result = mutable.ListBuffer[(Int, Int)]()
    // there is a top row present
    if r > 0 then
      val rt = r - 1
      // add edge between the current and top mid
      result += (rt -> c);
      // top left
      if diagonal then
        if c > 0 then
          val cl = c - 1
          // add edge between the current and top left
          result += (rt -> cl)
        // top right
        if c < table.cols - 1 then
          val cr = c + 1
          // add edge between the current and top right
          result += (rt -> cr)

    // current row
    if c > 0 then
      val cl = c - 1
      // add edge between the current and current left
      result += (r -> cl)
    // add edge between the current and top mid
    // skip reflective vertices
    // result += (r -> c)
    // top right
    if c < table.cols - 1 then
      val cr = c + 1
      // add edge between the current and current right
      result += (r -> cr)
    // there is a bottom row present
    if r < table.rows - 1 then
      val rb = r + 1
      // add edge between the current and bottom mid
      result += (rb -> c)
      // bottom left
      if diagonal then
        if c > 0 then
          val cl = c - 1;
          // add edge between the current and top left
          result += (rb -> cl)
        // top right
        if c < table.cols - 1 then
          val cr = c + 1;
          // add edge between the current and top right
          result += (rb -> cr)

    result.toList
