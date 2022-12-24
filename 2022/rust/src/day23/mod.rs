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

    fn adj(&self) -> Vec<Point> {
        Point::adj_vec().into_iter().map(|p| *self + p).collect()
    }

    fn adj_vec() -> Vec<Point> {
        vec![
            Point::new(-1, -1),
            Point::new(0, -1),
            Point::new(1, -1),
            Point::new(-1, 0),
            Point::new(1, 0),
            Point::new(-1, 1),
            Point::new(0, 1),
            Point::new(1, 1),
        ]
    }

    fn order() -> VecDeque<Point> {
        vec![Point::north(), Point::south(), Point::west(), Point::east()].into_iter().collect()
    }

    fn north() -> Point {
        Point::new(0, -1)
    }

    fn south() -> Point {
        Point::new(0, 1)
    }

    fn west() -> Point {
        Point::new(-1, 0)
    }

    fn east() -> Point {
        Point::new(1, 0)
    }

    fn is_north(&self) -> bool {
        self.x == 0 && self.y == -1
    }

    fn is_south(&self) -> bool {
        self.x == 0 && self.y == 1
    }

    fn is_west(&self) -> bool {
        self.x == -1 && self.y == 0
    }

    fn is_east(&self) -> bool {
        self.x == 1 && self.y == 0
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

fn input_example() -> HashSet<Point> {
    parse_input(utils::read_file_in_cwd_by_line("src/day23/example.txt"))
}

fn input() -> HashSet<Point> {
    parse_input(utils::read_file_in_cwd_by_line("src/day23/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> HashSet<Point> {
    input
        .into_iter()
        .enumerate()
        .flat_map(|(r, row)| {
            row.chars()
                .enumerate()
                .flat_map(|(c, v)| if v != '.' { Some(Point::new(c as i32, r as i32)) } else { None })
                .collect_vec()
        })
        .collect()
}

fn elf_move(elf: Point, elves: HashSet<Point>, order: VecDeque<Point>) -> Option<Point> {
    // If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving north one step.
    // If there is no Elf in the S, SE, or SW adjacent positions, the Elf proposes moving south one step.
    // If there is no Elf in the W, NW, or SW adjacent positions, the Elf proposes moving west one step.
    // If there is no Elf in the E, NE, or SE adjacent positions, the Elf proposes moving east one step.

    let (nw, n, ne, w, e, sw, s, se) = elf.adj().iter().map(|e| elves.contains(e)).collect_tuple::<(_, _, _, _, _, _, _, _)>().unwrap();
    let move_possible = nw || n || ne || w || e || sw || s || se;

    if move_possible {
        match order.into_iter().find(|p| {
            if p.is_north() {
                !(n || ne || nw)
            } else if p.is_south() {
                !(s || se || sw)
            } else if p.is_west() {
                !(w || nw || sw)
            } else if p.is_east() {
                !(e || ne || se)
            } else {
                false
            }
        }) {
            Some(p) => Some(elf + p),
            _ => None,
        }
    } else {
        None
    }
}

fn round(elves: HashSet<Point>, order: &mut VecDeque<Point>) -> (HashSet<Point>, bool) {
    // proposed moves (elf -> next_move)
    let moves = elves
        .clone()
        .into_iter()
        .map(|elf| (elf, elf_move(elf, elves.clone(), order.clone())))
        .collect::<HashSet<_>>();

    // how many elves move to the same place?
    let mut counts: HashMap<Point, i32> = HashMap::new();
    for k in moves.clone().into_iter().flat_map(|(_, p)| p) {
        match counts.get(&k) {
            Some(v) => {
                counts.insert(k, *v + 1);
            }
            _ => {
                counts.insert(k, 1);
            }
        }
    }

    let next: HashSet<Point> = moves
        .clone()
        .into_iter()
        .map(|(elf, possible_move)| match possible_move {
            Some(mv) => match counts.get(&mv) {
                Some(i) if *i == 1 => mv,
                _ => elf,
            },
            _ => elf,
        })
        .collect();

    // rotate moves order
    let top = order.pop_front().unwrap();
    order.push_back(top);

    (next.clone(), next == elves)
}

fn part1(input: HashSet<Point>) -> usize {
    let (mut elves, mut order) = (input.clone(), Point::order());

    for _ in 0..10 {
        let (next, _) = round(elves.clone(), &mut order);
        elves = next;
    }

    let (x_min, x_max) = elves.clone().into_iter().map(|p| p.x).minmax().into_option().unwrap();
    let (y_min, y_max) = elves.clone().into_iter().map(|p| p.y).minmax().into_option().unwrap();

    let pts = (x_min..(x_max + 1))
        .into_iter()
        .flat_map(|x| (y_min..(y_max + 1)).map(|y| Point::new(x, y)).collect_vec())
        .collect_vec();

    pts.into_iter().filter(|p| !elves.contains(p)).count()
}

fn part2(input: HashSet<Point>) -> usize {
    let (mut elves, mut order, mut stop, mut rounds) = (input.clone(), Point::order(), false, 0);

    while !stop {
        let (next, stop_next) = round(elves.clone(), &mut order);
        elves = next;
        stop = stop_next;
        rounds += 1;
    }

    rounds
}

lazy_static! {
    static ref INPUT_EXAMPLE: HashSet<Point> = input_example();
    static ref INPUT: HashSet<Point> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 110);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 4116);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 20);
    }

    #[test]
    #[ignore = "takes > 15s to run"]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 984);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
