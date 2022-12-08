use super::utils;
use utils::{index, rc};

use itertools::Itertools;
use lazy_static::lazy_static;

type Square = (Vec<u32>, usize);

fn input_example() -> Square {
    parse_input(utils::read_file_in_cwd_by_line("src/day08/example.txt"))
}

fn input() -> Square {
    parse_input(utils::read_file_in_cwd_by_line("src/day08/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Square {
    // radix
    const R: u32 = 10;
    // the input is square
    let n = input.len();

    let res = input
        .into_iter()
        .flat_map(|line| line.chars().map(|c| c.to_digit(R).unwrap_or(0)).collect_vec())
        .collect_vec();

    (res, n)
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
            let r0 = (0..row).map(|r| index(r, col, n)).map(|idx| v > vec[idx]).fold(true, |l, r| l && r);
            let rs = ((row + 1)..n).map(|r| index(r, col, n)).map(|idx| v > vec[idx]).fold(true, |l, r| l && r);

            // cols scan, same row
            let c0 = (0..col).map(|c| index(row, c, n)).map(|idx| v > vec[idx]).fold(true, |l, r| l && r);
            let cs = ((col + 1)..n).map(|c| index(row, c, n)).map(|idx| v > vec[idx]).fold(true, |l, r| l && r);

            (r0 || rs || c0 || cs) as u32
        })
        .sum()
}

fn part2(input: Square) -> u32 {
    let (vec, n) = input;
    vec.clone()
        .into_iter()
        .enumerate()
        .map(|(idx, v)| (rc(idx, n), v))
        .map(|((row, col), v)| {
            // results for all 4 scans
            let mut res = vec![0; 4];

            for idx in ((0..row).rev()).map(|r| index(r, col, n)) {
                res[0] += 1;
                if vec[idx] >= v {
                    break;
                }
            }

            for idx in ((row + 1)..n).map(|r| index(r, col, n)) {
                res[1] += 1;
                if vec[idx] >= v {
                    break;
                }
            }

            for idx in (0..col).rev().map(|c| index(row, c, n)) {
                res[2] += 1;
                if vec[idx] >= v {
                    break;
                }
            }

            for idx in ((col + 1)..n).map(|c| index(row, c, n)) {
                res[3] += 1;
                if vec[idx] >= v {
                    break;
                }
            }

            res.into_iter().reduce(|l, r| l * r).unwrap_or_default()
        })
        .max()
        .unwrap_or(0)
}

lazy_static! {
    static ref INPUT_EXAMPLE: Square = input_example();
    static ref INPUT: Square = input();
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
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 8);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 172224);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
