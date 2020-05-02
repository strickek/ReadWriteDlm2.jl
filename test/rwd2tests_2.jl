#2020 Klaus Stricker - Tests for ReadWriteDlm2
#License is MIT: http://julialang.org/license

# rwd2tests_2.jl


# 2nd block
# Test the new functions of ReadWriteDlm2

@testset "2_      dfregex" begin
    @test true  == occursin(dfregex("HH:MM"), "22:00")
    @test true  == occursin(dfregex("H:M"), "1:30")
    @test true  == occursin(dfregex("H:M"), "10:30")
    @test false == occursin(dfregex("H:M"), "10:62")
    @test true  == occursin(dfregex("HHhMM"), "22h00")
    @test false == occursin(dfregex("HHhMM"), "22h")
    @test true  == occursin(dfregex("Hh"), "22h")
    @test true  == occursin(dfregex("HhM\\min"), "22h15min")
    @test true  == occursin(dfregex("yyyy-mm-dd"), "2018-01-23")
    @test true  == occursin(dfregex("yyyy.mm.dd"), "2018.01.23")
    @test false == occursin(dfregex("yyyy-mm-dd"), "2018.01.23")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MM:SS"), "2018-01-23T23:52:00")
    @test false == occursin(dfregex("yyyy-mm-ddTHH:MM:SS"), "2018-01-23T23:72:00")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MMz"), "2018-01-23T23:52+01:00")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MMz"), "2018-01-23T23:52+0100")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MMz"), "2018-01-23T23:52-10:00")
    @test false == occursin(dfregex("yyyy-mm-ddTHH:MM z"), "2018-01-23T23:52+01:00")
    @test false == occursin(dfregex("yyyy-mm-ddTHH:MM z"), "2018-01-23T23:52 ")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MM z"), "2018-01-23T23:52 10:00")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MMZ"), "2018-01-23T23:52UTC")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MMZ"), "2018-01-23T23:52CET")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MMZ"), "2018-01-23T23:52CEST")
    @test false == occursin(dfregex("yyyy-mm-ddTHH:MM Z"), "2018-01-23T23:52CET")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MM Z"), "2018-01-23T23:52 CEST")
    @test false == occursin(dfregex("yyyy-mm-ddTHH:MM Z"), "2018-01-23T23:52CEST")
    @test false == occursin(dfregex("yyyy-mm-ddTHH:MMZ"), "2018-01-23T23:52CE")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MMZZZZZZ"), "2018-01-23T23:52CEST")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MM ZZZZ"), "2018-01-23T23:52 CET")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MM zzzzzz"), "2018-01-23T23:52 +11:00")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MM zzzz"), "2018-01-23T23:52 -09:00")
    @test true  == occursin(dfregex("yyyy-mm-ddTHH:MM\\Z"), "2018-01-23T23:52Z")
end

