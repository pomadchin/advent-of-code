pub mod path;

use chrono::Utc;
use futures::future::{join_all, try_join_all, Future};
use std::fs;
use std::{
    env,
    error::Error,
    fs::File,
    io::{prelude::*, BufReader},
    path::PathBuf,
};

pub type Result<T, E = Box<dyn Error + Send + Sync>> = std::result::Result<T, E>;

fn get_current_working_dir() -> PathBuf {
    return env::current_dir().unwrap();
}

#[allow(dead_code)]
pub fn read_file_in_cwd_string(file: &str) -> String {
    let file_path = get_current_working_dir().join(file);
    return fs::read_to_string(file_path).unwrap();
}

#[allow(dead_code)]
pub fn read_file_in_cwd_by_line(file: &str) -> Vec<String> {
    let file_path = get_current_working_dir().join(file);
    let file = File::open(file_path).expect("no such file");
    let buf = BufReader::new(file);
    buf.lines().map(|l| l.expect("Could not parse line")).collect()
}

#[allow(dead_code)]
pub fn instant_now() -> i64 {
    Utc::now().timestamp_millis()
}

#[allow(dead_code)]
pub fn try_traverse<I, T, R, E, F, FN>(xs: I, f: FN) -> impl Future<Output = Result<Vec<R>, E>>
where
    I: IntoIterator<Item = T>,
    F: Future<Output = Result<R, E>>,
    FN: FnMut(T) -> F,
{
    let futures: Vec<F> = xs.into_iter().map(f).collect();
    try_join_all(futures)
}

#[allow(dead_code)]
pub fn traverse<I, T, R, F, FN>(xs: I, f: FN) -> impl Future<Output = Vec<R>>
where
    I: IntoIterator<Item = T>,
    F: Future<Output = R>,
    FN: FnMut(T) -> F,
{
    let futures: Vec<F> = xs.into_iter().map(f).collect();
    join_all(futures)
}

#[allow(dead_code)]
pub fn tupled<F, S, R, FN>(f: FN) -> impl Fn((F, S)) -> R
where
    FN: Fn(F, S) -> R,
{
    move |tup: (F, S)| f(tup.0, tup.1)
}

pub fn parents(dir: PathBuf) -> Vec<PathBuf> {
    let mut dir_p = dir;
    let mut vec = vec![];
    vec.push(dir_p.clone());

    while let Some(parent) = dir_p.parent() {
        let pb = PathBuf::from(parent);
        vec.push(pb.clone());
        dir_p = pb;
    }

    vec
}
