package com.pomadchin.day14

import scala.io.Source
import scala.collection.mutable

object Solution:
  def readInput(path: String = "src/main/resources/day14/puzzle1.txt"): (Map[Char, Long], Map[String, Long], List[(String, Char)]) =
    val iter     = Source.fromFile(path).getLines
    val template = iter.next

    // preserve original counts
    val counts =
      template
        .groupBy(identity)
        .toMap
        .view
        .mapValues(_.length.toLong)
        .toMap

    // initial suffixes of length 2 counts
    val suffixes = template.sliding(2).toList.map((_, 1)).groupBy(_._1).view.mapValues(_.map(_._2).sum.toLong).toMap

    // instructions
    val instructions =
      iter
        .filter(_.contains("->"))
        .map(_.split(" -> ").toList)
        .flatMap {
          case List(f, s) => Some(f -> s.head)
          case _          => None
        }
        .toList

    (counts, suffixes, instructions)

  def part1(input: (Map[Char, Long], Map[String, Long], List[(String, Char)]), steps: Int): Long =
    val (counts, suffixes, instructions)       = input
    val countsMutable: mutable.Map[Char, Long] = counts.to(mutable.Map)
    var suffixesMutable                        = suffixes

    // the idea on every step to build the new suffixes array
    // every suffix may be there more than once
    // the number of replacements accumulate (and match the amount of suffixes)
    (0 until steps).map { s =>
      val suffixesNew = mutable.Map[String, Long]()
      // for each value find a matching rule
      suffixesMutable.foreach { (k, v) =>
        instructions.filter(_._1 == k).foreach { (from, to) =>
          // increment counts in the counts map
          countsMutable.put(to, countsMutable.getOrElse(to, 0L) + v)
          // fill in the new suffixes array
          val ft = s"${from.head}$to"
          val tf = s"$to${from.last}"
          // carefull with it
          suffixesNew.put(ft, suffixesNew.getOrElse(ft, 0L) + v)
          suffixesNew.put(tf, suffixesNew.getOrElse(tf, 0L) + v)
        }
      }

      // use the new suffixes array
      suffixesMutable = suffixesNew.toMap
    }

    val res = countsMutable.values
    res.max - res.min

  def part1f(input: (Map[Char, Long], Map[String, Long], List[(String, Char)]), steps: Int): Long =
    val (counts, suffixes, instructions) = input
    // the idea on every step to build the new suffixes array
    // every suffix may be there more than once
    // the number of replacements accumulate (and match the amount of suffixes)
    // folding all steps
    val (countsNew, _) = (0 until steps).foldLeft((counts, suffixes)) { case ((counts, suffixes), _) =>
      suffixes.foldLeft((counts, Map[String, Long]())) { case ((counts, suffixesNew), (k, v)) =>
        instructions.filter(_._1 == k).foldLeft((counts, suffixesNew)) { case ((counts, suffixesNew), (from, to)) =>
          // add more counts of the new target
          val countsNew = counts + (to -> (counts.getOrElse(to, 0L) + v))

          // compute new suffixes
          val ft = s"${from.head}$to"
          val tf = s"$to${from.last}"
          // build new suffixes with cumulatative counts
          (countsNew,
           suffixesNew +
             (ft -> (suffixesNew.getOrElse(ft, 0L) + v)) +
             (tf -> (suffixesNew.getOrElse(tf, 0L) + v))
          )
        }
      }
    }

    val res = countsNew.values
    res.max - res.min
