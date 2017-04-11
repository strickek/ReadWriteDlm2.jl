# strickek 2017 - V0.0.1 - License is MIT: http://julialang.org/license
# ReadWriteDlm2
# Handle a different decimal mark (comma) and allows dates parsing / formating

module ReadWriteDlm2

using Base.Dates,
    Base.DataFmt.readdlm_string, Base.DataFmt.val_opts

export readdlm2, writedlm2

"""

The following special readdlm2() methods have been added by module `ReadWriteDlm2`:

    readdlm2(source; options...)
    readdlm2(source, T::Type; options...)
    readdlm2(source, delim::Char; options...)
    readdlm2(source, delim::Char, T::Type; options...)
    readdlm2(source, delim::Char, eol::Char; options...)
    readdlm2(source, delim::Char, T::Type, eol::Char; options...)

They are designed to support
the decimal comma parts of the world and to allow parsing the input strings
for Date- and DateTime-types.

 a preprocessing of input with regex substitution
takes place, which by default changes the decimal mark from `d,d` to `d.d`.

The columns are expected to be separated by `';'`, an other `delim`
can be defined. End of line `eol` is the standard `'\\n'` by default.

If all data is numeric, the result will be a numeric array. If some elements
cannot be parsed as numbers, a heterogeneous array of numbers and strings
is returned.

In addition to Base dlmread(), strings are also parsed for ISO Date-
and DateTime formats by default. To switch off Dates parsing set both
formatstrings in options to: `dfs = \"\", dtfs = \"\"`.

Additional special options with default value are:

    rs = (r\"(\\d),(\\d)\", s\"\\1.\\2\") (regex (r,s)-Tupel)
    dfs = \"yyyy-mm-dd\" (format string for Date parsing)
    dtfs = \"yyyy-mm-ddTHH:MM:SS\" (format string for DateTime)

Code-Example for reading the Excel(lang=german) textfile `test_de.csv`:

    test = readdlm2(\"test_de.csv\", dfs=\"dd.mm.yyyy\", dtfs=\"dd.mm.yyyy HH:MM\")

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
        rs::Tuple = (r"(\d),(\d)", s"\1.\2"),
        dtfs::AbstractString = "yyyy-mm-ddTHH:MM:SS",
        dfs::AbstractString = "yyyy-mm-dd", opts...)
    
    rs == (r"(\d),(\d)", s"\1.\2") && dlm == ',' && error(
        "Error in readdlm2():  
        rs = (r\"(\d),(\d)\", s\"\1.\2\") and delim = ',' is not allowed.")

    if rs != ()
        # read input string, do regex substitution
        s = replace(readstring(input), rs[1], rs[2])
        # using Base.DataFmt internal functions to read dlm-string
        z = readdlm_string(s, dlm, T, eol, auto, val_opts(opts))
    else # read with standard readdlm(), no regex
        if auto==true
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

The following writedlm2() methods have been added by module `ReadWriteDlm2`:

    writedlm2(f::IO, A; opts...)
    writedlm2(f::IO, A, delim; opts...)
    writedlm2(filename::AbstractString, A; opts...)
    writedlm2(filename::AbstractString, A, delim; opts...)

They are designed to support the decimal comma parts of the world; they 
also allows to define the format, how Date- and DateTime-types are written.

If keyword argument `decimal=','`(default) a preprocessing of floats takes 
place, which are parsed to strings with decimal mark changed from `'.'` to `','`.

The columns will be separated by `';'`, an other `delim` can be defined.

In addition to Base dlmwrite() function the output format for Julia
Date- and DateTime-data can be defined with format strings. Default are
the ISO Formats.

Additional special options with default value are:

    decimal = ',' (decimal mark character)
    dfs = \"yyyy-mm-dd\" (format string for Date writing)
    dtfs = \"yyyy-mm-ddTHH:MM:SS\" (format string for DateTime)

Code-Example for writing the Julia `test` data
to an text file `test_de.csv` readable by Excel(lang=german):

    writedlm2(\"test_de.csv\", test, dtfs=\"dd.mm.yyyy HH:MM\", dfs=\"dd.mm.yyyy\")

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
    write_short ? print_shortest(iob, a) : print(iob, a)
    if decimal != '.'
        ar = replace(takebuf_string(iob), '.', decimal)
    else
        ar = takebuf_string(iob)
    end
    return ar
end

function writedlm2auto(f, a, dlm;
        decimal::Char=',',
        write_short::Bool=true,
        dfs::AbstractString="yyyy-mm-dd",
        dtfs::AbstractString="yyyy-mm-ddTHH:MM:SS", 
        opts...)

    string(dlm) == string(decimal) && error(
        "Error in writedlm(): Special decimal mark = delimiter = ´$(dlm)´")

    if isa(a, Union{Number, Date, DateTime})
         a1 = a # keep a in a1
         a = [a]  # create 1 element Array a
         restore = true
     else
         restore = false
     end

     if isa(a, AbstractArray)
         #format dates only if formatstrings are not ISO and not ""
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
         if restore
             a = a1 # restore a
         end
     else
         b = a # a is not a Number, Date, DateTime or Array -> no preprocessing
     end

     writedlm(f, b, dlm; opts...)

    end # end function writedlm2auto()

end # end modul ReadWriteDlm2
