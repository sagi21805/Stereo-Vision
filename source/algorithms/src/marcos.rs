#[macro_export]
macro_rules! time_function {
    ($func:expr) => {{
        let start = std::time::Instant::now();
        let result = $func;
        let duration = start.elapsed();
        (result, duration)
    }};
}
