use super::utils;

use std::collections::HashSet;
use std::collections::VecDeque;

use lazy_static::lazy_static;

fn input_example() -> Vec<Vec<char>> {
    parse_input(utils::read_file_in_cwd_by_line("src/day12/example.txt"))
}

fn input() -> Vec<Vec<char>> {
    parse_input(utils::read_file_in_cwd_by_line("src/day12/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Vec<Vec<char>> {
    input.into_iter().filter(|l| !l.is_empty()).map(|l| l.trim().chars().collect()).collect()
}

fn find_chars(input: &Vec<Vec<char>>, ch: char) -> Vec<(usize, usize)> {
    let mut res = vec![];
    for row in 0..input.len() {
        for col in 0..input[0].len() {
            if input[row][col] == ch {
                res.push((row, col));
            }
        }
    }

    res
}

fn find_char(input: &Vec<Vec<char>>, ch: char) -> (usize, usize) {
    let mut r = 0;
    let mut c = 0;
    'outer: for row in 0..input.len() {
        for col in 0..input[0].len() {
            if input[row][col] == ch {
                r = row;
                c = col;
                break 'outer;
            }
        }
    }

    (r, c)
}

fn adj(i: i32, j: i32) -> Vec<(i32, i32)> {
    vec![(i - 1, j), (i + 1, j), (i, j - 1), (i, j + 1)]
}

fn adj_usize(i: usize, j: usize, rows: usize, cols: usize) -> Vec<(usize, usize)> {
    adj(i as i32, j as i32)
        .into_iter()
        .filter(|(r, c)| c >= &0 && r >= &0 && c < &(cols as i32) && r < &(rows as i32))
        .map(|(r, c)| (r as usize, c as usize))
        .collect()
}

fn find_se(input: &Vec<Vec<char>>) -> ((usize, usize), (usize, usize)) {
    (find_char(input, 'S'), find_char(input, 'E'))
}

fn part1(input: Vec<Vec<char>>) -> i64 {
    let (rows, cols) = (input.len(), input[0].len());
    let (start, end) = find_se(&input);

    let mut grid = input;
    let mut visited = HashSet::new();
    let mut q = VecDeque::new();

    grid[start.0][start.1] = 'a';
    grid[end.0][end.1] = 'z';
    q.push_front((start, 0));

    let mut res = 0;
    while !q.is_empty() {
        if let Some(((row, col), dist)) = q.pop_back() {
            if (row, col) == end {
                res = dist;
                break;
            }

            if visited.contains(&(row, col)) {
                continue;
            }

            visited.insert((row, col));

            for (row_a, col_a) in adj_usize(row, col, rows, cols) {
                if grid[row_a][col_a] as i32 - grid[row][col] as i32 > 1 {
                    continue;
                }

                q.push_front(((row_a, col_a), dist + 1));
            }
        }
    }

    res
}

fn part2(input: Vec<Vec<char>>) -> i64 {
    let (rows, cols) = (input.len(), input[0].len());
    let (start, end) = find_se(&input);

    let mut grid = input;
    let mut visited = HashSet::new();
    let mut q = VecDeque::new();

    grid[start.0][start.1] = 'a';
    grid[end.0][end.1] = 'z';

    // push starts
    find_chars(&grid, 'a').into_iter().for_each(|s| q.push_front((s, 0)));

    let mut res = 0;
    while !q.is_empty() {
        if let Some(((row, col), dist)) = q.pop_back() {
            if (row, col) == end {
                res = dist;
                break;
            }

            if visited.contains(&(row, col)) {
                continue;
            }

            visited.insert((row, col));

            for (row_a, col_a) in adj_usize(row, col, rows, cols) {
                if grid[row_a][col_a] as i32 - grid[row][col] as i32 > 1 {
                    continue;
                }

                q.push_front(((row_a, col_a), dist + 1));
            }
        }
    }

    res
}

lazy_static! {
    static ref INPUT_EXAMPLE: Vec<Vec<char>> = input_example();
    static ref INPUT: Vec<Vec<char>> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 31);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 497);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 29);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 492);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
