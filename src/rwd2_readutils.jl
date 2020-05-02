# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - rwd2_readutils.jl- https://github.com/strickek/ReadWriteDlm2.jl

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
