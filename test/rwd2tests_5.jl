#2020 Klaus Stricker - Tests for ReadWriteDlm2
#License is MIT: http://julialang.org/license

# rwd2tests_5.jl

# Tests for Tables interface
# ==========================

@testset "5_Stand1 Tables" begin
    mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
    # first, create a MatrixTable from our matrix input
    mattbl = Tables.table(mat)
    # test that the MatrixTable `istable`
    @test Tables.istable(typeof(mattbl))
    # test that it defines row access
    @test Tables.rowaccess(typeof(mattbl))
    # test that it defines column access
    @test Tables.columnaccess(typeof(mattbl))
    @test Tables.columns(mattbl) === mattbl
    # test that we can access the first "column" of our matrix table by column name
    @test mattbl.Column1 == [1,2,3]
    # test our `Tables.AbstractColumns` interface methods
    @test Tables.getcolumn(mattbl, :Column1) == [1,2,3]
    @test Tables.getcolumn(mattbl, 1) == [1,2,3]
    @test Tables.columnnames(mattbl) == [:Column1, :Column2, :Column3]
    # now let's iterate our MatrixTable to get our first MatrixRow
    matrowtbl = Tables.rows(mattbl)
    matrow = first(matrowtbl)
    @test eltype(matrowtbl) == typeof(matrow)
    # now we can test our `Tables.AbstractRow` interface methods on our MatrixRow
    @test matrow.Column1 == 1
    @test Tables.getcolumn(matrow, :Column1) == 1
    @test Tables.getcolumn(matrow, 1) == 1
    @test propertynames(mattbl) == propertynames(matrow) == [:Column1, :Column2, :Column3]
end

@testset "5_Stand2 Tables" begin
    rt = [(a=1, b=4.0, c="7"), (a=2, b=5.0, c="8"), (a=3, b=6.0, c="9")]
    ct = (a=[1,2,3], b=[4.0, 5.0, 6.0])
    # let's turn our row table into a plain Julia Matrix object
    mat = Tables.matrix(rt)
    # test that our matrix came out like we expected
    @test mat[:, 1] == [1, 2, 3]
    @test size(mat) == (3, 3)
    @test eltype(mat) == Any
    # so we successfully consumed a row-oriented table,
    # now let's try with a column-oriented table
    mat2 = Tables.matrix(ct)
    @test eltype(mat2) == Float64
    @test mat2[:, 1] == ct.a

    # now let's take our matrix input, and make a column table out of it
    tbl = Tables.table(mat) |> Tables.columntable
    @test keys(tbl) == (:Column1, :Column2, :Column3)
    @test tbl.Column1 == [1, 2, 3]
    # and same for a row table
    tbl2 = Tables.table(mat2) |> Tables.rowtable
    @test length(tbl2) == 3
    @test map(x->x.Column1, tbl2) == [1.0, 2.0, 3.0]
end

@testset "5_matrix2  Tabl" begin
    mat = Any[1 4.0 true "a"; 2 5.0 false "b"; 3 6.0 true "c"]
    # first, create a MatrixTable from our matrix input
    mattbl = Tables.table(mat)
    # test that the MatrixTable `istable`
    @test Tables.istable(typeof(mattbl))
    # ReadWriteDlm2.matrix2: Matrix{Any}, first row Symbol colnames
    ma2 = ReadWriteDlm2.matrix2(mattbl)
    # test that it defines row access
    @test Tables.rowaccess(typeof(mattbl))
    # test that it defines column access
    @test Tables.columnaccess(typeof(mattbl))
    @test Tables.columns(mattbl) === mattbl
    # test that data fit
    @test mattbl.Column1 == [1, 2, 3]
    @test mattbl.Column2 == [4.0, 5.0, 6.0]
    @test mattbl.Column3 == [true, false, true]
    @test mattbl.Column4 == ["a", "b", "c"]
    matrowtbl = Tables.rows(mattbl)
    @test length(matrowtbl) === 3
    @test ma2[2:end, 1] == [1, 2, 3]
    @test ma2[2:end, 2] == [4.0, 5.0, 6.0]
    @test ma2[2:end, 3] == [true, false, true]
    @test ma2[2:end, 4] == ["a", "b", "c"]
    @test ma2[1, :] == [:Column1, :Column2, :Column3, :Column4]
    # test our `Tables.AbstractColumns` interface methods
    @test Tables.getcolumn(mattbl, :Column1) == [1, 2, 3]
    @test Tables.getcolumn(mattbl, 1) == [1, 2, 3]
    @test Tables.columnnames(mattbl) == [:Column1, :Column2, :Column3, :Column4]
    # now let's iterate our MatrixTable to get our first MatrixRow
    matrow = first(matrowtbl)
    @test eltype(matrowtbl) == typeof(matrow)
    # now we can test our `Tables.AbstractRow` interface methods on our MatrixRow
    @test matrow.Column1 == 1
    @test Tables.getcolumn(matrow, :Column1) == 1
    @test Tables.getcolumn(matrow, 1) == 1
    @test propertynames(mattbl) == propertynames(matrow) == [:Column1, :Column2, :Column3, :Column4]
