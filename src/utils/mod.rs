use opencv::{imgproc, prelude::*};
use std::rc::Rc;
pub mod point;

pub fn mat_to_slice(mat: &Mat) -> Result<Rc<&[u8]>, &str> {
    // Check if the Mat is continuous
    if !mat.is_continuous() {
        return Err("Mat isn't continuous, can't turn into a slice");
    }

    let data_ptr = mat.data() as *const u8;
    let total = (mat.total() * mat.elem_size().unwrap()) as usize;
    println!("total size: {}", total);

    Ok(unsafe { 
        Rc::new(std::slice::from_raw_parts(data_ptr, total)) 
    })
}


