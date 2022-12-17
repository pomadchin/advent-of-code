use super::utils;

extern crate serde;
use serde::Serialize;

use itertools::Itertools;
use lazy_static::lazy_static;

use regex::Regex;

use std::str::FromStr;

type Point = (i32, i32);

// sensor - beacon pair
#[derive(Clone, Copy, Debug, Serialize)]
struct SBPair {
    sensor: Point,
    beacon: Point,
    distance: i32,
}

impl SBPair {
    fn new(sensor: Point, beacon: Point, distance: i32) -> SBPair {
        SBPair { sensor, beacon, distance }
    }
}

impl FromStr for SBPair {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        POINT_REGEX
            .as_ref()
            .map_err(|e| e.to_string())?
            .captures_iter(s)
            .flat_map(|c| c.get(1))
            .map(|m| m.as_str().to_owned())
            .collect_tuple::<(_, _, _, _)>()
            .and_then(|(x1_s, y1_s, x2_s, y2_s)| {
                let sensor = (x1_s.parse::<i32>().ok()?, y1_s.parse::<i32>().ok()?);
                let beacon = (x2_s.parse::<i32>().ok()?, y2_s.parse::<i32>().ok()?);
                let distance = manhattan(sensor, beacon);

                Some(SBPair::new(sensor, beacon, distance))
            })
            .ok_or("parsing error occured".to_owned())
    }
}

#[derive(Clone, Copy, Debug, Serialize)]
struct Interval {
    min: i32,
    max: i32,
}

impl Interval {
    fn new(min: i32, max: i32) -> Interval {
        Interval { min, max }
    }

    fn size(&self) -> i32 {
        self.max - self.min + 1
    }

    fn merge(&self, other: Interval) -> Interval {
        let min = self.min.min(other.min);
        let max = self.max.max(other.max);
        Interval::new(min, max)
    }

    fn touching(&self, other: Interval) -> bool {
        if other.min < self.min {
            // assume here that min >= other.max
            (self.min - other.max) <= 1
        } else {
            // assume that other.min >= self.max
            (other.min - self.max) <= 1
        }
    }

    fn merge_into(&self, intervals: &Vec<Interval>) -> Vec<Interval> {
        let (left, mut right): (Vec<Interval>, Vec<Interval>) = intervals.clone().into_iter().partition(|i| i.touching(*self));

        let merged = left.into_iter().fold(*self, |acc, i| acc.merge(i));
        right.push(merged);

        right
    }
}

fn manhattan(p1: Point, p2: Point) -> i32 {
    let (x1, y1) = p1;
    let (x2, y2) = p2;
    (x1 - x2).abs() + (y1 - y2).abs()
}

fn input_example() -> Vec<SBPair> {
    parse_input(utils::read_file_in_cwd_by_line("src/day15/example.txt"))
}

