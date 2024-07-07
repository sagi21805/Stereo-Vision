from typing import Any
import numpy as np

class IntegralImage:
    integral_image: np.ndarray[Any, np.dtype[np.uint32]]

    def __new__(
            cls, 
            source_image: np.ndarray[Any, np.dtype[np.uint8]]
    ) -> 'IntegralImage': ...

    def sliding_window_multi_threshold(
            self, 
            window_size: int, 
            thresholds_num: int
    ) -> np.ndarray[np.uint8]: ...

def sliding_window_multi_threshold(
    img: np.ndarray[Any, np.dtype[np.uint8]], 
    window_size: int, 
    thresholds_num: int
) -> np.ndarray[Any, np.dtype[np.uint8]]: ...