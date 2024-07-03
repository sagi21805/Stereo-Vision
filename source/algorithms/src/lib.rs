#[macro_use]
mod marcos;
mod simd;


pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use std::time::Duration;

    use crate::simd::*;


    #[test]
    fn it_works() {

    
        let a= [20u8; 200000];
        let b = [20u8; 200000];
        let mut c = [0u16; 200000];


        let (_, duration) = time_function!(add_slices_u8_u8_u16(&a, &b, &mut c));

        println!("Time taken: {:?}", duration);

    // Optionally, use the result of the timed function
        // println!("Result of my_function: {:?}", c);

        
    }
}
    
