use super::utils;

extern crate serde;
use itertools::Itertools;
use serde::Serialize;

use lazy_static::lazy_static;

use std::collections::{HashMap, VecDeque};
use std::ops::{Add, Sub};
use std::str::FromStr;

use regex::Regex;

#[derive(Clone, Copy, Debug, Serialize, Hash, PartialEq, Eq)]
struct Cost {
    ore: i32,
    clay: i32,
    obsidian: i32,
    geode: i32,
}

impl Cost {
    fn empty() -> Cost {
        Cost::new(0, 0, 0, 0)
    }

    fn new(ore: i32, clay: i32, obsidian: i32, geode: i32) -> Cost {
        Cost { ore, clay, obsidian, geode }
    }
}

impl Sub for Cost {
    type Output = Self;

    fn sub(self, other: Self) -> Self::Output {
        Self {
            ore: self.ore - other.ore,
            clay: self.clay - other.clay,
            obsidian: self.obsidian - other.obsidian,
            geode: self.geode - other.geode,
        }
    }
}

impl Add for Cost {
    type Output = Self;

    fn add(self, other: Self) -> Self::Output {
        Self {
            ore: self.ore + other.ore,
            clay: self.clay + other.clay,
            obsidian: self.obsidian + other.obsidian,
            geode: self.geode + other.geode,
        }
    }
}

type Blueprints = Vec<Blueprint>;

#[derive(Clone, Copy, Debug, Serialize, Hash, PartialEq, Eq)]
struct Blueprint {
    n: i32,
    ore: Cost,
    clay: Cost,
    obsidian: Cost,
    geode: Cost,
}

impl Blueprint {
    fn new(n: i32, ore: Cost, clay: Cost, obsidian: Cost, geode: Cost) -> Blueprint {
        Blueprint { n, ore, clay, obsidian, geode }
    }
}

fn parse_i32_vec(s: &str) -> Option<Vec<i32>> {
    D_REGEX
        .as_ref()
        .ok()
        .map(|r| r.captures_iter(s).flat_map(|m| m.get(1)).flat_map(|m| m.as_str().parse::<i32>()).collect_vec())
}

impl FromStr for Blueprint {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        s.split(".")
            .collect_tuple::<(_, _, _, _, _)>()
            .and_then(|(ore_s, clay_s, obsidian_s, geode_s, _)| {
                let ore_vec = parse_i32_vec(ore_s)?;
                let clay_vec = parse_i32_vec(clay_s)?;
                let obsidian_vec = parse_i32_vec(obsidian_s)?;
                let geode_vec = parse_i32_vec(geode_s)?;

                let n = ore_vec[0];
                let ore_cost = Cost::new(ore_vec[1], 0, 0, 0);
                let clay_cost = Cost::new(clay_vec[0], 0, 0, 0);
                let obsidian_cost = Cost::new(obsidian_vec[0], obsidian_vec[1], 0, 0);
                let geode_cost = Cost::new(geode_vec[0], 0, geode_vec[1], 0);

                Some(Blueprint::new(n, ore_cost, clay_cost, obsidian_cost, geode_cost))
            })
            .ok_or("unable to parse blueprint".to_owned())
    }
}

#[derive(Clone, Copy, Debug, Serialize, Hash, PartialEq, Eq)]
struct State {
    resources: Cost,
    ore_robots: i32,
    clay_robots: i32,
    obsidian_robots: i32,
    geode_robots: i32,
}

impl State {
    fn new(ore_robots: i32, clay_robots: i32, obsidian_robots: i32, geode_robots: i32, resources: Cost) -> State {
        State {
            resources,
            ore_robots,
            clay_robots,
            obsidian_robots,
            geode_robots,
        }
    }

    fn robots_cost(&self) -> Cost {
        Cost::new(self.ore_robots, self.clay_robots, self.obsidian_robots, self.geode_robots)
    }

    // one tick
    fn compute(&self) -> State {
        State::new(
            self.ore_robots,
            self.clay_robots,
            self.obsidian_robots,
            self.geode_robots,
            self.resources + self.robots_cost(),
        )
    }

