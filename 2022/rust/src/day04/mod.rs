use super::utils;
use lazy_static::lazy_static;

type Assignment = (i32, i32);

fn parse_input(input: Vec<String>) -> Vec<(Assignment, Assignment)> {
    fn parse_assignment(str: &str) -> Assignment {
        let mut splitf = str.split("-").into_iter().flat_map(|s| s.parse::<i32>().ok());
        (splitf.next().unwrap(), splitf.next().unwrap())
    }

    input
        .into_iter()
        .map(|line| {
            let mut split = line.split(",");
            let (fst, snd) = (split.next().unwrap(), split.next().unwrap());
            (parse_assignment(fst), parse_assignment(snd))
        })
        .collect()
}

fn input_example() -> Vec<(Assignment, Assignment)> {
    parse_input(utils::read_file_in_cwd_by_line("src/day04/example.txt"))
}

fn input() -> Vec<(Assignment, Assignment)> {
    parse_input(utils::read_file_in_cwd_by_line("src/day04/puzzle1.txt"))
}

fn assignments_contained_tup(tup: &(Assignment, Assignment)) -> i32 {
    assignments_contained(tup.0, tup.1)
}
fn assignments_contained(fst: Assignment, snd: Assignment) -> i32 {
    let (fst_l, fst_r) = fst;
    let (snd_l, snd_r) = snd;

    ((fst_l <= snd_l && fst_r >= snd_r) || (snd_l <= fst_l && snd_r >= fst_r)) as i32
}

fn assignments_intersected_tup(tup: &(Assignment, Assignment)) -> i32 {
    assignments_intersected(tup.0, tup.1)
}
fn assignments_intersected(fst: Assignment, snd: Assignment) -> i32 {
    fn assignments_intersected_sub(fst: Assignment, snd: Assignment) -> bool {
        let (fst_l, fst_r) = fst;
        let (snd_l, snd_r) = snd;

        (fst_l >= snd_l) && (fst_r <= snd_r && fst_r >= snd_l) || (snd_l >= fst_l && snd_l <= fst_r) && (snd_r >= fst_r)
    }

    (assignments_intersected_sub(fst, snd) || assignments_intersected_sub(snd, fst)) as i32
}

fn part1(input: &Vec<(Assignment, Assignment)>) -> i32 {
    input.into_iter().map(assignments_contained_tup).sum()
}

fn part2(input: &Vec<(Assignment, Assignment)>) -> i32 {
    input.into_iter().map(assignments_intersected_tup).sum()
}

lazy_static! {
    static ref INPUT_EXAMPLE: Vec<(Assignment, Assignment)> = input_example();
    static ref INPUT: Vec<(Assignment, Assignment)> = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = &INPUT_EXAMPLE;
        assert_eq!(part1(input), 2);
    }

    #[test]
    fn q1() {
        let input = &INPUT;
        assert_eq!(part1(input), 490);
    }

    #[test]
    fn q2e() {
        let input = &INPUT_EXAMPLE;
        assert_eq!(part2(input), 4);
    }

    #[test]
    fn q2() {
        let input = &INPUT;
        assert_eq!(part2(input), 921);
    }
}

pub fn run() {
    let input = &INPUT;

    println!("Part 1: {}", part1(input));
    println!("Part 2: {}", part2(input));
}
