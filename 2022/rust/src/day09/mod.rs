use super::utils;

extern crate serde;
use lazy_static::lazy_static;
use serde::Serialize;

use std::collections::{HashMap, HashSet};
use std::str::FromStr;

type Pos = (i32, i32);

#[derive(Clone, Copy, Debug, Serialize, PartialEq, Eq, Hash)]
enum Direction {
    L,
    R,
    D,
    U,
}

impl FromStr for Direction {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s.chars().next().ok_or("unable to extract character".to_owned())? {
            'L' => Ok(Direction::L),
            'R' => Ok(Direction::R),
            'D' => Ok(Direction::D),
            'U' => Ok(Direction::U),
            _ => Err("wrong chracter to translate into direction".to_owned()),
        }
    }
}

#[derive(Clone, Copy, Debug, Serialize)]
pub struct Move {
    direction: Direction,
    n: usize,
}

fn input_example1() -> Vec<Move> {
    parse_input(utils::read_file_in_cwd_by_line("src/day09/example1.txt"))
}

fn input_example2() -> Vec<Move> {
    parse_input(utils::read_file_in_cwd_by_line("src/day09/example2.txt"))
}

fn input() -> Vec<Move> {
    parse_input(utils::read_file_in_cwd_by_line("src/day09/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Vec<Move> {
    input
        .into_iter()
        .flat_map(|line| {
            let (d_str, n_str) = line.split_once(" ")?;
            let direction = d_str.parse::<Direction>().ok()?;
            let n = n_str.parse::<usize>().ok()?;

            Some(Move { direction, n })
        })
        .collect()
}

fn move_head(start: Pos, d: Direction) -> Pos {
    let (xs, ys) = start;
    let (dx, dy) = DIRS[&d];
    (xs + dx, ys + dy)
}

fn move_tail(head: Pos, tail: Pos) -> Pos {
    let (hx, hy) = head;
    let mut tx = tail.0;
    let mut ty = tail.1;

    if hx == tx {
        if (hy - ty).abs() > 1 {
            if ty > hy {
                ty -= 1
            } else {
                ty += 1;
            }
        }
    } else if hy == ty {
        if (hx - tx).abs() > 1 {
            if tx > hx {
                tx -= 1
            } else {
                tx += 1;
            }
        }
    } else {
        if (hx - tx).abs() > 1 || (hy - ty).abs() > 1 {
            let (dx, dy) = ((hx - tx).signum(), (hy - ty).signum());

            // dx and dy should have the same sign?

            tx += dx;
            ty += dy;
        }
    }

    (tx, ty)
}

// my naive implementation
#[allow(dead_code)]
fn part1_simple(input: Vec<Move>) -> usize {
    let mut h: Pos = (0, 0);
    let mut t: Pos = h;

    let mut visited: HashSet<Pos> = [t].into_iter().collect();

    for mv in input {
        for _ in 0..mv.n {
            h = move_head(h, mv.direction);
            t = move_tail(h, t);
            visited.insert(t);
        }
    }

    visited.len()
}

fn simulate(input: Vec<Move>, rope_size: usize) -> usize {
    let t: Pos = (0, 0);

    let mut visited: HashSet<Pos> = [t].into_iter().collect();

    let mut rope: Vec<Pos> = vec![t; rope_size];
    let rope_tail = rope_size - 1;

    for mv in input {
        for _ in 0..mv.n {
            rope[0] = move_head(rope[0], mv.direction);
            for i in 0..rope_tail {
                rope[i + 1] = move_tail(rope[i], rope[i + 1])
            }
            visited.insert(rope[rope_tail]);
        }
    }

    visited.len()
}

fn part1(input: Vec<Move>) -> usize {
    simulate(input, 2)
}

fn part2(input: Vec<Move>) -> usize {
    simulate(input, 10)
}

lazy_static! {
    static ref DIRS: HashMap<Direction, Pos> = [(Direction::L, (-1, 0)), (Direction::R, (1, 0)), (Direction::D, (0, -1)), (Direction::U, (0, 1))]
        .into_iter()
        .collect();
    static ref INPUT_EXAMPLE1: Vec<Move> = input_example1();
    static ref INPUT_EXAMPLE2: Vec<Move> = input_example2();
    static ref INPUT: Vec<Move> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1se() {
        let input = INPUT_EXAMPLE1.to_owned();
        assert_eq!(part1_simple(input), 13);
    }

    #[test]
    fn q1s() {
        let input = INPUT.to_owned();
        assert_eq!(part1_simple(input), 6269);
    }

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE1.to_owned();
        assert_eq!(part1(input), 13);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 6269);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE2.to_owned();
        assert_eq!(part2(input), 36);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 2557);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