    // spend resources to build robots
    fn build_ore_robot(&self, robot_cost: &Cost) -> State {
        State::new(
            self.ore_robots + 1,
            self.clay_robots,
            self.obsidian_robots,
            self.geode_robots,
            self.resources - *robot_cost,
        )
    }

    fn build_clay_robot(&self, robot_cost: &Cost) -> State {
        State::new(
            self.ore_robots,
            self.clay_robots + 1,
            self.obsidian_robots,
            self.geode_robots,
            self.resources - *robot_cost,
        )
    }

    fn build_obsidian_robot(&self, robot_cost: &Cost) -> State {
        State::new(
            self.ore_robots,
            self.clay_robots,
            self.obsidian_robots + 1,
            self.geode_robots,
            self.resources - *robot_cost,
        )
    }

    fn build_geode_robot(&self, robot_cost: &Cost) -> State {
        State::new(
            self.ore_robots,
            self.clay_robots,
            self.obsidian_robots,
            self.geode_robots + 1,
            self.resources - *robot_cost,
        )
    }
}

fn input_example() -> Blueprints {
    parse_input(utils::read_file_in_cwd_by_line("src/day19/example.txt"))
}

fn input() -> Blueprints {
    parse_input(utils::read_file_in_cwd_by_line("src/day19/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Blueprints {
    input.into_iter().flat_map(|s| s.parse()).collect()
}

fn tick(state: State, bp: &Blueprint) -> Vec<State> {
    let computed = state.compute();

    let mut res = VecDeque::new();

    res.push_back(computed.clone());

    // if there are more resources the cost of the ore robot
    if state.resources.ore >= bp.ore.ore {
        res.push_back(computed.build_ore_robot(&bp.ore));
    }

    // if there are more resources the cost of the clay robot
    if state.resources.ore >= bp.clay.ore {
        res.push_back(computed.build_clay_robot(&bp.clay));
    }

    // if there are more resources the cost of the obsidian robot
    if state.resources.ore >= bp.obsidian.ore && state.resources.clay >= bp.obsidian.clay {
        res.push_back(computed.build_obsidian_robot(&bp.obsidian));
    }

    // if there are more resources the cost of the geode robot
    if state.resources.ore >= bp.geode.ore && state.resources.obsidian >= bp.geode.obsidian {
        res.push_back(computed.build_geode_robot(&bp.geode));
    }

    // res.reverse();

    res.into_iter().collect()
}

fn resolve(max_minutes: i32, blueprint: Blueprint) -> i32 {
    let initial_state = State::new(1, 0, 0, 0, Cost::empty());
    let mut seen = HashMap::new();
    seen.insert(initial_state.clone(), 0);

    let mut q = VecDeque::new();
    q.push_back((initial_state.clone(), 0));

    let mut max_geodes = 0;

    while !q.is_empty() {
        if let Some((state, minutes)) = q.pop_back() {
            let new_minutes = minutes + 1;

            for ns in tick(state, &blueprint) {
                let nt = match seen.get(&ns) {
                    Some(n) => *n,
                    _ => new_minutes + 1,
                };

                if nt > new_minutes {
                    max_geodes = max_geodes.max(ns.resources.geode);

                    let dff = max_minutes - new_minutes;
                    let max_collectible = ns.resources.geode + (ns.geode_robots * dff) + (dff * (dff - 1) / 2);

                    if max_collectible <= max_geodes {
                        continue;
                    }

                    seen.insert(ns.clone(), new_minutes);
                    q.push_back((ns.clone(), new_minutes));
                }
            }
        }
    }

    max_geodes
}

fn part1(input: Blueprints) -> i32 {
    input.into_iter().map(|b| b.n * resolve(24, b)).sum()
}

fn part2(input: Blueprints) -> i32 {
    input.into_iter().map(|b| resolve(32, b)).product()
}

lazy_static! {
    static ref D_REGEX: Result<Regex, regex::Error> = Regex::new(r"(\d+)");
    static ref INPUT_EXAMPLE: Blueprints = input_example();
    static ref INPUT: Blueprints = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 33);
    }

    #[test]
    #[ignore]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 1382);
    }

    #[test]
    #[ignore]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 3472);
    }

    #[test]
    #[ignore]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 31740);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
