# Stricker Klaus 2019 - License is MIT: http://julialang.org/license
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

export readdlm2, writedlm2, readcsv2, writecsv2


# readdlm2() and readcsv2()
# =========================

"""

    dfregex(df::AbstractString, locale::AbstractString=\"english\")

Create a regex string `r\"^...\$\"` for the given `Date` or `DateTime`
`format`string `df`.

The regex groups are named according to the `format`string codes. `locale` is
used to calculate min and max length of month and day names (for codes: UuEe).
"""
function dfregex(df::AbstractString, locale::AbstractString="english")
    # calculate min and max string lengths of months and day_of_weeks names
    Ule = try extrema([length(Dates.monthname(i;locale=locale)) for i in 1:12])catch; (3, 9) end
    ule = try extrema([length(Dates.monthabbr(i;locale=locale)) for i in 1:12])catch; (3, 3) end
    Ele = try extrema([length(Dates.dayname(i;locale=locale)) for i in 1:7])catch; (6, 9) end
    ele = try extrema([length(Dates.dayabbr(i;locale=locale)) for i in 1:7])catch; (3, 3) end

    codechars = 'y', 'Y', 'm', 'u', 'e', 'U', 'E', 'd', 'H', 'M', 'S', 's', 'Z', 'z', '\\'
    r = "^ *"; repeat_count = 1; ldf = length(df); dotsec = false
    for i = 1:ldf
        repeat_next = ((i < ldf) && (df[(i + 1)] == df[i])) ? true : false
        ((df[i] == '.') && (i < ldf) && (df[(i + 1)] == 's')) && (dotsec = true)
        repeat_count = (((i > 2) && (df[(i - 2)] != '\\') && (df[(i - 1)] == df[i])) ||
                        ((i == 2) && (df[1] == df[2]))) ? (repeat_count + 1) : 1
        r = r * (
        ((i > 1) && (df[(i - 1)] == '\\')) ? string(df[i]) :
        ((df[i] == 'y') && (repeat_count < 5) && !repeat_next) ? "(?<y>\\d{1,4})" :
        ((df[i] == 'y') && (repeat_count > 4) && !repeat_next) ? "(?<y>\\d{1,$repeat_count})" :
        ((df[i] == 'Y') && (repeat_count < 5) && !repeat_next) ? "(?<y>\\d{1,4})" :
        ((df[i] == 'Y') && (repeat_count > 4) && !repeat_next) ? "(?<y>\\d{1,$repeat_count})" :
        ((df[i] == 'm') && (repeat_count == 1) && !repeat_next) ? "(?<m>0?[1-9]|1[012])" :
        ((df[i] == 'm') && (repeat_count == 2) && !repeat_next) ? "(?<m>0[1-9]|1[012])" :
        ((df[i] == 'm') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<m>0[1-9]|1[012])" :
        ((df[i] == 'u') && (repeat_count == 1)) ? "(?<u>[A-Za-z\u00C0-\u017F]{$(ule[1]),$(ule[2])})" :
        ((df[i] == 'U') && (repeat_count == 1)) ? "(?<U>[A-Za-z\u00C0-\u017F]{$(Ule[1]),$(Ule[2])})" :
        ((df[i] == 'e') && (repeat_count == 1)) ? "(?<e>[A-Za-z\u00C0-\u017F]{$(ele[1]),$(ele[2])})" :
        ((df[i] == 'E') && (repeat_count == 1)) ? "(?<E>[A-Za-z\u00C0-\u017F]{$(Ele[1]),$(Ele[2])})" :
        ((df[i] == 'd') && (repeat_count == 1) && !repeat_next) ? "(?<d>0?[1-9]|[12]\\d|3[01])" :
        ((df[i] == 'd') && (repeat_count == 2) && !repeat_next) ? "(?<d>0[1-9]|[12]\\d|3[01])" :
        ((df[i] == 'd') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<d>0[1-9]|[12]\\d|3[01])" :
        ((df[i] == 'H') && (repeat_count == 1) && !repeat_next) ? "(?<H>0?\\d|1\\d|2[0-3])" :
        ((df[i] == 'H') && (repeat_count == 2) && !repeat_next) ? "(?<H>0\\d|1\\d|2[0-3])" :
        ((df[i] == 'H') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<H>0\\d|1\\d|2[0-3])" :
        ((df[i] == 'M') && (repeat_count == 1) && !repeat_next) ? "(?<M>\\d|[0-5]\\d)" :
        ((df[i] == 'M') && (repeat_count == 2) && !repeat_next) ? "(?<M>[0-5]\\d)" :
        ((df[i] == 'M') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<M>[0-5]\\d)" :
        ((df[i] == 'S') && (repeat_count == 1) && !repeat_next) ? "(?<S>\\d|[0-5]\\d)" :
        ((df[i] == 'S') && (repeat_count == 2) && !repeat_next) ? "(?<S>[0-5]\\d)" :
        ((df[i] == 'S') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<S>[0-5]\\d)" :
        ((df[i] == '.') && dotsec) ? "" :
        ((df[i] == '.')) ? "\\." :
        ((df[i] == 's') && (dotsec == true) && (repeat_count < 4) && !repeat_next) ? "(\\.(?<s>\\d{0,3}0{0,6}))?" :
        ((df[i] == 's') && (dotsec == true) && (repeat_count > 3) && !repeat_next) ? "(\\.(?<s>\\d{$(repeat_count)}))?" :
        ((df[i] == 's') && (dotsec == false) && (repeat_count < 4) && !repeat_next) ? "(?<s>\\d{3})?" :
        ((df[i] == 's') && (dotsec == false) && (repeat_count > 3) && !repeat_next) ? "(?<s>\\d{$(repeat_count)})?" :
        ((df[i] == 'z') && !repeat_next) ? "(?<z>[\\+|\\-]?(0\\d|1\\d|2[0-3]):?[0-5]\\d)" :
        ((df[i] == 'Z') && !repeat_next) ? "(?<Z>[A-Z]{3,14})" :
        in(df[i], codechars) ? "" : string(df[i])
        )
    end
    return Regex(r * " *" * string('$'))
