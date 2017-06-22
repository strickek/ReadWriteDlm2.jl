# strickek 2017 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 
#   - main function like Base.DataFmt
#   - additional support for DateTime, Date, Time, Complex und Rational types
#   - readdlm2 and writedlm2 defaults are for decimal comma users primary
#   - readcsv2 and writecsv2 are for decimal dot users with need of extended type parsing

"""
# ReadWriteDlm2 - CSV IO Supporting Decimal Comma, Date, DateTime, Time, Complex and Rational

## `readdlm2(), writedlm2()`:
The functions `readdlm2()` and `writedlm2()` of module `ReadWriteDlm2` are similar to 
`readdlm()` and `writedlm()` of Julia Base.  Differences are: `';'` as default delimiter, 
`','` as default decimal mark and support of `Date`, `DateTime`, `Time`, `Complex` and 
`Rational` types. The basic idea of these functions is to support the "decimal comma countries". 

## `readcsv2(), writecsv2()`:
For "decimal dot" users the functions `readcsv2()` and `writecsv2()` have the right defaults: 
Delimiter `','`, Type `Any` and  `decimal='.'`. Using the more flexible functions `readdlm2()` 
and `writdlm2()` needs delimiter argument explicit set to `' '`, `'\t'` or `','` and `decimal='.'`. 
"""
module ReadWriteDlm2

using Base.Dates,
    Base.DataFmt.readdlm_string, Base.DataFmt.val_opts

export readdlm2, writedlm2, readcsv2, writecsv2

# readdlm2 and readcsv2
# =====================

