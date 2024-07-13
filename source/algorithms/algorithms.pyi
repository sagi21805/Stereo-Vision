from typing import Any
import numpy as np

class IntegralImage:

    integral_image: np.ndarray[Any, np.dtype[np.uint32]]
    source_image: np.ndarray[Any, np.dtype[np.uint8]]
    
    def __new__(
            cls, 
            source_image: np.ndarray[Any, np.dtype[np.uint8]]
    ) -> 'IntegralImage': ...

    def sliding_window_multi_threshold(
            self, 
            window_size: int, 
            thresholds_num: int
    ) -> np.ndarray[np.uint8]: ...

    def adaptive_window_threshold(
            self, 
            window_size: int, 
            threshold: int,
    ) -> np.ndarray[Any, np.dtype[np.uint8]]: ...

    def sliding_window_threshold(
        self,
        window_size: int,
        threshold: int
    ) -> np.ndarray[Any, np.dtype[np.uint8]]: ...

    def threshold_integral(
        self, 
        t: float
    ) -> np.ndarray[Any, np.dtype[np.uint8]]: ...

    def adaptive_window_mean_threshold(
        self, 
        window_size: int, 
        threshold_factor: float
    ) -> np.ndarray[Any, np.dtype[np.uint8]]: ...



def sliding_window_multi_threshold(
    img: np.ndarray[Any, np.dtype[np.uint8]], 
    window_size: int, 
    thresholds_num: int
) -> np.ndarray[Any, np.dtype[np.uint8]]: ...