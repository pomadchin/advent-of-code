use super::utils;

use lazy_static::lazy_static;
use path_clean::PathClean;
use std::collections::HashMap;
use std::path::PathBuf;

fn input_example() -> HashMap<PathBuf, u32> {
    parse_input(utils::read_file_in_cwd_by_line("src/day07/example.txt"))
}

fn input() -> HashMap<PathBuf, u32> {
    parse_input(utils::read_file_in_cwd_by_line("src/day07/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> HashMap<PathBuf, u32> {
    let mut cwd = PathBuf::from("/");
    let mut dirs: HashMap<PathBuf, u32> = HashMap::new();

    input.iter().for_each(|line| match line.split(" ").collect::<Vec<_>>().as_slice() {
        ["$", "cd", newdir] => cwd = cwd.join(newdir).clean(),
        [size_str, _] => size_str.parse::<u32>().ok().into_iter().for_each(|size| {
            for path in utils::parents(cwd.clone()) {
                *dirs.entry(path.clone()).or_insert(0) += size
            }
        }),
        _ => (),
    });

    dirs
}

fn part1(dirs: HashMap<PathBuf, u32>) -> u32 {
    // directories with a total size of at most 100000
    dirs.values().cloned().filter(|x| *x < 100000).sum()
}

fn part2(dirs: HashMap<PathBuf, u32>) -> u32 {
    let root = PathBuf::from("/");
    // Find the smallest directory that, if deleted, would free up enough space (70000000 - 30000000) on the filesystem to run the update
    // Idea: delete this file from the system and see if we have enough space
    dirs.values()
        .cloned()
        .filter(|x| dirs.get(&root).unwrap() - *x <= 70000000 - 30000000)
        .min()
        .unwrap_or(0)
}

lazy_static! {
    static ref INPUT_EXAMPLE: HashMap<PathBuf, u32> = input_example();
    static ref INPUT: HashMap<PathBuf, u32> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 95437);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 1454188);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 24933642);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 4183246);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
