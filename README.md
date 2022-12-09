# Advent of Code
[![CI](https://github.com/pomadchin/advent-of-code/actions/workflows/ci.yml/badge.svg)](https://github.com/pomadchin/advent-of-code/actions/workflows/ci.yml)

[Advent of Code](https://adventofcode.com/) written in (hopfully) different languages.

#### Scala 2021

There also exists an alternative [feature/rec-schemes](https://github.com/pomadchin/advent-of-code/tree/feature/rec-schemes) branch to practice [recursion schemes](https://github.com/passy/awesome-recursion-schemes) using [Droste](https://github.com/higherkindness/droste)

#### Encryption

All input files should be encrypted; i.e.:

```bash
$ gpg --passphrase "$GPG_PASSPHRASE_INPUT" --symmetric --cipher-algo AES256 file.txt
```

Decription is done via a GitHub Actions step.
