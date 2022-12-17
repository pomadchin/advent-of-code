use super::utils;

extern crate serde;

use itertools::Itertools;
use lazy_static::lazy_static;

use std::collections::{HashMap, HashSet};

type Point = (i64, i64);
type Shape = HashSet<Point>;
type ShapeI = (usize, Shape);
type Shapes = Vec<Shape>;
type ShapesI = Vec<ShapeI>;
type Wind = Vec<i64>;

fn input_example() -> Wind {
    parse_input(utils::read_file_in_cwd_string("src/day17/example.txt"))
}

fn input() -> Wind {
    parse_input(utils::read_file_in_cwd_string("src/day17/puzzle1.txt"))
}

fn parse_input(input: String) -> Wind {
    fn direction(c: char) -> i64 {
        match c {
            '>' => 1,
            _ => -1,
        }
    }

    input.chars().map(direction).collect()
}

fn shape_move(shape: &Shape, p: Point) -> Shape {
    shape.clone().into_iter().map(|(x, y)| (x + p.0, y + p.1)).collect()
}

fn wind_direction(w: &Wind, idx: usize) -> i64 {
    w[idx % w.len()]
}

fn get_shape(s: &Shapes, idx: usize) -> Shape {
    s[idx % s.len()].clone()
}

fn get_shape_i(s: &ShapesI, idx: usize) -> ShapeI {
    s[idx % s.len()].clone()
}

fn get_max_y(rocks: &HashSet<Point>) -> i64 {
    rocks.into_iter().map(|(_, y)| *y).max().unwrap_or_default()
}

fn part1(wind: Wind) -> i64 {
    let mut rocks: Shape = (0..7).map(|x| (x, -1)).collect();
    let mut wind_idx = 0;
    let mut shape_idx = 0;

    while shape_idx < 2022 {
        let start: Point = (2, (4 + get_max_y(&rocks)));

        // get rock and shift it to the start // it represents the current rock position
        let mut rock: Shape = shape_move(&get_shape(&SHAPES, shape_idx), start);

        loop {
            let w = wind_direction(&wind, wind_idx);
            wind_idx += 1;

            // wind affected shape
            let mut rock_next: Shape = shape_move(&rock, (w, 0));

            // if rock_next intersects nothing and within bounds // it is a wind shift
            if (rocks.intersection(&rock_next).count() == 0) && rock_next.clone().into_iter().all(|(x, _)| x <= 6 && x >= 0) {
                rock = rock_next;
            }

            // move to the bottom
            rock_next = shape_move(&rock, (0, -1));

            // on intersection insert a previous rock
            if rocks.intersection(&rock_next).count() != 0 {
                for p in rock {
                    rocks.insert(p);
                }
                break;
            }

            rock = rock_next;
        }

        shape_idx += 1;
    }

    get_max_y(&rocks) + 1
}

fn part2(wind: Wind) -> i64 {
    let mut rocks: Shape = (0..7).map(|x| (x, -1)).collect();
    let mut wind_idx = 0;
    let mut shape_idx = 0;
    let mut t: i64 = 1000000000000;

    // [r_idx, w_idx, heights] -> old_t, old_max_y
    let mut memo: HashMap<(usize, usize, (i64, i64, i64, i64, i64, i64, i64)), (i64, i64)> = HashMap::new();

    while t > 0 {
        let mut max_y = get_max_y(&rocks);
        let start: Point = (2, (4 + max_y));

        // get rock and shift it to the start // it represents the current rock position
        let (rock_idx, shape_curr) = get_shape_i(&SHAPES_INDEXED, shape_idx);
        let mut rock: Shape = shape_move(&shape_curr, start);

        let mut w_idx;
        loop {
            let w = wind_direction(&wind, wind_idx);
            w_idx = wind_idx % wind.len();

            wind_idx += 1;

            // wind affected shape
            let mut rock_next: Shape = shape_move(&rock, (w, 0));

            // if rock_next intersects nothing and within bounds // it is a wind shift
            if (rocks.intersection(&rock_next).count() == 0) && rock_next.clone().into_iter().all(|(x, _)| x <= 6 && x >= 0) {
                rock = rock_next;
            }

            // move to the bottom
            rock_next = shape_move(&rock, (0, -1));

            // on intersection insert a previous rock
            if rocks.intersection(&rock_next).count() != 0 {
                for p in rock {
                    rocks.insert(p);
                }
                break;
            }

            rock = rock_next;
        }

        shape_idx += 1;
        t -= 1;

        // current max_y for the diff
        max_y = get_max_y(&rocks);
        // heights (relative to max_y)
        let heights = (0..7)
            .map(|x| {
                let h = rocks.clone().into_iter().filter(|p| p.0 == x).collect();
                max_y - get_max_y(&h)
            })
            .collect_tuple::<(_, _, _, _, _, _, _)>()
            .unwrap();

        let key = (rock_idx, w_idx, heights);
        if let Some((old_t, old_max_y)) = memo.get(&key) {
            // lift y to the max_y - old_max_y t / (old_t - t) times (times old_t - t is there in t)
            // i.e. t = 10000; old_t = 10100; the full cycle will be old_t - t = 100; and there are 100 times it's possible to build (max_y - old_max_y)
            let dy = t / (old_t - t) * (max_y - old_max_y);
            rocks = rocks.clone().into_iter().map(|(x, y)| (x, y + dy)).collect();
            // skip time we filled in rocks for; in the example about it's 0
            t %= *old_t - t
        } else {
            // memo time, and max_y
            memo.insert(key, (t.clone(), max_y));
        }
    }

    get_max_y(&rocks) + 1
}

lazy_static! {
    static ref SHAPES: Shapes = vec![
        [(0, 0), (1, 0), (2, 0), (3, 0)].into_iter().collect(),
        [(1, 0), (0, 1), (1, 1), (2, 1), (1, 2)].into_iter().collect(),
        [(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)].into_iter().collect(),
        [(0, 0), (0, 1), (0, 2), (0, 3)].into_iter().collect(),
        [(0, 0), (1, 0), (0, 1), (1, 1)].into_iter().collect()
    ];
    static ref SHAPES_INDEXED: ShapesI = SHAPES.clone().into_iter().enumerate().collect();
    static ref INPUT_EXAMPLE: Wind = input_example();
    static ref INPUT: Wind = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 3068);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 3085);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 1514285714288);
    }

    #[test]
    #[ignore = "takes > 30s to run"]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 1535483870924);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