"""

    dfregex(df::AbstractString, locale::AbstractString=\"english\")

Create a regex string `r\"^...\$\"` for the given `Date` or `DateTime` `format`string `df`.

Use `ismatch()` to test for true/false. With `match()` it is possible to extract parts of 
a date string. The regex groups are named according to the `format`string codes. The locale
is used to calculate min and max length of month and day names (for codes: UuEe).
"""
function dfregex(df::AbstractString, locale::AbstractString="english")
    # calculate min and max string lengths of months and day_of_weeks names
    Ule = try extrema([length(Dates.monthname(i;locale=locale)) for i in 1:12])catch; (3, 9) end
    ule = try extrema([length(Dates.monthabbr(i;locale=locale)) for i in 1:12])catch; (3, 3) end
    Ele = try extrema([length(Dates.dayname(i;locale=locale)) for i in 1:7])catch; (6, 9) end
    ele = try extrema([length(Dates.dayabbr(i;locale=locale)) for i in 1:7])catch; (3, 3) end
    
    codechars = 'y', 'Y', 'm', 'u', 'e', 'U', 'E', 'd', 'H', 'M', 'S', 's', '\\'
    r = "^ *"; repeat_count = 1; ldf = length(df); dotsec = false
    for i = 1:ldf
        repeat_next = (i < ldf && df[(i + 1)] == df[i])? true : false
        (df[i] == '.' && i < ldf && df[(i + 1)] == 's') && (dotsec = true) 
        repeat_count = (((i > 2 && df[(i - 2)] != '\\' && df[(i - 1)] == df[i])) || 
                        (i == 2 && df[1] == df[2]))? (repeat_count + 1) : 1
        r = r * (
        (i > 1 && df[(i - 1)] == '\\')? string(df[i]):
        (df[i] == 'y' && !repeat_next)? "(?<y>\\d{$repeat_count})":
        (df[i] == 'Y' && repeat_count < 5 && !repeat_next)? "(?<y>\\d{4})":
        (df[i] == 'Y' && repeat_count > 4 && !repeat_next)? "(?<y>\\d{$repeat_count})":
        (df[i] == 'm' && repeat_count == 1 && !repeat_next)? "(?<m>0?[1-9]|1[012])":
        (df[i] == 'm' && repeat_count == 2 && !repeat_next)? "(?<m>0[1-9]|1[012])": 
        (df[i] == 'm' && repeat_count > 2 && !repeat_next)? "0{$(repeat_count-2)}(?<m>0[1-9]|1[012])": 
        (df[i] == 'u' && repeat_count == 1)? "(?<u>[A-Za-z\u00C0-\u017F]{$(ule[1]),$(ule[2])})": 
        (df[i] == 'U' && repeat_count == 1)? "(?<U>[A-Za-z\u00C0-\u017F]{$(Ule[1]),$(Ule[2])})": 
        (df[i] == 'e' && repeat_count == 1)? "(?<e>[A-Za-z\u00C0-\u017F]{$(ele[1]),$(ele[2])})": 
        (df[i] == 'E' && repeat_count == 1)? "(?<E>[A-Za-z\u00C0-\u017F]{$(Ele[1]),$(Ele[2])})": 
        (df[i] == 'd' && repeat_count == 1 && !repeat_next)? "(?<d>0?[1-9]|[12]\\d|3[01])":
        (df[i] == 'd' && repeat_count == 2 && !repeat_next)? "(?<d>0[1-9]|[12]\\d|3[01])": 
        (df[i] == 'd' && repeat_count > 2 && !repeat_next)? "0{$(repeat_count-2)}(?<d>0[1-9]|[12]\\d|3[01])": 
        (df[i] == 'H' && repeat_count == 1 && !repeat_next)? "(?<H>0?\\d|1\\d|2[0-3])":
        (df[i] == 'H' && repeat_count == 2 && !repeat_next)? "(?<H>0\\d|1\\d|2[0-3])": 
        (df[i] == 'H' && repeat_count > 2 && !repeat_next)? "0{$(repeat_count-2)}(?<H>0\\d|1\\d|2[0-3])": 
        (df[i] == 'M' && repeat_count == 1 && !repeat_next)? "(?<M>\\d|[0-5]\\d)":
        (df[i] == 'M' && repeat_count == 2 && !repeat_next)? "(?<M>[0-5]\\d)": 
        (df[i] == 'M' && repeat_count > 2 && !repeat_next)? "0{$(repeat_count-2)}(?<M>[0-5]\\d)": 
        (df[i] == 'S' && repeat_count == 1 && !repeat_next)? "(?<S>\\d|[0-5]\\d)":
        (df[i] == 'S' && repeat_count == 2 && !repeat_next)? "(?<S>[0-5]\\d)": 
        (df[i] == 'S' && repeat_count > 2 && !repeat_next)? "0{$(repeat_count-2)}(?<S>[0-5]\\d)":
        (df[i] == '.' && i < ldf && df[(i + 1)] == 's')? "":
        (df[i] == '.')? "\\.":
        (df[i] == 's' && dotsec == true && repeat_count < 4 && !repeat_next)? "(\\.(?<s>\\d{0,3}0{0,6}))?":
        (df[i] == 's' && dotsec == true && repeat_count > 3 && !repeat_next)? "(\\.(?<s>\\d{$(repeat_count)}))?":
        (df[i] == 's' && dotsec == false && repeat_count < 4 && !repeat_next)? "(?<s>\\d{3})?":
        (df[i] == 's' && dotsec == false && repeat_count > 3 && !repeat_next)? "(?<s>\\d{$(repeat_count)})?":
        in(df[i], codechars)? "": string(df[i]) 
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
            (mt[4] == nothing)? s = ms = us = ns = 0:
            s  = parse(Int, lpad(mt[4], 2, 0)); (mt[6] == nothing)? ms = us = ns = 0:
            ms = parse(Int, rpad(mt[6], 3, 0)); (mt[7] == nothing)? us = ns = 0:
            us = parse(Int, rpad(mt[7], 3, 0)); (mt[8] == nothing)? ns = 0:
            ns = parse(Int, rpad(mt[8], 3, 0))
            return Dates.Time(h, mi, s, ms, us, ns)
        end
    end

    if doparsecomplex # parse Complex
        mc = match(r"^ *(-?\d+(\.\d+)?([eE]-?\d+)?|(-?\d+)//(\d+)) ?([\+-]) ?(\d+(\.\d+)?([eE]-?\d+)?|(\d+)//(\d+))(\*im|\*i|\*j|im|i|j) *$", y)
        if mc != nothing      
            real = 
                (mc[4] != nothing && mc[5] != nothing)? //(parse(Int, mc[4]), parse(Int, mc[5])):
                (mc[2] == nothing && mc[3] == nothing)? parse(Int, mc[1]): parse(Float64, mc[1])
            imag =
                (mc[10] != nothing && mc[11] != nothing)? //(parse(Int, mc[6]*mc[10]), parse(Int, mc[11])):
                (mc[8] == nothing && mc[9] == nothing)? parse(Int, mc[6]*mc[7]): parse(Float64, mc[6]*mc[7])
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

Equivalent to [`readdlm2`](@ref) with delim set to `','` and `decimal='.'`. Default Type `Any`
includes parsing of `Bool`, `Int`, `Float64`, `Complex`, `Rational`, `DateTime`, `Date` and `Time`.
"""
readcsv2(input; opts...) = 
    readdlm2auto(input, ',', Any, '\n', false; decimal='.', opts...)

readcsv2(input, T::Type; opts...) = 
    readdlm2auto(input, ',', T, '\n', false; decimal='.', opts...)

"""

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::Char; options...)
    readdlm2(source, delim::Char, T::Type; options...)
    readdlm2(source, delim::Char, eol::Char; options...)
    readdlm2(source, delim::Char, T::Type, eol::Char; options...)

