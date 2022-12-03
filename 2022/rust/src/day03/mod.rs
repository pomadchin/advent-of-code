use super::utils;
use std::collections::HashSet;

const INDEX: &str = ".abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

fn char_to_priority(c: char) -> i32 {
    INDEX.chars().position(|i| i == c).unwrap() as i32
}

fn input() -> Vec<String> {
    utils::read_file_in_cwd("src/day03/puzzle1.txt")
        .split('\n')
        .into_iter()
        .map(|s| s.to_string())
        .collect()
}

fn part1(rucksacks: &Vec<String>) -> i32 {
    rucksacks
        .into_iter()
        .map(|rucksack| {
            let (compartment_1, compartment_2) = rucksack.split_at(rucksack.len() / 2);
            let set1: HashSet<char> = compartment_1.chars().collect();
            let set2: HashSet<char> = compartment_2.chars().collect();

            set1.intersection(&set2).cloned().map(char_to_priority).sum::<i32>()
        })
        .sum()
}

fn part2(rucksacks: &Vec<String>) -> i32 {
    (0..rucksacks.len())
        .step_by(3)
        .map(|group_index| {
            let set1: HashSet<char> = rucksacks[group_index].chars().collect();
            let set2: HashSet<char> = rucksacks[group_index + 1].chars().collect();
            let set3: HashSet<char> = rucksacks[group_index + 2].chars().collect();

            set1.intersection(&set2)
                .cloned()
                .collect::<HashSet<_>>()
                .intersection(&set3)
                .cloned()
                .collect::<HashSet<_>>()
                .into_iter()
                .map(char_to_priority)
                .sum::<i32>()
        })
        .sum()
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
