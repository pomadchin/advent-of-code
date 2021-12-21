package com.pomadchin.day20

import com.pomadchin.util.CforMacros.cfor

import scala.io.Source
import java.lang.{Integer, StringBuilder}

// later I found a nice explanation https://abigail.github.io/HTML/AdventOfCode/2021/day-20.html
// https://www.conwaylife.com/wiki/Non-isotropic_Life-like_cellular_automaton#Range-1_Moore_neighbourhood
object Solution:
  opaque type Tile = Array[Array[Boolean]]
  object Tile:
    def apply(a: Array[Array[Boolean]]): Tile        = a
    def fill(rows: Int, cols: Int, v: Boolean): Tile = Array.fill[Boolean](rows, cols)(v)

  extension (t: Tile)
    def alloc(v: Boolean): Tile        = Tile.fill(rows, cols, v)
    def toArray: Array[Array[Boolean]] = t
    def buffer(buf: Int, v: Boolean): Tile =
      val n = Tile(Array.fill[Boolean](rows + buf * 2, cols + buf * 2)(v))
      cfor(0)(_ < rows, _ + 1) { r =>
        cfor(0)(_ < cols, _ + 1) { c =>
          n.set(buf + r, buf + c, get(r, c))
        }
      }
      n
    def rows: Int                           = t.length
    def cols: Int                           = t(0).length
    def get(row: Int, col: Int): Boolean    = t(row)(col)
    def set(row: Int, col: Int, z: Boolean) = t(row)(col) = z
    // . . .
    // . x .
    // . . .
    // => bin string
    // => int
    def enhancerIndex(row: Int, col: Int): Int =
      val sb = new StringBuilder()
      if get(row - 1, col - 1) then sb.append("1") else sb.append("0")
      if get(row - 1, col) then sb.append("1") else sb.append("0")
      if get(row - 1, col + 1) then sb.append("1") else sb.append("0")
      if get(row, col - 1) then sb.append("1") else sb.append("0")
      if get(row, col) then sb.append("1") else sb.append("0")
      if get(row, col + 1) then sb.append("1") else sb.append("0")
      if get(row + 1, col - 1) then sb.append("1") else sb.append("0")
      if get(row + 1, col) then sb.append("1") else sb.append("0")
      if get(row + 1, col + 1) then sb.append("1") else sb.append("0")
      Integer.parseInt(sb.toString, 2)

    def countLit: Int =
      var count = 0;
      cfor(0)(_ < rows, _ + 1) { r =>
        cfor(0)(_ < cols, _ + 1) { c =>
          count += (if get(r, c) then 1 else 0)
        }
      }
      count

    def asciiPrint: Unit =
      val sb = new StringBuilder()
      cfor(0)(_ < rows, _ + 1) { r =>
        cfor(0)(_ < cols, _ + 1) { c =>
          if get(r, c) then sb.append("#") else sb.append(".")
        }
        sb.append("\n")
      }

      println(sb.toString)

  // applying the image enhancement algorithm to every pixel simultaneously
  def enchance(tile: Tile, enhancer: Array[Boolean], fill: Boolean): Tile =
    val nt = tile.alloc(fill)
    cfor(2)(_ < tile.rows - 2, _ + 1) { r =>
      cfor(2)(_ < tile.cols - 2, _ + 1) { c =>
        nt.set(r, c, enhancer(tile.enhancerIndex(r, c)))
      }
    }

    nt

  def charToBit(c: Char): Boolean =
    c match
      case '#' => true // light
      case '.' => false // dark

  def readInput(path: String = "src/main/resources/day20/puzzle1.txt"): (Tile, Array[Boolean]) =
    val lines                    = Source.fromFile(path).getLines
    val enhancer: Array[Boolean] = lines.next.toCharArray.map(charToBit)
    lines.next // skip one
    val tile = Tile(lines.toArray.map(_.toCharArray.map(charToBit)))
    (tile, enhancer)

  // if "#" is the first char
  // that at first iteration
  // all outer pixels (if set to 0) are going to change and to convert to true
  // ...    ###
  // ... => ###
  // ...    ###
  // and the next iteration after that will convert borders one more time
  // ###    ...
  // ### => ...
  // ###    ...
  // => we can't fill broders every time
  // => every even case is filled with 0 and every odd with 1
  def rule(i: Int, enhancer: Array[Boolean]): Boolean =
    if enhancer(0) then if i % 2 == 0 then true else false
    else false

  def part1(tile: Tile, enhancer: Array[Boolean]): Int =
    var t = tile.buffer(10, false)
    cfor(0)(_ < 2, _ + 1) { i => t = enchance(t, enhancer, rule(i, enhancer)) }
    t.asciiPrint
    t.countLit

  def part2(tile: Tile, enhancer: Array[Boolean]): Int =
    var t = tile.buffer(60, false)
    cfor(0)(_ < 50, _ + 1) { i => t = enchance(t, enhancer, rule(i, enhancer)) }
    // t.asciiPrint
    t.countLit
