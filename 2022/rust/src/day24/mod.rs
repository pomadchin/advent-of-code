use super::utils;

extern crate serde;
use itertools::Itertools;
use serde::Serialize;

use lazy_static::lazy_static;
use std::collections::{HashMap, HashSet, VecDeque};
use std::ops::Add;

#[derive(Clone, Copy, Debug, Serialize, PartialEq, Eq, PartialOrd, Ord, Hash)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(x: i32, y: i32) -> Point {
        Point { x, y }
    }
}

impl Add for Point {
    type Output = Self;

    fn add(self, other: Self) -> Self::Output {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

fn input_example() -> (HashMap<Point, char>, usize, usize) {
    parse_input(utils::read_file_in_cwd_by_line("src/day24/example.txt"))
}

fn input() -> (HashMap<Point, char>, usize, usize) {
    parse_input(utils::read_file_in_cwd_by_line("src/day24/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> (HashMap<Point, char>, usize, usize) {
    let mut no_wall = input.clone();
    no_wall.drain(0..1);
    no_wall.drain((no_wall.len() - 1)..no_wall.len());

    let (n, m) = (no_wall.len(), no_wall[0].len() - 2);

    let mut grid = no_wall
        .into_iter()
        .map(|row| {
            let mut r_vec = row.chars().collect_vec();
            r_vec.drain(0..1);
            r_vec.drain((r_vec.len() - 1)..r_vec.len());
            r_vec
        })
        .enumerate()
        .flat_map(|(r, row)| row.into_iter().enumerate().map(|(c, v)| (Point::new(r as i32, c as i32), v)).collect_vec())
        .collect::<HashMap<Point, char>>();

    grid.insert(Point::new(-1, 0), '.');
    grid.insert(Point::new(n as i32, m as i32 - 1), '.');

    (grid, n, m)
}

fn has_blizzard(grid: &HashMap<Point, char>, n: usize, m: usize, t: i32, p: Point) -> bool {
    let (i, j) = (p.x, p.y);
    if (i == -1 && j == 0) || (i == n as i32 && j == (m - 1) as i32) {
        false
    } else {
        let c1 = match grid.get(&Point::new((i - t).rem_euclid(n as i32), j)) {
            Some(c) => *c == 'v',
            _ => return true,
        };

        let c2 = match grid.get(&Point::new((i + t).rem_euclid(n as i32), j)) {
            Some(c) => *c == '^',
            _ => return true,
        };

        let c3 = match grid.get(&Point::new(i, (j - t).rem_euclid(m as i32))) {
            Some(c) => *c == '>',
            _ => return true,
        };

        let c4 = match grid.get(&Point::new(i, (j + t).rem_euclid(m as i32))) {
            Some(c) => *c == '<',
            _ => return true,
        };

        c1 || c2 || c3 || c4
    }
}

fn bfs(grid: &HashMap<Point, char>, start: Point, end: Point, start_t: i32, n: usize, m: usize) -> i32 {
    // time, point
    let mut visited: HashSet<(i32, Point)> = HashSet::new();

    let mut q: VecDeque<(i32, Point)> = VecDeque::new();
    q.push_front((start_t, start));

    while !q.is_empty() {
        if let Some(x @ (t, p)) = q.pop_back() {
            if visited.contains(&x) {
                continue;
            }
            visited.insert(x);

            if p == end {
                return t as i32;
            }

            for (dt, dx, dy) in [(1, 0, 0), (1, -1, 0), (1, 1, 0), (1, 0, -1), (1, 0, 1)].into_iter() {
                let next = (t + dt, Point::new(p.x + dx, p.y + dy));
                if !has_blizzard(&grid, n, m, next.0, next.1) {
                    q.push_front(next);
                }
            }
        }
    }

    return -1;
}

fn part1(grid: HashMap<Point, char>, n: usize, m: usize) -> i32 {
    bfs(&grid, Point::new(-1, 0), Point::new(n as i32, m as i32 - 1), 0, n, m)
}

fn part2(grid: HashMap<Point, char>, n: usize, m: usize) -> i32 {
    let t1 = bfs(&grid, Point::new(-1, 0), Point::new(n as i32, m as i32 - 1), 0, n, m);
    let t2 = bfs(&grid, Point::new(n as i32, m as i32 - 1), Point::new(-1, 0), t1, n, m);

    bfs(&grid, Point::new(-1, 0), Point::new(n as i32, m as i32 - 1), t2, n, m)
}

lazy_static! {
    static ref INPUT_EXAMPLE: (HashMap<Point, char>, usize, usize) = input_example();
    static ref INPUT: (HashMap<Point, char>, usize, usize) = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let (grid, n, m) = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(grid, n, m), 18);
    }

    #[test]
    fn q1() {
        let (grid, n, m) = INPUT.to_owned();
        assert_eq!(part1(grid, n, m), 257);
    }

    #[test]
    fn q2e() {
        let (grid, n, m) = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(grid, n, m), 54);
    }

    #[test]
    fn q2() {
        let (grid, n, m) = INPUT.to_owned();
        assert_eq!(part2(grid, n, m), 828);
    }
}

pub fn run() {
    let (grid, n, m) = INPUT.to_owned();

    println!("Part 1: {}", part1(grid.clone(), n, m));
    println!("Part 2: {}", part2(grid.clone(), n, m));
}
