use super::utils;

extern crate serde;
use itertools::Itertools;
use serde::Serialize;

use lazy_static::lazy_static;
use std::collections::HashMap;

#[derive(Clone, Debug, Serialize, PartialEq, Eq, Hash)]
enum MonkeyS {
    Number(i64),
    Add(String, String),
    Sub(String, String),
    Mul(String, String),
    Div(String, String),
    Noop,
}

fn input_example() -> HashMap<String, MonkeyS> {
    parse_input(utils::read_file_in_cwd_by_line("src/day21/example.txt"))
}

fn input() -> HashMap<String, MonkeyS> {
    parse_input(utils::read_file_in_cwd_by_line("src/day21/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> HashMap<String, MonkeyS> {
    input
        .into_iter()
        .flat_map(|s| match s.split_whitespace().map(|s| s.to_owned()).collect_vec().as_slice() {
            [name_ref, left_ref, op, right_ref] => {
                let name = name_ref.replace(":", "").to_owned();
                let left = left_ref.to_owned();
                let right = right_ref.to_owned();
                let op = match &op.to_owned()[..] {
                    "+" => MonkeyS::Add(left, right),
                    "-" => MonkeyS::Sub(left, right),
                    "*" => MonkeyS::Mul(left, right),
                    "/" => MonkeyS::Div(left, right),
                    _ => MonkeyS::Noop,
                };
                Some((name.to_owned(), op))
            }
            [name_ref, number] => Some((name_ref.replace(":", "").to_owned(), MonkeyS::Number(number.parse::<i64>().ok()?))),
            _ => None,
        })
        .collect()
}

fn simulate(input: HashMap<String, MonkeyS>) -> HashMap<String, i64> {
    let mut res = HashMap::new();

    fn compute(name: &String, input: &HashMap<String, MonkeyS>, res: &mut HashMap<String, i64>) -> i64 {
        match res.get(name) {
            Some(i) => *i,
            _ => {
                let result = rec(name, input, res);
                res.insert(name.to_owned(), result);
                result
            }
        }
    }

    fn rec(name: &String, input: &HashMap<String, MonkeyS>, res: &mut HashMap<String, i64>) -> i64 {
        match input.get(name) {
            Some(MonkeyS::Number(i)) => *i,
            Some(MonkeyS::Add(left, right)) => compute(left, input, res) + compute(right, input, res),
            Some(MonkeyS::Sub(left, right)) => compute(left, input, res) - compute(right, input, res),
            Some(MonkeyS::Mul(left, right)) => compute(left, input, res) * compute(right, input, res),
            Some(MonkeyS::Div(left, right)) => compute(left, input, res) / compute(right, input, res),
            _ => panic!(),
        }
    }

    compute(&"root".to_owned(), &input, &mut res);
    res
}

fn part1(input: HashMap<String, MonkeyS>) -> i64 {
    match simulate(input).get("root") {
        Some(i) => *i,
        _ => -1,
    }
}

fn part2(input: HashMap<String, MonkeyS>) -> i64 {
    let results = simulate(input.clone());

    fn rec(name: &String, val: i64, input: &HashMap<String, MonkeyS>, results: &HashMap<String, i64>) -> Option<i64> {
        match input.get(name) {
            Some(MonkeyS::Number(_)) if name == "humn" => Some(val),
            // left == right == val
            Some(MonkeyS::Add(left, right)) if name == "root" => rec(left, *results.get(right)?, input, results).or(rec(right, *results.get(left)?, input, results)),
            // left + right = val
            // left = right - val
            // right = val - left
            Some(MonkeyS::Add(left, right)) => rec(right, val - results.get(left)?, input, results).or(rec(left, val - results.get(right)?, input, results)),
            // val = left - right =>
            // val + right = left
            // right = left - val
            Some(MonkeyS::Sub(left, right)) => rec(right, results.get(left)? - val, input, results).or(rec(left, val + results.get(right)?, input, results)),
            // val = left * right
            // val / right = left
            // val / left = right
            Some(MonkeyS::Mul(left, right)) => {
                let l = if *results.get(left)? != 0 {
                    rec(right, val / results.get(left)?, input, results)
                } else {
                    None
                };

                let r = if *results.get(right)? != 0 {
                    rec(left, val / results.get(right)?, input, results)
                } else {
                    None
                };

                l.or(r)
            }
            // val = left / right
            // right = left / val
            // left = val * right
            Some(MonkeyS::Div(left, right)) => {
                let l = if val != 0 { rec(right, results.get(left)? / val, input, results) } else { None };
                let r = rec(left, results.get(right)? * val, input, results);
                l.or(r)
            }
            _ => None,
        }
    }

    rec(&"root".to_owned(), -1, &input, &results).unwrap_or_default()
}

lazy_static! {
    static ref INPUT_EXAMPLE: HashMap<String, MonkeyS> = input_example();
    static ref INPUT: HashMap<String, MonkeyS> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 152);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 170237589447588);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 301);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 3712643961892);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
