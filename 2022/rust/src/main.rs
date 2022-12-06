mod utils;

mod day03;
mod day04;
mod day05;
mod day06;

fn main() {
    let day: String = std::env::args().nth(1).expect("No day given. Possible options are: 01-25.");
    let day_slice: &str = day.as_str();

    match day_slice {
        "03" => day03::run(),
        "04" => day04::run(),
        "05" => day05::run(),
        "06" => day06::run(),
        _ => println!("No valid day given. Possible options are: 01-25."),
    };
}