fn input() -> Vec<SBPair> {
    parse_input(utils::read_file_in_cwd_by_line("src/day15/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Vec<SBPair> {
    input.iter().flat_map(|line| line.parse::<SBPair>()).collect()
}

fn intervals_for(input: Vec<SBPair>, y_target: i32) -> Vec<Interval> {
    // intervals where we _can't_ put beacons
    let mut intervals: Vec<Interval> = vec![];
    for pair in input.clone() {
        // fiff between the current sensor closest sensor, and the one on the target row
        // this dx sets the interval where we can't set our beacon
        let dx = pair.distance - (pair.sensor.1 - y_target).abs();

        // we can't put a beacon to this position
        if dx >= 0 {
            intervals = Interval::new(pair.sensor.0 - dx, pair.sensor.0 + dx).merge_into(&intervals);
        }
    }
    intervals
}

fn part1(input: Vec<SBPair>, y_target: i32) -> i32 {
    // intervals where we _can't_ put beacons
    let intervals = intervals_for(input.clone(), y_target);

    // get a list of current beacons
    let beacons_current_size = input.into_iter().map(|p| p.beacon).filter(|(_, y)| *y == y_target).unique().collect_vec().len() as i32;
    // sum interval lengths, it is a total length of beacons that we can't reach on row y_target
    let intervals_size = intervals.iter().map(|i| i.size()).sum::<i32>();

    intervals_size - beacons_current_size
}

fn point_distress(p: Point) -> i64 {
    ((4000000 * p.0 as i64) + p.1 as i64) as i64
}

// bruteforce
fn part2(input: Vec<SBPair>) -> i64 {
    let mut res = -1;

    // beacon is between intervals, we pick up the one on the left side
    fn hole_disstress(l: Interval, r: Interval, y: i32) -> i64 {
        point_distress((l.max.min(r.max) + 1, y))
    }

    for y in 0..4000000 {
        // where we can't put a beacon
        let intervals = intervals_for(input.clone(), y);

        // the idea is the beacon is hidden somewhere inbetween two intervals on a row
        // it is min(x1max, x2max) + 1 (so we're in some place where we can put a beacon), y
        // find the first whole inbetween intervals
        match intervals[0..] {
            [l, r] | [l, r, _] => {
                res = hole_disstress(l, r, y);
                break;
            }
            _ => (),
        }
    }

    res
}

fn uncovered_point_in_rectangle(coordinates: (Point, Point), input: &Vec<SBPair>) -> Option<Point> {
    let ((x1, y1), (x2, y2)) = coordinates;
    let mut res = None;

    // throw away fully covered rectangles
    // if at least one sensor covers it => there is no interest in it
    for pair in input {
        if all_corners_covered(pair, coordinates) {
            return res;
        }
    }

    if x1 == x2 && y1 == y2 {
        // found the uncovered point!
        res = Some((x1, y1))
    } else {
        // split in two halves, do the same until there is an uncovered point
        for half in halves(coordinates) {
            let uncovered = uncovered_point_in_rectangle(half, &input);

            if uncovered.is_some() {
                res = uncovered;
                break;
            }
        }
    }

    res
}

fn all_corners_covered(pair: &SBPair, coordinates: (Point, Point)) -> bool {
    let ((x1, y1), (x2, y2)) = coordinates;
    let corner_points = [(x1, y1), (x2, y1), (x1, y2), (x2, y2)];
    let mut res = true;
    for corner in corner_points {
        if manhattan(pair.sensor, corner) > pair.distance {
            res = false;
            break;
        }
    }

    res
}

fn halves(coordinates: (Point, Point)) -> [(Point, Point); 2] {
    let ((x1, y1), (x2, y2)) = coordinates;
    if x2 - x1 > y2 - y1 {
        let x_mid = (x1 + x2) / 2;
        [((x1, y1), (x_mid, y2)), ((x_mid + 1, y1), (x2, y2))]
    } else {
        let y_mid = (y1 + y2) / 2;
        [((x1, y1), (x2, y_mid)), ((x1, y_mid + 1), (x2, y2))]
    }
}

fn part2_rectangles(input: Vec<SBPair>) -> i64 {
    let res = uncovered_point_in_rectangle(((0, 0), (4000000, 4000000)), &input).unwrap_or_default();
    point_distress(res)
}

lazy_static! {
    static ref POINT_REGEX: Result<Regex, regex::Error> = Regex::new(r"=([+-]?(\d+))");
    static ref INPUT_EXAMPLE: Vec<SBPair> = input_example();
    static ref INPUT: Vec<SBPair> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input, 10), 26);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input, 2000000), 4725496);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 56000011);
    }

    #[test]
    #[ignore = "takes > 25s to run"]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 12051287042458);
    }

    #[test]
    fn q2e_rectangles() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2_rectangles(input), 56000011);
    }

    #[test]
    fn q2_rectangles() {
        let input = INPUT.to_owned();
        assert_eq!(part2_rectangles(input), 12051287042458);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone(), 2000000));
    println!("Part 2: {}", part2(input.clone()));
    println!("Part 2 rectangles: {}", part2_rectangles(input.clone()));
}
