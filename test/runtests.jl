#2018 Klaus Stricker - Tests for ReadWriteDlm2 - License is MIT: http://julialang.org/license

#Start  Test Script
using DelimitedFiles
using ReadWriteDlm2
using Test
using Random
using Dates

# Run tests

# 1st block modified standardtests

isequaldlm(m1, m2, t) = isequal(m1, m2) && (eltype(m1) == eltype(m2) == t)

@testset "readdlm2" begin
    @test isequaldlm(readdlm2(IOBuffer("1;2\n3;4\n5;6\n"), Float64), [1. 2; 3 4; 5 6], Float64)
    @test isequaldlm(readdlm2(IOBuffer("1;2\n3;4\n5;6\n"), Int), [1 2; 3 4; 5 6], Int)
    @test isequaldlm(readdlm2(IOBuffer("1 2\n3 4\n5 6\n"),' ', Float64), [1. 2; 3 4; 5 6], Float64)
    @test isequaldlm(readdlm2(IOBuffer("1 2\n3 4\n5 6\n"), ' ', Int), [1 2; 3 4; 5 6], Int)

    @test size(readdlm2(IOBuffer("1;2;3;4\n1;2;3"))) == (2,4)
    @test size(readdlm2(IOBuffer("1; 2;3;4\n1;2;3"))) == (2,4)
    @test size(readdlm2(IOBuffer("1; 2;3;4\n1;2;3\n"))) == (2,4)
    @test size(readdlm2(IOBuffer("1;;2;3;4\n1;2;3\n"))) == (2,5)

    let result1 = reshape(Any["", "", "", "", "", "", 1.0, 1.0, "", "", "", "", "", 1.0, 2.0, "", 3.0, "", "", "", "", "", 4.0, "", "", ""], 2, 13),
        result2 = reshape(Any[1.0, 1.0, 2.0, 1.0, 3.0, "", 4.0, ""], 2, 4)

        @test isequaldlm(readdlm2(IOBuffer(";;;1;;;;2;3;;;4;\n;;;1;;;1\n")), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("   1    2 3   4 \n   1   1\n"), ' '), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("   1    2 3   4 \n   1   1\n"), ' '), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("1;2\n3;4 \n"), Float64), [[1.0, 3.0] [2.0, 4.0]], Float64)
    end

    let result1 = reshape(Any["", "", "", "", "", "", "भारत", 1.0, "", "", "", "", "", 1.0, 2.0, "", 3.0, "", "", "", "", "", 4.0, "", "", ""], 2, 13)
        @test isequaldlm(readdlm2(IOBuffer(",,,भारत,,,,2,3,,,4,\n,,,1,,,1\n"), ',', rs=()) , result1, Any)
    end

    let result1 = reshape(Any[1.0, 1.0, 2.0, 2.0, 3.0, 3.0, 4.0, ""], 2, 4)
        @test isequaldlm(readdlm2(IOBuffer("1;2;3;4\n1;2;3")), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("1;2;3;4\n1;2;3;"),';'), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("1,2,3,4\n1,2,3"), ',', rs=()), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("1,2,3,4\r\n1,2,3\r\n"), ',', rs=()), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("1,2,3,\"4\"\r\n1,2,3\r\n"), ',', rs=()), result1, Any)
    end

    let result1 = reshape(Any["abc", "hello", "def,ghi", " \"quote\" ", "new\nline", "world"], 2, 3),
        result2 = reshape(Any["abc", "line\"", "\"hello\"", "\"def", "", "\" \"\"quote\"\" \"", "ghi\"", "", "world", "\"new", "", ""], 3, 4)

        @test isequaldlm(readdlm2(IOBuffer("abc,\"def,ghi\",\"new\nline\"\n\"hello\",\" \"\"quote\"\" \",world"), ',', rs=()), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("abc,\"def,ghi\",\"new\nline\"\n\"hello\",\" \"\"quote\"\" \",world"), ',', rs=(), quotes=false), result2, Any)
        @test isequaldlm(readdlm2(IOBuffer("abc,\"def,ghi\",\"new\nline\"\n\"hello\",\" \"\"quote\"\" \",world"), ',', rs=()), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("abc,\"def,ghi\",\"new\nline\"\n\"hello\",\" \"\"quote\"\" \",world"), ',', rs=(), quotes=false), result2, Any)

        @test isequaldlm(readdlm2(IOBuffer("abc;\"def,ghi\";\"new\nline\"\n\"hello\";\" \"\"quote\"\" \";world")), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("abc;\"def;ghi\";\"new\nline\"\n\"hello\";\" \"\"quote\"\" \";world"), quotes=false), result2, Any)
        @test isequaldlm(readdlm2(IOBuffer("abc;\"def,ghi\";\"new\nline\"\n\"hello\";\" \"\"quote\"\" \";world"), rs=()), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("abc;\"def;ghi\";\"new\nline\"\n\"hello\";\" \"\"quote\"\" \";world"), rs=(), quotes=false), result2, Any)
    end

    let result1 = reshape(Any["t", "c", "", "c"], 2, 2),
        result2 = reshape(Any["t", "\"c", "t", "c"], 2, 2)
        @test isequaldlm(readdlm2(IOBuffer("t;\n\"c\";c")), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("t;t\n\"\"\"c\";c")), result2, Any)
        @test isequaldlm(readdlm2(IOBuffer("t;\n\"c\";c"), rs=()), result1, Any)
        @test isequaldlm(readdlm2(IOBuffer("t;t\n\"\"\"c\";c"), rs=()), result2, Any)
    end


    @test isequaldlm(readdlm2(IOBuffer("\n1;2;3\n4;5;6\n\n\n"), skipblanks=false),
                    reshape(Any["",1.0,4.0,"","","",2.0,5.0,"","","",3.0,6.0,"",""], 5, 3), Any)
    @test isequaldlm(readdlm2(IOBuffer("\n1;2;3\n4;5;6\n\n\n"), Float64, skipblanks=true),
                    reshape([1.0,4.0,2.0,5.0,3.0,6.0], 2, 3), Float64)
    @test isequaldlm(readdlm2(IOBuffer("1;2\n\n4;5"), skipblanks=false),
                    reshape(Any[1.0,"",4.0,2.0,"",5.0], 3, 2), Any)
    @test isequaldlm(readdlm2(IOBuffer("1;2\n\n4;5"), Float64, skipblanks=true),
                    reshape([1.0,4.0,2.0,5.0], 2, 2), Float64)
