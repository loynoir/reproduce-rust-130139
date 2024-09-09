pub use bar::Bar;

mod bar {
    pub struct Bar<T>(T);

    impl Bar<i32> {
        pub const unsafe fn from_unchecked(value: i32) -> Self {
            Bar(value)
        }

        pub const fn get(&self) -> i32 {
            self.0
        }
    }
}
