use super::utils;

extern crate serde;
use itertools::Itertools;

use lazy_static::lazy_static;
use std::collections::HashMap;

fn input_example() -> Vec<Vec<(usize, char)>> {
    parse_input(utils::read_file_in_cwd_by_line("src/day25/example.txt"))
}

fn input() -> Vec<Vec<(usize, char)>> {
    parse_input(utils::read_file_in_cwd_by_line("src/day25/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Vec<Vec<(usize, char)>> {
    input.into_iter().map(|num| num.trim().chars().rev().enumerate().collect_vec()).collect_vec()
}

fn part1(input: Vec<Vec<(usize, char)>>) -> String {
    let mut sum = 0i64;
    for num in input {
        for (i, d) in num {
            sum = sum + TO_DIGITS.get(&d).unwrap() * i64::pow(5, i as u32);
        }
    }

    let mut res = vec![];
    while sum > 0 {
        let (s, mut d) = (sum / 5, sum % 5);
        sum = s;
        if d > 2 {
            d = d - 5;
            sum = sum + 1;
        }

        let conv = &FROM_DIGITS;
        res.push(conv.get(&d).unwrap())
    }

    res.into_iter().rev().collect()
}

lazy_static! {
    static ref TO_DIGITS: HashMap<char, i64> = [('2', 2), ('1', 1), ('0', 0), ('-', -1), ('=', -2)].into_iter().collect();
    static ref FROM_DIGITS: HashMap<i64, char> = TO_DIGITS.clone().into_iter().map(|(k, v)| (v, k)).collect();
    static ref INPUT_EXAMPLE: Vec<Vec<(usize, char)>> = input_example();
    static ref INPUT: Vec<Vec<(usize, char)>> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), "2=-1=0");
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), "2-2--02=1---1200=0-1");
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input));
}
