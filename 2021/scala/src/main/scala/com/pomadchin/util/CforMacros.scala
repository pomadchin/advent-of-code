package com.pomadchin.util

object CforMacros:
  inline def cfor[A](init: => A)(test: => A => Boolean, next: => A => A)(body: => A => Unit): Unit =
    cforInline(init, test, next, body)

  inline def cforInline[R](inline init: R, inline test: R => Boolean, inline next: R => R, inline body: R => Unit): Unit =
    var index = init
    while test(index) do
      body(index)
      index = next(index)
