
using ClimateModels, PyCall, Conda

"""
    demo_seaduck()

Example copied from [seaduck documentation](https://macekuailv.github.io/seaduck/one_min_guide.html)

```
using ClimateModels, PyCall, Conda
include("examples/seaduck.jl")
demo_seaduck()
"""
demo_seaduck() = begin
  ClimateModels.conda(:seaduck)
  sd=ClimateModels.pyimport(:seaduck)

  ds = sd.utils.get_dataset("ecco")

  longitude = -11.0
  latitude = 71.0
  depth = -5.0
  time = sd.utils.convert_time("1992-02")

  time = sd.utils.convert_time("1992-02")
  s = sd.OceInterp(ds, "SALT", longitude, latitude, depth, time)
end

