use super::utils;
use itertools::Itertools;
use lazy_static::lazy_static;
use std::collections::VecDeque;

#[derive(Debug)]
struct Op {
    n: i32,
    from: usize,
    to: usize,
}

type Input = (Vec<Vec<char>>, Vec<Op>);

fn parse_input(input: Vec<String>) -> Input {
    let idx = input.iter().position(|s| s.is_empty()).unwrap_or(0);
    let (stacks_str, ops_str) = input.split_at(idx);
    let stacks_len_max = stacks_str.len() - 1; // the last string is for count
    let stacks_count = stacks_str
        .last()
        .unwrap()
        .trim()
        .split("   ")
        .map(|i| i.parse::<usize>().unwrap())
        .last()
        .unwrap_or(0);

    let mut stacks: Vec<Vec<char>> = vec![vec![]; stacks_count];
    for i in stacks_str[0..stacks_len_max].iter() {
        for j in 0..stacks_count {
            if let Some(x) = i.chars().nth(1 + j * 4) {
                if x.is_whitespace() {
                    continue;
                }

                stacks[j].push(x);
            }
        }
    }

    // reverse stacks
    let stacks_rev = stacks.into_iter().map(|vec| vec.into_iter().rev().collect_vec()).collect_vec();

    let ops = ops_str
        .iter()
        .filter(|s| !s.is_empty())
        .map(|val| {
            let op_str = val.split(" ").collect_vec();
            let n = op_str[1].parse::<i32>().unwrap();
            let from = op_str[3].parse::<usize>().unwrap() - 1;
            let to = op_str[5].parse::<usize>().unwrap() - 1;
            Op { n, from, to }
        })
        .collect_vec();

    (stacks_rev, ops)
}

fn input_example() -> Input {
    parse_input(utils::read_file_in_cwd_by_line("src/day05/example.txt"))
}

fn input() -> Input {
    parse_input(utils::read_file_in_cwd_by_line("src/day05/puzzle1.txt"))
}

fn simulate(stacks_input: Vec<Vec<char>>, ops: &Vec<Op>, grouped: bool) -> String {
    let mut stacks = stacks_input;

    // simulate
    for op in ops {
        // could be just a stack, in case it is not grouped - reverse
        // let mut group: Vec<char> = vec![];
        let mut group: VecDeque<char> = VecDeque::new();
        for _ in 0..op.n {
            let c = stacks[op.from].pop().unwrap();
            // group.push(c);
            if grouped {
                group.push_front(c);
            } else {
                group.push_back(c);
            }
        }
        // group.reverse();

        group.into_iter().for_each(|c| stacks[op.to].push(c))
        // stacks[op.to].append(&mut group); // if group is a deque - to iter and collect into vec
    }

    // build a string
    stacks.into_iter().fold("".to_owned(), |mut acc, mut st| {
        acc.push(st.pop().unwrap());
        acc
    })
}

fn part1_tup(input: &Input) -> String {
    let (stacks_input, ops) = input;
    part1(stacks_input.clone(), &ops)
}

fn part1(stacks_input: Vec<Vec<char>>, ops: &Vec<Op>) -> String {
    simulate(stacks_input, ops, false)
}

fn part2_tup(input: &Input) -> String {
    let (stacks_input, ops) = input;
    part2(stacks_input.clone(), &ops)
}
fn part2(stacks_input: Vec<Vec<char>>, ops: &Vec<Op>) -> String {
    simulate(stacks_input, ops, true)
}

lazy_static! {
    static ref INPUT_EXAMPLE: Input = input_example();
    static ref INPUT: Input = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = &INPUT_EXAMPLE;
        assert_eq!(part1_tup(input), "CMZ".to_owned());
    }

    #[test]
    fn q1() {
        let input = &INPUT;
        assert_eq!(part1_tup(input), "WCZTHTMPS".to_owned());
    }

    #[test]
    fn q2e() {
        let input = &INPUT_EXAMPLE;
        assert_eq!(part2_tup(input), "MCD".to_owned());
    }

    #[test]
    fn q2() {
        let input = &INPUT;
        assert_eq!(part2_tup(input), "BLSGJSDTS".to_owned());
    }
}

pub fn run() {
    let input = &INPUT;

    println!("Part 1: {}", part1_tup(input));
    println!("Part 2: {}", part2_tup(input));
}
