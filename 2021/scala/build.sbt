name         := "advent-of-code-2021"
version      := "0.1.0-SNAPSHOT"
scalaVersion := "3.2.0"
organization := "com.pomadchin"
scalacOptions ++= Seq(
  "-deprecation",
  "-unchecked",
  "-language:implicitConversions",
  "-language:reflectiveCalls",
  "-language:higherKinds",
  "-language:postfixOps",
  "-language:existentials",
  "-feature",
  "-source:future",
  "-Ykind-projector"
)

libraryDependencies += "org.scalameta" %% "munit" % "0.7.29" % Test
testFrameworks += new TestFramework("munit.Framework")