Read a matrix from `source`. The `source` can be a text file, stream or byte array.
Each line (separated by `eol`, this is `'\\n'` by default) gives one row. The columns are
separated by `';'`, another `delim` can be defined.

Pre-processing of `source` with regex substitution changes the decimal marks from `d,d` to `d.d`.
For default `rs` the keyword argument `decimal=','` sets the decimal Char in the `r`-string of `rs`.
When a special regex substitution tuple `rs=(r.., s..)` is defined, the argument `decimal` is not used.
Pre-processing can be switched off with: `rs=()`.

In addition to Base readdlm(), strings are also parsed for Dates formats (ISO) and the
Time format `\"HH:MM[:SS[.s{1,9}]]\"`. To switch off parsing Dates and Time set:
`dfs=\"\", dtfs=\"\"`. `locale` defines the language of day (`E`, `e`) and month (`U`, `u`) names.

If all data is numeric, the result will be a numeric array. In other cases
a heterogeneous array of numbers, dates and strings is returned. To include parsing for Complex and 
Rational numbers, use `Any` as Type argument. Homogeneous arrays are supported for the Type-Arguments:
`Bool`, `Int`, `Float64`, `Complex`, `Rational`, `DateTime`, `Date` and `Time`.

# Additional Keyword Arguments

* `decimal=','`: decimal mark Char used by default `rs`, irrelevant if `rs`-tuple is not the default one
* `rs=(r\"(\\d),(\\d)\", s\"\\1.\\2\")`: Regex (r,s)-tuple, change d,d to d.d if `decimal=','`
* `dtfs=\"yyyy-mm-ddTHH:MM:SS\"`: format string for DateTime parsing, default is ISO
* `dfs=\"yyyy-mm-dd\"`: format string for Date parsing, default is ISO
* `locale=\"english\"`: language for parsing dates names, default is english

Find more information about Base `readdlm()` functionality and (keyword) arguments -
which are also supported by `readdlm2()` - in `help` for `readdlm()`.

