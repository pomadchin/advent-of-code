package com.pomadchin.day2

import scala.io.Source

object Solution:

  enum Action:
    case Loose, Draw, Win
    def toHand: Hand = this match
      case Loose => Hand.Rock
      case Draw  => Hand.Paper
      case Win   => Hand.Scissors

    def score: Int = this match
      case Loose => 0
      case Draw  => 3
      case Win   => 6

  object Action:
    def fromString(str: String) =
      str match
        case "X" => Some(Action.Loose)
        case "Y" => Some(Action.Draw)
        case "Z" => Some(Action.Win)
        case _   => None

  enum Hand:
    case Rock, Paper, Scissors

    def score: Int = this match
      case Rock     => 1
      case Paper    => 2
      case Scissors => 3

  object Hand:
    def fromString(str: String): Option[Hand] =
      str match
        case "X" | "A" => Some(Hand.Rock)
        case "Y" | "B" => Some(Hand.Paper)
        case "Z" | "C" => Some(Hand.Scissors)
        case _         => None

  opaque type Outcome = (Hand, Action)
  object Outcome:
    def apply(t: (Hand, Action)): Outcome  = t
    def apply(f: Hand, s: Action): Outcome = f -> s

  extension (o: Outcome)
    def tupled: (Hand, Action) = o
    def f: Hand                = o._1
    def s: Action              = o._2
    def sh: Hand               = o._2.toHand
    def scoreF: Int            = f.score
    def scoreSh: Int           = sh.score
    def scoreS: Int            = s.score
    def outcome1: Int =
      if f == sh then 3
      else if f == Hand.Rock && sh == Hand.Paper
        || f == Hand.Paper && sh == Hand.Scissors
        || f == Hand.Scissors && sh == Hand.Rock
      then 6
      else 0
    def outcomeTotal1: Int = scoreSh + outcome1

    def outcome2: Int =
      o match
        case (Hand.Rock, Action.Loose)     => 3
        case (Hand.Rock, Action.Draw)      => 1
        case (Hand.Rock, Action.Win)       => 2
        case (Hand.Paper, Action.Loose)    => 1
        case (Hand.Paper, Action.Draw)     => 2
        case (Hand.Paper, Action.Win)      => 3
        case (Hand.Scissors, Action.Loose) => 2
        case (Hand.Scissors, Action.Draw)  => 3
        case (Hand.Scissors, Action.Win)   => 1

    def outcomeTotal2: Int = scoreS + outcome2

  def readInput(path: String = "src/main/resources/day2/puzzle1.txt"): List[Outcome] =
    Source
      .fromFile(path)
      .getLines
      .map(_.split(" ").toList)
      .flatMap {
        case List(f, s) => Hand.fromString(f).flatMap(f => Action.fromString(s).map(f -> _))
        case _          => None
      }
      .toList

  def part1(input: List[Outcome]): Int =
    input.map(_.outcomeTotal1).sum

  def part2(input: List[Outcome]): Int =
    input.map(_.outcomeTotal2).sum