end

@testset "writedlm2" begin
    let x = bitrand(5, 10), io = IOBuffer()
        writedlm2(io, x)
        seek(io, 0)
        @test readdlm2(io, Bool) == x
    end

    let x = bitrand(5, 10)
        writedlm2("test.csv", x, ";")
        @test readdlm2("test.csv", ';', Bool, '\n') == x
        @test readdlm2("test.csv", ';', '\n') == x
    end

    let x = bitrand(5, 10)
        writedlm2("test.csv", x, ";")
        @test readdlm2("test.csv", ';', Bool) == x
        @test readdlm2("test.csv", ';') == x
    end

    let x = bitrand(5, 10)
        writedlm2("test.csv", x)
        @test readdlm2("test.csv", Bool) == x
        @test readdlm2("test.csv") == x
    end

    let x = [1,2,3], y = [4,5,6], io = IOBuffer()
        writedlm2(io, zip(x,y), ",  ")
        seek(io, 0)
        @test readdlm2(io, ',', rs=()) == [x y]
    end

    let x = [0.1 0.3 0.5], io = IOBuffer()
        writedlm2(io, x, ", ")
        seek(io, 0)
        @test read(io, String) == "0,1, 0,3, 0,5\n"
    end

    let x = [0.1 0.3 0.5], io = IOBuffer()
        writedlm2(io, x, "; ")
        seek(io, 0)
        @test read(io, String) == "0,1; 0,3; 0,5\n"
    end

    let x = [0.1 0.3 0.5], io = IOBuffer()
        writedlm2(io, x)
        seek(io, 0)
        @test readdlm2(io) == [0.1 0.3 0.5]
    end

    let x = [0.1 0.3 0.5], io = IOBuffer()
        writedlm2(io, x, decimal='€')
        seek(io, 0)
        @test readdlm2(io, rs=(r"(\d)€(\d)", s"\1.\2")) == [0.1 0.3 0.5]
    end

    let x = [0.1 0.3 0.5], io = IOBuffer()
        writedlm2(io, x, ':', decimal='€')
        seek(io, 0)
        @test readdlm2(io, ':', rs=(r"(\d)€(\d)", s"\1.\2")) == [0.1 0.3 0.5]
    end


    let x = ["abc", "def\"ghi", "jk\nl"], y = [1, ",", "\"quoted\""], io = IOBuffer()
        writedlm2(io, zip(x,y))
        seek(io, 0)
        @test readdlm2(io) == [x y]
    end

    let x = ["abc", "def\"ghi", "jk\nl"], y = [1, ",", "\"quoted\""], io = IOBuffer()
        writedlm2(io, zip(x,y))
        seek(io, 0)
        @test readdlm2(io, Any) == [x y]
    end

    let x = ["a" "b"; "d" ""], io = IOBuffer()
        writedlm2(io, x)
        seek(io, 0)
        @test readdlm2(io) == x
    end

    let x = ["\"hello\"", "world\""], io = IOBuffer()
        writedlm2(io, x, quotes=false)
        @test String(take!(io)) == "\"hello\"\nworld\"\n"
        writedlm2(io, x)
        @test String(take!(io)) == "\"\"\"hello\"\"\"\n\"world\"\"\"\n"
    end
