use super::utils;

use itertools::Itertools;
use lazy_static::lazy_static;

use std::cmp::Ordering;
use std::collections::VecDeque;

fn input_example() -> Vec<Vec<String>> {
    parse_input(utils::read_file_in_cwd_string("src/day13/example.txt"))
}

fn input() -> Vec<Vec<String>> {
    parse_input(utils::read_file_in_cwd_string("src/day13/puzzle1.txt"))
}

fn parse_input(input: String) -> Vec<Vec<String>> {
    input.split("\n\n").map(|s| s.lines().map(|s| s.replace("10", "X").to_owned()).collect()).collect()
}

fn prepend(head: &[char], tail: &[char]) -> Vec<char> {
    let mut d = tail.into_iter().map(|c| *c).collect::<VecDeque<_>>();
    head.iter().rev().for_each(|c| d.push_front(*c));
    d.into_iter().collect_vec()
}

fn compare_packets(left_chars: &[char], right_chars: &[char]) -> bool {
    match (left_chars[0], right_chars[0]) {
        (l, r) if l == r => compare_packets(&left_chars[1..], &right_chars[1..]),
        (']', _) => true,
        (_, ']') => false,
        ('[', r) => {
            let v = prepend(&[r, ']'], &right_chars[1..]);
            compare_packets(&left_chars[1..], &v)
        }
        (l, '[') => {
            let v = prepend(&[l, ']'], &left_chars[1..]);
            compare_packets(&v, &right_chars[1..])
        }
        (l, r) => l < r,
    }
}

fn compare_packets_vec(left_chars: Vec<char>, right_chars: Vec<char>) -> bool {
    compare_packets(&left_chars, &right_chars)
}

fn compare_packets_refs(left_chars: &Vec<char>, right_chars: &Vec<char>) -> Ordering {
    match compare_packets_vec(left_chars.clone(), right_chars.clone()) {
        true => Ordering::Less,
        false => Ordering::Greater,
    }
}

fn find_divider(input: &Vec<Vec<char>>, str: &str) -> usize {
    input
        .into_iter()
        .map(|v| v.into_iter().collect::<String>())
        .enumerate()
        .find(|(_, s)| s == str)
        .map(|(idx, _)| idx + 1)
        .unwrap_or_default()
}

fn part1(input: Vec<Vec<String>>) -> usize {
    input
        .into_iter()
        .enumerate()
        .filter(|(_, v)| compare_packets_vec(v[0].chars().collect(), v[1].chars().collect()))
        .map(|(idx, _)| idx + 1)
        .sum()
}

fn part2(input: Vec<Vec<String>>) -> usize {
    let mut input_vec = input.into_iter().flatten().collect_vec();
    input_vec.push("[[2]]".to_owned());
    input_vec.push("[[6]]".to_owned());

    let mut vec_chars = input_vec.clone().into_iter().map(|s| s.chars().collect_vec()).collect_vec();
    vec_chars.sort_by(compare_packets_refs);

    let fst = find_divider(&vec_chars, "[[2]]");
    let snd = find_divider(&vec_chars, "[[6]]");

    fst * snd
}

lazy_static! {
    static ref INPUT_EXAMPLE: Vec<Vec<String>> = input_example();
    static ref INPUT: Vec<Vec<String>> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 13);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 4643);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 140);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 21614);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
