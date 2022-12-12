use super::utils;

extern crate serde;
use itertools::Itertools;
use serde::Serialize;

use lazy_static::lazy_static;
use substring::Substring;
use tuples::*;

use std::collections::HashMap;
use std::num::ParseIntError;
use std::str::FromStr;

#[derive(Clone, Copy, Debug, Serialize)]
enum OpExpr {
    Mul(i64),
    Add(i64),
    Square,
    Id,
}

impl OpExpr {
    fn eval(&self, x: i64) -> i64 {
        match *self {
            OpExpr::Mul(v) => x * v,
            OpExpr::Add(v) => x + v,
            OpExpr::Square => x * x,
            OpExpr::Id => x,
        }
    }
}

impl FromStr for OpExpr {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s.trim().split_once(" ") {
            Some(("+", num)) => OpExpr::Add(num.parse::<i64>()?),
            Some(("*", num)) => {
                if num == "old" {
                    OpExpr::Square
                } else {
                    OpExpr::Mul(num.parse::<i64>()?)
                }
            }
            _ => OpExpr::Id,
        })
    }
}

type Monkeys = Vec<Monkey>;

#[derive(Clone, Debug, Serialize)]
struct Monkey {
    items: Vec<i64>,
    op: OpExpr,
    test_n: i64,
    true_throw: usize,
    false_throw: usize,
}

impl Monkey {
    // return a monkey to throw this item into
    fn test(&self, x: i64) -> usize {
        if (x % self.test_n) == 0 {
            self.true_throw
        } else {
            self.false_throw
        }
    }
}

impl FromStr for Monkey {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (_, line1, line2, line3, line4, line5) = s.lines().collect_vec().collect_tuple::<tuple![6;]>();

        let items = line1.substring(18, line1.len()).split(",").flat_map(|s| s.trim().parse::<i64>()).collect_vec();
        let op = line2.substring(23, line2.len()).parse::<OpExpr>()?;
        let test_n = line3.substring(21, line3.len()).parse::<i64>()?;
        let true_throw = line4.substring(29, line4.len()).parse::<usize>()?;
        let false_throw = line5.substring(30, line5.len()).parse::<usize>()?;

        Ok(Monkey {
            items,
            op,
            test_n,
            true_throw,
            false_throw,
        })
    }
}

fn input_example() -> Monkeys {
    parse_input(utils::read_file_in_cwd_string("src/day11/example.txt"))
}

fn input() -> Monkeys {
    parse_input(utils::read_file_in_cwd_string("src/day11/puzzle1.txt"))
}

fn parse_input(input: String) -> Monkeys {
    input.split("\n\n").flat_map(|s| s.parse::<Monkey>()).collect()
}

fn simulate<F: Fn(i64) -> i64>(input: Monkeys, iterations: usize, shrink_i64: F) -> i64 {
    let mut input_mut = input;
    let mut monkeys = input_mut.iter_mut().collect_vec();
    let mut counts: HashMap<usize, i64> = HashMap::new();
    let monkeys_count = monkeys.len();

    for _ in 0..iterations {
        for from in 0..monkeys_count {
            while let Some(old) = monkeys[from].items.pop() {
                // monkey did processing
                counts.insert(from, counts.get(&from).unwrap_or(&0) + 1);

                // new stress level
                let new = shrink_i64(monkeys[from].op.eval(old));
                let to = monkeys[from].test(new);

                // pass item to a new monkey
                monkeys[to].items.push(new);
            }
        }
    }

    let mut res = counts.values().collect_vec();
    res.sort_by(|a, b| b.cmp(a));

    res[0] * res[1]
}

fn part1(input: Monkeys) -> i64 {
    simulate(input, 20, |v| v / 3)
}

fn part2(input: Monkeys) -> i64 {
    let mod_product: i64 = input.clone().into_iter().map(|m| m.test_n).product();
    simulate(input, 10000, |v| v % mod_product)
}

lazy_static! {
    static ref INPUT_EXAMPLE: Monkeys = input_example();
    static ref INPUT: Monkeys = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 10605);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 107822);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 2713310158);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 27267163742);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: \n {}", part2(input.clone()));
}