end

@testset "comments" begin
    @test isequaldlm(readdlm2(IOBuffer("#this is comment\n1;2;3\n#one more comment\n4;5;6"), Float64, comments=true), [1. 2. 3.;4. 5. 6.], Float64)
    @test isequaldlm(readdlm2(IOBuffer("#this is \n#comment\n1;2;3\n#one more \n#comment\n4;5;6"), Float64, comments=true), [1. 2. 3.;4. 5. 6.], Float64)
    @test isequaldlm(readdlm2(IOBuffer("1;2;#3\n4;5;6"), comments=true), [1. 2. "";4. 5. 6.], Any)
    @test isequaldlm(readdlm2(IOBuffer("1#;2;3\n4;5;6"), comments=true), [1. "" "";4. 5. 6.], Any)
    @test isequaldlm(readdlm2(IOBuffer("1;2;\"#3\"\n4;5;6"), comments=true), [1. 2. "#3";4. 5. 6.], Any)
    @test isequaldlm(readdlm2(IOBuffer("1;2;3\n #with leading whitespace\n4;5;6"), comments=true), [1. 2. 3.;" " "" "";4. 5. 6.], Any)
end

@testset "skipstart" begin
    x = ["a" "b" "c"; "d" "e" "f"; "g" "h" "i"; "A" "B" "C"; 1 2 3; 4 5 6; 7 8 9]
    io = IOBuffer()

    writedlm2(io, x, quotes=false)
    seek(io, 0)
    (data, hdr) = readdlm2(io, header=true, skipstart=3)
    @test data == [1 2 3; 4 5 6; 7 8 9]
    @test hdr == ["A" "B" "C"]

    x = ["a" "b" "\nc"; "d" "\ne" "f"; "g" "h" "i\n"; "A" "B" "C"; 1 2 3; 4 5 6; 7 8 9]
    io = IOBuffer()

    writedlm2(io, x, quotes=true)
    seek(io, 0)
    (data, hdr) = readdlm2(io, header=true, skipstart=6)
    @test data == [1 2 3; 4 5 6; 7 8 9]
    @test hdr == ["A" "B" "C"]

    io = IOBuffer()
    writedlm2(io, x, quotes=false)
    seek(io, 0)
    (data, hdr) = readdlm2(io, header=true, skipstart=6)
    @test data == [1 2 3; 4 5 6; 7 8 9]
    @test hdr == ["A" "B" "C"]
end