end

"""

    parseothers(y::AbstractString, doparsetime::Bool, doparsecomplex::Bool, doparserational::Bool)

Parse string `y` for `Time`, `Complex` and `Rational` format and if match return the value.
Otherwise return the input string `y`.
"""
function parseothers(y, doparsetime, doparsecomplex, doparserational)

    if doparsetime # parse Time
        mt = match(r"^ *(0?\d|1\d|2[0-3])[:Hh]([0-5]?\d)(:([0-5]?\d)([\.,](\d{1,3})(\d{1,3})?(\d{1,3})?)?)? *$", y)
        if mt != nothing
            h = parse(Int, mt[1])
            mi = parse(Int, mt[2])
            (mt[4] == nothing) ? s = ms = us = ns = 0 :
            s  = parse(Int, lpad(string(mt[4]), 2, string(0))); (mt[6] == nothing) ? ms = us = ns = 0 :
            ms = parse(Int, rpad(string(mt[6]), 3, string(0))); (mt[7] == nothing) ? us = ns = 0 :
            us = parse(Int, rpad(string(mt[7]), 3, string(0))); (mt[8] == nothing) ? ns = 0 :
            ns = parse(Int, rpad(string(mt[8]), 3, string(0)))
            return Dates.Time(h, mi, s, ms, us, ns)
        end
    end

    if doparsecomplex # parse Complex
        mc = match(r"^ *(-?\d+(\.\d+)?([eE]-?\d+)?|(-?\d+)//(\d+)) ?([\+-]) ?(\d+(\.\d+)?([eE]-?\d+)?|(\d+)//(\d+))(\*im|\*i|\*j|im|i|j) *$", y)
        if mc != nothing
            real =
                ((mc[4] != nothing) && (mc[5] != nothing)) ? //(parse(Int, mc[4]), parse(Int, mc[5])) :
                ((mc[2] == nothing) && (mc[3] == nothing)) ? parse(Int, mc[1]) : parse(Float64, mc[1])
            imag =
                ((mc[10] != nothing) && (mc[11] != nothing)) ? //(parse(Int, mc[6]*mc[10]), parse(Int, mc[11])) :
                ((mc[8] == nothing) && (mc[9] == nothing)) ? parse(Int, mc[6]*mc[7]) : parse(Float64, mc[6]*mc[7])
            return complex(real, imag)
        end
    end

    if doparserational # parse Rational
        mr = match(r"^ *(-?\d+)//(-?\d+) *$", y)
        if mr != nothing
            nu = parse(Int, mr[1])
            de = parse(Int, mr[2])
            return //(nu, de)
        end
    end

    return y
