import numpy as np
import array_tricks as tricks

class CamStorge:

    def __init__(self,
                 wpr_padded: int,
                 wpc_padded: int,
                 window_size: int,
                 elements_per_window: int = 4
                 ) -> None:
        
        self.frame = np.empty()
        self.bgra = np.empty()
        self.windowed = np.empty()
        self.bgrabgra = np.empty((wpr_padded * wpc_padded * window_size * window_size, elements_per_window))
        self.bbggrraa = np.empty((wpr_padded * wpc_padded * window_size * window_size * elements_per_window, ))

    
    def window_bgra(self, window_size):
        self.windowed = tricks.window_bgra(
            tricks.pad_array_power_of_2(self.bgra), window_size
        )

    def sort_windowed_bgrabgra(self, window_size, wpr_padded: int, wpc_padded: int):
        self.window_bgra(window_size)
        tricks.sort_windowed_bgrabgra(
            self.windowed, window_size, wpr_padded, wpc_padded, self.bgrabgra
        )

    def sort_windowed_bbggrraa(self):
        tricks.sort_windowed_bbggrraa(
            self.windowed, self.bbggrraa
        )
