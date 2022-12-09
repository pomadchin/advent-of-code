use super::utils;
use utils::{index, rc};

use itertools::Itertools;
use lazy_static::lazy_static;
use take_until::TakeUntilExt;

use std::cmp;

type Square = (Vec<u32>, usize);
type Square2D = Vec<Vec<u32>>;

fn input_example() -> Square {
    parse_input(utils::read_file_in_cwd_by_line("src/day08/example.txt"))
}

fn input() -> Square {
    parse_input(utils::read_file_in_cwd_by_line("src/day08/puzzle1.txt"))
}

fn input_2d() -> Square2D {
    parse_input_2d(utils::read_file_in_cwd_by_line("src/day08/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Square {
    // radix
    const R: u32 = 10;
    // the input is square
    let n = input.len();

    let res = input
        .into_iter()
        .flat_map(|line| line.chars().flat_map(|c| c.to_digit(R)).collect_vec())
        .collect_vec();

    (res, n)
}

fn parse_input_2d(input: Vec<String>) -> Square2D {
    // radix
    const R: u32 = 10;
    input.into_iter().map(|line| line.chars().flat_map(|c| c.to_digit(R)).collect()).collect()
}

// A tree is visible if all of the other trees between it and an edge of the grid are shorter than it.
// Only consider trees in the same row or column; that is, only look up, down, left, or right from any given tree.
fn part1(input: Square) -> u32 {
    let (vec, n) = input;
    vec.clone()
        .into_iter()
        .enumerate()
        .map(|(idx, v)| (rc(idx, n), v))
        .map(|((row, col), v)| {
            // v should be lower than:
            // -- rows scan
            // -- [(0, col), (row, col))
            // -- ((row, col), (rows, col)]
            // -- columns scan
            // -- [(row), 0), (row, col))
            // -- ((row, col), row, cols)]

            // rows scan, same col
            let r0 = (0..row).map(|r| index(r, col, n)).all(|idx| v > vec[idx]);
            let rs = ((row + 1)..n).map(|r| index(r, col, n)).all(|idx| v > vec[idx]);

            // cols scan, same row
            let c0 = (0..col).map(|c| index(row, c, n)).all(|idx| v > vec[idx]);
            let cs = ((col + 1)..n).map(|c| index(row, c, n)).all(|idx| v > vec[idx]);

            (r0 || rs || c0 || cs) as u32
        })
        .sum()
}

#[allow(dead_code)]
fn part1_2d(vec: Square2D) -> u32 {
    let n = vec.len();
    let mut res = 0;

    for row in 0..n {
        for col in 0..n {
            let v = vec[row][col];

            let r0 = (0..row).all(|r| v > vec[r][col]);
            let rs = ((row + 1)..n).all(|r| v > vec[r][col]);
            let c0 = (0..col).all(|c| v > vec[row][c]);
            let cs = ((col + 1)..n).all(|c| v > vec[row][c]);

            res += (r0 || rs || c0 || cs) as u32;
        }
    }
    res
}

fn part2(input: Square) -> u32 {
    let (vec, n) = input;
    vec.clone()
        .into_iter()
        .enumerate()
        .map(|(idx, v)| (rc(idx, n), v))
        .map(|((row, col), v)| {
            // results of all 4 scans
            //
            // let mut res = vec![0; 4];
            // for idx in ((0..row).rev()).map(|r| index(r, col, n)) {
            //     res[0] += 1;
            //     if vec[idx] >= v {
            //         break;
            //     }
            // }
            //
            // for idx in ((row + 1)..n).map(|r| index(r, col, n)) {
            //     res[1] += 1;
            //     if vec[idx] >= v {
            //         break;
            //     }
            // }
            //
            // for idx in (0..col).rev().map(|c| index(row, c, n)) {
            //     res[2] += 1;
            //     if vec[idx] >= v {
            //         break;
            //     }
            // }
            //
            // for idx in ((col + 1)..n).map(|c| index(row, c, n)) {
            //     res[3] += 1;
            //     if vec[idx] >= v {
            //         break;
            //     }
            // }
            // res.into_iter().reduce(|l, r| l * r).unwrap_or_default()

            ((0..row).rev().map(|r| index(r, col, n)).take_until(|idx| vec[*idx] >= v).count()
                * ((row + 1)..n).map(|r| index(r, col, n)).take_until(|idx| vec[*idx] >= v).count()
                * (0..col).rev().map(|c| index(row, c, n)).take_until(|idx| vec[*idx] >= v).count()
                * ((col + 1)..n).map(|c| index(row, c, n)).take_until(|idx| vec[*idx] >= v).count()) as u32
        })
        .max()
        .unwrap_or(0)
}

#[allow(dead_code)]
fn part2_2d(vec: Square2D) -> u32 {
    let n = vec.len();
    let mut res = 0;

    for row in 0..n {
        for col in 0..n {
            let v = vec[row][col];

            let cnt = ((0..row).rev().take_until(|r| vec[*r][col] >= v).count()
                * ((row + 1)..n).take_until(|r| vec[*r][col] >= v).count()
                * (0..col).rev().take_until(|c| vec[row][*c] >= v).count()
                * ((col + 1)..n).take_until(|c| vec[row][*c] >= v).count()) as u32;

            res = cmp::max(res, cnt);
        }
    }

    res
}

lazy_static! {
    static ref INPUT_EXAMPLE: Square = input_example();
    static ref INPUT: Square = input();
    static ref INPUT_2D: Square2D = input_2d();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 21);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 1779);
    }

    #[test]
    fn q1_2d() {
        let input = INPUT_2D.to_owned();
        assert_eq!(part1_2d(input), 1779);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 8);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 172224);
    }

    #[test]
    fn q2_2d() {
        let input = INPUT_2D.to_owned();
        assert_eq!(part2_2d(input), 172224);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
