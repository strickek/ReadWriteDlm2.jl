# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - rwd2_read.jl - https://github.com/strickek/ReadWriteDlm2.jl

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

The result will be a (heterogeneous) array of default element type `Any`. If
`header=true` it will be a tuple containing the data array and a vector for
the columnnames. Other (abstract) types for the data array elements could be
defined. If data is empty, a `0×0 Array{T,2}` is returned.

With `tables=true`[, `header=true`] option[s] a `Tables` interface compatible
`MatrixTable` with individual column types is returned, which for example
can be used as Argument for `DataFrame()`.

# Additional Keyword Arguments

* `decimal=','`: Decimal mark Char used by default `rs`, irrelevant if `rs`-tuple is not the default one
* `rs=(r\"(\\d),(\\d)\", s\"\\1.\\2\")`: Regex (r,s)-tuple, the default change d,d to d.d if `decimal=','`
* `dtfs=\"yyyy-mm-ddTHH:MM:SS.s\"`: Format string for DateTime parsing
* `dfs=\"yyyy-mm-dd\"`: Format string for Date parsing
* `locale=\"english\"`: Language for parsing dates names
* `tables=false`: Return `Tables` interface compatible MatrixTable if `true`
* `dfheader=false`: 'dfheader=true' is shortform for `tables=true, header=true`
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
    readdlm2auto(input, ';', Nothing, '\n', true; opts...)

readdlm2(input, T::Type; opts...) =
    readdlm2auto(input, ';', T, '\n', false; opts...)

readdlm2(input, dlm::AbstractChar; opts...) =
    readdlm2auto(input, dlm, Nothing, '\n', true; opts...)

readdlm2(input, dlm::AbstractChar, T::Type; opts...) =
    readdlm2auto(input, dlm, T, '\n', false; opts...)

readdlm2(input, dlm::AbstractChar, eol::AbstractChar; opts...) =
    readdlm2auto(input, dlm, Nothing, eol, true; opts...)

readdlm2(input, dlm::AbstractChar, T::Type, eol::AbstractChar; opts...) =
    readdlm2auto(input, dlm, T, eol, false; opts...)

function readdlm2auto(input, dlm, T, eol, auto;
    decimal::AbstractChar=',',
    rs::Tuple=(r"(\d),(\d)", s"\1.\2"),
    dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS.s",
    dfs::AbstractString="yyyy-mm-dd",
    locale::AbstractString="english",
    tables::Bool=false,
    dfheader::Bool=false,
    missingstring::AbstractString="na",
    opts...)

    if dfheader == true
        tables = true
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

    if T == Nothing            # to know wether T ist Any by default
            T = Any
            anybydefault = true
        else
            anybydefault = false
        end

    # "parsing-logic" for different T::Types
    ((typeintersect(DateTime, T)) == Union{}) && (doparsedatetime = false)
    ((typeintersect(Date, T)) == Union{}) && (doparsedate = false)
    doparsetime =
        ((doparsedatetime && doparsedate) || ((Time <: T) && !(Any <:T)))
    T <: Union{AbstractFloat, AbstractString, Char} &&
        (T2 = T; convertarray = false)
    ((typeintersect(Complex, T)) == Union{}) && (doparsecomplex = false)
    ((typeintersect(Rational, T)) == Union{}) && (doparserational = false)
    Missing <: T && (doparsemissing = true)
    Nothing <: T && (doparsenothing = true)
    (Any <: T) && (convertarray = false)
    if tables == true
        T2 = Any
        convertarray = false
        !anybydefault && (convertarray = true)
        T <: Union{AbstractString, Char} &&
            (T2 = T; convertarray = false)
    end

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

    # Formats, Regex for Date/DateTime parsing
    doparsedatetime &&
        (dtdf = DateFormat(dtfs, locale); rdt = dfregex(dtfs, locale))
    doparsedate &&
        (ddf = DateFormat(dfs, locale); rd = dfregex(dfs, locale))

    if tables == true  # return MatrixTable for Tables Interface
        if isa(z, Tuple)
             y, h = z
             headerexist = true
             cn = Symbol.(reshape(h, :))
        else
             y = z
             headerexist = false
        end

        rows, cols = size(y)
        coltypes = Array{Type, 1}(undef, cols)
        Tn = typeintersect(T, Number)
        for c in 1:cols # iterate columns
            colcontainmissing = false
            colcontainnothing = false
            coltype = Union{}
        for r in 1:rows # iterate rows in columns

            if isa(y[r,c], AbstractString)
                if doparsedatetime && occursin(rdt, y[r,c]) # parse DateTime
                    try y[r,c] = DateTime(y[r,c], dtdf) catch; end
                elseif doparsedate && occursin(rd, y[r,c]) # parse Date
                    try y[r,c] = Date(y[r,c], ddf) catch; end
                elseif doparsemissing && y[r,c] == missingstring # parse Missing
                    try y[r,c] = missing catch; end
                elseif doparsenothing && y[r,c] == "nothing" # parse Nothing
                    try y[r,c] = nothing catch; end
                else # parse Time, Complex and Rational
                    try y[r,c] = parseothers(y[r,c], doparsetime, doparsecomplex, doparserational) catch; end
                    if isa(y[r,c], AbstractString)
                        #Substring to String
                        try y[r,c] = String.(split(y[r,c]))[1] catch; end
                    end
                end
            elseif convertarray && !(typeof(y[r,c]) <: Tn)
                try y[r,c] = convert(Tn, y[r,c]) catch; end
            end
            if typeof(y[r,c]) == Missing
                colcontainmissing = true
            elseif typeof(y[r,c]) == Nothing
                colcontainnothing = true
            else
                coltype = typejoin(coltype, typeof(y[r,c]))
            end

        end # end for - iterate rows in columns

        if colcontainmissing && colcontainnothing
            coltypes[c] = Union{Missing, Nothing, coltype}
        elseif colcontainmissing
            coltypes[c] = Union{Missing, coltype}
        elseif colcontainnothing
            coltypes[c] = Union{Nothing, coltype}
        else
            coltypes[c] = coltype
        end

        if convertarray && (coltypes[c] <: T)
            coltypes[c] = T
        end

        end # end for - iterate columns

        vdata = vecofvec(y, coltypes)

        if headerexist
            return Tables.table(vdata, header=cn)
        else
            return Tables.table(vdata)
        end

    else     # return standard Format (Arry or Tuple(data, header))

        if isa(z, Tuple)
             y, h = z
        else
             y = z
        end
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
        end

        if convertarray
            isa(z, Tuple) ? z = (convert(Array{T}, y), h) : z = convert(Array{T}, z)
        end

        return z

end # End function readdlm2auto()