end

"""

    readcsv2(source, T::Type=Any; opts...)

Equivalent to `readdlm2()` with delimiter `','` and `decimal='.'`. Default Type
`Any` activates parsing of `Bool`, `Int`, `Float64`, `Complex`, `Rational`,
`Missing`, `DateTime`, `Date` and `Time`.

# Code Example
```jldoctest
julia> using ReadWriteDlm2

julia> B = Any[1 complex(1.5,2.7);1.0 1//3];

julia> writecsv2("test.csv", B)

julia> readcsv2("test.csv")
2×2 Array{Any,2}:
 1    1.5+2.7im
 1.0    1//3
```
"""
readcsv2(input; opts...) =
    readdlm2auto(input, ',', Any, '\n', false; decimal='.', opts...)

readcsv2(input, T::Type; opts...) =
    readdlm2auto(input, ',', T, '\n', false; decimal='.', opts...)

"""

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::AbstractChar; options...)
    readdlm2(source, delim::AbstractChar, T::Type; options...)
    readdlm2(source, delim::AbstractChar, eol::AbstractChar; options...)
    readdlm2(source, delim::AbstractChar, T::Type, eol::AbstractChar; options...)

Read a matrix from `source`. The `source` can be a text file, stream or byte
array. Each line (separated by `eol`, this is `'\\n'` by default) gives one row.
The columns are separated by `';'`, another `delim` can be defined.

Pre-processing of `source` with regex substitution changes the decimal marks
from `d,d` to `d.d`. For default `rs` the keyword argument `decimal=','` sets
the decimal Char in the `r`-string of `rs`. When a special regex substitution
tuple `rs=(r.., s..)` is defined, the argument `decimal` is not used.
Pre-processing can be switched off with: `rs=()`.

In addition to stdlib readdlm(), data is also parsed for `Dates` formats,
the `Time` format `\"HH:MM[:SS[.s{1,9}]]\"` and for complex and rational numbers.
To deactivate parsing dates/time set: `dfs=\"\", dtfs=\"\"`.
`locale` defines the language of day (`E`, `e`) and month (`U`, `u`) names.

The result will be a (heterogeneous) array of default type `Any`.
Other (abstract) types for the array elements could be defined.
If data is empty, a `0×0 Array{T,2}` is returned.
If `dfheader=true` instead of `header=true` is used, the returned tuple
(data::Array{T,2}, header::Array{Symbol,1}) fits for `DataFrames`.

# Additional Keyword Arguments

* `decimal=','`: Decimal mark Char used by default `rs`, irrelevant if `rs`-tuple is not the default one
* `rs=(r\"(\\d),(\\d)\", s\"\\1.\\2\")`: Regex (r,s)-tuple, the default change d,d to d.d if `decimal=','`
* `dtfs=\"yyyy-mm-ddTHH:MM:SS.s\"`: Format string for DateTime parsing
* `dfs=\"yyyy-mm-dd\"`: Format string for Date parsing
* `locale=\"english\"`: Language for parsing dates names
* `dfheader=false`: Return header in DataFrames format if `true`
* `missingstring=\"na\"`: How missing values are represented

Find more information about `readdlm()` functionality and (keyword) arguments -
 which are also supported by `readdlm2()` - in `help` for `readdlm()`.

# Code Example
```jldoctest
julia> using ReadWriteDlm2

julia> A = Any[1 1.2; "text" missing];

julia> writedlm2("test.csv", A)

julia> readdlm2("test.csv")
2×2 Array{Any,2}:
 1        1.2
  "text"   missing
```
"""
readdlm2(input; opts...) =
    readdlm2auto(input, ';', Any, '\n', true; opts...)

