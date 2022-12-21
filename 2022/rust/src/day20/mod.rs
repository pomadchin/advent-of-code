use super::utils;

extern crate serde;

use lazy_static::lazy_static;
use std::collections::VecDeque;

fn input_example() -> VecDeque<(usize, i64)> {
    parse_input(utils::read_file_in_cwd_by_line("src/day20/example.txt"))
}

fn input() -> VecDeque<(usize, i64)> {
    parse_input(utils::read_file_in_cwd_by_line("src/day20/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> VecDeque<(usize, i64)> {
    input.into_iter().flat_map(|s| s.parse::<i64>()).enumerate().collect()
}

// deque in-place rotation
fn rotate<T: Copy>(nums: &mut VecDeque<T>, nr: i64) {
    fn reverse<T: Copy>(nums: &mut VecDeque<T>, start: usize, end: usize) {
        let mut i = start;
        let mut j = end - 1;
        while i < j {
            let tmp = nums[i];
            nums[i] = nums[j];
            nums[j] = tmp;
            i += 1;
            j -= 1;
        }
    }

    let mut n = nr;
    let length = nums.len();

    n = n % length as i64;

    if n == 0 {
        return;
    }

    if n < 0 {
        n = length as i64 + n;
    }

    reverse(nums, 0, n as usize);
    reverse(nums, n as usize, length);
    reverse(nums, 0, length);
}
fn part1(input: VecDeque<(usize, i64)>) -> i64 {
    let mut deque = input;
    let ordering = deque.clone();
    let len = deque.len() as i64;

    // move items around in a deque
    for x @ (id, val) in ordering {
        // find idx to move, where the elem in order is now
        let idx_now = deque
            .clone()
            .into_iter()
            .enumerate()
            .find(|(_, (idx_curr, _))| *idx_curr == id)
            .map(|(i, _)| i)
            .unwrap();
        // rotate deque so idx_now is on of the back of the deque
        deque.rotate_left(idx_now);
        deque.pop_front(); // pop it
                           // rotate list in a such a way that insertion into the top matches to the 'current' position
                           // doing inplace rotation
        rotate(&mut deque, val);
        // could not do a cyclic rotate via inbuilt functions
        // if val > 0 {
        //     deque.rotate_left(val.abs() as usize)
        // } else {
        //     deque.rotate_right(val.abs() as usize)
        // }
        deque.push_front(x);
    }

    let idx_zero = deque.clone().into_iter().enumerate().find(|(_, (_, val))| *val == 0).map(|(i, _)| i).unwrap();
    deque.rotate_left(idx_zero);

    deque[1000 % len as usize].1 + deque[2000 % len as usize].1 + deque[3000 % len as usize].1
}

fn part2(input: VecDeque<(usize, i64)>) -> i64 {
    let mut deque: VecDeque<(usize, i64)> = input.into_iter().map(|(idx, v)| (idx, 811589153 * v)).collect();
    let ordering = deque.clone();
    let len = deque.len() as i64;

    for _ in 0..10 {
        for x @ (id, val) in ordering.clone() {
            // find idx to move, where the elem in order is now
            let idx_now = deque
                .clone()
                .into_iter()
                .enumerate()
                .find(|(_, (idx_curr, _))| *idx_curr == id)
                .map(|(i, _)| i)
                .unwrap();
            // rotate deque so idx_now is on of the back of the deque
            deque.rotate_left(idx_now);
            deque.pop_front(); // pop it
                               // rotate list in a such a way that insertion into the top matches to the 'current' position
            rotate(&mut deque, val);
            deque.push_front(x);
        }
    }

    let idx_zero = deque.clone().into_iter().enumerate().find(|(_, (_, val))| *val == 0).map(|(i, _)| i).unwrap();
    deque.rotate_left(idx_zero);

    deque[1000 % len as usize].1 + deque[2000 % len as usize].1 + deque[3000 % len as usize].1
}

lazy_static! {
    static ref INPUT_EXAMPLE: VecDeque<(usize, i64)> = input_example();
    static ref INPUT: VecDeque<(usize, i64)> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 3);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 10763);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 1623178306);
    }

    #[test]
    #[ignore = "takes > 20s to run"]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 4979911042808);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
