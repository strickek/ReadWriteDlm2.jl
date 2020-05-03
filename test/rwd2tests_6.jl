#2020 Klaus Stricker - Tests for ReadWriteDlm2
#License is MIT: http://julialang.org/license

# rwd2tests_6.jl


@testset "6_1    Examples" begin

    # README.md - Basic Example

    a = ["text" 1.2; Date(2017,1,1) 1]      # create array with eltype: String, Date, Float64 and Int
    writedlm2("test.csv", a)                # test.csv(decimal comma): "text;1,2\n2017-01-01;1\n"
    @test readdlm2("test.csv") == a         # read `CSV` data: All four eltypes are parsed correctly!

    b = readdlm2("test.csv", tables=true)   # test Tables interface
    # b = ReadWriteDlm2.MatrixTable: (Column1 = Any["text", 2017-01-01], Column2 = Real[1.2, 1])
    @test Tables.istable(typeof(b))
    @test Tables.rowaccess(typeof(b))
    @test Tables.getcolumn(b, :Column1) == Any["text", Date(2017,1,1)]
    @test Tables.getcolumn(b, :Column2) == Real[1.2, 1]
    @test Tables.getcolumn(b, 1) == Any["text", Date(2017,1,1)]
    @test Tables.getcolumn(b, 2) == Real[1.2, 1]
    @test Tables.columnnames(b) == [:Column1, :Column2]
    fr = first(b)    # first row of 'b' = ReadWriteDlm2.MatrixRow: (Column1 = "text", Column2 = 1.2)
    @test eltype(b) == typeof(fr)  # ReadWriteDlm2.MatrixRow


    # README.md - More Examples

    # `writecsv2()` And `readcsv2()`
    a = Any[1 complex(1.5,2.7);1.0 1//3]    # create array with: Int, Complex, Float64 and Rational type
    writecsv2("test.csv", a)                # test.csv(decimal dot): "1,1.5+2.7im\n1.0,1//3\n"
    @test readcsv2("test.csv")  == a        # read CSV data: All four types are parsed correctly!
    rm("test.csv")

    # `writedlm2()` And `readdlm2()` With Special `decimal=`
    a = Float64[1.1 1.2;2.1 2.2]
    writedlm2("test.csv", a; decimal='€')     # '€' is decimal Char in 'test.csv'
    @test readdlm2("test.csv", Float64; decimal='€') == a     # standard: use keyword argument
    @test readdlm2("test.csv", Float64; rs=(r"(\d)€(\d)", s"\1.\2")) == a   # alternativ: rs-Regex-Tupel
    rm("test.csv")

    # `writedlm2()` And `readdlm2()` With `Union{Missing, Float64}`
    a = Union{Missing, Float64}[1.1 0/0;missing 2.2;1/0 -1/0]
    writedlm2("test.csv", a; missingstring="???")     # use "???" for missing data
    @test read("test.csv", String) == "1,1;NaN\n???;2,2\nInf;-Inf\n"
    b = readdlm2("test.csv", Union{Missing, Float64}; missingstring="???")
    @test typeof(a) == typeof(b)
    @test isequal(a, b)
    rm("test.csv")

    # `Date` And `DateTime` With `locale="french"`
    Dates.LOCALES["french"] = Dates.DateLocale(
        ["janvier", "février", "mars", "avril", "mai", "juin",
            "juillet", "août", "septembre", "octobre", "novembre", "décembre"],
        ["janv", "févr", "mars", "avril", "mai", "juin",
            "juil", "août", "sept", "oct", "nov", "déc"],
        ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"],
        ["lu", "ma", "me", "je", "ve", "sa", "di"],
        );

    a = hcat([Date(2017,1,1), DateTime(2017,1,1,5,59,1,898), 1, 1.0, "text"])
    writedlm2("test.csv", a; dfs="E, d.U yyyy", dtfs="e, d.u yyyy H:M:S,s", locale="french")

    @test read("test.csv", String) == "dimanche, 1.janvier 2017\ndi, 1.janv 2017 5:59:1,898\n1\n1,0\ntext\n"

    @test readdlm2("test.csv"; dfs="E, d.U yyyy", dtfs="e, d.u yyyy H:M:S,s", locale="french") == a
    rm("test.csv")

end

@testset "6_2 df-Examples" begin
    cn = [:date, :value_1, :value_2]
    mat = [Date(2017,1,1) 1.4 2;
           Date(2017,1,2) 1.8 3;
           nothing missing 4]
    ct = [Union{Nothing, Date}, Union{Missing, Float64}, Int64]
    vof = ReadWriteDlm2.vecofvec(mat, ct) # take columns from array -> Vector{Vector{ct}}
    # first, create a MatrixTable from our Vector{Vector{T}} input
    mattdf = Tables.table(vof, header=cn)
    # test that the MatrixTable `istable`
    @test Tables.istable(typeof(mattdf))
    # test that it defines row access
    @test Tables.rowaccess(typeof(mattdf))
    @test Tables.rows(mattdf) === mattdf
    # test that it defines column access
    @test Tables.columnaccess(typeof(mattdf))
    @test Tables.columns(mattdf) === mattdf
    # test that we can access the first "column" of our matrix table by column name
    @test mattdf.date == [Date(2017,1,1),Date(2017,1,2),nothing]
    # test our `Tables.AbstractColumns` interface methods
    @test Tables.getcolumn(mattdf, :date) == [Date(2017,1,1),Date(2017,1,2),nothing]
    @test Tables.getcolumn(mattdf, 1) == [Date(2017,1,1),Date(2017,1,2),nothing]
    @test Tables.columnnames(mattdf) == [:date, :value_1, :value_2]
    # now let's iterate our MatrixTable to get our first MatrixRow
    matrow = first(mattdf)
    @test eltype(mattdf) == typeof(matrow)
    # now we can test our `Tables.AbstractRow` interface methods on our MatrixRow
    @test matrow.date == Date(2017,1,1)
    @test matrow.value_1 == 1.4
    @test Tables.getcolumn(matrow, :date) == Date(2017,1,1)
    @test Tables.getcolumn(matrow, 1) == Date(2017,1,1)
    @test propertynames(mattdf) == propertynames(matrow) == cn

    # write CSV
    cna = reshape(Tables.columnnames(mattdf), 1, :)
    amt = ReadWriteDlm2.mttoarray(mattdf)
    a = vcat(cna, amt)
    writedlm2("test1.csv", a)
    writecsv2("test2.csv", a)

    # read CSV / Tables Interface
    @test read("test1.csv", String) ==
    "date;value_1;value_2\n2017-01-01;1,4;2\n2017-01-02;1,8;3\nnothing;na;4\n"
    @test read("test2.csv", String) ==
    "date,value_1,value_2\n2017-01-01,1.4,2\n2017-01-02,1.8,3\nnothing,na,4\n"
    df2input1 = readdlm2("test1.csv", tables=true, header=true)
    df2input2 = readcsv2("test2.csv", tables=true, header=true)
    rm("test1.csv")
    rm("test2.csv")

    # test result from reading csv
    @test Tables.istable(typeof(df2input1))
    @test Tables.istable(typeof(df2input2))
    # test that it defines row access
    @test Tables.rowaccess(typeof(df2input1))
    @test Tables.rowaccess(typeof(df2input2))
    @test Tables.rows(df2input1) === df2input1
    @test Tables.rows(df2input2) === df2input2
    # test that it defines column access
    @test Tables.columnaccess(typeof(df2input1))
    @test Tables.columnaccess(typeof(df2input2))
    @test Tables.columns(df2input1) === df2input1
    @test Tables.columns(df2input2) === df2input2
    # test that we can access the first "column" of our matrix table by column name
    @test df2input1.date == [Date(2017,1,1),Date(2017,1,2),nothing]
    @test df2input2.date == [Date(2017,1,1),Date(2017,1,2),nothing]
    # test our `Tables.AbstractColumns` interface methods
    @test Tables.getcolumn(df2input1, :date) == [Date(2017,1,1),Date(2017,1,2),nothing]
    @test Tables.getcolumn(df2input1, 1) == [Date(2017,1,1),Date(2017,1,2),nothing]
    @test Tables.columnnames(df2input1) == [:date, :value_1, :value_2]
    @test Tables.getcolumn(df2input2, :date) == [Date(2017,1,1),Date(2017,1,2),nothing]
    @test Tables.getcolumn(df2input2, 1) == [Date(2017,1,1),Date(2017,1,2),nothing]
    @test Tables.columnnames(df2input2) == [:date, :value_1, :value_2]
    # now let's iterate our MatrixTable to get our first MatrixRow
    matrow = first(df2input1)
    @test eltype(df2input1) == typeof(matrow)
    matrow = first(df2input2)
    @test eltype(df2input2) == typeof(matrow)
    # now we can test our `Tables.AbstractRow` interface methods on our MatrixRow
    @test matrow.date == Date(2017,1,1)
    @test matrow.value_1 == 1.4
    @test Tables.getcolumn(matrow, :date) == Date(2017,1,1)
    @test Tables.getcolumn(matrow, 1) == Date(2017,1,1)
    @test propertynames(df2input1) == propertynames(matrow) == cn
    @test matrow.date == Date(2017,1,1)
    @test matrow.value_1 == 1.4
    @test Tables.getcolumn(matrow, :date) == Date(2017,1,1)
    @test Tables.getcolumn(matrow, 1) == Date(2017,1,1)
    @test propertynames(df2input2) == propertynames(matrow) == cn
end
