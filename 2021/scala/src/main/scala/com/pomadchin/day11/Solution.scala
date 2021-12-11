package com.pomadchin.day11

import com.pomadchin.util.CforMacros.cfor

import scala.io.Source
import scala.collection.mutable

object Solution:

  type P = (Int, Int)

  opaque type Table = Array[Array[Int]]
  object Table:
    def apply(arr: Array[Array[Int]]): Table = arr

  extension (t: Table)
    def toArray: Array[Array[Int]]   = t
    def get(row: Int, col: Int): Int = toArray(row)(col)
    def set(row: Int, col: Int, z: Int): Int =
      toArray(row)(col) = z
      z
    def inc(row: Int, col: Int): Int =
      val v = get(row, col) + 1
      val z = if (v > 9) 0 else v
      set(row, col, z)
    def cols: Int                             = toArray(0).length
    def rows: Int                             = toArray.length
    def size: Int                             = cols * rows
    def index(row: Int, col: Int): Int        = row * cols + col
    def col(index: Int): Int                  = index % cols
    def row(index: Int): Int                  = index / cols
    def adj(r: Int, c: Int): List[(Int, Int)] = Solution.adj(r, c, t, true)

  def readInput(path: String = "src/main/resources/day11/puzzle1.txt"): Table =
    Source
      .fromFile(path)
      .getLines
      .map(_.toCharArray.map(_.asDigit))
      .toArray

  def part1(input: Table, steps: Int): Long =
    var counts: Long = 0
    cfor(0)(_ < steps, _ + 1) { s =>
      // increase all elems by 1
      cfor(0)(_ < input.rows, _ + 1) { r =>
        cfor(0)(_ < input.cols, _ + 1) { c =>
          input.inc(r, c)
        }
      }

      var flashed = true
      val marked  = Array.ofDim[Boolean](input.rows, input.cols)

      // flashes check
      while flashed do
        flashed = false
        cfor(0)(_ < input.rows, _ + 1) { r =>
          cfor(0)(_ < input.cols, _ + 1) { c =>
            // if there is a flash, +1 every element around
            if input.get(r, c) == 0 && !marked(r)(c) then
              input.adj(r, c).filter((r, c) => input.get(r, c) != 0).foreach(input.inc)
              marked(r)(c) = true
              flashed = true
              counts += 1
          }
        }
    }
    counts

  def part2(input: Table): Int =
    var stop = false
    var s    = 0
    while !stop do
      // increase all elems by 1
      cfor(0)(_ < input.rows, _ + 1) { r =>
        cfor(0)(_ < input.cols, _ + 1) { c =>
          input.inc(r, c)
        }
      }

      var flashed = true
      var marks   = 0
      val marked  = Array.ofDim[Boolean](input.rows, input.cols)

      // flashes check
      while flashed do
        flashed = false
        cfor(0)(_ < input.rows, _ + 1) { r =>
          cfor(0)(_ < input.cols, _ + 1) { c =>
            // if there is a flash, +1 every element around
            if input.get(r, c) == 0 && !marked(r)(c) then
              input.adj(r, c).filter((r, c) => input.get(r, c) != 0).foreach(input.inc)
              marked(r)(c) = true
              flashed = true
              marks += 1
          }
        }

      if (marks == input.size) stop = true
      s += 1
    s

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
