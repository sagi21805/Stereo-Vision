use opencv::{imgproc, prelude::*};
use std::rc::Rc;
pub mod point;

pub fn mat_to_slice<'a>(mat: &Mat) -> Option<Rc<&'a [u8]>> {
    // Check if the Mat is continuous
    if !mat.is_continuous() { return None; }

    let data_ptr = mat.data() as *const u8;
    let total = (mat.total() * mat.elem_size().unwrap()) as usize;
    println!("total size: {}", total);

    Some(unsafe { 
        Rc::new(std::slice::from_raw_parts(data_ptr, total)) 
    })
}