@testset "i18n" begin
    # source: http://www.i18nguy.com/unicode/unicode-example-utf8.zip
    let i18n_data = ["Origin (English)", "Name (English)", "Origin (Native)", "Name (Native)",
            "Australia", "Nicole Kidman", "Australia", "Nicole Kidman",
            "Austria", "Johann Strauss", "Österreich", "Johann Strauß",
            "Belgium (Flemish)", "Rene Magritte", "België", "René Magritte",
            "Belgium (French)", "Rene Magritte", "Belgique", "René Magritte",
            "Belgium (German)", "Rene Magritte", "Belgien", "René Magritte",
            "Bhutan", "Gonpo Dorji", "འབྲུག་ཡུལ།", "མགོན་པོ་རྡོ་རྗེ།",
            "Canada", "Celine Dion", "Canada", "Céline Dion",
            "Canada - Nunavut (Inuktitut)", "Susan Aglukark", "ᓄᓇᕗᒻᒥᐅᑦ", "ᓱᓴᓐ ᐊᒡᓗᒃᑲᖅ",
            "Democratic People's Rep. of Korea", "LEE Sol-Hee", "조선 민주주의 인민 공화국", "이설희",
            "Denmark", "Soren Hauch-Fausboll", "Danmark", "Søren Hauch-Fausbøll",
            "Denmark", "Soren Kierkegaard", "Danmark", "Søren Kierkegård",
            "Egypt", "Abdel Halim Hafez", "ﻣﺼﺮ", "ﻋﺑﺪﺍﻠﺣﻟﻳﻢ ﺤﺎﻓﻅ",
            "Egypt", "Om Kolthoum", "ﻣﺼﺮ", "ﺃﻡ ﻛﻟﺛﻭﻡ",
            "Eritrea", "Berhane Zeray", "ብርሃነ ዘርኣይ", "ኤርትራ",
            "Ethiopia", "Haile Gebreselassie", "ኃይሌ ገብረሥላሴ", "ኢትዮጵያ",
            "France", "Gerard Depardieu", "France", "Gérard Depardieu",
            "France", "Jean Reno", "France", "Jean Réno",
            "France", "Camille Saint-Saens", "France", "Camille Saint-Saëns",
            "France", "Mylene Demongeot", "France", "Mylène Demongeot",
            "France", "Francois Truffaut", "France", "François Truffaut",
            "France (Braille)", "Louis Braille", "⠋⠗⠁⠝⠉⠑", "⠇⠕⠥⠊⠎⠀<BR>⠃⠗⠁⠊⠇⠇⠑",
            "Georgia", "Eduard Shevardnadze", "საქართველო", "ედუარდ შევარდნაძე",
            "Germany", "Rudi Voeller", "Deutschland", "Rudi Völler",
            "Germany", "Walter Schultheiss", "Deutschland", "Walter Schultheiß",
            "Greece", "Giorgos Dalaras", "Ελλάς", "Γιώργος Νταλάρας",
            "Iceland", "Bjork Gudmundsdottir", "Ísland", "Björk Guðmundsdóttir",
            "India (Hindi)", "Madhuri Dixit", "भारत", "माधुरी दिछित",
            "Ireland", "Sinead O'Connor", "Éire", "Sinéad O'Connor",
            "Israel", "Yehoram Gaon", "ישראל", "יהורם גאון",
            "Italy", "Fabrizio DeAndre", "Italia", "Fabrizio De André",
            "Japan", "KUBOTA Toshinobu", "日本", "久保田    利伸",
            "Japan", "HAYASHIBARA Megumi", "日本", "林原 めぐみ",
            "Japan", "Mori Ogai", "日本", "森鷗外",
            "Japan", "Tex Texin", "日本", "テクス テクサン",
            "Norway", "Tor Age Bringsvaerd", "Noreg", "Tor Åge Bringsværd",
            "Pakistan (Urdu)", "Nusrat Fatah Ali Khan", "پاکستان", "نصرت فتح علی خان",
            "People's Rep. of China", "ZHANG Ziyi", "中国", "章子怡",
            "People's Rep. of China", "WONG Faye", "中国", "王菲",
            "Poland", "Lech Walesa", "Polska", "Lech Wałęsa",
            "Puerto Rico", "Olga Tanon", "Puerto Rico", "Olga Tañón",
            "Rep. of China", "Hsu Chi", "臺灣", "舒淇",
            "Rep. of China", "Ang Lee", "臺灣", "李安",
            "Rep. of Korea", "AHN Sung-Gi", "한민국", "안성기",
            "Rep. of Korea", "SHIM Eun-Ha", "한민국", "심은하",
            "Russia", "Mikhail Gorbachev", "Россия", "Михаил Горбачёв",
            "Russia", "Boris Grebenshchikov", "Россия", "Борис Гребенщиков",
            "Slovenia", "\"Frane \"\"Jezek\"\" Milcinski", "Slovenija", "Frane Milčinski - Ježek",
            "Syracuse (Sicily)", "Archimedes", "Συρακούσα", "Ἀρχιμήδης",
            "Thailand", "Thongchai McIntai", "ประเทศไทย", "ธงไชย แม็คอินไตย์",
            "U.S.A.", "Brad Pitt", "U.S.A.", "Brad Pitt",
            "Yugoslavia (Cyrillic)", "Djordje Balasevic", "Југославија", "Ђорђе Балашевић",
            "Yugoslavia (Latin)", "Djordje Balasevic", "Jugoslavija", "Đorđe Balašević"]

        i18n_arr = permutedims(reshape(i18n_data, 4, Int(floor(length(i18n_data)/4))), [2, 1])
        i18n_buff = PipeBuffer()

        writedlm2(i18n_buff, i18n_arr, ',', decimal='.')
        @test i18n_arr == readdlm2(i18n_buff, ',', rs=())

        writedlm2(i18n_buff, i18n_arr)
        @test i18n_arr == readdlm2(i18n_buff)

        hdr = i18n_arr[1:1, :]
        data = i18n_arr[2:end, :]

        writedlm2(i18n_buff, i18n_arr)
        @test (data, hdr) == readdlm2(i18n_buff, header=true)
    end