readdlm2(input, T::Type; opts...) =
    readdlm2auto(input, ';', T, '\n', false; opts...)

readdlm2(input, dlm::AbstractChar; opts...) =
    readdlm2auto(input, dlm, Any, '\n', true; opts...)

readdlm2(input, dlm::AbstractChar, T::Type; opts...) =
    readdlm2auto(input, dlm, T, '\n', false; opts...)

readdlm2(input, dlm::AbstractChar, eol::AbstractChar; opts...) =
    readdlm2auto(input, dlm, Any, eol, true; opts...)

readdlm2(input, dlm::AbstractChar, T::Type, eol::AbstractChar; opts...) =
    readdlm2auto(input, dlm, T, eol, false; opts...)

function readdlm2auto(input, dlm, T, eol, auto;
        decimal::AbstractChar=',',
        rs::Tuple=(r"(\d),(\d)", s"\1.\2"),
        dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS.s",
        dfs::AbstractString="yyyy-mm-dd",
        locale::AbstractString="english",
        dfheader::Bool=false,
        missingstring::AbstractString="na",
        opts...)

    if dfheader == true
        opts = [opts...]
        push!(opts, :header => true)
    end

    ((!isempty(dtfs) && !occursin(Regex("[^YymdHMSs]"), dtfs)) ||
    (!isempty(dfs) && !occursin(Regex("[^YymdHMSs]"), dfs))) && info(
        """
        Format string for DateTime(`$dtfs`) or Date(`$dfs`)
        contains numeric code elements only. At least one non-numeric
        code element or character is needed for parsing dates.
        """)

    # "parsing-logic" - defaults
    doparsedatetime = !isempty(dtfs)
    doparsedate = !isempty(dfs)
    doparsetime = false
    doparsecomplex = true
    doparserational = true
    doparsemissing = false
    doparsenothing = false
    convertarray = true
    T2 = Any

    # "parsing-logic" for different T::Types
    ((typeintersect(DateTime, T)) == Union{}) && (doparsedatetime = false)
    ((typeintersect(Date, T)) == Union{}) && (doparsedate = false)
    doparsetime = ((doparsedatetime && doparsedate) || ((Time <: T) && !(Any <:T)))
    T <: Union{AbstractFloat, AbstractString, Char} && (T2 = T; convertarray = false)
    ((typeintersect(Complex, T)) == Union{}) && (doparsecomplex = false)
    ((typeintersect(Rational, T)) == Union{}) && (doparserational = false)
    Missing <: T && (doparsemissing = true)
    Nothing <: T && (doparsenothing = true)
    (Any <: T) && (convertarray = false)


    s = read(input, String)

    # empty input data - return empty array
    if (isempty(s) || (s == string(eol)))
        return Array{T2}(undef, 0, 0)
    end

    if (!isempty(rs) && (decimal != '.')) # do pre-processing of decimal mark

        # adopt dfs if decimal between two digits of formatstring
        if (rs == (r"(\d),(\d)", s"\1.\2")) && doparsedate
            drs = (Regex("([YymdHM])$decimal([YymdHM])"), s"\1.\2")
            dfs = replace(dfs, drs[1] => drs[2])
        end

        # adopt dtfs if decimal between two digits of formatstring
        if (rs == (r"(\d),(\d)", s"\1.\2")) && doparsedatetime
            drs = (Regex("([YymdHMSs])$decimal([YymdHMSs])"), s"\1.\2")
            dtfs = replace(dtfs, drs[1] => drs[2])
        end

        # Change default regex substitution Tuple if decimal != ','
        if ((rs == (r"(\d),(\d)", s"\1.\2")) && (decimal != ','))
            rs = (Regex("(\\d)$decimal(\\d)"), s"\1.\2")
        end

        # Error if decimal mark to replace is also the delim Char
        "1"*string(dlm)*"1" != replace("1"*string(dlm)*"1", rs[1] => rs[2]) &&
        error(
            """
            Error: Decimal mark to replace is also the delim Char.
            Pre-processing with decimal mark Regex substitution for
            `$(dlm)` (= delim!!) is not allowed - change rs/decimal or delim!
            """)

        # Regex substitution decimal
        s = replace(s, rs[1] => rs[2])

    end

    # Using stdlib DelimitedFiles internal function to read dlm-string
    z = readdlm_string(s, dlm, T2, eol, auto, val_opts(opts))

    if isa(z, Tuple)
         y, h = z
         if dfheader == true # format header to DataFrames format
             h = Symbol.(reshape(h, :))
             z = (y, h)
         end
    else
         y = z
    end

    # Formats, Regex for Date/DateTime parsing
    doparsedatetime && (dtdf = DateFormat(dtfs, locale); rdt = dfregex(dtfs, locale))
    doparsedate && (ddf = DateFormat(dfs, locale); rd = dfregex(dfs, locale))

    for i in eachindex(y)
        if isa(y[i], AbstractString)
            if doparsedatetime && occursin(rdt, y[i]) # parse DateTime
                try y[i] = DateTime(y[i], dtdf) catch; end
            elseif doparsedate && occursin(rd, y[i]) # parse Date
                try y[i] = Date(y[i], ddf) catch; end
            elseif doparsemissing && y[i] == missingstring # parse Missing
                try y[i] = missing catch; end
            elseif doparsenothing && y[i] == "nothing" # parse Nothing
                try y[i] = nothing catch; end
            else # parse Time, Complex and Rational
                try y[i] = parseothers(y[i], doparsetime, doparsecomplex, doparserational) catch; end
            end
        end
    end

    if convertarray
        isa(z, Tuple) ? z = (convert(Array{T}, y), h) : z = convert(Array{T}, z)
    end

    return z

