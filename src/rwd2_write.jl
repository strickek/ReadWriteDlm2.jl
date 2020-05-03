# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - rwd2_write.jl - https://github.com/strickek/ReadWriteDlm2.jl

"""

    writedlm2(f, A; opts...)
    writedlm2(f, A, delim; opts...)

Write `A` (a vector, matrix, or an iterable collection of iterable rows, a
`Tables` source) as text to `f` (either a filename or an IO stream). The columns
are separated by `';'`, another `delim` (Char or String) can be defined.

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
        "Only `\"im\"`, `\"i\"` or `\"j\"` are valid for `imsuffix`.")

    if isa(a, Union{Nothing, Missing, Number, TimeType})
         a = [a]  # create 1 element Array
    elseif Tables.istable(a) == true # Tables interface
        a = matrix2(a)  # Matrix{Any}, first row columnnames, row 2:end -> data
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