@testset "2_new functions" begin
    let data = "2015-01-01;5,1;Text1\n10;19e6;4\n"
        @test isequaldlm(readdlm2(IOBuffer(data)), [Date(2015) 5.1 "Text1";10 190.0e5 4.0], Any)
        @test isequaldlm(readdlm2(IOBuffer(data)), [Date(2015) 5.1 "Text1";10 190.0e5 4.0], Any)
    end

    a = [Date(2015) 5.1 "Text1";10 190.0e5 4.0]
    writedlm2("test.csv", a, decimal='€')
    @test read("test.csv", String) == "2015-01-01;5€1;Text1\n10;1€9e7;4€0\n"
    b = readdlm2("test.csv", rs=(r"(\d)€(\d)", s"\1.\2"))
    rm("test.csv")
    @test b[1] == Date(2015)

    a = DateTime(2017)
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "2017-01-01T00:00:00.0\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test b[1] == DateTime(2017)

    a = Any[Date(2017,1,14) DateTime(2017,2,15,23,40,59)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "2017-01-14;2017-02-15T23:40:59.0\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test isequaldlm(a, b, Any)

    a = Any[Date(2017, 1, 1) DateTime(2017, 2, 15, 23, 0, 0)]
    writedlm2("test.csv", a, dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
    @test read("test.csv", String) == "01/2017;15.02.2017/23.h\n"
    writedlm2("test.csv", a, dfs="", dtfs="")
    @test read("test.csv", String) == "2017-01-01;2017-02-15T23:00:00\n"
    writedlm2("test.csv", a, decimal='.')
    @test read("test.csv", String) == "2017-01-01;2017-02-15T23:00:00.0\n"
    writedlm2("test.csv", a, decimal='.', dfs="\\Y\\ear: yyyy", dtfs="\\Y\\ear: yyyy")
    @test read("test.csv", String) == "Year: 2017;Year: 2017\n"
    writedlm2("test.csv", a, dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
    @test read("test.csv", String) == "01/2017;15.02.2017/23.h\n"
    b = readdlm2("test.csv", dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
    @test isequaldlm(a, b, Any)
    b = readdlm2("test.csv", rs=(), dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
    rm("test.csv")
    @test isequaldlm(a, b, Any)

    a = Date(2017,5,1)
    writedlm2("test.csv", a, dfs="dd.mm.yyyy")
    @test read("test.csv", String) == "01.05.2017\n"
    b = readdlm2("test.csv", dfs="dd.mm.yyyy")
    rm("test.csv")
    @test b[1] == a

    a = "ABC"
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "A\nB\nC\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test b[1] == "A" && b[3] == "C"

    D = rand(1:9, 10, 5)
    writedlm2("test.csv", D)
    @test length(read("test.csv", String)) == 100
    b = readdlm2("test.csv")
    rm("test.csv")
    @test D == b

    a = 10.9
    writedlm2("test.csv", a, decimal='€')
    @test read("test.csv", String) == "10€9\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test b[1] == "10€9"

    a = 10.9
    writedlm2("test.csv", a, decimal='.')
    @test read("test.csv", String) == "10.9\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test b[1] == 10.9

    a = [10.9 12.5; Date(2017) DateTime(2017)]
    writedlm2("test.csv", a, ',', decimal='€')
    b = readdlm2("test.csv", ',', decimal='€')
    rm("test.csv")
    @test a == b

    a = [10.9 12.5; Date(2017) DateTime(2017)]
    writedlm2("test.csv", a, ',', decimal='.')
    b = readdlm2("test.csv", ',', decimal='.')
    rm("test.csv")
    @test a == b

    a = [10.9 12.5; Date(2017) DateTime(2017)]
    writedlm2("test.csv", a)
    b = readdlm2("test.csv")
    rm("test.csv")
    @test a == b
end

@testset "2_  date format" begin
    # test date format strings with variable length
    a = DateTime(2017,5,1,5,59,1)
    writedlm2("test.csv", a, dtfs="E, dd.mm.yyyy H:M:S")
    @test read("test.csv", String) == "Monday, 01.05.2017 5:59:1\n"
    b = readdlm2("test.csv", dtfs="E, dd.mm.yyyy H:M:S")
    rm("test.csv")
    @test a == b[1]

    a = DateTime(2017,5,1,5,59,1,898)
    writedlm2("test.csv", a, dtfs="E, d.u yyyy H:M:S,s")
    @test read("test.csv", String) == "Monday, 1.May 2017 5:59:1,898\n"
    b = readdlm2("test.csv", dtfs="E, d.u yyyy H:M:S.s")
    @test a == b[1]
    b = readdlm2("test.csv", dtfs="E, d.u yyyy H:M:S,s")
    @test a == b[1]
    rm("test.csv")

    # test date format strings with fix length
    a = [DateTime(2017,5,1,5,59,1,898) 1.0 1.1 1.222e7 1 true]
    writedlm2("test.csv", a, dtfs="yyyyymmmdddTHHHMMMSSSsss")
    @test read("test.csv", String) == "02017005001T005059001898;1,0;1,1;1,222e7;1;true\n"
    b = readdlm2("test.csv", dtfs="yyyyymmmdddTHHHMMMSSSsss")
    rm("test.csv")
    @test b == a
end

@testset "2_ Time parsing" begin
    a = [Dates.Time(23,55,56,123,456,789) Dates.Time(23,55,56,123,456) Dates.Time(23,55,56,123) Dates.Time(12,45) Dates.Time(11,23,11)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "23:55:56,123456789;23:55:56,123456;23:55:56,123;12:45:00;11:23:11\n"
    b = readdlm2("test.csv")
    @test b == a
    write("test.csv", "23:55:56.123456789;23:55:56,123456;23:55:56,123;12:45;11:23:11\n")
    b = readdlm2("test.csv")
    rm("test.csv")
    @test b == a

    a = [Dates.Time(23,55,56,123,456) Dates.Time(12,45) Dates.Time(11,23,11)]
    writedlm2("test.csv", a, decimal='.')
    @test read("test.csv", String) == "23:55:56.123456;12:45:00;11:23:11\n"
    @test readdlm2("test.csv", dtfs="", dfs="") == ["23:55:56.123456" "12:45:00" "11:23:11"]
    @test readdlm2("test.csv") == a
    rm("test.csv")
end

@testset "2_   DateLocale" begin # Test locale for french and german
    Dates.LOCALES["french"] = Dates.DateLocale(
        ["janvier", "février", "mars", "avril", "mai", "juin",
            "juillet", "août", "septembre", "octobre", "novembre", "décembre"],
        ["janv", "févr", "mars", "avril", "mai", "juin",
            "juil", "août", "sept", "oct", "nov", "déc"],
        ["lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"],
        ["lu", "ma", "me", "je", "ve", "sa", "di"],
        )

    Dates.LOCALES["german"] = Dates.DateLocale(
        ["Januar", "Februar", "März", "April", "Mai", "Juni",
            "Juli", "August", "September", "Oktober", "November", "Dezember"],
        ["Jan", "Feb", "Mar", "Apr", "Mai", "Jun",
            "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
        ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"],
        ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
        )

    a = DateTime(2017,5,1,5,59,1)
    writedlm2("test.csv", a, dtfs="E, dd.mm.yyyy H:M:S", locale="french")
    @test read("test.csv", String) == "lundi, 01.05.2017 5:59:1\n"
    b = readdlm2("test.csv", dtfs="E, dd.mm.yyyy H:M:S", locale="french")
    rm("test.csv")
    @test b[1] == a

    a = DateTime(2017,1,1,5,59,1,898)
    writedlm2("test.csv", a, dtfs="E, d.u yyyy H:M:S,s", locale="french")
    @test read("test.csv", String) == "dimanche, 1.janv 2017 5:59:1,898\n"
    b = readdlm2("test.csv", dtfs="E, d.u yyyy H:M:S.s", locale="french")
    @test b[1] == a
    b = readdlm2("test.csv", dtfs="E, d.u yyyy H:M:S,s", locale="french")
    @test b[1] == a
    rm("test.csv")

    a = DateTime(2017,8,1,5,59,1)
    writedlm2("test.csv", a, dtfs="E, dd.mm.yyyy H:M:S", locale="german")
    @test read("test.csv", String) == "Dienstag, 01.08.2017 5:59:1\n"
    b = readdlm2("test.csv", dtfs="E, dd.mm.yyyy H:M:S", locale="german")
    rm("test.csv")
    @test b[1] == a

    a = DateTime(2017,11,1,5,59,1,898)
    writedlm2("test.csv", a, dtfs="E, d. U yyyy H:M:S,s", locale="german")
    @test read("test.csv", String) == "Mittwoch, 1. November 2017 5:59:1,898\n"
    b = readdlm2("test.csv", dtfs="E, d. U yyyy H:M:S.s", locale="german")
    @test b[1] == a
    b = readdlm2("test.csv", dtfs="E, d. U yyyy H:M:S,s", locale="german")
    @test b[1] == a
    rm("test.csv")
end
