# ReadWriteDlm2 
### CSV IO Supporting Decimal Comma, Date, DateTime, Time, Complex and Rational
[![ReadWriteDlm2](http://pkg.julialang.org/badges/ReadWriteDlm2_0.5.svg)](http://pkg.julialang.org/?pkg=ReadWriteDlm2) [![ReadWriteDlm2](http://pkg.julialang.org/badges/ReadWriteDlm2_0.6.svg)](http://pkg.julialang.org/?pkg=ReadWriteDlm2) [![Build Status](https://travis-ci.org/strickek/ReadWriteDlm2.jl.svg?branch=master)](https://travis-ci.org/strickek/ReadWriteDlm2.jl)   [![Build status](https://ci.appveyor.com/api/projects/status/ojv8nnuw63kh9yba/branch/master?svg=true)](https://ci.appveyor.com/project/strickek/readwritedlm2-jl/branch/master)  [![codecov.io](http://codecov.io/github/strickek/ReadWriteDlm2.jl/coverage.svg?branch=master)](http://codecov.io/github/strickek/ReadWriteDlm2.jl?branch=master)

The functions `readdlm2()` and `writedlm2()` of module `ReadWriteDlm2` are similar to `readdlm()` and `writedlm()` of Julia Base.  Differences in usage are: `';'` as default delimiter, `','` as default decimal mark. The basic idea of this package is to support the "decimal comma countries". But, because of the additional parsing capabilities for Date, DateTime, Time, Complex and Rational types, the functions are also useful for others (with `decimal point`).

### Installation
This package is registered and can be installed with:
```
Pkg.add("ReadWriteDlm2")
```

### Basic Example: How To Use `ReadWriteDlm2`

```
julia> using ReadWriteDlm2              # make readdlm2() and writedlm2() available

julia> A = [1 1.2; "text" Date(2017)];  # create test array with: Int, Float64, String and Date type

julia> writedlm2("test.csv", A)         # syntax and arguments like Julia.Base writedlm()

julia> readstring("test.csv")           # show `CSV` file. Please note: decimal mark ',' - delimiter ';'
"1;1,2\ntext;2017-01-01\n"

julia> B = readdlm2("test.csv")         # read `CSV` data: All four types are parsed correctly!
2×2 Array{Any,2}:
 1        1.2
  "text"   2017-01-01
```

## Function `readdlm2()`
Read a matrix from `source`. The `source` can be a text file, stream or byte array. Each line, separated
by `eol` (default is `'\n'`), gives one row. The columns are separated by `';'`, another `delim` can be defined. 

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::Char; options...)
    readdlm2(source, delim::Char, T::Type; options...)
    readdlm2(source, delim::Char, eol::Char; options...)
    readdlm2(source, delim::Char, T::Type, eol::Char; options...)

Pre-processing of `source` with regex substitution changes the decimal marks from `d,d` to `d.d`.
For default `rs` the keyword argument `decimal=','` sets the decimal Char in the `r`-string of `rs`.
When a special regex substitution tuple `rs=(r.., s..)` is defined, the argument `decimal` is not used.
Pre-processing can be switched off with: `rs=()`.

In addition to Base `readdlm()`, strings are also parsed for Dates formats (defaults are ISO) and
Time format `HH:MM[:SS[.s{1,9}]]`. To switch off parsing Dates/Time set: `dfs=\"\", dtfs=\"\"`.
`locale` defines the language of day (`E`, `e`) and month (`U`, `u`) names.

If all data is numeric, the result will be a numeric array. In other cases
a heterogeneous array of numbers, dates and strings is returned. To include parsing for Complex and 
Rational numbers, use `Any` as Type argument. Homogeneous arrays are possible for the types Int, 
Float64, Bool, Complex, Rational, DateTime, Date and Time.

### Documentation For Base `readdlm()`
More information about Base functionality and (keyword) arguments - which are also 
supported by `readdlm2()` - is available in the 
[stable documentation for readdlm()](http://docs.julialang.org/en/stable/stdlib/io-network/?highlight=readdlm#Base.readdlm). 

### Additional Keyword Arguments `readdlm2()`
* `decimal=','`: decimal mark Char used by default `rs`, irrelevant if `rs`-tuple is not the default one
* `rs=(r"(\d),(\d)", s"\1.\2")`: [regular expression](http://docs.julialang.org/en/stable/manual/strings/?highlight=regular%20expressions#regular-expressions) (r, s)-tuple, change d,d to d.d if `decimal=','`
* `dtfs="yyyy-mm-ddTHH:MM:SS"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-parsing) for DateTime parsing, default is ISO
* `dfs="yyyy-mm-dd"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-parsing) for Date parsing, default is ISO
* `locale="english"`: language for parsing dates names, default is english

### Compare Default Functionality `readdlm()` - `readdlm2()`
| Module        | Function               | Delimiter  | Dec.Mark  | Date(Time)   |
|:------------- |:-----------------------|:----------:|:---------:|:-------------|
| Base.DataFmt  | readdlm()              | `' '`      | `'.'`     | n.a.(String) |
| ReadWriteDlm2 | readdlm2()             | `';'`      | `','`     | parse ISO    |

For decimal point: `readdlm2(source, ' ', decimal='.', dfs="", dtfs="")` gives the same result as `readdlm(source)`.

### Example `readdlm2()`
Read the Excel (lang=german) text-file `test_de.csv` and store the array in `data`:
```
data = readdlm2("test_de.csv", dfs="dd.mm.yyyy", dtfs="dd.mm.yyyy HH:MM")
```



## Function `writedlm2()`
Write `A` (a vector, matrix, or an iterable collection of iterable rows) as text to `f` 
(either a filename string or an IO stream). The columns will be separated by `';'`,
another `delim` (Char or String) can be defined.

    writedlm2(f::IO, A; options...)
    writedlm2(f::IO, A, delim; options...)
    writedlm2(f::AbstractString, A; options...)
    writedlm2(f::AbstractString, A, delim; options...)

By default, a pre-processing of floats takes place. Floats are parsed to strings
with decimal mark changed from `'.'` to `','`. With a keyword argument
another decimal mark can be defined. To switch off this pre-processing set: `decimal='.'`.

Base `writedlm()` writes `3000.0` always short as `3e3`. To keep type information
`writedlm2()` writes long like print() by default. Set `write_short=true` to have 
the same behavior as in Base `writedlm()`.

In `writedlm2()` the output format for Date and DateTime data can be defined with format strings.
Defaults are the ISO formats. Day (`E`, `e`) and month (`U`, `u`) names are written in
the `locale` language. For writing Complex numbers the imaginary component suffix can be changed with the
`imsuffix=` keyword argument.

### Documentation For Base `writedlm()`
More information about Base functionality and (keyword-) arguments - which are also 
supported by `writedlm2()` - is available in the 
[stable documentation for writedlm()](http://docs.julialang.org/en/stable/stdlib/io-network/?highlight=writedlm#Base.writedlm).

### Additional Keyword Arguments `writedlm2()`
* `decimal=','`: Character for writing decimal marks, default is a comma
* `write_short=false`: Bool - use print() to write data, set `true` for print_shortest()
* `dtfs="yyyy-mm-ddTHH:MM:SS"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-formatting),  DateTime write format, default is ISO
* `dfs="yyyy-mm-dd"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-formatting), Date write format, default is ISO
* `locale="english"`: language for writing dates names, default is english
* `imsuffix="im"`: Complex - imaginary component suffix `"i"`, `"j"` or `"im"`(=default)

### Compare Default Functionality `writedlm()` - `writedlm2()`
| Module        | Function           | Delimiter | Dec.Mark | Date(Time) | Write Numbers    |
|:------------- |:------------------ |:---------:|:--------:|:---------- |:-----------------| 
| Base.DataFmt  | writedlm()         | `'\t'`    | `'.'`    | ISO-Format | print_shortest() |
| ReadWriteDlm2 | writedlm2()        | `';'`     | `','`    | ISO-Format | like print()     |

For decimal point: `writedlm2(f, A, '\t', decimal='.', write_short=true)`  gives the same result as  `writedlm(f, A)`.

### Example `writedlm2()`
Write Julia `data` to text-file `test_de.csv`, readable by Excel (lang=german):
```
writedlm2("test_de.csv", data, dtfs="dd.mm.yyyy HH:MM", dfs="dd.mm.yyyy")
```
