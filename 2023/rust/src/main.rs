mod utils;

mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod day06;
mod day07;
mod day08;
mod day09;
mod day10;
mod day11;
mod day12;
mod day13;
mod day14;
mod day15;
mod day16;
mod day17;
mod day18;
mod day19;
mod day20;
mod day21;
mod day22;
mod day23;
mod day24;
mod day25;

fn main() {
    let day: String = std::env::args().nth(1).expect("No day given. Possible options are: 01-25.");
    let day_slice: &str = day.as_str();

    match day_slice {
        "01" => day01::run(),
        "02" => day02::run(),
        "03" => day03::run(),
        "04" => day04::run(),
        "05" => day05::run(),
        "06" => day06::run(),
        "07" => day07::run(),
        "08" => day08::run(),
        "09" => day09::run(),
        "10" => day10::run(),
        "11" => day11::run(),
        "12" => day12::run(),
        "13" => day13::run(),
        "14" => day14::run(),
        "15" => day15::run(),
        "16" => day16::run(),
        "17" => day17::run(),
        "18" => day18::run(),
        "19" => day19::run(),
        "20" => day20::run(),
        "21" => day21::run(),
        "22" => day22::run(),
        "23" => day23::run(),
        "24" => day24::run(),
        "25" => day25::run(),
        _ => println!("No valid day given. Possible options are: 01-25."),
    }
}
