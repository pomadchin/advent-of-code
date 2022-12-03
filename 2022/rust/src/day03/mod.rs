use super::utils;
use std::collections::HashSet;

const INDEX: &str = ".abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

fn char_to_priority(c: char) -> i32 {
    INDEX.chars().position(|i| i == c).unwrap() as i32
}

fn part1(rucksacks: &Vec<String>) -> i32 {
    rucksacks
        .into_iter()
        .map(|rucksack| {
            let (compartment_1, compartment_2) = rucksack.split_at(rucksack.len() / 2);
            let set1 = compartment_1.chars().collect::<HashSet<_>>();
            let set2 = compartment_2.chars().collect::<HashSet<_>>();

            set1.intersection(&set2).map(|c| char_to_priority(*c)).sum::<i32>()
        })
        .sum()
}

fn part2(rucksacks: &Vec<String>) -> i32 {
    (0..rucksacks.len())
        .step_by(3)
        .map(|group_index| {
            let set1 = rucksacks[group_index].chars().collect::<HashSet<_>>();
            let set2 = rucksacks[group_index + 1].chars().collect::<HashSet<_>>();
            let set3 = rucksacks[group_index + 2].chars().collect::<HashSet<_>>();

            set1.intersection(&set2)
                .map(|c| *c)
                .collect::<HashSet<_>>()
                .intersection(&set3)
                .map(|c| *c)
                .collect::<HashSet<_>>()
                .into_iter()
                .map(|c| char_to_priority(c))
                .sum::<i32>()
        })
        .sum()
}

fn input() -> Vec<String> {
    let input = utils::read_file_in_cwd("src/day03/puzzle1.txt");

    input.split('\n').into_iter().map(|s| s.to_string()).collect::<Vec<_>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1() {
        let input = input();
        assert_eq!(part1(&input), 8109);
    }

    #[test]
    fn q2() {
        let input = input();
        assert_eq!(part2(&input), 2738);
    }
}

pub fn run() {
    let input = input();

    println!("Part 1: {}", part1(&input));
    println!("Part 2: {}", part2(&input));
}
