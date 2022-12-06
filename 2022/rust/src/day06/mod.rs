use super::utils;
use itertools::Itertools;
use lazy_static::lazy_static;
use std::collections::HashSet;

fn input_example() -> String {
    utils::read_file_in_cwd_string("src/day06/example.txt")
}

fn input() -> String {
    utils::read_file_in_cwd_string("src/day06/puzzle1.txt")
}

fn find_marker(message: String, size: usize) -> i32 {
    message
        .chars()
        .collect_vec()
        .windows(size)
        .into_iter()
        .enumerate()
        .find(|(_, tuple)| tuple.to_vec().into_iter().collect::<HashSet<_>>().len() == size)
        .iter()
        .map(|(idx, _)| (idx + size) as i32)
        .next()
        .unwrap_or_default()
}

fn part1(message: String) -> i32 {
    find_marker(message, 4)
}

fn part2(message: String) -> i32 {
    find_marker(message, 14)
}

lazy_static! {
    static ref INPUT_EXAMPLE: String = input_example();
    static ref INPUT: String = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 11);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 1953);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 26);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 2301);
    }
}

pub fn run() {
    let input = INPUT.clone();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
