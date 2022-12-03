mod day03;
mod utils;

fn main() {
    let day: String = std::env::args().nth(1).expect("No day given. Possible options are: 01-25.");
    let day_slice: &str = day.as_str();

    match day_slice {
        "03" => day03::run(),
        _ => println!("No valid day given. Possible options are: 01-25."),
    };
}
