use super::utils;

extern crate serde;
use itertools::Itertools;
use serde::Serialize;

use lazy_static::lazy_static;
use std::collections::HashMap;
use std::ops::Add;
use std::str::FromStr;

use regex::Regex;

#[derive(Clone, Copy, Debug, Serialize, PartialEq, Eq, PartialOrd, Ord, Hash)]
struct Point {
    x: i32,
    y: i32,
}

impl Point {
    fn new(x: i32, y: i32) -> Point {
        Point { x, y }
    }

    fn clockwise(&self) -> Point {
        Point::new(-self.y, self.x)
    }

    fn counter_clockwise(&self) -> Point {
        Point::new(self.y, -self.x)
    }

    fn with_x(&self, x: i32) -> Point {
        Point::new(x, self.y)
    }

    fn with_y(&self, y: i32) -> Point {
        Point::new(self.x, y)
    }

    fn is_right(&self) -> bool {
        self.x == 1 && self.y == 0
    }

    fn is_left(&self) -> bool {
        self.x == -1 && self.y == 0
    }

    fn is_down(&self) -> bool {
        self.x == 0 && self.y == 1
    }

    fn is_up(&self) -> bool {
        self.x == 0 && self.y == -1
    }

    fn score(&self) -> i32 {
        if self.is_right() {
            0
        } else if self.is_down() {
            1
        } else if self.is_left() {
            2
        } else if self.is_up() {
            3
        } else {
            0
        }
    }

    fn right() -> Point {
        Point::new(1, 0)
    }

    fn left() -> Point {
        Point::new(-1, 0)
    }

    fn down() -> Point {
        Point::new(0, 1)
    }

