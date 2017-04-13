#Tests for WriteReadDlm2 - License is MIT: http://julialang.org/license

#Start Test Script
using ReadWriteDlm2
using Base.Test

# Run tests

# 1st block modified standardtests
# Test readdlm2() and writedlm2() - License is MIT: http://julialang.org/license

isequaldlm(m1, m2, t) = isequal(m1, m2) && (eltype(m1) == eltype(m2) == t)

@test isequaldlm(readdlm2(IOBuffer("1;2\n3;4\n5;6\n")), [1. 2; 3 4; 5 6], Float64)
@test isequaldlm(readdlm2(IOBuffer("1;2\n3;4\n5;6\n"), Int), [1 2; 3 4; 5 6], Int)
@test isequaldlm(readdlm2(IOBuffer("1 2\n3 4\n5 6\n"),' '), [1. 2; 3 4; 5 6], Float64)
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
    @test isequaldlm(readdlm2(IOBuffer("1;2\n3;4 \n")), [[1.0, 3.0] [2.0, 4.0]], Float64)
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
@test isequaldlm(readdlm2(IOBuffer("\n1;2;3\n4;5;6\n\n\n"), skipblanks=true),
                reshape([1.0,4.0,2.0,5.0,3.0,6.0], 2, 3), Float64)
@test isequaldlm(readdlm2(IOBuffer("1;2\n\n4;5"), skipblanks=false), 
                reshape(Any[1.0,"",4.0,2.0,"",5.0], 3, 2), Any)
@test isequaldlm(readdlm2(IOBuffer("1;2\n\n4;5"), skipblanks=true), 
                reshape([1.0,4.0,2.0,5.0], 2, 2), Float64)

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
    @test readstring(io) == "0,1, 0,3, 0,5\n"
end

let x = [0.1 0.3 0.5], io = IOBuffer()
    writedlm2(io, x, "; ")
    seek(io, 0)
    @test readstring(io) == "0,1; 0,3; 0,5\n"
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

# change to take! in 0.6!!
let x = ["\"hello\"", "world\""], io = IOBuffer()
    writedlm2(io, x, quotes=false)
    @test takebuf_string(io) == "\"hello\"\nworld\"\n"
    writedlm2(io, x)
    @test takebuf_string(io) == "\"\"\"hello\"\"\"\n\"world\"\"\"\n"
end

# test comments
@test isequaldlm(readdlm2(IOBuffer("#this is comment\n1;2;3\n#one more comment\n4;5;6")), [1. 2. 3.;4. 5. 6.], Float64)
@test isequaldlm(readdlm2(IOBuffer("#this is \n#comment\n1;2;3\n#one more \n#comment\n4;5;6")), [1. 2. 3.;4. 5. 6.], Float64)
@test isequaldlm(readdlm2(IOBuffer("1;2;#3\n4;5;6")), [1. 2. "";4. 5. 6.], Any)
@test isequaldlm(readdlm2(IOBuffer("1#;2;3\n4;5;6")), [1. "" "";4. 5. 6.], Any)
@test isequaldlm(readdlm2(IOBuffer("1;2;\"#3\"\n4;5;6")), [1. 2. "#3";4. 5. 6.], Any)
@test isequaldlm(readdlm2(IOBuffer("1;2;3\n #with leading whitespace\n4;5;6")), [1. 2. 3.;" " "" "";4. 5. 6.], Any)

# test skipstart with true
let x = ["a" "b" "c"; "d" "e" "f"; "g" "h" "i"; "A" "B" "C"; 1 2 3; 4 5 6; 7 8 9], io = IOBuffer()
    writedlm2(io, x, quotes=false)
    seek(io, 0)
    (data, hdr) = readdlm2(io, header=true, skipstart=3)
    @test data == [1 2 3; 4 5 6; 7 8 9]
    @test hdr == ["A" "B" "C"]
end

let x = ["a" "b" "\nc"; "d" "\ne" "f"; "g" "h" "i\n"; "A" "B" "C"; 1 2 3; 4 5 6; 7 8 9]
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

@test isequaldlm(readdlm2(IOBuffer("1,22222222222222222222222222222222222222,0x3,10e6\n2000.1,true,false,-10.34"), ',', Any, rs=()),
    reshape(Any[1,2000.1,Float64(22222222222222222222222222222222222222),true,0x3,false,10e6,-10.34], 2, 4), Any)

@test isequaldlm(readdlm2(IOBuffer("-9223355253176920979,9223355253176920979"), ',', Int64, rs=()), Int64[-9223355253176920979  9223355253176920979], Int64)

@test isequaldlm(readdlm2(IOBuffer("-9223355253176920979;9223355253176920979"), Int64), Int64[-9223355253176920979  9223355253176920979], Int64)



