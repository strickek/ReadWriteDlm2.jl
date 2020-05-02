# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - rwd2_writeutils.jl - https://github.com/strickek/ReadWriteDlm2.jl

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