end

@testset "5_Speci  Tables" begin
    mat = [1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
    ct = [Int64, Float64, String]
    vof = ReadWriteDlm2.vecofvec(mat, ct) # take columns from array -> Vector{Vector{ct}}
    # first, create a MatrixTable from our Vector{Vector{T}} input
    mattbl = Tables.table(vof)
    # test that the MatrixTable `istable`
    @test Tables.istable(typeof(mattbl))
    # test that it defines row access
    @test Tables.rowaccess(typeof(mattbl))
    @test Tables.rows(mattbl) === mattbl
    # test that it defines column access
    @test Tables.columnaccess(typeof(mattbl))
    @test Tables.columns(mattbl) === mattbl
    # test that we can access the first "column" of our matrix table by column name
    @test mattbl.Column1 == [1,2,3]
    # test our `Tables.AbstractColumns` interface methods
    @test Tables.getcolumn(mattbl, :Column1) == [1,2,3]
    @test Tables.getcolumn(mattbl, 1) == [1,2,3]
    @test Tables.getcolumn(mattbl, ReadWriteDlm2.MatrixTable, 1, :Column1) == [1,2,3]
    @test Tables.columnnames(mattbl) == [:Column1, :Column2, :Column3]
    @test length(mattbl) === 3
    @test iterate(mattbl)[1] == first(mattbl)
    @test iterate(mattbl)[2] == 2
    @test iterate(mattbl, 4) == nothing
    @test Tables.schema(mattbl) ==
        Tables.Schema([:Column1, :Column2, :Column3], [Int64, Float64, String])
    # now let's iterate our MatrixTable to get our first MatrixRow
    matrow = first(mattbl)
    @test eltype(mattbl) == typeof(matrow)
    # now we can test our `Tables.AbstractRow` interface methods on our MatrixRow
    @test matrow.Column1 == 1
    @test matrow.Column2 == 4.0
    @test Tables.getcolumn(matrow, :Column1) == 1
    @test Tables.getcolumn(matrow, 1) == 1
    @test Tables.getcolumn(matrow, ReadWriteDlm2.MatrixRow, 1, :Column1) == 1
    @test propertynames(mattbl) == propertynames(matrow) == [:Column1, :Column2, :Column3]
end

@testset "5_rwdf   Tables" begin
    ma_in = Any[1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
    ct = [Int64, Float64, String]
    # take columns from array -> Vector{Vector{ct}}
    vof = ReadWriteDlm2.vecofvec(ma_in, ct)
    # create a MatrixTable from our Vector{Vector{T}} input
    mattbl = Tables.table(vof)
    @test Tables.istable(typeof(mattbl))
    # take data from Matrixtable mattbl in array
    ma_out = ReadWriteDlm2.mttoarray(mattbl, elt=Any)
    # test input array = output array
    @test ma_out == ma_in

    ma_in = Any[1 4.0 "7"; 2 5.0 "8"; 3 6.0 "9"]
    ct = [Float64, Float64, String]
    # take columns from array -> Vector{Vector{ct}}
    vof = ReadWriteDlm2.vecofvec(ma_in, ct)
    # create a MatrixTable from our Vector{Vector{T}} input
    mattbl = Tables.table(vof)
    @test Tables.istable(typeof(mattbl))
    # take data from Matrixtable mattbl in array
    ma_out = ReadWriteDlm2.mttoarray(mattbl, elt=Union{String, Float64})
    # test input array = output array (different types in column1), but ok
    @test ma_out == ma_in


    cn = [:date, :value_1, :value_2]
    mat = [Date(2017,1,1) 1.4 2;
           Date(2017,1,2) 1.8 3;
           nothing missing 4]
    ct = [Union{Nothing, Date}, Union{Missing, Float64}, Int64]
    cna = reshape(cn, 1, :)
    a = vcat(cna, mat)
    writedlm2("test.csv", a)
    astr = read("test.csv", String)
    cstr = "date;value_1;value_2\n2017-01-01;1,4;2\n2017-01-02;1,8;3\nnothing;na;4\n"
    @test astr == cstr
    rdlm1 = readdlm2("test.csv", tables=true, header=true)
    aro1 = ReadWriteDlm2.mttoarray(rdlm1)
    @test isequal(aro1, mat)
    rdlm2 = readdlm2("test.csv", Union{Missing, Nothing, Date, Float64},
                    tables=true, header=true)
    aro2 = ReadWriteDlm2.mttoarray(rdlm2)
    @test isequal(aro2, mat)
    rm("test.csv")
end

@testset "5_csvdlm Tables" begin
    cn = [:date, :value_1, :value_2]
    mat = [Date(2017,1,1) 1.4 2;
           Date(2017,1,2) 1.8 3]
    ct = [Union{Nothing, Date}, Union{Missing, Float64}, Int64]
    vof = ReadWriteDlm2.vecofvec(mat, ct) # take columns from array -> Vector{Vector{ct}}
    # first, create a MatrixTable from our Vector{Vector{T}} input
    mattdf = Tables.table(vof, header=cn)
    # write CSV
    cna = reshape(Tables.columnnames(mattdf), 1, :)
    amt = ReadWriteDlm2.mttoarray(mattdf)
    a = vcat(cna, amt)
    writedlm2("test1.csv", a)
    writecsv2("test2.csv", a)
    # read CSV / Tables Interface
    @test read("test1.csv", String) ==
    "date;value_1;value_2\n2017-01-01;1,4;2\n2017-01-02;1,8;3\n"
    @test read("test2.csv", String) ==
    "date,value_1,value_2\n2017-01-01,1.4,2\n2017-01-02,1.8,3\n"
    df2input1a = readdlm2("test1.csv", dfheader=true)
    df2input2a = readcsv2("test2.csv", dfheader=true)
    @test string(df2input1a) == string(df2input2a)
    df2input1 = readdlm2("test1.csv", tables=true, header=true)
    df2input2 = readcsv2("test2.csv", tables=true, header=true)
    @test string(df2input1) == string(df2input2)
    @test string(df2input1) == string(df2input1a)
    @test string(df2input2) == string(df2input2a)
end

@testset "5_MisNtg Tables" begin
    cn = [:date, :value_1, :value_2]
    mat = [Date(2017,1,1) 1.4 missing;
           Date(2017,1,2) 1.8 nothing]
    ct = [Date, Float64, Union{Missing, Nothing}]
    vof = ReadWriteDlm2.vecofvec(mat, ct) # take columns from array -> Vector{Vector{ct}}
    # first, create a MatrixTable from our Vector{Vector{T}} input
    mattdf = Tables.table(vof, header=cn)
    # write CSV
    cna = reshape(Tables.columnnames(mattdf), 1, :)
    amt = ReadWriteDlm2.mttoarray(mattdf)
    a = vcat(cna, amt)
    writedlm2("test1.csv", a)
    writecsv2("test2.csv", a)
    # read CSV / Tables Interface
    @test read("test1.csv", String) ==
    "date;value_1;value_2\n2017-01-01;1,4;na\n2017-01-02;1,8;nothing\n"
    @test read("test2.csv", String) ==
    "date,value_1,value_2\n2017-01-01,1.4,na\n2017-01-02,1.8,nothing\n"
    df2input1a = readdlm2("test1.csv", dfheader=true)
    df2input2a = readcsv2("test2.csv", dfheader=true)
    @test string(df2input1a) == string(df2input2a)
    df2input1 = readdlm2("test1.csv", tables=true, header=true)
    df2input2 = readcsv2("test2.csv", tables=true, header=true)
    @test string(df2input1) == string(df2input2)
    @test string(df2input1) == string(df2input1a)
    @test string(df2input2) == string(df2input2a)
end
