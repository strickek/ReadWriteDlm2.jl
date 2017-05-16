# strickek 2017 - License is MIT: http://julialang.org/license
# ReadWriteDlm2
# Handle different decimal marks (default comma) and allows dates parsing / formating

module ReadWriteDlm2

using Base.Dates,
    Base.DataFmt.readdlm_string, Base.DataFmt.val_opts

export readdlm2, writedlm2


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
    r = "^"; repeat_count = 1; ldf = length(df); dotsec = false
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
    return Regex(r * string('$'))
end 

"""

    parsetime(str::AbstractString)

Parse a `valid(!!!)` time string \"HH:MM[:SS[.s{1,9}]]\" and return the `Dates.Time` result.
"""

function parsetime(str::AbstractString)
    h = parse(Int, SubString(str, 1, 2))
    mi = parse(Int, SubString(str, 4, 5))
    s = (length(str) > 5)? parse(Float64, SubString(str, 7)): 0.0
    ns = Integer(1000000000s) + 60000000000mi + 3600000000000h
    return Dates.Time(Dates.Nanosecond(ns))
end

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

In addition to Base readdlm(), strings are also parsed for Dates formats (ISO) and the fix
Time format `\"HH:MM[:SS[.s{1,9}]]\"` by default. To switch off parsing Dates/Time set:
`dfs=\"\", dtfs=\"\"`. `locale` defines the language of day (`E`, `e`) and month (`U`, `u`) names.

If all data is numeric, the result will be a numeric array. In other cases
a heterogeneous array of numbers, dates and strings is returned.

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
        contains numeric code elements only. `readdlm2()` needs at least 
        one non-numeric code element or character for parsing dates.
        """)     
    
   if !isempty(rs) && decimal != '.' # pre-processing of decimal mark should be done
        
        # Error if decimal mark to replace is also "decimal" in a date format string
        rs == (r"(\d),(\d)", s"\1.\2") &&
        ismatch(Regex("([YymdHMSs]+$decimal[YymdHMSs]+)"), dtfs*" "*dfs) && 
        error(
            """
            Error: Regex substitution from Decimal=`$decimal` to '.' and using `$decimal` in a 
            Dates format string directly between two digit elements (codes: YymdHMSs) doesn't work.
            Therefore, use e.g. `S.s` instead of `S$(decimal)s` in the DateTime format
            string of `readdlm2()`. But, because of the blank before the second digit element, 
            for example do not(!) change `Y$(decimal) m`.
            """
            )    
        
        # change default regex substitution Tupel if decimal != ','
        if rs == (r"(\d),(\d)", s"\1.\2") && decimal != ','
            rs = (Regex("(\\d)$decimal(\\d)"), s"\1.\2")
        end
        
        # Error if decimal mark to replace is also the delim Char
        "1"*string(dlm)*"1" != replace("1"*string(dlm)*"1", rs[1], rs[2]) && error(
            """
            Error in readdlm2(): 
            Pre-processing with decimal mark Regex substitution
            for `$(dlm)` (= delim!!) is not allowed - change rs/decimal or delim!
            """)

        # read input string, do regex substitution
        s = replace(readstring(input), rs[1], rs[2])
        
        # using Base.DataFmt internal functions to read dlm-string
        z = readdlm_string(s, dlm, T, eol, auto, val_opts(opts))
        
    else # read with standard readdlm(), no regex
        if auto
            z = readdlm(input, dlm, eol; opts...)
        else
            z = readdlm(input, dlm, T, eol; opts...)
        end
    end

    isa(z, Tuple) ? (y, h) = z : y = z #Tupel(data, header) or only data? y = data.

    # parse data for Date/DateTime and Time Format -> Julia Dates-Types
    isempty(dfs) && isempty(dtfs) && return z # empty formats -> no d/dt-parsing

    dtdf = DateFormat(dtfs, locale)
    ddf = DateFormat(dfs, locale) 
    rdt = dfregex(dtfs, locale)
    rd = dfregex(dfs, locale)

    for i in eachindex(y)
        if isa(y[i], AbstractString)
            if ismatch(rdt, y[i])
                try y[i] = DateTime(y[i], dtdf) catch; end
            elseif ismatch(rd, y[i])
                try y[i] = Date(y[i], ddf) catch; end
            elseif ismatch(r"^(0\d|1\d|2[0-3]):[0-5]\d((:[0-5]\d)(\.\d{1,9})?)?$", y[i])
                try y[i] = parsetime(y[i]) catch; end                
            end
        end
    end

    return z

    end # end function readdlm2auto()

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
language.

# Additional Keyword Arguments

* `decimal=','`: decimal mark character, default is a comma
* `write_short=false`: Bool - use print() to write data, set `true` for print_shortest()
* `dtfs=\"yyyy-mm-ddTHH:MM:SS\"`: format string, DateTime write format, default is ISO
* `dfs=\"yyyy-mm-dd\"`: format string, Date write format, default is ISO
* `locale=\"english\"`: language for DateTime writing, default is english

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

function floatdec(a, decimal, write_short) # print shortest and change decimal mark
    iob = IOBuffer()
    write_short == true ? print_shortest(iob, a) : print(iob, a)
    if decimal != '.'
        return replace(String(take!(iob)), '.', decimal)
    else
        return String(take!(iob))
    end
end

function writedlm2auto(f, a, dlm;
        decimal::Char=',',
        write_short::Bool=false,
        dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS",
        dfs::AbstractString="yyyy-mm-dd",
        locale::AbstractString="english",
        opts...)
    
    ((!isempty(dtfs) && !ismatch(Regex("[^YymdHMSs]"), dtfs)) ||
    (!isempty(dfs) && !ismatch(Regex("[^YymdHMSs]"), dfs))) && info(
        """
        Format string for DateTime(`$dtfs`) or Date(`$dfs`) 
        contains numeric code elements only. `readdlm2()` needs at least 
        one non-numeric code element or character for parsing dates.
        """)     

    string(dlm) == string(decimal) && error(
        "Error in writedlm(): decimal = delim = ´$(dlm)´ - change decimal or delim!")

    if isa(a, Union{Number, Date, DateTime})
         a = [a]  # create 1 element Array 
     end

     if isa(a, AbstractArray)
         #format dates only if format strings are not not ""
         fdt = !isempty(dtfs)  # Bool: format DateTime
         fd = !isempty(dfs)    # Bool: format Date
         dtdf = DateFormat(dtfs, locale)
         ddf = DateFormat(dfs, locale)

         # create b for manipulation/write - keep a unchanged
         b = similar(a, Any)
         for i in eachindex(a)
             b[i] =
             isa(a[i], AbstractFloat) ? floatdec(a[i], decimal, write_short):
             isa(a[i], DateTime) && fdt ? Dates.format(a[i], dtdf):
             isa(a[i], Date) && fd ? Dates.format(a[i], ddf): string(a[i])
         end
     else  # a is not a Number, Date, DateTime or Array -> no preprocessing
         b = a 
     end

     writedlm(f, b, dlm; opts...)

    end # end function writedlm2auto()

end # end module ReadWriteDlm2
