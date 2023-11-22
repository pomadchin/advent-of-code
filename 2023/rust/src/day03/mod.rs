use super::utils;
use lazy_static::lazy_static;

type Input = Vec<String>;

fn parse_input(input: Vec<String>) -> Input {
    input
}

fn input_example() -> Input {
    // parse_input(utils::read_file_in_cwd_by_line("src/day03/example.txt"));
    vec![]
}

fn input() -> Input {
    // parse_input(utils::read_file_in_cwd_by_line("src/day03/puzzle1.txt"));
    vec![]
}

fn part1(rucksacks: &Vec<String>) -> bool {
    true
}

fn part2(rucksacks: &Vec<String>) -> bool {
    true
}

lazy_static! {
    static ref INPUT: Vec<String> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1() {
        let input = &INPUT;
        assert_eq!(part1(input), true);
    }

    #[test]
    fn q2() {
        let input = &INPUT;
        assert_eq!(part2(input), true);
    }
}

pub fn run() {
    let input = &INPUT;

    println!("Part 1: {}", part1(input));
    println!("Part 2: {}", part2(input));
}