end # End function readdlm2auto()


# writedlm2() and writecsv2()
# ===========================

"""

    floatformat(a, decimal::AbstractChar)

Convert Int or Float64 numbers to String and change decimal mark.
"""
function floatformat(a, decimal)
    a = string(a)
    (decimal != '.') && (a = replace(a, '.' => decimal))
    return a
end

"""

    timeformat(a, decimal::AbstractChar)

Convert Time to String, optional with change of decimal mark for secounds.
"""
function timeformat(a, decimal)
    a = string(a)
    (decimal != '.') && (a = replace(a, '.' => decimal))
    return a
end

"""

    Complexformat(a, decimal::AbstractChar, imsuffix::AbstractString)

Convert Complex number to String, optional change of decimal and/or imsuffix.
"""
function complexformat(a, decimal, imsuffix)
    a = string(a)
    a = replace(a, " " => "" )  #"1 + 3im" => "1+3im"
    (imsuffix != "im") && (a = string(split(a, "im")[1], imsuffix))
    (decimal != '.') && (a = replace(a, '.' => decimal))
    return a
end

"""

    writecsv2(f, A; opts...)

Equivalent to `writedlm2()` with fixed delimiter `','` and `decimal='.'`.

# Code Example
```jldoctest
julia> using ReadWriteDlm2

julia> B = Any[1 complex(1.5,2.7);1.0 1//3];

julia> writecsv2("test.csv", B)

julia> read("test.csv", String)
"1,1.5+2.7im\\n1.0,1//3\\n"
```
"""
writecsv2(f, a; opts...) =
    writedlm2auto(f, a, ','; decimal='.', opts...)

