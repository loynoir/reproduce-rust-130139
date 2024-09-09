pub fn f1() {}

pub fn f2() {}

#[cfg(test)]
mod tests {
    use bar_util::Bar;

    #[test]
    fn should_ok() {
        let x = unsafe { Bar::from_unchecked(42) };

        let _ = x.get();
    }
}