    fn up() -> Point {
        Point::new(0, -1)
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

#[derive(Clone, Copy, Debug, Serialize, PartialEq, Eq, PartialOrd, Ord, Hash)]
enum Tile {
    Open,
    Solid,
    None,
}

impl Tile {
    fn from_char(c: char) -> Tile {
        match c {
            '.' => Tile::Open,
            '#' => Tile::Solid,
            _ => Tile::None,
        }
    }
}

#[derive(Clone, Copy, Debug, Serialize, PartialEq, Eq, PartialOrd, Ord, Hash)]
enum Rotation {
    Clockwise,        // R
    CounterClockwise, // L,
}

impl FromStr for Rotation {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        match s {
            "L" => Ok(Rotation::CounterClockwise),
            "R" => Ok(Rotation::Clockwise),
            _ => Err("wrong chracter to translate into rotation".to_owned()),
        }
    }
}

// steps + rotation tuple
type Move = (i32, Rotation);
type Moves = Vec<Move>;

fn input_example() -> (HashMap<Point, Tile>, Moves) {
    parse_input(utils::read_file_in_cwd_by_line("src/day22/example.txt"))
}

fn input() -> (HashMap<Point, Tile>, Moves) {
    parse_input(utils::read_file_in_cwd_by_line("src/day22/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> (HashMap<Point, Tile>, Moves) {
    let mut iter = input.split(|s| s.is_empty()).into_iter();
    let maze = iter.next().unwrap().into_iter().map(|s| s.to_owned()).collect_vec();
    let instructions = iter.next().unwrap().into_iter().map(|s| s.to_owned()).next().unwrap();

    let mut res = HashMap::new();
    for (y, row) in maze.into_iter().enumerate() {
        for (x, v) in row.chars().enumerate() {
            let t = Tile::from_char(v);
            match t {
                Tile::None => (),
                _ => {
                    res.insert(Point::new(x as i32, y as i32), t);
                }
            };
        }
    }

    let steps = STEPS_REGEX
        .as_ref()
        .map_err(|e| e.to_string())
        .unwrap()
        .captures_iter(&instructions)
        .flat_map(|c| c.get(1).into_iter().flat_map(|m| m.as_str().parse::<i32>().ok()))
        .collect_vec();

    let rotations = ROTATION_REGEX
        .as_ref()
        .map_err(|e| e.to_string())
        .unwrap()
        .captures_iter(&instructions)
        .flat_map(|c| c.get(1).into_iter().flat_map(|m| m.as_str().parse::<Rotation>().ok()))
        .collect_vec();

    let moves = steps.into_iter().zip(rotations.into_iter()).collect_vec();

    (res, moves)
}

fn simulate<FN>(grid: HashMap<Point, Tile>, path: Moves, start: Point, wrap: FN) -> i32
where
    FN: Fn(Point, Point) -> (Point, Point),
{
    // initial state, start point facing right
    let mut state = (start, Point::new(1, 0));

    for (steps, rotate) in path {
        let (mut position, mut direction) = state;

        for _ in 0..steps {
            let next = position + direction;
            match grid.get(&next).unwrap_or(&Tile::None) {
                // move in the direction
                Tile::Open => {
                    position = next.clone();
                }
                // do nothing
                Tile::Solid => (),
                Tile::None => {
                    let (wrap_position, wrap_direction) = wrap(position, direction);
                    match grid.get(&wrap_position) {
                        Some(&Tile::Open) => {
                            position = wrap_position;
                            direction = wrap_direction;
                        }
                        _ => (),
                    }
                }
            };
        }

        let next_direction = match rotate {
            Rotation::Clockwise => direction.clone().clockwise(),
            Rotation::CounterClockwise => direction.clone().counter_clockwise(),
        };

        state = (position, next_direction);
    }
    1000 * (state.0.y + 1) + 4 * (state.0.x + 1) + state.1.score()
}

fn part1(grid: HashMap<Point, Tile>, path: Moves, start: Point) -> i32 {
    let mut x_map: HashMap<i32, Vec<i32>> = HashMap::new();
    for (p, _) in grid.clone() {
        let key = p.y;
        let mut v = match x_map.get(&key) {
            Some(v) => v.clone(),
            _ => vec![],
        };
        v.push(p.x);
        x_map.insert(key, v);
    }

    let mut y_map: HashMap<i32, Vec<i32>> = HashMap::new();
    for (p, _) in grid.clone() {
        let key = p.x;
        let mut v = match y_map.get(&key) {
            Some(v) => v.clone(),
            _ => vec![],
        };
        v.push(p.y);
        y_map.insert(key, v);
    }

    let x_min_max = x_map
        .into_iter()
        .map(|(x, v)| (x, v.into_iter().minmax().into_option().unwrap()))
        .collect::<HashMap<_, _>>();
    let y_min_max = y_map
        .into_iter()
        .map(|(x, v)| (x, v.into_iter().minmax().into_option().unwrap()))
        .collect::<HashMap<_, _>>();

    simulate(grid, path, start, |position, direction| {
        if direction.is_right() {
            (position.with_x(x_min_max.get(&position.y).unwrap().0), direction)
        } else if direction.is_left() {
            (position.with_x(x_min_max.get(&position.y).unwrap().1), direction)
        } else if direction.is_up() {
            (position.with_y(y_min_max.get(&position.x).unwrap().1), direction)
        } else if direction.is_down() {
            (position.with_y(y_min_max.get(&position.x).unwrap().0), direction)
        } else {
            (position, direction)
        }
    })
}

fn part2(grid: HashMap<Point, Tile>, path: Moves, start: Point) -> i32 {
    simulate(grid, path, start, |position, direction| {
        // Cube faces:
        //  BA
        //  C
        // ED
        // F
        let (cube_x, cube_y) = (position.x / 50, position.y / 50);
        let (mod_x, mod_y) = (position.x % 50, position.y % 50);

        match (cube_x, cube_y) {
            (2, 0) if direction.is_up() => (Point::new(mod_x, 199), Point::up()),           // A -> F
            (2, 0) if direction.is_down() => (Point::new(99, 50 + mod_x), Point::left()),   // A -> C
            (2, 0) if direction.is_right() => (Point::new(99, 149 - mod_y), Point::left()), // A -> D
            (1, 0) if direction.is_up() => (Point::new(0, 150 + mod_x), Point::right()),    // B -> F
            (1, 0) if direction.is_left() => (Point::new(0, 149 - mod_y), Point::right()),  // B -> E
            (1, 1) if direction.is_left() => (Point::new(mod_y, 100), Point::down()),       // C -> E
            (1, 1) if direction.is_right() => (Point::new(100 + mod_y, 49), Point::up()),   // C -> A
            (1, 2) if direction.is_down() => (Point::new(49, 150 + mod_x), Point::left()),  // D -> F
            (1, 2) if direction.is_right() => (Point::new(149, 49 - mod_y), Point::left()), // D -> A
            (0, 2) if direction.is_up() => (Point::new(50, 50 + mod_x), Point::right()),    // E -> C
            (0, 2) if direction.is_left() => (Point::new(50, 49 - mod_y), Point::right()),  // E -> B
            (0, 3) if direction.is_down() => (Point::new(100 + mod_x, 0), Point::down()),   // F -> A
            (0, 3) if direction.is_left() => (Point::new(50 + mod_y, 0), Point::down()),    // F -> B
            (0, 3) if direction.is_right() => (Point::new(50 + mod_y, 149), Point::up()),   // F -> D
            _ => (position, direction),
        }
    })
}

lazy_static! {
    static ref ROTATION_REGEX: Result<Regex, regex::Error> = Regex::new(r"(\D+)");
    static ref STEPS_REGEX: Result<Regex, regex::Error> = Regex::new(r"(\d+)");
    static ref INPUT_EXAMPLE: (HashMap<Point, Tile>, Moves) = input_example();
    static ref INPUT: (HashMap<Point, Tile>, Moves) = input();
}

#[cfg(test)]
mod tests {
    use tuples::TupleAsRef;

    use super::*;

    #[test]
    fn q1e() {
        let (grid, path) = INPUT_EXAMPLE.as_ref();
        assert_eq!(part1(grid.clone(), path.clone(), Point::new(8, 0)), 6032);
    }

    #[test]
    fn q1() {
        let (grid, path) = INPUT.as_ref();
        assert_eq!(part1(grid.clone(), path.clone(), Point::new(50, 0)), 77318);
    }

    #[test]
    #[ignore = "example is way much more different than the actual input"]
    fn q2e() {
        let (grid, path) = INPUT_EXAMPLE.as_ref();
        assert_eq!(part2(grid.clone(), path.clone(), Point::new(8, 0)), 5031);
    }

    #[test]
    fn q2() {
        let (grid, path) = INPUT.as_ref();
        assert_eq!(part2(grid.clone(), path.clone(), Point::new(50, 0)), 126017);
    }
}

pub fn run() {
    let (grid, path) = INPUT.to_owned();

    println!("Part 1: {}", part1(grid.clone(), path.clone(), Point::new(50, 0)));
    println!("Part 2: {}", part2(grid.clone(), path.clone(), Point::new(50, 0)));
}
