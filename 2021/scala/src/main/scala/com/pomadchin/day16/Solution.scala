package com.pomadchin.day16

import scala.io.Source
import scala.collection.mutable

sealed trait Packet {
  val version: Int
  val length: Int
}
case class Literal(version: Int, value: Long, length: Int)                            extends Packet
case class Operator(version: Int, typeId: Int, subpackets: List[Packet], length: Int) extends Packet

object Solution:

  def readInput(path: String = "src/main/resources/day16/puzzle1.txt"): String =
    Source.fromFile(path).getLines.next

  // need to do a smarter way of converting bits
  private val hexBits = Map(
    '0' -> "0000",
    '1' -> "0001",
    '2' -> "0010",
    '3' -> "0011",
    '4' -> "0100",
    '5' -> "0101",
    '6' -> "0110",
    '7' -> "0111",
    '8' -> "1000",
    '9' -> "1001",
    'A' -> "1010",
    'B' -> "1011",
    'C' -> "1100",
    'D' -> "1101",
    'E' -> "1110",
    'F' -> "1111"
  )

  def hexToBin(hex: String): String = hex.map(hexBits).mkString
  def binToInt(bin: String): Int    = java.lang.Integer.parseInt(bin, 2)
  def binToLong(bin: String): Long  = java.lang.Long.parseLong(bin, 2)

  def packet(bin: String): Packet =
    // println(bin)
    // the first three bits encode the packet version
    // next three bits encode the packet type ID

    // version
    val version = binToInt(bin.substring(0, 3))
    // packet type id
    val packetTypeId = binToInt(bin.substring(3, 6))

    val headerOffset = 6

    packetTypeId match
      case 4 =>
        // literal value parsing
        // starting the header offset we have numbers to parse by 4 (bits are padded)
        val literals = mutable.ListBuffer[String]()

        var offset = headerOffset
        var parsed = false
        while (offset + 4) < bin.length && !parsed do
          val literal = bin.substring(offset, offset + 5)
          literals += literal.tail
          if literal.head == '0' then parsed = true
          offset += 5

        val literalValue = binToLong(literals.toList.mkString)

        Literal(version, literalValue, offset)

      // operator
      case packetType =>
        // length type ID
        var offset = headerOffset
        val typeId = bin.substring(offset, offset + 1)
        // move the parsing offset ahead
        offset += 1
        typeId match
          // If the length type ID is 0, then the next 15 bits are a number that represents
          // the total length in bits of the sub-packets contained by this packet
          case "0" =>
            val subpackets = mutable.ListBuffer[Packet]()

            // get the next 15 bits
            val totalLength = binToInt(bin.substring(offset, offset + 15))
            offset += 15

            var counter = totalLength
            while counter > 0 do
              val p = packet(bin.substring(offset, offset + counter))
              counter -= p.length
              offset += p.length
              subpackets += p

            Operator(version, packetType.toInt, subpackets.toList, offset)

          // If the length type ID is 1, then the next 11 bits are a number that represents
          // the number of sub-packets immediately contained by this packet.
          case "1" =>
            val subpackets = mutable.ListBuffer[Packet]()

            // get the next 11 bits
            val totalPackages = binToInt(bin.substring(offset, offset + 11))
            offset += 11

            var counter = 0
            while counter < totalPackages do
              val p = packet(bin.substring(offset))
              counter += 1
              offset += p.length
              subpackets += p

            Operator(version, packetType.toInt, subpackets.toList, offset)

  def sumVersions(p: Packet): Long =
    p match
      case Literal(version, _, _)              => version.toLong
      case Operator(version, _, subpackets, _) => version.toLong + subpackets.map(sumVersions).sum

  def eval(p: Packet): Long =
    p match
      case Literal(_, value, _) => value
      case Operator(_, typeId, subpackets, _) =>
        val subliterals = subpackets.map(eval)

        // format: off
        /** 
         * Packets with type ID 0 are sum packets - their value is the sum of the values of their sub-packets. If they only have a single sub-packet, their value is the value of the sub-packet.
         * Packets with type ID 1 are product packets - their value is the result of multiplying together the values of their sub-packets. If they only have a single sub-packet, their value is the value of the sub-packet.
         * Packets with type ID 2 are minimum packets - their value is the minimum of the values of their sub-packets.
         * Packets with type ID 3 are maximum packets - their value is the maximum of the values of their sub-packets.
         * Packets with type ID 5 are greater than packets - their value is 1 if the value of the first sub-packet is greater than the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
         * Packets with type ID 6 are less than packets - their value is 1 if the value of the first sub-packet is less than the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
         * Packets with type ID 7 are equal to packets - their value is 1 if the value of the first sub-packet is equal to the value of the second sub-packet; otherwise, their value is 0. These packets always have exactly two sub-packets.
         */
        // format: on
        typeId match
          case 0 => subliterals.sum
          case 1 => subliterals.product
          case 2 => subliterals.min
          case 3 => subliterals.max
          case 5 =>
            val List(value1, value2) = subliterals
            if value1 > value2 then 1 else 0
          case 6 =>
            val List(value1, value2) = subliterals
            if value1 < value2 then 1 else 0
          case 7 =>
            val List(value1, value2) = subliterals
            if value1 == value2 then 1 else 0

  def part1(hex: String): Long =
    sumVersions(packet(hexToBin(hex)))

  def part2(hex: String): Long =
    eval(packet(hexToBin(hex)))
