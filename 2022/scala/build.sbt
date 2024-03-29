name         := "advent-of-code-2022"
version      := "0.1.0-SNAPSHOT"
scalaVersion := "3.3.1"
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

libraryDependencies += "org.scalameta" %% "munit" % "1.0.0-M10" % Test
testFrameworks += new TestFramework("munit.Framework")
