use super::utils;

use itertools::Itertools;
use lazy_static::lazy_static;

use std::collections::HashSet;

type Point = (i32, i32);

// the sand initial location
const INIT: Point = (500, 0);

fn input_example() -> HashSet<Point> {
    parse_input(utils::read_file_in_cwd_by_line("src/day14/example.txt"))
}

fn input() -> HashSet<Point> {
    parse_input(utils::read_file_in_cwd_by_line("src/day14/puzzle1.txt"))
}

fn draw(x1: i32, x2: i32, y1: i32, y2: i32) -> Vec<Point> {
    if x2 < x1 {
        draw(x2, x1, y1, y2)
    } else if y2 < y1 {
        draw(x1, x2, y2, y1)
    } else {
        (x1..(x2 + 1)).cartesian_product(y1..(y2 + 1)).collect()
    }
}

fn parse_tuple(s: &str) -> Option<Point> {
    let mut split = s.split(",").into_iter().flat_map(|s| s.parse::<i32>().ok());
    let x = split.next()?;
    let y = split.next()?;
    Some((x, y))
}

fn parse_input(input: Vec<String>) -> HashSet<Point> {
    input
        .into_iter()
        .flat_map(|s| {
            let splits = s.split(" -> ");
            splits
                .clone()
                .zip(splits.skip(1))
                .flat_map(|(from, to)| {
                    let (xf, yf) = parse_tuple(from)?;
                    let (xt, yt) = parse_tuple(to)?;
                    Some(draw(xf, xt, yf, yt))
                })
                .flatten()
                .collect_vec()
        })
        .collect()
}

fn adj(p: Point) -> Vec<Point> {
    let (x, y) = p;
    vec![(x, y + 1), (x - 1, y + 1), (x + 1, y + 1)]
}

fn adj_filtered<FN>(p: Point, f: FN) -> Vec<Point>
where
    FN: Fn(&(i32, i32)) -> bool,
{
    adj(p).into_iter().filter(f).collect()
}

fn compute_max_y(input: &HashSet<Point>) -> i32 {
    input.into_iter().map(|(_, y)| *y).max().unwrap_or_default()
}

fn part1(input: HashSet<Point>) -> i32 {
    let max_y = compute_max_y(&input);
    let mut rocks = input;

    let mut i = 0;
    loop {
        let mut curr = INIT;

        while curr.1 < max_y {
            let adj_vec = adj_filtered(curr, |adj| !rocks.contains(adj));

            // can't move and reached the bottom
            if adj_vec.is_empty() {
                break;
            }

            curr = adj_vec[0];
        }

        // abyss
        if curr.1 >= max_y {
            break;
        }

        rocks.insert(curr);

        i += 1;
    }

    i
}

fn part2(input: HashSet<Point>) -> i32 {
    let max_y = compute_max_y(&input);
    let mut rocks = input;

    let mut i = 0;
    loop {
        let mut curr = INIT;

        loop {
            let adj_vec = adj_filtered(curr, |adj| !rocks.contains(adj) && adj.1 < max_y + 2);

            // can't move and reached the bottom
            if adj_vec.is_empty() {
                break;
            }

            curr = adj_vec[0];
        }

        // reached the top
        if curr == INIT {
            i += 1;
            break;
        }

        rocks.insert(curr);

        i += 1;
    }

    i
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
        assert_eq!(part1(input), 24);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 901);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 93);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 24589);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
