# ReadWriteDlm2 - Read And Write Decimal Comma "CSV"
Tested for release(Julia 0.5) and nightly(allow failures). Click the status images for detail:

Linux, Mac OS X: [![Build Status](https://travis-ci.org/strickek/ReadWriteDlm2.jl.svg?branch=master)](https://travis-ci.org/strickek/ReadWriteDlm2.jl)    Windows 32, 64: [![Build status](https://ci.appveyor.com/api/projects/status/h0ikgidytp48w5kk/branch/master?svg=true)](https://ci.appveyor.com/project/strickek/readwritedlm2-jl-drp7c/branch/master)    Code coverage: [![codecov.io](http://codecov.io/github/strickek/ReadWriteDlm2.jl/coverage.svg?branch=master)](http://codecov.io/github/strickek/ReadWriteDlm2.jl?branch=master)

The functions `readdlm2()` and `writedlm2()` of modul `ReadWriteDlm2` are similar to readdlm() and writedlm() of Julia.Base.  Differences are: `';'` as default delimiter, `','` as default decimal mark and the support of Date/DateTime types. 

## Installation

This package is unregistered and so must be installed using Pkg.clone

    Pkg.clone("https://github.com/strickek/ReadWriteDlm2.jl")
    
## Basic Example: How To Use `ReadWriteDlm2`

```
julia> using ReadWriteDlm2              # make readdlm2() and writedlm2() available

julia> A = [1 1.2; "text" Date(2017)];  # create test array with: Int, Float64, String and Date type

julia> writedlm2("test.csv", A)         # syntax and arguments like Julia.Base writedlm()

julia> readstring("test.csv")           # show `CSV` file. Please note: decimal mark ',' - delimiter ';'
"1;1,2\ntext;2017-01-01\n"

julia> B = readdlm2("test.csv")         # read `CSV` data: All four types are parsed correct!
2×2 Array{Any,2}:
 1        1.2
  "text"   2017-01-01
```

## New Function `readdlm2()`

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::Char; options...)
    readdlm2(source, delim::Char, T::Type; options...)
    readdlm2(source, delim::Char, eol::Char; options...)
    readdlm2(source, delim::Char, T::Type, eol::Char; options...)

By default a preprocessing of input with regex substitution takes place, which
changes the decimal mark from `d,d` to `d.d`. With the keyword argument `rs=( , )`
another regular expression Tupel can be defined. Regex substitution preprocessing
can be switched off with: `rs=()`.

The columns are expected to be separated by `';'`, another `delim`
can be defined. End of line `eol` is `'\n'` by default. In addition
to Base readdlm(), strings are also parsed for ISO Date and DateTime formats
by default. To switch off Dates parsing set: `dfs="", dtfs=""`.

If all data is numeric, the result will be a numeric array. In other cases
a heterogeneous array of numbers, dates and strings is returned.

### Documentation For Base.readdlm() 
More information about Base functionality and (keyword) arguments - which are also 
supported by `readdlm2()` - is available in the 
[stable documentation for readdlm()](http://docs.julialang.org/en/stable/stdlib/io-network/?highlight=readdlm#Base.readdlm). 

### Additional Keyword Arguments `readdlm2()`
* `rs=(r"(\d),(\d)", s"\1.\2")`: [regular expression](http://docs.julialang.org/en/stable/manual/strings/?highlight=regular%20expressions#regular-expressions) (r, s)-Tupel, default for d.d -> d,d
* `dfs="yyyy-mm-dd"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-parsing) for Date parsing, default is ISO
* `dtfs="yyyy-mm-ddTHH:MM:SS"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-parsing) for DateTime parsing, default is ISO

### Compare Default Functionality readdlm() With `readdlm2()`
| Module        | Function With Arguments              | Delimiter| Dec.Mark | Date(Time)   |
|:------------- |:------------------------------------ |:--------:|:--------:|:------------ |
| Base.DataFmt  | readdlm()                            |`' '`     |`'.'`     | n.a.(String) |
| ReadWriteDlm2 | readdlm2()                           |`';'`     |`','`     | parse ISO    |

### Example `readdlm2()`
Read the Excel(lang=german) text-file `test_de.csv` and store the array in `data`:

    data = readdlm2("test_de.csv", dfs="dd.mm.yyyy", dtfs="dd.mm.yyyy HH:MM")



## New Function `writedlm2()`

    writedlm2(f::IO, A; options...)
    writedlm2(f::IO, A, delim; options...)
    writedlm2(filename::AbstractString, A; options...)
    writedlm2(filename::AbstractString, A, delim; options...)

By default a preprocessing of floats takes place, which are parsed to strings
with decimal mark changed from `'.'` to `','`. With an keyword argument
an other decimal mark can be defined, to switch off preprocessing set this to `decimal='.'`.
By default `3000.0` is written as `3e3` - same as Base readdlm() does -
to write like normal print set keyword argument `write_short=false`.


The columns will be separated by `';'`, an other `delim` (Char or String)
can be defined. In addition to Base writedlm() function the output format for
Date and DateTime data can be defined with format strings. Default are
the ISO formats.

### Documentation For Base.writedlm()
More information about Base functionality and (keyword-) arguments - which are also 
supported by `writedlm2()` - is available in the 
[stable documentation for writedlm()](http://docs.julialang.org/en/stable/stdlib/io-network/?highlight=writedlm#Base.writedlm).

### Additional Keyword Arguments `writedlm2()`
* `decimal=','`: decimal mark character, default is a comma
* `write_short=true`: Bool - use print_shortest() to write data
* `dfs="yyyy-mm-dd"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-formatting), defines how to write Date, default is ISO
* `dtfs="yyyy-mm-ddTHH:MM:SS"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-formatting), defines how to write DateTime, default is ISO

### Compare Default Functionality writedlm() With `writedlm2()`
| Module        | Function With Arguments          | Delimiter| Dec.Mark | Date(Time) |
|:------------- |:-------------------------------- |:--------:|:--------:|:---------- |
| Base.DataFmt  | writedlm()                       |`'\t'`    |`'.'`     | ISO-Format |
| ReadWriteDlm2 | writedlm2()                      |`';'`     |`','`     | ISO-Format |

### Example `writedlm2()`
Write Julia `data` to text-file `test_de.csv`, readable by Excel(lang=german):

    writedlm2("test_de.csv", data, dtfs="dd.mm.yyyy HH:MM", dfs="dd.mm.yyyy")
    
