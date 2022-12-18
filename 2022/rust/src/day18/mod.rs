use super::utils;

extern crate serde;
use itertools::Itertools;
use serde::Serialize;

use lazy_static::lazy_static;

use std::collections::{HashSet, VecDeque};
use std::str::FromStr;

type Cubes = HashSet<Cube>;

#[derive(Clone, Copy, Debug, Serialize, PartialEq, Eq, Hash, PartialOrd, Ord)]
struct Cube {
    x: i32,
    y: i32,
    z: i32,
}

impl Cube {
    fn new(x: i32, y: i32, z: i32) -> Cube {
        Cube { x, y, z }
    }

    fn shift(&self, dx: i32, dy: i32, dz: i32) -> Cube {
        Cube::new(self.x + dx, self.y + dy, self.z + dz)
    }

    fn shift_cube(&self, dc: Cube) -> Cube {
        self.shift(dc.x, dc.y, dc.z)
    }

    fn adj(&self) -> Cubes {
        ORT.clone().into_iter().map(|dc| self.shift_cube(dc)).collect()
    }
}

impl FromStr for Cube {
    type Err = String;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let (x, y, z) = s
            .split(",")
            .collect_tuple::<(_, _, _)>()
            .and_then(|(x_s, y_s, z_s)| {
                let x = x_s.parse::<i32>().ok()?;
                let y = y_s.parse::<i32>().ok()?;
                let z = z_s.parse::<i32>().ok()?;
                Some((x, y, z))
            })
            .ok_or("unable to parse cube")?;
        Ok(Cube::new(x, y, z))
    }
}

struct Envelope3D {
    xmin: i32,
    xmax: i32,
    ymin: i32,
    ymax: i32,
    zmin: i32,
    zmax: i32,
}

impl Envelope3D {
    fn new(x: (i32, i32), y: (i32, i32), z: (i32, i32)) -> Envelope3D {
        Envelope3D {
            xmin: x.0,
            xmax: x.1,
            ymin: y.0,
            ymax: y.1,
            zmin: z.0,
            zmax: z.1,
        }
    }

    fn contains(&self, cube: &Cube) -> bool {
        self.xmin <= cube.x && self.xmax >= cube.x && self.ymin <= cube.y && self.ymax >= cube.y && self.zmin <= cube.z && self.zmax >= cube.z
    }

    fn cube_min(&self) -> Cube {
        Cube::new(self.xmin, self.ymin, self.zmin)
    }
}

fn input_example() -> Cubes {
    parse_input(utils::read_file_in_cwd_by_line("src/day18/example.txt"))
}

fn input() -> Cubes {
    parse_input(utils::read_file_in_cwd_by_line("src/day18/puzzle1.txt"))
}

fn parse_input(input: Vec<String>) -> Cubes {
    input.into_iter().flat_map(|s| s.parse::<Cube>()).unique().collect()
}

fn input_projection_min<FN>(input: &Cubes, f: FN) -> i32
where
    FN: Fn(Cube) -> i32,
{
    input.clone().into_iter().map(f).min().unwrap_or_default()
}

fn input_projection_max<FN>(input: &Cubes, f: FN) -> i32
where
    FN: Fn(Cube) -> i32,
{
    input.clone().into_iter().map(f).max().unwrap_or_default()
}

fn input_projection_min_max<FN>(input: &Cubes, f: FN) -> (i32, i32)
where
    FN: Fn(Cube) -> i32,
{
    (input_projection_min(input, &f) - 1, input_projection_max(input, &f) + 1)
}

fn part1(input: Cubes) -> usize {
    // count all adjacent cubes that are not a part of the original list
    input.clone().into_iter().map(|c| c.adj().into_iter().filter(|c| !input.contains(c)).count()).sum()
}

fn envelope_3d(input: &Cubes) -> Envelope3D {
    Envelope3D::new(
        input_projection_min_max(&input, |c| c.x),
        input_projection_min_max(&input, |c| c.y),
        input_projection_min_max(&input, |c| c.z),
    )
}

fn part2(input: Cubes) -> usize {
    let bbox = envelope_3d(&input);

    let mut q = VecDeque::new();
    let mut visited = HashSet::new();

    let init = bbox.cube_min();

    q.push_back(init);
    visited.insert(init);

    while !q.is_empty() {
        let cube = q.pop_back().unwrap();
        visited.insert(cube);

        // adjacent cubes that are not a part of the list (don't touch) and not visited
        for cube_next in cube.adj().into_iter().filter(|c| !input.contains(c)) {
            // skip visited
            if visited.contains(&cube_next) {
                continue;
            }
            // within the bbox
            if bbox.contains(&cube_next) {
                visited.insert(cube_next);
                q.push_front(cube_next);
            }
        }
    }

    // count adjacent node that are visited
    input.clone().into_iter().map(|c| c.adj().into_iter().filter(|c| visited.contains(c)).count()).sum()
}

lazy_static! {
    static ref ORT: Cubes = [
        Cube::new(1, 0, 0),
        Cube::new(-1, 0, 0),
        Cube::new(0, 1, 0),
        Cube::new(0, -1, 0),
        Cube::new(0, 0, 1),
        Cube::new(0, 0, -1),
    ]
    .into_iter()
    .collect();
    static ref INPUT_EXAMPLE: Cubes = input_example();
    static ref INPUT: Cubes = input();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn q1e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part1(input), 64);
    }

    #[test]
    fn q1() {
        let input = INPUT.to_owned();
        assert_eq!(part1(input), 4300);
    }

    #[test]
    fn q2e() {
        let input = INPUT_EXAMPLE.to_owned();
        assert_eq!(part2(input), 58);
    }

    #[test]
    fn q2() {
        let input = INPUT.to_owned();
        assert_eq!(part2(input), 2490);
    }
}

pub fn run() {
    let input = INPUT.to_owned();

    println!("Part 1: {}", part1(input.clone()));
    println!("Part 2: {}", part2(input.clone()));
}
