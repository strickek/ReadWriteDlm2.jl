# strickek 2017 - License is MIT: http://julialang.org/license
# ReadWriteDlm2
# Handle different decimal marks (default comma) and allows dates parsing / formating

module ReadWriteDlm2

using Base.Dates,
    Base.DataFmt.readdlm_string, Base.DataFmt.val_opts

export readdlm2, writedlm2

"""

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::Char; options...)
    readdlm2(source, delim::Char, T::Type; options...)
    readdlm2(source, delim::Char, eol::Char; options...)
    readdlm2(source, delim::Char, T::Type, eol::Char; options...)

Read a matrix from the `source`. The `source` can be a text file, stream or byte array.
Each line (separated by `eol`, this is `'\\n'` by default) gives one row. The columns are
separated by `';'`, another `delim` can be defined.

Pre-processing of `source` with regex substitution changes the decimal marks from `d,d` to `d.d`.
For default `rs` the keyword argument `decimal=','` sets the decimal Char in the `r`-string of `rs`.
When a special regex substitution Tupel `rs=(r.., s..)` is defined, the argument `decimal` is not used.
Pre-processing can be switched off with: `rs=()`.

In addition to Base readdlm(), strings are also parsed for ISO Date and DateTime formats
by default. To switch off parsing Dates formats set: `dfs=\"\", dtfs=\"\"`.

If all data is numeric, the result will be a numeric array. In other cases
a heterogeneous array of numbers, dates and strings is returned.

# Additional Keyword Arguments

* `decimal=','`: decimal mark Char used by default `rs`, irrelevant if `rs`-Tupel is not the default one
* `rs=(r\"(\\d),(\\d)\", s\"\\1.\\2\")`: Regex (r,s)-Tupel), change `d,d` to `d.d` if `decimal=','`
* `dfs=\"yyyy-mm-dd\"`: format string for Date parsing, default is ISO
* `dtfs=\"yyyy-mm-ddTHH:MM:SS\"`: format string for DateTime parsing, default is ISO

Find more information about Base `readdlm()` functionality and (keyword) arguments -
which are also supported by `readdlm2()` - in `help` for `readdlm()`.

# Code-Example 
for reading the Excel(lang=german) textfile `test_de.csv`:
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
        opts...)
    
   if rs != () && decimal != '.' # pre-processing of decimal mark should be done
        
        # change default regex substitution Tupel if decimal != ','
        if rs == (r"(\d),(\d)", s"\1.\2") && decimal != ','
            rs=(Regex("(\\d)$decimal(\\d)"), s"\1.\2")
        end
        
        # Error if decimal mark to replace is also the delim Char
        "1"*string(dlm)*"1" != replace("1"*string(dlm)*"1", rs[1], rs[2]) && error(
            "Error in readdlm2(): 
            Pre-prozessing with decimal mark Regex substitution
            for `$(dlm)` (= delim!!) is not allowed - change rs/decimal or delim!")

        # read input string, do regex substitution
        s = replace(readstring(input), rs[1], rs[2])
        
        # using Base.DataFmt internal functions to read dlm-string
        z = readdlm_string(s, dlm, T, eol, auto, val_opts(opts))
        
    else # read with standard readdlm(), no regex
        if auto == true
            z = readdlm(input, dlm, eol; opts...)
        else
            z = readdlm(input, dlm, T, eol; opts...)
        end
    end

    isa(z, Tuple) ? (y, h) = z : y = z #Tupel(data, header) or only data? y = data.

    # parse data for Date/DateTime-Format -> Julia Dates-Types
    ldfs = length(dfs); ldtfs = length(dtfs)
    ldfs == 0 && ldtfs == 0 && return z # empty formats -> no d/dt-parsing

    fdfs = DateFormat(dfs); fdtfs = DateFormat(dtfs)

    for i in eachindex(y)
        if isa(y[i], AbstractString)
            lyi = length(y[i])
            dtfvalid = false
            if lyi == ldtfs
                try y[i] = DateTime(y[i], fdtfs); dtfvalid = true catch; end
            end
            if !dtfvalid && lyi == ldfs
                try y[i] = Date(y[i], fdfs) catch; end
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

Like in writedlm() of Base, `writedlm2()` writes `3000.0` by default short as `3e3`. To write 
in the normal print() format set: `write_short=false`.

In `writedlm2()` the output format for Date and DateTime data can be defined with format strings.
Defaults are the ISO formats.

#Additional Keyword Arguments

* `decimal=','`: decimal mark character, default is a comma
* `write_short=true`: Bool - use print_shortest() to write data
* `dfs=\"yyyy-mm-dd\"`: format string, Date write format, default is ISO
* `dtfs=\"yyyy-mm-ddTHH:MM:SS\"`: format string, DateTime write format, default is ISO

# Code-Example 
for writing the Julia `test` data to an text file `test_de.csv` readable by Excel(lang=german):
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
    iob=IOBuffer()
    if write_short == true
        print_shortest(iob, a) 
    else
        print(iob, a)
    end
    if decimal != '.'
        return replace(takebuf_string(iob), '.', decimal)
    else
        return String(takebuf_string(iob))
    end
end

function writedlm2auto(f, a, dlm;
        decimal::Char=',',
        write_short::Bool=true,
        dfs::AbstractString="yyyy-mm-dd",
        dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS", 
        opts...)

    string(dlm) == string(decimal) && error(
        "Error in writedlm(): decimal = delim = ´$(dlm)´ - change decimal or delim!")

    if isa(a, Union{Number, Date, DateTime})
         a = [a]  # create 1 element Array 
     end

     if isa(a, AbstractArray)
         #format dates only if format strings are not ISO and not ""
         fdt = (dtfs != "yyyy-mm-ddTHH:MM:SS") && (dtfs != "") # Bool: format DateTime
         fd = (dfs != "yyyy-mm-dd") && (dfs != "")    # Bool: format Date

         # creat b for manipulation/write - keep a unchanged
         b = similar(a, Any)
         for i in eachindex(a)
             b[i] =
             isa(a[i], AbstractFloat) ? floatdec(a[i], decimal, write_short):
             isa(a[i], DateTime) && fdt ? Dates.format(a[i], dtfs):
             isa(a[i], Date) && fd ? Dates.format(a[i], dfs): string(a[i])
         end
     else  # a is not a Number, Date, DateTime or Array -> no preprocessing
         b = a 
     end

     writedlm(f, b, dlm; opts...)

    end # end function writedlm2auto()

end # end modul ReadWriteDlm2
