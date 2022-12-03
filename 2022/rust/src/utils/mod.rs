use chrono::Utc;
use futures::future::{join_all, try_join_all, Future};
use std::fs;
use std::{env, path::PathBuf};

fn get_current_working_dir() -> PathBuf {
    return env::current_dir().unwrap();
}

#[allow(dead_code)]
pub fn read_file_in_cwd(file: &str) -> String {
    let file_path = get_current_working_dir().join(file);
    dbg!(file_path.clone());
    return fs::read_to_string(file_path).unwrap();
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
