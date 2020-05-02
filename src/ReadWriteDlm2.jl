# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - https://github.com/strickek/ReadWriteDlm2.jl

"""
## ReadWriteDlm2
`ReadWriteDlm2` functions `readdlm2()`, `writedlm2()`, `readcsv2()` and
`writecsv2()` are similar to those of stdlib.DelimitedFiles, but with additional
support for `Date`, `DateTime`, `Time`, `Complex`, `Rational`, `Missing` types
and special decimal marks.

### `readcsv2(), writecsv2()`:
For "decimal dot" users the functions `readcsv2()` and `writecsv2()` have the
respective defaults: Delimiter is `','` (fixed) and `decimal='.'`.

### `readdlm2(), writedlm2()`:
The basic idea of these functions is to support the "decimal comma countries".
They use `';'` as default delimiter and `','` as default decimal mark.
"Decimal dot" users of these functions need to define `decimal='.'`

### Detailed Documentation:
For more information about functionality and (keyword) arguments see `?help` for
`readdlm2()`, `writedlm2()`, `readcsv2()` and `writecsv2()`.
"""
module ReadWriteDlm2

using Dates
using DelimitedFiles
using DelimitedFiles: readdlm_string, val_opts
import Tables

export readdlm2, writedlm2, readcsv2, writecsv2

include("rwd2_dateregex.jl")
include("rwd2_readutils.jl")
include("rwd2_read.jl")
include("rwd2_writeutils.jl")
include("rwd2_write.jl")
include("rwd2_csv.jl")
include("rwd2_tables.jl")

end # End module ReadWriteDlm2
