# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - rwd2_tables.jl - https://github.com/strickek/ReadWriteDlm2.jl

"""
    ReadWriteDlm2.matrix2(table)
Materialize any table source input as a `Matrix{Any}`.
Column names - in Symbol type - are written in first row.
"""
function matrix2(table)
    cols = Tables.columns(table)
    cnames = Tables.columnnames(table)
    nr = length(table) + 1
    nc = length(cnames)
    matrix = Matrix{Any}(undef, nr, nc)
    for (i, col) in enumerate(Tables.Columns(cols))
        matrix[1, i] = cnames[i]
        matrix[2:end, i] = col
    end
    return matrix
end

"""
    vecofvec(a::Matrix, ct::Vector{Type})
Take the columns of Matrix `a`, convert each column to `Array{T,1} where T`
(`ct` provides Type), and return the columns as `Vector{Array{T,1} where T}`.
"""
function vecofvec(a::Matrix, ct::Vector{<:Type})
    cols = size(a, 2)
    cols == length(ct) || throw(ArgumentError(
        "`ct` length ($(length(ct))) must match number of columns in matrix ($(size(a, 2)))"
        ))
    vov = Vector{Array{T,1} where T}(undef, cols)
    for i = 1:cols
        vov[i] = convert(Vector{ct[i]}, view(a, :,i))
    end
    return vov
end

# MatrixTable - ReadWriteDlm2 outputformat for Tables interface
struct MatrixTable <: Tables.AbstractColumns
    names::Vector{Symbol}
    lookup::Dict{Symbol, Int}
    matrix::Vector{Array{T,1} where T}
end

# Overload Table.table for m::Vector{Vector}
"""
    Tables.table(m::Vector{Array{T,1} where T; [header::Vector{Symbol}])
Wrap an vector containing columns as vectors (`Array{T,1} where T`) in a
`MatrixTable`, which satisfies the Tables.jl interface. This allows accesing
the matrix via `Tables.rows` and `Tables.columns`. An optional keyword argument
`header` can be passed as a `Vector{Symbol}` to be used as the column names.
"""
function Tables.table(m::Vector{Array{T,1} where T};
    header::Vector{Symbol} = [Symbol("Column$i") for i = 1:length(m)]
    )
    length(header) == length(m) || throw(ArgumentError(
    "`header` length must match number of columns in matrix ($(length(m)))"))
    lookup = Dict(nm=>i for (i, nm) in enumerate(header))
    return MatrixTable(header, lookup, m)
end

"""
    mttoarray(m::ReadWriteDlm2.MatrixTable; elt::Type=Union{})
Take Vectors of field matrix in MatrixTable `m` and return data as Array{T,2}.
With given `elt` T=elt, otherwise T is the union of element types in matrix.
"""
function mttoarray(m::ReadWriteDlm2.MatrixTable; elt::Type=Union{})
    ma = ReadWriteDlm2.matrix(m)
    nc = length(ma)
    nr = length(ma[1])
    elt == Union{} ? T1 = Any : T1 = elt
    a = Array{T1}(undef, (nr,nc))
    T = elt
    for i in eachindex(ma)
        T = Union{T, eltype(m[i])}
        a[:,i] = m[i]
    end
    elt != Union{} && return a
    return convert(Array{T,2}, a)
end

# declare that MatrixTable is a table
Tables.istable(::Type{<:MatrixTable}) = true
# getter methods to avoid getproperty clash
names(m::MatrixTable) = getfield(m, :names)
matrix(m::MatrixTable) = getfield(m, :matrix)
lookup(m::MatrixTable) = getfield(m, :lookup)
# schema is column names and types
Tables.schema(m::MatrixTable) = Tables.Schema(names(m), eltype.(matrix(m)))

# column interface
Tables.columnaccess(::Type{<:MatrixTable}) = true
Tables.columns(m::MatrixTable) = m
# required Tables.AbstractColumns object methods
Tables.getcolumn(m::MatrixTable, ::Type{T}, col::Int, nm::Symbol) where {T} = matrix(m)[col]
Tables.getcolumn(m::MatrixTable, nm::Symbol) = matrix(m)[lookup(m)[nm]]
Tables.getcolumn(m::MatrixTable, i::Int) = matrix(m)[i]
Tables.columnnames(m::MatrixTable) = names(m)

# declare that any MatrixTable defines its own `Tables.rows` method
Tables.rowaccess(::Type{<:MatrixTable}) = true
# just return itself, which means MatrixTable must iterate `Tables.AbstractRow`-compatible objects
Tables.rows(m::MatrixTable) = m
# the iteration interface, at a minimum, requires `eltype`, `length`, and `iterate`
# for `MatrixTable` `eltype`, we're going to provide a custom row type
Base.eltype(m::MatrixTable) = MatrixRow
Base.length(m::MatrixTable) = length(matrix(m)[1])
Base.iterate(m::MatrixTable, st=1) = st > length(m) ? nothing : (MatrixRow(st, m), st + 1)

# a custom row type; acts as a "view" into a row of an AbstractMatrix
struct MatrixRow <: Tables.AbstractRow
    row::Int
    source::MatrixTable
end
# required `Tables.AbstractRow` interface methods (same as for `Tables.AbstractColumns` object before)
# but this time, on our custom row type
Tables.getcolumn(m::MatrixRow, ::Type, col::Int, nm::Symbol) =
    getfield(getfield(m, :source), :matrix)[col][getfield(m, :row)]
Tables.getcolumn(m::MatrixRow, i::Int) =
    getfield(getfield(m, :source), :matrix)[i][getfield(m, :row)]
Tables.getcolumn(m::MatrixRow, nm::Symbol) =
    getfield(getfield(m, :source), :matrix)[getfield(getfield(m, :source), :lookup)[nm]][getfield(m, :row)]
Tables.columnnames(m::MatrixRow) = names(getfield(m, :source))
