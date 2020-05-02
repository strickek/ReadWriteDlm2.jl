# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - rwd2_csv.jl - https://github.com/strickek/ReadWriteDlm2.jl

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
writecsv2(f, a; opts...) = writedlm2auto(f, a, ','; decimal='.', opts...)
