#2020 Klaus Stricker - Tests for ReadWriteDlm2
#License is MIT: http://julialang.org/license

# rwd2tests_4.jl

# Tests for readcsv2 and writecsv2
# ================================

@testset "4_readwritecsv2" begin
    # test comments with readcsv2
    @test isequaldlm(readcsv2(IOBuffer("#this is comment\n1,2,3\n#one more comment\n4,5,6"), comments=true), Any[1 2 3;4 5 6], Any)
    @test isequaldlm(readcsv2(IOBuffer("#this is \n#comment\n1,2,3\n#one more \n#comment\n4,5,6"), comments=true), Any[1 2 3;4 5 6], Any)

    # test readcsv2 and writecsv2 with alternative decimal
    a = Float64[1.1 1.2;2.1 2.2]
    writecsv2("test.csv", a, decimal='€')
    @test read("test.csv", String) == "1€1,1€2\n2€1,2€2\n"
    b = readcsv2("test.csv", Any, rs=(r"(\d)€(\d)", s"\1.\2"), decimal='n')
    rm("test.csv")
    @test a == b

    #  Test different types with header for readcsv2 and writecsv2
    a = Any["Nr" "Value";1 Date(2017);2 DateTime(2018);3 Dates.Time(23,54,45,123,456,78);4 1.5e10+5im;5 1500//5;6 1.5e10]
    writecsv2("test.csv", a)
    @test read("test.csv", String) ==
    """
    Nr,Value
    1,2017-01-01
    2,2018-01-01T00:00:00.0
    3,23:54:45.123456078
    4,1.5e10+5.0im
    5,300//1
    6,1.5e10
    """
    b = readcsv2("test.csv", header=true)
    rm("test.csv")
    @test a[2:end,:] == b[1]
    @test a[1:1,:] == b[2]

    # Test size for readcsv2
    @test size(readcsv2(IOBuffer("1,2,3,4"))) == (1,4)
    @test size(readcsv2(IOBuffer("1,2,3,"))) == (1,4)
    @test size(readcsv2(IOBuffer("1,2,3,4\n"))) == (1,4)
    @test size(readcsv2(IOBuffer("1,2,3,\n"))) == (1,4)
    @test size(readcsv2(IOBuffer("1,2,3,4\n1,2,3,4"))) == (2,4)
    @test size(readcsv2(IOBuffer("1,2,3,4\n1,2,3,"))) == (2,4)
    @test size(readcsv2(IOBuffer("1,2,3,4\n1,2,3"))) == (2,4)

    @test size(readcsv2(IOBuffer("1,2,3,4\r\n"))) == (1,4)
    @test size(readcsv2(IOBuffer("1,2,3,4\r\n1,2,3\r\n"))) == (2,4)
    @test size(readcsv2(IOBuffer("1,2,3,4\r\n1,2,3,4\r\n"))) == (2,4)
    @test size(readcsv2(IOBuffer("1,2,3,\"4\"\r\n1,2,3,4\r\n"))) == (2,4)

    #Time types for readcsv2 and writecsv2
    a = [Dates.Time(23,55,56,123,456,789) Dates.Time(23,55,56,123,456) Dates.Time(23,55,56,123) Dates.Time(12,45) Dates.Time(11,23,11)]
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "23:55:56.123456789,23:55:56.123456,23:55:56.123,12:45:00,11:23:11\n"
    b = readcsv2("test.csv")
    rm("test.csv")
    @test b == a

    # Test readcsv2/writecsv2 with Complex - Rationals
    a = Complex[complex(-1//3,-7//5) complex(1,-1//3) complex(-1//2,3e-19)]
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "-1//3-7//5*im,1//1-1//3*im,-0.5+3.0e-19im\n"
    b = readcsv2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}
end

@testset "4_empty IO-data" begin
    # Tests for empty IO-Data
    a = ""
    writedlm2("test.csv", a)
    @test read("test.csv", String) == ""
    b = readdlm2("test.csv")
    @test typeof(b) == Array{Any,2}
    @test typeof(readdlm2("test.csv", Any)) == Array{Any,2}
    rm("test.csv")
    @test isempty(b)
    writecsv2("test.csv", a)
    @test read("test.csv", String) == ""
    b = readcsv2("test.csv")
    @test typeof(b) == Array{Any,2}
    @test typeof(readcsv2("test.csv", Float64)) == Array{Float64,2}
    rm("test.csv")
    @test isempty(b)

    a = [""]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "\n"
    b = readdlm2("test.csv")
    @test typeof(b) == Array{Any,2}
    @test typeof(readdlm2("test.csv", Any)) == Array{Any,2}
    rm("test.csv")
    @test isempty(b)
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "\n"
    b = readcsv2("test.csv")
    @test typeof(b) == Array{Any,2}
    @test typeof(readcsv2("test.csv", Float64)) == Array{Float64,2}
    rm("test.csv")
    @test isempty(b)

    a = missing
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "na\n"
    b = readcsv2("test.csv")
    rm("test.csv")
    @test typeof(b) == Array{Any,2}
    @test isequal(a, b[1])
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "na\n"
    b = readcsv2("test.csv")
    rm("test.csv")
    @test typeof(b) == Array{Any,2}
    @test isequal(a, b[1])

    a = [nothing]
    a = reshape(a, 1,1)
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "nothing\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test typeof(b) == Array{Any,2}
    @test isequal(a, b)
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "nothing\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test typeof(b) == Array{Any,2}
    @test isequal(a, b)

    a = [1.2 NaN "" nothing missing]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "1,2;NaN;;nothing;na\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test isequal(a, b)

    a = [1.2 NaN "" nothing missing]
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "1.2,NaN,,nothing,na\n"
    b = readcsv2("test.csv")
    rm("test.csv")
    @test isequal(a, b)

end

@testset "4_  random data" begin
    # Test write and read of random Any array with 10000 rows
    n = 1000
    A = Array{Any}(undef, n, 9)
    for i = 1:n
        A[i,:] = Any[randn() rand(Int) rand(Bool) rand(Date(1980,1,1):Day(1):Date(2017,12,31)) rand(Dates.Time(0,0,0,0,0,0):Dates.Nanosecond(1):Dates.Time(23,59,59,999,999,999)) rand(DateTime(1980,1,1,0,0,0,0):Dates.Millisecond(1):DateTime(2017,12,31,23,59,59,999)) randstring(24) complex(randn(), randn()) (rand(Int)//rand(Int))]
    end

    writedlm2("test.csv", A)
    B = readdlm2("test.csv")
    rm("test.csv")
    @test isequaldlm(A, B, Any)

    writecsv2("test.csv", A)
    B = readcsv2("test.csv")
    rm("test.csv")
    @test isequaldlm(A, B, Any)
end


@testset "4_abstract type" begin

    #Abstract Time Types
    a = TimeType[Date(2017, 1, 1) DateTime(2017, 2, 15, 23, 0, 0)]
    writedlm2("test.csv", a, dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
    b = readdlm2("test.csv", TimeType, dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
    @test isequaldlm(a, b, TimeType)
    b = readdlm2("test.csv", TimeType, rs=(), dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
    rm("test.csv")
    @test isequaldlm(a, b, TimeType)

    # Abstract Number
    a = Number[1 1.1 1//3 complex(-1,-2) complex(1.2,-2) complex(-1e9,3e-19)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "1;1,1;1//3;-1-2im;1,2-2,0im;-1,0e9+3,0e-19im\n"
    b = readdlm2("test.csv", Number)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Number,2}

    # Abstract real
    a = readdlm2(IOBuffer("1,1;2\n3;4,5\n5;1//3\n"), Real)
    b = Real[1.1 2; 3 4.5; 5 1//3]
    @test a == b
    @test typeof(a) == typeof(b)

end

@testset "4_    1 0 1 0 0" begin

    # Different Types for "1 0 1 0 0"
    a = readdlm2(IOBuffer("1;0;1;0;0\n"))
    b = Any[1 0 1 0 0]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Float64)
    b = [1.0 0.0 1.0 0.0 0.0]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Float16)
    b = Float16[1.0 0.0 1.0 0.0 0.0]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Int)
    b = [1 0 1 0 0]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Char)
    b = ['1' '0' '1' '0' '0']
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), AbstractString)
    b = AbstractString["1" "0" "1" "0" "0"]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), String)
    b = ["1" "0" "1" "0" "0"]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Bool)
    b = [true false true false false]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Complex{Int})
    b = [1+0im 0+0im 1+0im 0+0im 0+0im]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Complex{Float64})
    b = [1.0+0.0im 0.0+0.0im 1.0+0.0im 0.0+0.0im 0.0+0.0im]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Complex{Rational{Int}})
    b = [1//1+0//1*im 0//1+0//1*im 1//1+0//1*im 0//1+0//1*im 0//1+0//1*im]
    @test a == b
    @test typeof(a) == typeof(b)

    a = readdlm2(IOBuffer("1;0;1;0;0\n"), Rational)
    b = Rational[1//1 0//1 1//1 0//1 0//1]
    @test a == b
    @test typeof(a) == typeof(b)

end
