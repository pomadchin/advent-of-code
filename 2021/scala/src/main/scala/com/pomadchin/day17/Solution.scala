package com.pomadchin.day17

import scala.io.Source

object Solution:

  opaque type Target = ((Int, Int), (Int, Int))
  object Target:
    def apply(p: ((Int, Int), (Int, Int))): Target = p

  extension (t: Target)
    def x: (Int, Int)                   = t._1
    def x1: Int                         = x._1
    def x2: Int                         = x._2
    def y: (Int, Int)                   = t._2
    def y1: Int                         = y._1
    def y2: Int                         = y._2
    def xs: Seq[Int]                    = x._1 to x._2
    def ys: Seq[Int]                    = y._1 to y._2
    def withinX(x: Int): Boolean        = x1 <= x && x <= x2
    def withinY(y: Int): Boolean        = y1 <= y && y <= y2
    def within(x: Int, y: Int): Boolean = withinX(x) && withinY(y)
    // velocities rough guesses with x3 buffer
    def vxs: Seq[Int] = 0 until (x1 * 3)
    def vys: Seq[Int] = math.min(0, y1) to (math.abs(y2) * 3)

  def readInput(path: String = "src/main/resources/day17/puzzle1.txt"): Target =
    Source
      .fromFile(path)
      .getLines
      .flatMap {
        _.split("area: ").last
          .split(", ")
          .toList
          .flatMap(
            _.split("=").last.split("""\..""").toList match
              case List(f, t) => Some(f.toInt, t.toInt)
              case _          => None
          ) match
          case List(x, y) => Some(x, y)
          case _          => None
      }
      .next

  // bruteforce all points
  // input is initial velocities and the target area
  def simulate(ivx: Int, ivy: Int, target: Target) =
    // mutable copies of velocities
    var (vx, vy) = (ivx, ivy)
    // initial position
    var (x, y) = (0, 0)
    // initial 'vertex'
    var (xmax, ymax) = (0, 0)
    // initial hit
    var within = target.within(x, y)

    var run = true
    while run do
      // The probe's x position increases by its x velocity.
      // The probe's y position increases by its y velocity.
      x += vx
      y += vy

      // Due to drag, the probe's x velocity changes by 1 toward the value 0; that is, it decreases by 1 if it is greater than 0, increases by 1 if it is less than 0, or does not change if it is already 0.
      // Due to gravity, the probe's y velocity decreases by 1.
      vx = if vx > 0 then vx - 1 else if vx < 0 then vx + 1 else vx
      vy -= 1

      // the hit area flag
      within = within || target.within(x, y)

      // find maximums
      xmax = math.max(xmax, x)
      ymax = math.max(ymax, y)

      // find the first hit
      if y < target.y1 then run = false

    ((xmax, ymax), within)

  def compute(t: Target): (Int, Int) =
    var (xmax, ymax) = (Int.MinValue, Int.MinValue)
    var counts       = 0
    for
      vx <- t.vxs
      vy <- t.vys
    do
      val ((x, y), w) = simulate(vx, vy, t)
      if w then
        xmax = math.max(xmax, x)
        ymax = math.max(ymax, y)
        counts += 1

    (ymax, counts)

  def part1(t: Target): Int =
    compute(t)._1

  def part2(t: Target): Int =
    compute(t)._2
