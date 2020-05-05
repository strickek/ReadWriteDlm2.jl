#2020 Klaus Stricker - Tests for ReadWriteDlm2
#License is MIT: http://julialang.org/license

# rwd2tests_3.jl

@testset "3_  other types" begin

    # Test Complex and Rational parsing
    a = Any[complex(-1,-2) complex(1.2,-2) complex(1e9,3e19) 1//3 -1//5 -2//-4 1//-0 -0//1]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "-1-2im;1,2-2,0im;1,0e9+3,0e19im;1//3;-1//5;1//2;1//0;0//1\n"
    b = readdlm2("test.csv", Any)
    rm("test.csv")
    @test isequaldlm(a, b, Any)

    # Complex and Rational - tolerance with blancs, i/j and different signes
    write("test.csv", "    -1-2j; 1,2 - 2,0i ;1.0E9+3.0E19im;   -1//-3;1//-5;  1//2 ;1//-0;-0//1 \n")
    b = readdlm2("test.csv", Any)
    rm("test.csv")
    @test b == a

    # Test Complex and Rational parsing - decimal = '.', delimiter = \t
    a = Any[complex(-1,-2) complex(1.2,-2) complex(1e9,3e19) 1//3 -1//5 -2//-4 1//-0 -0//1]
    writedlm2("test.csv", a, '\t', decimal='.')
    @test read("test.csv", String) == "-1-2im\t1.2-2.0im\t1.0e9+3.0e19im\t1//3\t-1//5\t1//2\t1//0\t0//1\n"
    b = readdlm2("test.csv",'\t', Any, decimal='.')
    rm("test.csv")
    @test isequaldlm(a, b, Any)

    #  Test different types with header and Any Array - decimal comma
    a = Any["Nr" "Wert";1 Date(2017);2 DateTime(2018);3 Dates.Time(23,54,45,123,456,78);4 1.5e10+5im;5 1500//5;6 1.5e10]
    writedlm2("test.csv", a)
    @test read("test.csv", String) ==
    """
    Nr;Wert
    1;2017-01-01
    2;2018-01-01T00:00:00.0
    3;23:54:45,123456078
    4;1,5e10+5,0im
    5;300//1
    6;1,5e10
    """
    b = readdlm2("test.csv", Any, header=true)
    rm("test.csv")
    @test a[2:end,:] == b[1]
    @test a[1:1,:] == b[2]

    #  Test different types with header and Any Array - english decimal
    a = Any["Nr" "Value";1 Date(2017);2 DateTime(2018);3 Dates.Time(23,54,45,123,456,78);4 1.5e10+5im;5 1500//5;6 1.5e10]
    writedlm2("test.csv", a, '\t', decimal='.')
    @test read("test.csv", String) ==
    """
    Nr\tValue
    1\t2017-01-01
    2\t2018-01-01T00:00:00.0
    3\t23:54:45.123456078
    4\t1.5e10+5.0im
    5\t300//1
    6\t1.5e10
    """
    b = readdlm2("test.csv", '\t', Any, decimal='.', header=true)
    rm("test.csv")
    @test a[2:end,:] == b[1]
    @test a[1:1,:] == b[2]

    # Test Complex Array read and write
    a = Complex[complex(-1,-2) complex(1.2,-2) complex(-1e9,3e-19)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "-1-2im;1,2-2,0im;-1,0e9+3,0e-19im\n"
    b = readdlm2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}

    a = Complex[complex(-1,-2) complex(1.2,-2) complex(-1e9,3e-19)]
    writedlm2("test.csv", a, imsuffix="i")
    @test read("test.csv", String) == "-1-2i;1,2-2,0i;-1,0e9+3,0e-19i\n"
    b = readdlm2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}

    a = Any["test" "test2";complex(-1,-2) complex(1.2,-2);complex(-1e9,3e-19) complex(1,115)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test;test2\n-1-2im;1,2-2,0im\n-1,0e9+3,0e-19im;1+115im\n"
    b = readdlm2("test.csv", Any)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Any,2}

    a = Any["test1" "test2";complex(-1,-2) complex(1.2,-2);complex(-1e9,3e-19) complex(1,115)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test1;test2\n-1-2im;1,2-2,0im\n-1,0e9+3,0e-19im;1+115im\n"
    b, h = readdlm2("test.csv", Complex, header=true)
    rm("test.csv")
    @test b == Complex[complex(-1,-2) complex(1.2,-2);complex(-1e9,3e-19) complex(1,115)]
    @test h == AbstractString["test1" "test2"]

    a = Complex[complex(-1//3,-7//5) complex(1,-1//3) complex(-1//2,3e-19)]
    writedlm2("test.csv", a, imsuffix="i")
    @test read("test.csv", String) == "-1//3-7//5*i;1//1-1//3*i;-0,5+3,0e-19i\n"
    b = readdlm2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}

    a = Complex[complex(-1//3,-7//5) complex(1,-1//3) complex(-1//2,3e-19)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "-1//3-7//5*im;1//1-1//3*im;-0,5+3,0e-19im\n"
    b = readdlm2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}

    # Test Time read and write
    a = Time[Time(12,54,43,123,456,789) Time(13,45);Time(1,45,58,0,0,1) Time(23,59,59)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "12:54:43,123456789;13:45:00\n01:45:58,000000001;23:59:59\n"
    b = readdlm2("test.csv", Time)
    rm("test.csv")
    @test b == a
    @test typeof(b) == Array{Time,2}

    a = Any["test1" "test2";Time(12,54,43,123,456,789) Time(13,45);Time(1,45,58,0,0,1) Time(23,59,59)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test1;test2\n12:54:43,123456789;13:45:00\n01:45:58,000000001;23:59:59\n"
    b, h = readdlm2("test.csv", Time, header=true)
    rm("test.csv")
    @test b == Time[Time(12,54,43,123,456,789) Time(13,45);Time(1,45,58,0,0,1) Time(23,59,59)]
    @test h == AbstractString["test1" "test2"]

    # Test Rational read and write
    a = Rational[456//123 123//45;456//23 1203//45]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "152//41;41//15\n456//23;401//15\n"
    b = readdlm2("test.csv", Rational)
    rm("test.csv")
    @test b == a
    @test typeof(b) == Array{Rational,2}

    a = Any["test1" "test2";456//123 123//45;456//23 1203//45]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test1;test2\n152//41;41//15\n456//23;401//15\n"
    b, h = readdlm2("test.csv", Rational, header=true)
    rm("test.csv")
    @test b == Rational[456//123 123//45;456//23 1203//45]
    @test h == AbstractString["test1" "test2"]

    # Test DateTime read and write
    a = DateTime[DateTime(2017) DateTime(2016);DateTime(2015) DateTime(2014)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "2017-01-01T00:00:00.0;2016-01-01T00:00:00.0\n2015-01-01T00:00:00.0;2014-01-01T00:00:00.0\n"
    b = readdlm2("test.csv", DateTime)
    c = readdlm2("test.csv", DateTime, tables=true) # test tables interface
    @test ReadWriteDlm2.mttoarray(c) == a
    rm("test.csv")
    @test b == a
    @test typeof(b) == Array{DateTime,2}

    a = Any["test1" "test2";DateTime(2017) DateTime(2016);DateTime(2015) DateTime(2014)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test1;test2\n2017-01-01T00:00:00.0;2016-01-01T00:00:00.0\n2015-01-01T00:00:00.0;2014-01-01T00:00:00.0\n"
    b, h = readdlm2("test.csv", DateTime, header=true)
    rm("test.csv")
    @test b == DateTime[DateTime(2017) DateTime(2016);DateTime(2015) DateTime(2014)]
    @test h == AbstractString["test1" "test2"]

    # Test Date read and write
    a = Date[Date(2017) Date(2016);Date(2015) Date(2014)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "2017-01-01;2016-01-01\n2015-01-01;2014-01-01\n"
    b = readdlm2("test.csv", Date)
    rm("test.csv")
    @test b == a
    @test typeof(b) == Array{Date,2}

    a = Any["test1" "test2";Date(2017) Date(2016);Date(2015) Date(2014)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test1;test2\n2017-01-01;2016-01-01\n2015-01-01;2014-01-01\n"
    b, h = readdlm2("test.csv", Date, header=true)
    rm("test.csv")
    @test b == Date[Date(2017) Date(2016);Date(2015) Date(2014)]
    @test h == AbstractString["test1" "test2"]

    # Test alternative rs Tuple - is decimal ignored?
    a = Float64[1.1 1.2;2.1 2.2]
    writedlm2("test.csv", a, decimal='€')
    @test read("test.csv", String) == "1€1;1€2\n2€1;2€2\n"
    b = readdlm2("test.csv", Any, rs=(r"(\d)€(\d)", s"\1.\2"), decimal='n')
    rm("test.csv")
    @test a == b
end
