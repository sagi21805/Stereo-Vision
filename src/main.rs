#[macro_use]
mod utils;
mod camera;
mod stereo;
use camera::Camera;
use opencv::core::MatTrait;
use utils::camera::{CamParameters, CamSettings};
use utils::{mat_to_slice, save_frame};
use std::thread;
use std::time::{Instant, Duration};
use stereo::Stereo;
use arrayfire::{self as af};
// fn main() {

//     let settings = CamSettings::default();
//     let params = CamParameters::empty();
             
//     let mut camera = Camera::new(
//         0, 
//         &settings, 
//         &params
//     );

//     save_frame("frame", &camera.frame);

//     let array = af::Array::new(
//         mat_to_slice(&camera.frame).unwrap(), 
//         af::dim4!(1280, 800)
//     );


//     benchmark();
// }


extern crate arrayfire;

use arrayfire::{Dim4, Array, randu, matmul, device_info, set_backend, get_device, sync, Backend};

fn benchmark_matmul(backend: Backend, dim: u64) -> std::time::Duration {
    set_backend(backend);
    let dims = Dim4::new(&[dim, dim, 1, 1]);
    let a = randu::<f32>(dims);
    let b = randu::<f32>(dims);
    sync(get_device()); // Ensure all operations are complete
    
    let start = Instant::now();
    let _c = matmul(&a, &b, arrayfire::MatProp::NONE, arrayfire::MatProp::NONE);
    sync(get_device()); // Ensure all operations are complete
    start.elapsed()
}

fn main() {
    // Benchmark settings
    let dim = 1024; // Example dimension size


    // GPU Benchmark
    let gpu_time = benchmark_matmul(Backend::OPENCL, dim);
    println!("GPU time: {:?}", gpu_time);

    // CPU Benchmark
    let cpu_time = benchmark_matmul(Backend::CPU, dim);
    println!("CPU time: {:?}", cpu_time);
}

