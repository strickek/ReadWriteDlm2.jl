# ReadWriteDlm2 - Read And Write Decimal Comma "CSV"
Tested for Julia 0.5 and 0.6 and nightly. Click the status images for details:

Linux, Mac OS X: [![Build Status](https://travis-ci.org/strickek/ReadWriteDlm2.jl.svg?branch=master)](https://travis-ci.org/strickek/ReadWriteDlm2.jl)    Windows 32, 64: [![Build status](https://ci.appveyor.com/api/projects/status/ojv8nnuw63kh9yba/branch/master?svg=true)](https://ci.appveyor.com/project/strickek/readwritedlm2-jl/branch/master)    Code coverage: [![codecov.io](http://codecov.io/github/strickek/ReadWriteDlm2.jl/coverage.svg?branch=master)](http://codecov.io/github/strickek/ReadWriteDlm2.jl?branch=master)

The functions `readdlm2()` and `writedlm2()` of modul `ReadWriteDlm2` are similar to `readdlm()` and `writedlm()` of Julia Base.  Differences in usage are: `';'` as default delimiter, `','` as default decimal mark and the support of Date/DateTime types. The basic idea of this package is to support the "decimal comma countries" - highlited in green in the following map:

<p><a href="https://commons.wikimedia.org/wiki/File:DecimalSeparator.svg#/media/File:DecimalSeparator.svg"><img src="https://upload.wikimedia.org/wikipedia/commons/a/a8/DecimalSeparator.svg" alt="DecimalSeparator.svg" height="325" width="640"></a><br>Map provided by <a href="//commons.wikimedia.org/wiki/User:NuclearVacuum" title="User:NuclearVacuum">NuclearVacuum</a> - <a href="//commons.wikimedia.org/wiki/File:BlankMap-World6.svg" title="File:BlankMap-World6.svg">File:BlankMap-World6.svg</a>
, <a href="http://creativecommons.org/licenses/by-sa/3.0" title="Creative Commons Attribution-Share Alike 3.0">CC BY-SA 3.0</a>, <a href="https://commons.wikimedia.org/w/index.php?curid=10843055">Link</a></p>

## Installation

This package is unregistered and therfore must be installed using Pkg.clone

    Pkg.clone("https://github.com/strickek/ReadWriteDlm2.jl")
    
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
Read a matrix from the source. The `source` can be a text file, stream or byte array.
Each line (separated by `eol`) gives one row, with elements separated by the given `delim`.  

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::Char; options...)
    readdlm2(source, delim::Char, T::Type; options...)
    readdlm2(source, delim::Char, eol::Char; options...)
    readdlm2(source, delim::Char, T::Type, eol::Char; options...)

The columns are expected to be separated by `';'`, another `delim` can be defined. 

By default, a pre-processing of input with regex substitution takes place, which
changes the decimal mark from `d,d` to `d.d`. With the keyword argument `decimal=','`
the regex Char used by the default regex/substitution Tupel can be changed. With `rs=(.., ..)`
a special regex/substitution Tupel can be defined (in this case `decimal` is not used).
Regex substitution pre-processing can be switched off with: `rs=()`.

End of line `eol` is `'\n'` by default. In addition
to Base `readdlm()`, strings are also parsed for ISO Date and DateTime formats
by default. To switch off parsing Dates formats set: `dfs="", dtfs=""`.

If all data is numeric, the result will be a numeric array. In other cases
a heterogeneous array of numbers, dates and strings is returned.

### Documentation For Base `readdlm()`
More information about Base functionality and (keyword) arguments - which are also 
supported by `readdlm2()` - is available in the 
[stable documentation for readdlm()](http://docs.julialang.org/en/stable/stdlib/io-network/?highlight=readdlm#Base.readdlm). 

### Additional Keyword Arguments `readdlm2()`
* `decimal=','`: decimal mark Char used by default `rs`, irrelevant if `rs`-Tupel is not the default one
* `rs=(r"(\d),(\d)", s"\1.\2")`: [regular expression](http://docs.julialang.org/en/stable/manual/strings/?highlight=regular%20expressions#regular-expressions) (r, s)-Tupel, change d,d to d.d if `decimal=','`
* `dfs="yyyy-mm-dd"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-parsing) for Date parsing, default is ISO
* `dtfs="yyyy-mm-ddTHH:MM:SS"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-parsing) for DateTime parsing, default is ISO

### Compare Default Functionality `readdlm()` - `readdlm2()`
| Module        | Function               | Delimiter| Dec.Mark | Date(Time)   |
|:------------- |:---------------------- |:--------:|:--------:|:------------ |
| Base.DataFmt  | readdlm()              |`' '`     |`'.'`     | n.a.(String) |
| ReadWriteDlm2 | readdlm2()             |`';'`     |`','`     | parse ISO    |

`readdlm2(source, ' ', decimal='.', dfs="", dtfs="")` gives the same result as `readdlm(source)`.

### Example `readdlm2()`
Read the Excel(lang=german) text-file `test_de.csv` and store the array in `data`:
```
data = readdlm2("test_de.csv", dfs="dd.mm.yyyy", dtfs="dd.mm.yyyy HH:MM")
```



## Function `writedlm2()`
Write A (a vector, matrix, or an iterable collection of iterable rows) as text to f 
(either a filename string or an IO stream). 

    writedlm2(f::IO, A; options...)
    writedlm2(f::IO, A, delim; options...)
    writedlm2(f::AbstractString, A; options...)
    writedlm2(f::AbstractString, A, delim; options...)
    
The columns will be separated by `';'`, another `delim` (Char or String) can be defined.

By default, a pre-processing of floats takes place. Floats are parsed to strings
with decimal mark changed from `'.'` to `','`. With a keyword argument
another decimal mark can be defined. To switch off this pre-processing set: `decimal='.'`.

Like in `writedlm()` of Base, `writedlm2()` writes `3000.0` by default short as `3e3`. To write 
numbers in the normal print() format set keyword argument: `write_short=false`.

In `writedlm2()` the output format for Date and DateTime data can be defined with format strings.
Defaults are the ISO formats.

### Documentation For Base `writedlm()`
More information about Base functionality and (keyword-) arguments - which are also 
supported by `writedlm2()` - is available in the 
[stable documentation for writedlm()](http://docs.julialang.org/en/stable/stdlib/io-network/?highlight=writedlm#Base.writedlm).

### Additional Keyword Arguments `writedlm2()`
* `decimal=','`: decimal mark character, default is a comma
* `write_short=true`: Bool - use print_shortest() to write data
* `dfs="yyyy-mm-dd"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-formatting), Date write format, default is ISO
* `dtfs="yyyy-mm-ddTHH:MM:SS"`: [format string](http://docs.julialang.org/en/stable/stdlib/dates/#man-date-formatting),  DateTime write format, default is ISO

### Compare Default Functionality `writedlm()` - `writedlm2()`
| Module        | Function           | Delimiter| Dec.Mark | Date(Time) |
|:------------- |:------------------ |:--------:|:--------:|:---------- |
| Base.DataFmt  | writedlm()         |`'\t'`    |`'.'`     | ISO-Format |
| ReadWriteDlm2 | writedlm2()        |`';'`     |`','`     | ISO-Format |

`writedlm2(f, A, '\t', decimal='.')`  gives the same result as  `writedlm(f, A)`.

### Example `writedlm2()`
Write Julia `data` to text-file `test_de.csv`, readable by Excel(lang=german):
```
writedlm2("test_de.csv", data, dtfs="dd.mm.yyyy HH:MM", dfs="dd.mm.yyyy")
```