# Code Example 
for reading the Excel (lang=german) textfile `test_de.csv`:
```
test = readdlm2(\"test_de.csv\", dfs=\"dd.mm.yyyy\", dtfs=\"dd.mm.yyyy HH:MM\")
```
"""

readdlm2(input; opts...) =
    readdlm2auto(input, ';', Float64, '\n', true; opts...)

readdlm2(input, T::Type; opts...) =
    readdlm2auto(input, ';', T, '\n', false; opts...)

readdlm2(input, dlm::Char; opts...) =
    readdlm2auto(input, dlm, Float64, '\n', true; opts...)

readdlm2(input, dlm::Char, T::Type; opts...) =
    readdlm2auto(input, dlm, T, '\n', false; opts...)

readdlm2(input, dlm::Char, eol::Char; opts...) =
    readdlm2auto(input, dlm, Float64, eol, true; opts...)

readdlm2(input, dlm::Char, T::Type, eol::Char; opts...) =
    readdlm2auto(input, dlm, T, eol, false; opts...)

function readdlm2auto(input, dlm, T, eol, auto;
        decimal::Char=',',
        rs::Tuple=(r"(\d),(\d)", s"\1.\2"),
        dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS",
        dfs::AbstractString="yyyy-mm-dd", 
        locale::AbstractString="english",
        opts...)
    
    ((!isempty(dtfs) && !ismatch(Regex("[^YymdHMSs]"), dtfs)) ||
    (!isempty(dfs) && !ismatch(Regex("[^YymdHMSs]"), dfs))) && info(
        """
        Format string for DateTime(`$dtfs`) or Date(`$dfs`) 
        contains numeric code elements only. At least one non-numeric 
        code element or character is needed for parsing dates.
        """)    
    
    # "parsing-matrix" for different T::Types
    doparsedatetime = false
    doparsedate = false
    doparsetime = false
    doparsecomplex = false
    doparserational = false
    convertarray = false
    T2 = Any
    if T == DateTime
        isempty(dtfs) && error("Error: Parsing for DateTime - format string `dtfs` is empty.")
        doparsedatetime = true
        convertarray = true
    elseif T == Date
        isempty(dtfs) && error("Error: Parsing for Date - format string `dfs` is empty.")
        doparsedate = true
        convertarray = true
    elseif T == Time
        doparsetime = true
        convertarray = true
    elseif T == Complex
        doparsecomplex = true
        convertarray = true
    elseif T == Rational
        doparserational = true
        convertarray = true
    elseif T == Any
        doparsedatetime = !isempty(dtfs)
        doparsedate = !isempty(dfs)
        doparsetime = true
        doparsecomplex = true
        doparserational = true
    elseif T == Float64 && auto == true
        T2 = T
        doparsedatetime = !isempty(dtfs)
        doparsedate = !isempty(dfs)
        doparsetime = doparsedatetime && doparsedate
    else
        T2 = T
    end 
    
   if !isempty(rs) && decimal != '.' # pre-processing of decimal mark should be done
        
        # Error if decimal mark to replace is also "decimal" in a date format string
        rs == (r"(\d),(\d)", s"\1.\2") &&
        ismatch(Regex("([YymdHMSs]+$decimal[YymdHMSs]+)"), dtfs*" "*dfs) && 
        error(
            """
            Error: Regex substitution from Decimal=`$decimal` to '.' and using `$decimal` in a 
            Dates format string directly between two digit elements (codes: YymdHMSs) doesn't work.
            Therefore, use e.g. `S.s` instead of `S$(decimal)s` in the DateTime format
            string. But, because of the blank before the second digit element, 
            for example do not(!) change `Y$(decimal) m`.
            """
            )    
        
        # change default regex substitution Tuple if decimal != ','
        if rs == (r"(\d),(\d)", s"\1.\2") && decimal != ','
            rs = (Regex("(\\d)$decimal(\\d)"), s"\1.\2")
        end
        
        # Error if decimal mark to replace is also the delim Char
        "1"*string(dlm)*"1" != replace("1"*string(dlm)*"1", rs[1], rs[2]) && error(
            """
            Error: Decimal mark to replace is also the delim Char.
            Pre-processing with decimal mark Regex substitution
            for `$(dlm)` (= delim!!) is not allowed - change rs/decimal or delim!
            """)

        # read input string, do regex substitution
        s = replace(readstring(input), rs[1], rs[2])
        
        # using Base.DataFmt internal functions to read dlm-string
        z = readdlm_string(s, dlm, T2, eol, auto, val_opts(opts))
        
    else # read with standard readdlm(), no regex
        if auto
            z = readdlm(input, dlm, eol; opts...)
        else
            z = readdlm(input, dlm, T2, eol; opts...)
        end
    end

    isa(z, Tuple) ? (y, h) = z : y = z #Tuple(data, header) or only data? y = data.

    # Formats, Regex for Date/DateTime parsing
    dtdf = DateFormat(dtfs, locale)
    ddf = DateFormat(dfs, locale) 
    rdt = dfregex(dtfs, locale)
    rd = dfregex(dfs, locale)

    for i in eachindex(y)
        if isa(y[i], AbstractString) 
            if doparsedatetime && ismatch(rdt, y[i]) # parse DateTime
                try y[i] = DateTime(y[i], dtdf) catch; end 
            elseif doparsedate && ismatch(rd, y[i]) # parse Date
                try y[i] = Date(y[i], ddf) catch; end
            else # parse Time, Complex and Rational
                try y[i] = parseothers(y[i], doparsetime, doparsecomplex, doparserational) catch; end
            end
        end
    end

    if convertarray  
        isa(z, Tuple) ? z = (convert(Array{T}, y), h): z = convert(Array{T}, z) 
    end

    return z

end # end function readdlm2auto()


# writedlm2 and writecsv2
# =======================

"""

    floatformat(a, decimal::Char, write_short::Bool) 

Convert Int or Float64 numbers to String, optional with print_shortest and change of decimal mark.
"""
function floatformat(a, decimal, write_short) 
    if write_short == false
        a = string(a)
    else
        iob = IOBuffer()
        print_shortest(iob, a) 
        a = String(take!(iob)) 
    end
    decimal != '.' && (a = replace(a, '.', decimal))
    return a
end

"""

    timeformat(a, decimal::Char) 

Convert Time to String, optional with change of decimal mark for secounds.
"""
function timeformat(a, decimal) # change decimal mark in string(Time)
    a = string(a)
    decimal != '.' && (a = replace(a, '.', decimal))
    return a
end

"""

    Complexformat(a, decimal::Char, imsuffix::AbstractString) 

Convert Complex number to String, optional with change of decimal and/or imsuffix.
"""
function complexformat(a, decimal, imsuffix) # change decimal mark and imsuffix for Complex
    a = string(a)
    imsuffix != "im" && (a = string(split(a, "im")[1], imsuffix))
    decimal != '.' && (a = replace(a, '.', decimal))
    return a
end

"""

    writecsv2(filename, A; opts...)