"""

    writedlm2(f, A; opts...)
    writedlm2(f, A, delim; opts...)

Write `A` (a vector, matrix, or an iterable collection of iterable rows) as
text to `f`(either a filename string or an IO stream). The columns will be
separated by `';'`, another `delim` (Char or String) can be defined.

By default, a pre-processing of values takes place. Before writing as strings,
decimal marks are changed from `'.'` to `','`. With the keyword argument
`decimal=` another decimal mark can be defined.
To switch off this pre-processing set: `decimal='.'`.

In `writedlm2()` the output format for `Date` and `DateTime` data can be
defined with format strings. Defaults are the ISO formats. Day (`E`, `e`)
and month (`U`, `u`) names are written in the `locale` language. For writing
`Complex` numbers the imaginary component suffix can be selected with the
`imsuffix=` keyword argument.

# Additional Keyword Arguments

* `decimal=','`: Character for writing decimal marks
* `dtfs=\"yyyy-mm-ddTHH:MM:SS.s\"`: DateTime write format
* `dfs=\"yyyy-mm-dd\"`: Date write format
* `locale=\"english\"`: Language for DateTime writing
* `imsuffix=\"im\"`: Complex Imag suffix `\"im\"`, `\"i\"` or `\"j\"`
* `missingstring=\"na\"`: How missing values are written

# Code Example
```jldoctest
julia> using ReadWriteDlm2, Dates

julia> A = Any[1 1.2; "text" Date(2017)];

julia> writedlm2("test.csv", A)

julia> read("test.csv", String)
"1;1,2\\ntext;2017-01-01\\n"
```
"""
writedlm2(io::IO, a; opts...) =
    writedlm2auto(io, a, ';'; opts...)

writedlm2(io::IO, a, dlm; opts...) =
    writedlm2auto(io, a, dlm; opts...)

writedlm2(f::AbstractString, a; opts...) =
    writedlm2auto(f, a, ';'; opts...)

writedlm2(f::AbstractString, a, dlm; opts...) =
    writedlm2auto(f, a, dlm; opts...)

function writedlm2auto(f, a, dlm;
        decimal::AbstractChar=',',
        dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS.s",
        dfs::AbstractString="yyyy-mm-dd",
        locale::AbstractString="english",
        imsuffix::AbstractString="im",
        missingstring::AbstractString="na",
        opts...)

    ((!isempty(dtfs) && !occursin(Regex("[^YymdHMSs]"), dtfs)) ||
    (!isempty(dfs) && !occursin(Regex("[^YymdHMSs]"), dfs))) && info(
        """
        Format string for DateTime(`$dtfs`) or Date(`$dfs`)
        contains numeric code elements only. At least one non-numeric
        code element or character is needed for parsing dates.
        """)

    (string(dlm) == string(decimal)) && error(
        "Error: decimal = delim = ´$(dlm)´ - change decimal or delim!")

    ((imsuffix != "im") && (imsuffix != "i") && (imsuffix != "j")) && error(
    "Only `\"im\"`, `\"i\"` or `\"j\"` are valid arguments for keyword `imsuffix=`.")

    if isa(a, Union{Nothing, Missing, Number, TimeType})
         a = [a]  # create 1 element Array
    end

    if isa(a, AbstractArray)
        fdt = !isempty(dtfs)  # Bool: format DateTime
        dtdf = DateFormat(dtfs, locale)
        fd = !isempty(dfs)    # Bool: format Date
        ddf = DateFormat(dfs, locale)
        ft = (decimal != '.')   # Bool: format Time (change decimal)

        # create b for manipulation/write - keep a unchanged
        b = similar(a, Any)
        for i in eachindex(a)
            b[i] =
            isa(a[i], AbstractFloat) ? floatformat(a[i], decimal) :
            isa(a[i], Missing) ? missingstring :
            isa(a[i], Nothing) ? "nothing" :
            isa(a[i], DateTime) && fdt ? Dates.format(a[i], dtdf) :
            isa(a[i], Date) && fd ? Dates.format(a[i], ddf) :
            isa(a[i], Time) && ft ? timeformat(a[i], decimal) :
            isa(a[i], Complex) ? complexformat(a[i], decimal, imsuffix) :
            string(a[i])
        end
        else  # a is not a Number, TimeType or Array -> no preprocessing
        b = a
    end

    writedlm(f, b, dlm; opts...)

    end # End function writedlm2auto()

end # End module ReadWriteDlm2
