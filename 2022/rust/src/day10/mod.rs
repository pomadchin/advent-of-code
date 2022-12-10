use super::utils;

extern crate serde;
use serde::Serialize;

use lazy_static::lazy_static;

use std::num::ParseIntError;
use std::str::FromStr;

// display size is 6 x 40
const ROWS: usize = 6;
const COLS: usize = 40;

#[derive(Clone, Copy, Debug, Serialize)]
enum Expr {
    Addx(i32),
    Noop,
}

impl FromStr for Expr {
    type Err = ParseIntError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s.split_once(" ") {
            Some(("addx", num)) => Expr::Addx(num.parse::<i32>()?),
            _ => Expr::Noop,
        })
    }
}

#[derive(Clone, Debug, Serialize)]
struct State {
    x: i32,
    ticks: i32,
    signal: i32,
    display: Vec<String>,
}

impl State {
    fn addx(&mut self, x: i32) {
        self.x += x;
    }

    fn tick(&mut self) {
        // part 2
        let cols = COLS as i32;
        let col = utils::col_i32(self.ticks, cols);
        let row = utils::row_i32(self.ticks, cols) as usize;
        if row < ROWS {
            // the sprite is 3 pixels wide, col is the middle
            // if we're in 3 pixels bounds within x register print #
            // if the sprite is positioned such that one of its three pixels is the pixel currently being drawn
            if (self.x - 1 <= col) && (col <= self.x + 1) {
                self.display[row].push('#');
            } else {
                self.display[row].push('.');
            }
        }

        // part 1
        self.ticks += 1;
        if [20, 60, 100, 140, 180, 220].contains(&self.ticks) {
            self.signal += self.x * self.ticks;
        };
    }

    #[allow(dead_code)]
    fn print_display(&self) {
        println!("{}", self.render_display());
    }

    fn render_display(&self) -> String {
        self.display.clone().join("\n")
    }
}

fn input_example() -> Vec<Expr> {
    parse_input(utils::read_file_in_cwd_by_line("src/day10/example1.txt"))
}

fn input() -> Vec<Expr> {
    parse_input(utils::read_file_in_cwd_by_line("src/day10/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Vec<Expr> {
    input.into_iter().flat_map(|line| line.parse::<Expr>()).collect()
}

fn emulate(input: Vec<Expr>) -> State {
    let mut state = State {
        x: 1,
        ticks: 0,
        signal: 0,
        display: vec!["".to_owned(); ROWS],
    };

    for expr in input {
        match expr {
            Expr::Addx(x) => {
                state.tick();
                state.tick();
                state.addx(x)
            }
            Expr::Noop => {
                state.tick();
            }
        };
    }

    state
}

fn part1(input: Vec<Expr>) -> i32 {
    emulate(input).signal
}

fn part2(input: Vec<Expr>) -> String {
    emulate(input).render_display()
}

lazy_static! {
    static ref INPUT_EXAMPLE: Vec<Expr> = input_example();
    static ref INPUT: Vec<Expr> = input();
}

#[cfg(test)]
mod tests {
    use super::*;
    use indoc::indoc;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 13140);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 17180);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        let expected = indoc! {"
            ##..##..##..##..##..##..##..##..##..##..
            ###...###...###...###...###...###...###.
            ####....####....####....####....####....
            #####.....#####.....#####.....#####.....
            ######......######......######......####
            #######.......#######.......#######....."}
        .to_owned();

        assert_eq!(part2(input), expected);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        // REHPRLUB
        let expected = indoc! {"
            ###..####.#..#.###..###..#....#..#.###..
            #..#.#....#..#.#..#.#..#.#....#..#.#..#.
            #..#.###..####.#..#.#..#.#....#..#.###..
            ###..#....#..#.###..###..#....#..#.#..#.
            #.#..#....#..#.#....#.#..#....#..#.#..#.
            #..#.####.#..#.#....#..#.####..##..###.."}
        .to_owned();

        assert_eq!(part2(input), expected);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: \n {}", part2(input.clone()));
}
