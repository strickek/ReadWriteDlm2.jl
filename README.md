# ReadWriteDlm2
### CSV IO Supports Decimal Comma, Date, DateTime, Time, Complex, Missing and Rational
[![Build Status](https://travis-ci.com/strickek/ReadWriteDlm2.jl.svg?branch=master)](https://travis-ci.com/strickek/ReadWriteDlm2.jl)   [![Build status](https://ci.appveyor.com/api/projects/status/ojv8nnuw63kh9yba/branch/master?svg=true)](https://ci.appveyor.com/project/strickek/readwritedlm2-jl/branch/master)  [![codecov.io](http://codecov.io/github/strickek/ReadWriteDlm2.jl/coverage.svg?branch=master)](http://codecov.io/github/strickek/ReadWriteDlm2.jl?branch=master)

`ReadWriteDlm2` functions `readdlm2()`, `writedlm2()`, `readcsv2()` and `writecsv2()` are similar to those of stdlib.DelimitedFiles, but with additional support for `Dates` formats, `Complex`, `Rational`, `Missing` types and special decimal marks. `ReadWriteDlm2` supports the `Tables.jl` interface.

* For "decimal dot" users the functions `readcsv2()` and `writecsv2()` have the respective defaults: Delimiter is `','` (fixed) and `decimal='.'`.

* The basic idea of `readdlm2()` and `writedlm2()` is to support the [decimal comma countries](https://commons.wikimedia.org/wiki/File:DecimalSeparator.svg?uselang=en#file). These functions use `';'` as default delimiter and `','` as default decimal mark. "Decimal dot" users of these functions need to define `decimal='.'`.

* Alternative package: `CSV` (supports also special decimal marks)

### Installation
This package is registered and can be installed within the [`Pkg` REPL-mode](https://docs.julialang.org/en/latest/stdlib/Pkg/): Type `]` in the REPL and then:
```
pkg> add ReadWriteDlm2
```

### Basic Example([-> more](#more-examples)): How To Use `ReadWriteDlm2`
```
julia> using ReadWriteDlm2, Dates           # activate modules ReadWriteDlm2, Dates

julia> a = ["text" 1.2; Date(2017,1,1) 1];  # create array with: String, Date, Float64 and Int eltype

julia> writedlm2("test.csv", a)             # test.csv(decimal comma): "text;1,2\n2017-01-01;1\n"

julia> readdlm2("test.csv")                 # read `CSV` data: All four eltypes are parsed correctly!
2×2 Array{Any,2}:
 "text"      1.2
 2017-01-01  1

julia> using DataFrames                     # Tables interface: auto Types for DataFrame columns

julia> DataFrame(readdlm2("test.csv", tables=true))
2×2 DataFrame
│ Row │ Column1    │ Column2 │
│     │ Any        │ Real    │
├─────┼────────────┼─────────┤
│ 1   │ text       │ 1.2     │
│ 2   │ 2017-01-01 │ 1       │
```

## Function `readdlm2()`
Read a matrix from `source`. The `source` can be a text file, stream or byte array.
Each line, separated by `eol` (default is `'\n'`), gives one row.
The columns are separated by `';'`, another `delim` can be defined.

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::Char; options...)
    readdlm2(source, delim::Char, T::Type; options...)
    readdlm2(source, delim::Char, eol::Char; options...)
    readdlm2(source, delim::Char, T::Type, eol::Char; options...)

Pre-processing of `source` with regex substitution changes the decimal marks
from `d,d` to `d.d`. For default `rs` the keyword argument `decimal=','` sets
the decimal Char in the `r`-string of `rs`. When a special regex substitution
tuple `rs=(r.., s..)` is defined, the argument `decimal` is not used (
[-> Example](#writedlm2-and-readdlm2-with-special-decimal)). Pre-processing
can be switched off with: `rs=()`.

In addition to stdlib `readdlm()`, data is also parsed for `Dates` formats (ISO),
the`Time` format `HH:MM[:SS[.s{1,9}]]` and for complex and rational numbers.
To deactivate parsing dates/time set: `dfs="", dtfs=""`.
`locale` defines the language of day (`E`, `e`) and month (`U`, `u`) names.

The result will be a (heterogeneous) array of default element type `Any`. If
`header=true` it will be a tuple containing the data array and a vector for
the columnnames. Other (abstract) types for the data array elements could be
defined. If data is empty, a `0×0 Array{T,2}` is returned.

With `tables=true`[, `header=true`] option[s] a `Tables` interface compatible
`MatrixTable` with individual column types is returned, which for example can
be used as argument for `DataFrame()`.

### Additional Keyword Arguments `readdlm2()`
* `decimal=','`: Decimal mark Char used by default `rs`, irrelevant if `rs`-tuple is not the default one
* `rs=(r"(\d),(\d)", s"\1.\2")`: [Regex](https://docs.julialang.org/en/latest/manual/strings/#Regular-Expressions-1) (r,s)-tuple, the default change d,d to d.d if `decimal=','`
* `dtfs="yyyy-mm-ddTHH:MM:SS.s"`: [Format string](https://docs.julialang.org/en/latest/stdlib/Dates/#Dates.DateFormat) for DateTime parsing
* `dfs="yyyy-mm-dd"`: [Format string](https://docs.julialang.org/en/latest/stdlib/Dates/#Dates.DateFormat) for Date parsing
* `locale="english"`: Language for parsing dates names, default is english
* `tables=false`: Return `Tables` interface compatible MatrixTable if `true`
* `dfheader=false`: `dfheader=true` is shortform for `tables=true, header=true`
* `missingstring="na"`: How missing values are represented, default is `"na"`

### Function `readcsv2()`

    readcsv2(source, T::Type=Any; opts...)

Equivalent to `readdlm2()` with delimiter `','` and `decimal='.'`.

### Documentation For Base `readdlm()`
More information about Base functionality and (keyword) arguments - which are also
supported by `readdlm2()` and `readcsv2()` - is available in the [documentation for readdlm()](https://docs.julialang.org/en/latest/stdlib/DelimitedFiles/#DelimitedFiles.readdlm-Tuple{Any,AbstractChar,Type,AbstractChar}).

### Compare Default Functionality `readdlm()` - `readdlm2()` - `readcsv2()`
| Module         | Function                    | Delimiter  | Dec. Mark | Element Type | Ext. Parsing |
|:-------------- |:----------------------------|:----------:|:---------:|:-------------|:-------------|
| DelimitedFiles | `readdlm()`                 | `' '`      | `'.'`     | Float64/Any  | No (String)  |
| ReadWriteDlm2  | `readdlm2()`                | `';'`      | `','`     | Any          | Yes          |
| ReadWriteDlm2  | `readcsv2()`                | `','`      | `'.'`     | Any          | Yes          |
| ReadWriteDlm2  | `readdlm2(opt:tables=true)` | `';'`      | `','`     | Column spec. | Yes, + col T |
| ReadWriteDlm2  | `readcsv2(opt:tables=true)` | `','`      | `'.'`     | Column spec. | Yes, + col T |

## Function `writedlm2()`
Write `A` (a vector, matrix, or an iterable collection of iterable rows, a
`Tables` source) as text to `f` (either a filename or an IO stream). The columns
are separated by `';'`, another `delim` (Char or String) can be defined.

    writedlm2(f, A; options...)
    writedlm2(f, A, delim; options...)

By default, a pre-processing of values takes place. Before writing as strings,
decimal marks are changed from `'.'` to `','`.
With a keyword argument another decimal mark can be defined.
To switch off this pre-processing set: `decimal='.'`.

In `writedlm2()` the output format for `Date` and `DateTime` data can be
defined with format strings. Defaults are the ISO formats. Day (`E`, `e`) and
month (`U`, `u`) names are written in the `locale` language. For writing
`Complex` numbers the imaginary component suffix can be selected with the
`imsuffix=` keyword argument.

### Additional Keyword Arguments `writedlm2()`
* `decimal=','`: Character for writing decimal marks, default is a comma
* `dtfs="yyyy-mm-ddTHH:MM:SS.s"`: [Format string](https://docs.julialang.org/en/latest/stdlib/Dates/#Dates.DateFormat),  DateTime write format
* `dfs="yyyy-mm-dd"`: [Format string](https://docs.julialang.org/en/latest/stdlib/Dates/#Dates.DateFormat), Date write format
* `locale="english"`: Language for writing date names, default is english
* `imsuffix="im"`: Complex - imaginary component suffix `"im"`(=default), `"i"` or `"j"`
* `missingstring="na"`: How missing values are written, default is `"na"`

### Function `writecsv2()`

    writecsv2(f, A; opts...)

Equivalent to `writedlm2()` with fixed delimiter `','` and `decimal='.'`.

### Compare Default Functionality `writedlm()` - `writedlm2()` - `writecsv2()`
| Module          | Function           | Delimiter | Decimal Mark |
|:--------------- |:------------------ |:---------:|:------------:|
| DelimitedFiles  | `writedlm()`       | `'\t'`    | `'.'`        |
| ReadWriteDlm2   | `writedlm2()`      | `';'`     | `','`        |
| ReadWriteDlm2   | `writecsv2()`      | `','`     | `'.'`        |


## More Examples

#### `writecsv2()` And `readcsv2()`
```
julia> using ReadWriteDlm2

julia> a = Any[1 complex(1.5,2.7);1.0 1//3];   # create array with: Int, Complex, Float64 and Rational type

julia> writecsv2("test.csv", a)                # test.csv(decimal dot): "1,1.5+2.7im\n1.0,1//3\n"

julia> readcsv2("test.csv")                    # read CSV data: All four types are parsed correctly!
2×2 Array{Any,2}:
 1    1.5+2.7im
 1.0    1//3
```
#### `writedlm2()` And `readdlm2()` With Special `decimal=`
```
julia> using ReadWriteDlm2

julia> a = Float64[1.1 1.2;2.1 2.2]
2×2 Array{Float64,2}:
 1.1  1.2
 2.1  2.2

julia> writedlm2("test.csv", a; decimal='€')     # '€' is decimal Char in 'test.csv'

julia> readdlm2("test.csv", Float64; decimal='€')      # a) standard: use keyword argument
2×2 Array{Float64,2}:
 1.1  1.2
 2.1  2.2

julia> readdlm2("test.csv", Float64; rs=(r"(\d)€(\d)", s"\1.\2"))    # b) more flexible: rs-Regex-Tupel
2×2 Array{Float64,2}:
 1.1  1.2
 2.1  2.2
```
#### `writedlm2()` And `readdlm2()` With `Union{Missing, Float64}`
```
julia> using ReadWriteDlm2

julia> a = Union{Missing, Float64}[1.1 0/0;missing 2.2;1/0 -1/0]
3×2 Array{Union{Missing, Float64},2}:
   1.1        NaN
    missing     2.2
 Inf         -Inf

julia> writedlm2("test.csv", a; missingstring="???")     # use "???" for missing data

julia> read("test.csv", String)
"1,1;NaN\n???;2,2\nInf;-Inf\n"

julia> readdlm2("test.csv", Union{Missing, Float64}; missingstring="???")
3×2 Array{Union{Missing, Float64},2}:
   1.1        NaN
    missing     2.2
 Inf         -Inf
```
#### `Date` And `DateTime` With `locale="french"`
```
julia> using ReadWriteDlm2, Dates

julia> Dates.LOCALES["french"] = Dates.DateLocale(
           ["janvier", "février", "mars", "avril", "mai", "juin",
               "juillet", "août", "septembre", "octobre", "novembre", "décembre"],
           ["janv", "févr", "mars", "avril", "mai", "juin",
               "juil", "août", "sept", "oct", "nov", "déc"],
           ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"],
           ["lu", "ma", "me", "je", "ve", "sa", "di"],
           );

julia> a = hcat([Date(2017,1,1), DateTime(2017,1,1,5,59,1,898), 1, 1.0, "text"])
5x1 Array{Any,2}:
  2017-01-01
  2017-01-01T05:59:01.898
 1
 1.0
  "text"

julia> writedlm2("test.csv", a; dfs="E, d.U yyyy", dtfs="e, d.u yyyy H:M:S,s", locale="french")

julia> read("test.csv", String)  # to see what have been written in "test.csv" file
"dimanche, 1.janvier 2017\ndi, 1.janv 2017 5:59:1,898\n1\n1,0\ntext\n"

julia> readdlm2("test.csv"; dfs="E, d.U yyyy", dtfs="e, d.u yyyy H:M:S,s", locale="french")
5×1 Array{Any,2}:
  2017-01-01
  2017-01-01T05:59:01.898
 1
 1.0
  "text"
```

#### `Tables`-Interface Example With `DataFrames`
See [-> `DataFrames`](https://github.com/JuliaData/DataFrames.jl) for installation and more information.
```
julia> using ReadWriteDlm2, Dates, DataFrames, Statistics
```
##### Write CSV: `Tables & DataFrames` compared with `Array`
```
julia> a = ["date" "value_1" "value_2";              # Create Array `a`
            Date(2017,1,1) 1.4 2;
            Date(2017,1,2) 1.8 3;
            nothing missing 4]
4×3 Array{Any,2}:
 "date"       "value_1"   "value_2"
 2017-01-01  1.4         2
 2017-01-02  1.8         3
 nothing      missing    4

julia> df = DataFrame(                                # Create DataFrame `df`
    date = [Date(2017,1,1), Date(2017,1,2), nothing],
    value_1 = [1.4, 1.8, missing],
    value_2 = [2, 3, 4]
    )
3×3 DataFrame
│ Row │ date       │ value_1  │ value_2 │
│     │ Union…     │ Float64⍰ │ Int64   │
├─────┼────────────┼──────────┼─────────┤
│ 1   │ 2017-01-01 │ 1.4      │ 2       │
│ 2   │ 2017-01-02 │ 1.8      │ 3       │
│ 3   │            │ missing  │ 4       │

julia> writedlm2("testa_com.csv", a)     # decimal comma: write array a

julia> writedlm2("testdf_com.csv", df)   # decimal comma: write DataFrame df

julia> read("testa_com.csv", String) ==  # decimal comma: a.csv == df.csv
       read("testdf_com.csv", String) ==
       "date;value_1;value_2\n2017-01-01;1,4;2\n2017-01-02;1,8;3\nnothing;na;4\n"
true

julia> writecsv2("testa_dot.csv", a)     # decimal dot: write array a

julia> writecsv2("testdf_dot.csv", df)   # decimal dot: write DataFrame df

julia> read("testa_dot.csv", String) ==  # decimal dot: a.csv == df.csv
       read("testdf_dot.csv", String) ==
       "date,value_1,value_2\n2017-01-01,1.4,2\n2017-01-02,1.8,3\nnothing,na,4\n"
true

```
##### Read CSV: Using `Tables` interface and create a `DataFrame`
```

julia> df2 = DataFrame(readdlm2("testdf_com.csv", header=true, tables=true))
3×3 DataFrame
│ Row │ date       │ value_1  │ value_2 │
│     │ Union…     │ Float64⍰ │ Int64   │
├─────┼────────────┼──────────┼─────────┤
│ 1   │ 2017-01-01 │ 1.4      │ 2       │
│ 2   │ 2017-01-02 │ 1.8      │ 3       │
│ 3   │            │ missing  │ 4       │

julia> mean(skipmissing(df2[!, :value_1]))
1.6

julia> mean(df2[!, :value_2])
3.0
```
