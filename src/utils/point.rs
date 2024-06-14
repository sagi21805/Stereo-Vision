use num::Num;
use std::ops::{Add, Div, Mul, Sub};
#[derive(Debug, Copy, Clone, PartialEq)]
pub struct Point<T> {
    pub x: T,
    pub y: T,
}

impl<T: Num + Copy> Point<T> {
    pub fn new(x: T, y: T) -> Self {
        Point { x, y }
    }
}

impl<T: Num + Copy> Add for Point<T> {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Point {
            x: self.x + other.x,
            y: self.y + other.y,
        }
    }
}

impl<T: Num + Copy> Sub for Point<T> {
    type Output = Self;

    fn sub(self, other: Self) -> Self {
        Point {
            x: self.x - other.x,
            y: self.y - other.y,
        }
    }
}

impl<T: Num + Copy> Mul<T> for Point<T> {
    type Output = Self;

    fn mul(self, scalar: T) -> Self {
        Point {
            x: self.x * scalar,
            y: self.y * scalar,
        }
    }
}

impl<T: Num + Copy> Div<T> for Point<T> {
    type Output = Self;

    fn div(self, scalar: T) -> Self {
        Point {
            x: self.x / scalar,
            y: self.y / scalar,
        }
    }
}