Equivalent to [`writedlm2`](@ref) with delim set to `','` and `decimal='.'`.
"""
writecsv2(f, a; opts...) = 
    writedlm2auto(f, a, ','; decimal='.', opts...)

"""

    writedlm2(f::IO, A; opts...)
    writedlm2(f::IO, A, delim; opts...)
    writedlm2(f::AbstractString, A; opts...)
    writedlm2(f::AbstractString, A, delim; opts...)

Write `A` (a vector, matrix, or an iterable collection of iterable rows) as text to `f` 
(either a filename string or an IO stream). The columns will be separated by `';'`, 
another `delim` (Char or String) can be defined.

By default a pre-processing of floats takes place. Floats are parsed to strings
with decimal mark changed from `'.'` to `','`. With a keyword argument
another decimal mark can be defined. To switch off this pre-processing set: `decimal='.'`.

Base `writedlm()` writes `3000.0` always short as `3e3`. To keep type information `writedlm2()`
writes long like print() by default. Set `write_short=true` to have the same behavior as
in Base `writedlm()`.

In `writedlm2()` the output format for Date and DateTime data can be defined with format strings.
Defaults are the ISO formats. Day (`E`, `e`) and month (`U`, `u`) names are written in `locale`
language. For writing Complex numbers the imaginary component suffix can be changed with the
`imsuffix=` keyword argument.

# Additional Keyword Arguments

* `decimal=','`: Charater for writing decimal marks, default is a comma
* `write_short=false`: Bool - use print() to write data, set `true` for print_shortest()
* `dtfs=\"yyyy-mm-ddTHH:MM:SS\"`: format string, DateTime write format, default is ISO
* `dfs=\"yyyy-mm-dd\"`: format string, Date write format, default is ISO
* `locale=\"english\"`: language for DateTime writing, default is english
* `imsuffix=\"im\"`: Complex - imaginary component suffix `\"i\"`, `\"j\"` or `\"im\"`(=default)

# Code Example 
for writing the Julia `test` data to an text file `test_de.csv` readable by Excel (lang=german):
```
writedlm2(\"test_de.csv\", test, dtfs=\"dd.mm.yyyy HH:MM\", dfs=\"dd.mm.yyyy\")
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
        decimal::Char=',',
        write_short::Bool=false,
        dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS",
        dfs::AbstractString="yyyy-mm-dd",
        locale::AbstractString="english",
        imsuffix::AbstractString="im", 
        opts...)
    
    ((!isempty(dtfs) && !ismatch(Regex("[^YymdHMSs]"), dtfs)) ||
    (!isempty(dfs) && !ismatch(Regex("[^YymdHMSs]"), dfs))) && info(
        """
        Format string for DateTime(`$dtfs`) or Date(`$dfs`) 
        contains numeric code elements only. At least one non-numeric 
        code element or character is needed for parsing dates.
        """)     

    string(dlm) == string(decimal) && error(
        "Error: decimal = delim = ´$(dlm)´ - change decimal or delim!")

    imsuffix != "im" && imsuffix != "i" && imsuffix != "j" && error(
    "Only `\"im\"`, `\"i\"` or `\"j\"` are valid arguments for keyword `imsuffix=`.")
    
    if isa(a, Union{Number, Date, DateTime})
         a = [a]  # create 1 element Array 
    end

    if isa(a, AbstractArray)
        fdt = !isempty(dtfs)  # Bool: format DateTime
        dtdf = DateFormat(dtfs, locale)
        fd = !isempty(dfs)    # Bool: format Date
        ddf = DateFormat(dfs, locale)
        ft = decimal != '.'   # Bool: format Time (change decimal)
        fc = (imsuffix != "im" || decimal != '.') # Bool: format Complex

        # create b for manipulation/write - keep a unchanged
        b = similar(a, Any)
        for i in eachindex(a)
            b[i] =
            isa(a[i], AbstractFloat) ? floatformat(a[i], decimal, write_short):
            isa(a[i], DateTime) && fdt ? Dates.format(a[i], dtdf):
            isa(a[i], Date) && fd ? Dates.format(a[i], ddf):
            isa(a[i], Time) && ft ? timeformat(a[i], decimal):
            isa(a[i], Complex) && fc ? complexformat(a[i], decimal, imsuffix): string(a[i])
        end
    else  # a is not a Number, Date, DateTime or Array -> no preprocessing
        b = a 
    end

    writedlm(f, b, dlm; opts...)

    end # end function writedlm2auto()

end # end module ReadWriteDlm2