end


@testset "issue #13028" begin
    for data in ["A B C", "A B C\n"]
        data,hdr = readdlm2(IOBuffer(data), ' ', header=true)
        @test hdr == AbstractString["A" "B" "C"]
        @test data == Array{Float64}(undef, 0, 3)
    end
end

@testset "issue #13179" begin # fix #13179 parsing unicode lines with default delmiters
    @test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1\tα\n2\tβ\n"), '\t', comments=true), Any[1 "α"; 2 "β"], Any)
    @test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1;α\n2;β\n"), comments=true), Any[1 "α"; 2 "β"], Any)
    @test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1\tα\n2\tβ\n"), '\t', rs=(), comments=true), Any[1 "α"; 2 "β"], Any)
    @test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1;α\n2;β\n"), rs=(), comments=true), Any[1 "α"; 2 "β"], Any)
end

@testset "other issues" begin
    # BigInt parser
    let data = "1;2;3"
        @test readdlm2(IOBuffer(data), BigInt) == BigInt[1 2 3]
        @test readdlm2(IOBuffer(data), BigInt, rs=()) == BigInt[1 2 3]
    end
    let data = "1 2 3"
        @test readdlm2(IOBuffer(data), ' ', BigInt) == BigInt[1 2 3]
        @test readdlm2(IOBuffer(data), ' ', BigInt, rs=()) == BigInt[1 2 3]
    end

    # Test that we can read a write protected file
    let fn = tempname()
        open(fn, "w") do f
            write(f, "Julia")
        end
        chmod(fn, 0o444)
        @test readdlm2(fn)[] == "Julia"
        rm(fn)
    end

    # issue #21180
    let data = "\"721\",\"1438\",\"1439\",\"…\",\"1\""
        @test readdlm2(IOBuffer(data), ',', rs=()) == Any[721  1438  1439  "…"  1]
    end
    let data = "\"721\";\"1438\";\"1439\";\"…\";\"1\""
        @test readdlm2(IOBuffer(data)) == Any[721  1438  1439  "…"  1]
    end

    # issue #21207
    let data = "\"1\";\"灣\"\"灣灣灣灣\";\"3\""
        @test readdlm2(IOBuffer(data)) == Any[1 "灣\"灣灣灣灣" 3]
    end

    # issue #11484: useful error message for invalid readdlm filepath arguments
    # not implemented in ReadWriteDlm2
end

@testset "complex" begin
    @test readdlm2(IOBuffer("3+4im; 4+5im"), Complex{Int}) == [3+4im 4+5im]
end

# 2nd block
# Test the new functions of ReadWriteDlm2
@testset "new functions" begin
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

@testset "date format" begin
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
    rm("test.csv")
    @test a == b[1]

    # test date format strings with fix length
    a = [DateTime(2017,5,1,5,59,1,898) 1.0 1.1 1.222e7 1 true]
    writedlm2("test.csv", a, dtfs="yyyyymmmdddTHHHMMMSSSsss")
    @test read("test.csv", String) == "02017005001T005059001898;1,0;1,1;1,222e7;1;true\n"
    b = readdlm2("test.csv", dtfs="yyyyymmmdddTHHHMMMSSSsss")
    rm("test.csv")
    @test b == a
end

@testset "Time parsing" begin
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

@testset "DateLocale" begin # Test locale for french and german
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
    rm("test.csv")
    @test b[1] == a

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
    rm("test.csv")
    @test b[1] == a