# fix #13028
for data in ["A B C", "A B C\n"]
    data,hdr = readdlm2(IOBuffer(data), ' ', header=true)
    @test hdr == AbstractString["A" "B" "C"]
    @test data == Array{Float64}(0, 3)
end


# fix #13179 parsing unicode lines with default delmiters
@test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1\tα\n2\tβ\n"), '\t'), Any[1 "α"; 2 "β"], Any)
@test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1;α\n2;β\n")), Any[1 "α"; 2 "β"], Any)
@test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1\tα\n2\tβ\n"), '\t', rs=()), Any[1 "α"; 2 "β"], Any)
@test isequaldlm(readdlm2(IOBuffer("# Should ignore this π\n1;α\n2;β\n"), rs=()), Any[1 "α"; 2 "β"], Any)

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


# 2nd block
# Test the new functions of ReadWriteDlm2

let data = "2015-01-01;5,1;Text1\n10;19e6;4\n"
    @test isequaldlm(readdlm2(IOBuffer(data)), [Date(2015) 5.1 "Text1";10 190.0e5 4.0], Any)
    @test isequaldlm(readdlm2(IOBuffer(data)), [Date(2015) 5.1 "Text1";10 190.0e5 4.0], Any)
end

a = [Date(2015) 5.1 "Text1";10 190.0e5 4.0]
writedlm2("test.csv", a)
@test readstring("test.csv") == "2015-01-01;5,1;Text1\n10;19e6;4\n"
b = readdlm2("test.csv")
rm("test.csv")
@test b[1] == Date(2015)
writedlm2("test.csv", a, decimal='€', write_short=false)
@test readstring("test.csv") == "2015-01-01;5€1;Text1\n10€0;1€9e7;4€0\n"
b = readdlm2("test.csv", rs=(r"(\d)€(\d)", s"\1.\2"))
rm("test.csv")
@test b[1] == Date(2015)

a = [DateTime(2015) 5.1 "Text1";10 190.0e5 4.0]
writedlm2("test.csv", a)
@test readstring("test.csv") == "2015-01-01T00:00:00;5,1;Text1\n10;19e6;4\n"
b = readdlm2("test.csv")
rm("test.csv")
@test b[1] == DateTime(2015)

a = DateTime(2017)
writedlm2("test.csv", a)
@test readstring("test.csv") == "2017-01-01T00:00:00\n"
b = readdlm2("test.csv")
rm("test.csv")
@test b[1] == DateTime(2017)

a = Any[Date(2017,1,14) DateTime(2017,2,15,23,40,59)]
writedlm2("test.csv", a)
@test readstring("test.csv") == "2017-01-14;2017-02-15T23:40:59\n"
b = readdlm2("test.csv")
rm("test.csv")
@test isequaldlm(a, b, Any)

a = Any[Date(2017, 1, 1) DateTime(2017, 2, 15, 23, 0, 0)]
writedlm2("test.csv", a, dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
@test readstring("test.csv") == "01/2017;15.02.2017/23.h\n"
writedlm2("test.csv", a, dfs="", dtfs="")
@test readstring("test.csv") == "2017-01-01;2017-02-15T23:00:00\n"
writedlm2("test.csv", a, decimal='.')
@test readstring("test.csv") == "2017-01-01;2017-02-15T23:00:00\n"
writedlm2("test.csv", a, decimal='.', dfs="yyyy", dtfs="yyyy")
@test readstring("test.csv") == "2017;2017\n"
writedlm2("test.csv", a, dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
@test readstring("test.csv") == "01/2017;15.02.2017/23.h\n"
b = readdlm2("test.csv", dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
@test isequaldlm(a, b, Any)
b = readdlm2("test.csv", rs=(), dfs="mm/yyyy", dtfs="dd.mm.yyyy/HH.h")
rm("test.csv")
@test isequaldlm(a, b, Any)

a = Date(2017,5,1)
writedlm2("test.csv", a, dfs="dd.mm.yyyy")
@test readstring("test.csv") == "01.05.2017\n"
b = readdlm2("test.csv", dfs="dd.mm.yyyy")
rm("test.csv")
@test b[1] == a

a = "ABC"
writedlm2("test.csv", a)
@test readstring("test.csv") == "A\nB\nC\n"
b = readdlm2("test.csv")
rm("test.csv")
@test b[1] == "A" && b[3] == "C"

D = rand(1:9, 10, 5)
writedlm2("test.csv", D)
@test length(readstring("test.csv")) == 100
b = readdlm2("test.csv")
rm("test.csv")
@test D == b

a = 10.9
writedlm2("test.csv", a, decimal='€')
@test readstring("test.csv") == "10€9\n"
b = readdlm2("test.csv")
rm("test.csv")
@test b[1] == "10€9"

a = 10.9
writedlm2("test.csv", a, decimal='.')
@test readstring("test.csv") == "10.9\n"
b = readdlm2("test.csv")
rm("test.csv")
@test b[1] == 10.9
