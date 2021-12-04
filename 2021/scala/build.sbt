name         := "advent-of-code-2021"
version      := "0.1.0-SNAPSHOT"
scalaVersion := "3.1.0"
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

resolvers ++= Seq(
  Resolver.sonatypeRepo("releases"),
  Resolver.sonatypeRepo("snapshots")
)

fork := true

libraryDependencies ++= Seq(
  "org.typelevel" %% "cats-core"   % "2.7.0",
  "org.typelevel" %% "cats-mtl"    % "1.2.1",
  "org.typelevel" %% "cats-effect" % "3.1.1",
  "org.scalatest" %% "scalatest"   % "3.2.9" % Test
)