end

@testset "other types" begin
    # Test Complex and Rational parsing
    a = Any[complex(-1,-2) complex(1.2,-2) complex(1e9,3e19) 1//3 -1//5 -2//-4 1//-0 -0//1]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "-1 - 2im;1,2 - 2,0im;1,0e9 + 3,0e19im;1//3;-1//5;1//2;1//0;0//1\n"
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
    @test read("test.csv", String) == "-1 - 2im\t1.2 - 2.0im\t1.0e9 + 3.0e19im\t1//3\t-1//5\t1//2\t1//0\t0//1\n"
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
    4;1,5e10 + 5,0im
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
    4\t1.5e10 + 5.0im
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
    @test read("test.csv", String) == "-1 - 2im;1,2 - 2,0im;-1,0e9 + 3,0e-19im\n"
    b = readdlm2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}

    a = Complex[complex(-1,-2) complex(1.2,-2) complex(-1e9,3e-19)]
    writedlm2("test.csv", a, imsuffix="i")
    @test read("test.csv", String) == "-1 - 2i;1,2 - 2,0i;-1,0e9 + 3,0e-19i\n"
    b = readdlm2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}

    a = Any["test" "test2";complex(-1,-2) complex(1.2,-2);complex(-1e9,3e-19) complex(1,115)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test;test2\n-1 - 2im;1,2 - 2,0im\n-1,0e9 + 3,0e-19im;1 + 115im\n"
    b = readdlm2("test.csv", Any)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Any,2}

    a = Any["test1" "test2";complex(-1,-2) complex(1.2,-2);complex(-1e9,3e-19) complex(1,115)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "test1;test2\n-1 - 2im;1,2 - 2,0im\n-1,0e9 + 3,0e-19im;1 + 115im\n"
    b, h = readdlm2("test.csv", Complex, header=true)
    rm("test.csv")
    @test b == Complex[complex(-1,-2) complex(1.2,-2);complex(-1e9,3e-19) complex(1,115)]
    @test h == AbstractString["test1" "test2"]

    a = Complex[complex(-1//3,-7//5) complex(1,-1//3) complex(-1//2,3e-19)]
    writedlm2("test.csv", a, imsuffix="i")
    @test read("test.csv", String) == "-1//3 - 7//5*i;1//1 - 1//3*i;-0,5 + 3,0e-19i\n"
    b = readdlm2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}

    a = Complex[complex(-1//3,-7//5) complex(1,-1//3) complex(-1//2,3e-19)]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "-1//3 - 7//5*im;1//1 - 1//3*im;-0,5 + 3,0e-19im\n"
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


# Tests for readcsv2 and writecsv2
# ================================

@testset "readwritecsv2" begin
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
    4,1.5e10 + 5.0im
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
    @test read("test.csv", String) == "-1//3 - 7//5*im,1//1 - 1//3*im,-0.5 + 3.0e-19im\n"
    b = readcsv2("test.csv", Complex)
    rm("test.csv")
    @test a == b
    @test typeof(b) == Array{Complex,2}
end

@testset "empty IO-data" begin
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

    a = nothing
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "nothing\n"
    b = readdlm2("test.csv")
    @test typeof(readdlm2("test.csv", Nothing)) == Array{Nothing, 2}
    rm("test.csv")
    @test typeof(b) == Array{Any,2}
    @test isequal(a, b[1])
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "nothing\n"
    b = readcsv2("test.csv")
    @test typeof(readcsv2("test.csv", Nothing)) == Array{Nothing, 2}
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

    a = [1.2 NaN "" nothing]
    writedlm2("test.csv", a)
    @test read("test.csv", String) == "1,2;NaN;;nothing\n"
    b = readdlm2("test.csv")
    rm("test.csv")
    @test isequal(a, b)

    a = [1.2 NaN "" nothing]
    writecsv2("test.csv", a)
    @test read("test.csv", String) == "1.2,NaN,,nothing\n"
    b = readcsv2("test.csv")
    rm("test.csv")
    @test isequal(a, b)
end

@testset "random data" begin
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


@testset "abstract type" begin

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
    @test read("test.csv", String) == "1;1,1;1//3;-1 - 2im;1,2 - 2,0im;-1,0e9 + 3,0e-19im\n"
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

@testset "1 0 1 0 0" begin

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
