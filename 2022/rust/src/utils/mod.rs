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

pub fn get_current_working_dir() -> PathBuf {
    return env::current_dir().unwrap();
}

pub fn read_file_in_cwd_string(file: &str) -> String {
    let file_path = get_current_working_dir().join(file);
    return fs::read_to_string(file_path).unwrap();
}

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

pub fn index(row: usize, col: usize, n: usize) -> usize {
    row * n + col
}

pub fn col(idx: usize, n: usize) -> usize {
    idx % n
}

pub fn row(idx: usize, n: usize) -> usize {
    idx / n
}

pub fn rc(idx: usize, n: usize) -> (usize, usize) {
    (row(idx, n), col(idx, n))
}

#[allow(dead_code)]
pub fn index_i32(row: i32, col: i32, n: i32) -> i32 {
    row * n + col
}

pub fn col_i32(idx: i32, n: i32) -> i32 {
    idx % n
}

pub fn row_i32(idx: i32, n: i32) -> i32 {
    idx / n
}

#[allow(dead_code)]
pub fn rc_i32(idx: i32, n: i32) -> (i32, i32) {
    (row_i32(idx, n), col_i32(idx, n))
}
