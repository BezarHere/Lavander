class_name NoiseMap extends OpenSimplexNoise

func Ratio_1D(x : float) -> float: return get_noise_1d(x) / 2.0 + 0.5
func Ratio_2D(x : float, y : float) -> float: return get_noise_2d(x, y) / 2.0 + 0.5
func Ratio_3D(x : float, y : float, z : float) -> float: return get_noise_3d(x, y, z) / 2.0 + 0.5
func Ratio_4D(x : float, y : float, z : float, w : float) -> float: return get_noise_4d(x, y, z, w) / 2.0 + 0.5

func Value_1D(x : float) -> float: return abs(get_noise_1d(x))
func Value_2D(x : float, y : float) -> float: return abs(get_noise_2d(x, y))
func Value_3D(x : float, y : float, z : float) -> float: return abs(get_noise_3d(x, y, z))
func Value_4D(x : float, y : float, z : float, w : float) -> float: return abs(get_noise_4d(x, y, z, w))
