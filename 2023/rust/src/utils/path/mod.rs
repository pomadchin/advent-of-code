use itertools::Itertools;

pub type PathStr = String;
pub type PathVec = Vec<String>;

pub fn path_vec_clean(vec: PathVec) -> PathVec {
    let mut vec_mut = vec;
    match vec_mut.last() {
        Some(str) => {
            if str.to_owned() == ".." {
                vec_mut.pop();
                vec_mut.pop();
            }
            vec_mut
        }
        _ => vec_mut,
    }
}

pub fn parents(dir: PathVec) -> Vec<PathStr> {
    let mut dir_p = dir;
    let mut vec = vec![];
    vec.push(dir_p.clone());

    while let Some(_) = dir_p.pop() {
        vec.push(dir_p.clone());
    }

    let mut res = vec.into_iter().map(|v| v.join("/")).collect_vec();
    res.pop();
    res
}

#[allow(dead_code)]
pub fn path_to_string(vec: PathVec) -> String {
    vec.join("/")
}

#[allow(dead_code)]
pub fn string_to_path(vec: PathStr) -> Vec<String> {
    vec.split("/").map(|s| s.to_owned()).collect_vec()
}
