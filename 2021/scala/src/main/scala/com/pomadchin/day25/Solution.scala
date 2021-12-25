package com.pomadchin.day25

import scala.io.Source
import com.pomadchin.util.CforMacros.cfor

object Solution:
  extension (a: Array[Array[Boolean]])
    def clear: Unit = cfor(0)(_ < a.length, _ + 1) { r => cfor(0)(_ < a(0).length, _ + 1) { c => a(r)(c) = false } }

  // moves east (>)
  // moves south (v)
  // empty (.)
  sealed trait Move:
    def isFree: Boolean
  object Move:
    def fromChar(c: Char): Move =
      c match
        case '>' => East
        case 'v' => South
        case _   => Empty
  case object East extends Move:
    val isFree                    = false
    override def toString: String = ">"
  case object South extends Move:
    val isFree                    = false
    override def toString: String = "v"
  case object Empty extends Move:
    val isFree                    = true
    override def toString: String = "."

  // a mutable Grid
  opaque type Grid = Array[Array[Move]]
  object Grid:
    def apply(a: Array[Array[Move]]): Grid = a

  extension (g: Grid)
    def rows: Int                              = g.length
    def cols: Int                              = g(0).length
    def gridSize: Int                          = rows * cols
    def get(row: Int, col: Int): Move          = g(row)(col)
    def set(row: Int, col: Int, v: Move): Move = { g(row)(col) = v; v }
    def next(row: Int, col: Int, m: Move): (Int, Int) =
      m match
        case East  => if (col + 1) < cols then (row, col + 1) else (row, 0)
        case South => if (row + 1) < rows then (row + 1, col) else (0, col)
        case Empty => (row, col)

    def asciiPrint: Unit =
      val sb = new StringBuilder()
      cfor(0)(_ < rows, _ + 1) { r =>
        cfor(0)(_ < cols, _ + 1) { c =>
          sb.append(get(r, c).toString)
        }
        sb.append("\n")
      }

      println(sb.toString)

  def readInput(path: String = "src/main/resources/day25/puzzle1.txt"): Grid =
    Grid(Source.fromFile(path).getLines.map(_.toCharArray.map(Move.fromChar)).toArray)

  def step(g: Grid): Boolean =
    var move   = false
    val marked = Array.fill[Boolean](g.rows, g.cols)(false)

    // move East
    cfor(0)(_ < g.rows, _ + 1) { r =>
      cfor(0)(_ < g.cols, _ + 1) { c =>
        if !marked(r)(c) then
          g.get(r, c) match
            case East =>
              marked(r)(c) = true
              val (nc, rc) = g.next(r, c, East)
              if g.get(nc, rc).isFree && !marked(nc)(rc) then
                move = true
                g.set(nc, rc, East)
                g.set(r, c, Empty)
                marked(nc)(rc) = true

            case Empty | South => // do nothing
      }
    }

    marked.clear
    // move South
    cfor(0)(_ < g.rows, _ + 1) { r =>
      cfor(0)(_ < g.cols, _ + 1) { c =>
        if !marked(r)(c) then
          g.get(r, c) match
            case South =>
              marked(r)(c) = true
              val (nc, rc) = g.next(r, c, South)
              if g.get(nc, rc).isFree && !marked(nc)(rc) then
                move = true
                g.set(nc, rc, South)
                g.set(r, c, Empty)
                marked(nc)(rc) = true

            case Empty | East => // do nothing
      }
    }

    move

  def part1(g: Grid): Int =
    var move  = true
    var steps = 0
    while move do
      move = step(g)
      steps += 1
    steps
