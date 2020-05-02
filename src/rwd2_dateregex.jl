# Stricker Klaus 2020 - License is MIT: http://julialang.org/license
# ReadWriteDlm2 - rwd2_dateregex - https://github.com/strickek/ReadWriteDlm2.jl

"""

    dfregex(df::AbstractString, locale::AbstractString=\"english\")

Create a regex string `r\"^...\$\"` for the given `Date` or `DateTime`
`format`string `df`.

The regex groups are named according to the `format`string codes. `locale` is
used to calculate min and max length of month and day names (for codes: UuEe).
"""
function dfregex(df::AbstractString, locale::AbstractString="english")
    # calculate min and max string lengths of months and day_of_weeks names
    Ule = try extrema([length(Dates.monthname(i;locale=locale)) for i in 1:12])catch; (3, 9) end
    ule = try extrema([length(Dates.monthabbr(i;locale=locale)) for i in 1:12])catch; (3, 3) end
    Ele = try extrema([length(Dates.dayname(i;locale=locale)) for i in 1:7])catch; (6, 9) end
    ele = try extrema([length(Dates.dayabbr(i;locale=locale)) for i in 1:7])catch; (3, 3) end

    codechars = 'y', 'Y', 'm', 'u', 'e', 'U', 'E', 'd', 'H', 'M', 'S', 's', 'Z', 'z', '\\'
    r = "^ *"; repeat_count = 1; ldf = length(df); dotsec = false
    for i = 1:ldf
        repeat_next = ((i < ldf) && (df[(i + 1)] == df[i])) ? true : false
        ((df[i] == '.') && (i < ldf) && (df[(i + 1)] == 's')) && (dotsec = true)
        repeat_count = (((i > 2) && (df[(i - 2)] != '\\') && (df[(i - 1)] == df[i])) ||
                        ((i == 2) && (df[1] == df[2]))) ? (repeat_count + 1) : 1
        r = r * (
        ((i > 1) && (df[(i - 1)] == '\\')) ? string(df[i]) :
        ((df[i] == 'y') && (repeat_count < 5) && !repeat_next) ? "(?<y>\\d{1,4})" :
        ((df[i] == 'y') && (repeat_count > 4) && !repeat_next) ? "(?<y>\\d{1,$repeat_count})" :
        ((df[i] == 'Y') && (repeat_count < 5) && !repeat_next) ? "(?<y>\\d{1,4})" :
        ((df[i] == 'Y') && (repeat_count > 4) && !repeat_next) ? "(?<y>\\d{1,$repeat_count})" :
        ((df[i] == 'm') && (repeat_count == 1) && !repeat_next) ? "(?<m>0?[1-9]|1[012])" :
        ((df[i] == 'm') && (repeat_count == 2) && !repeat_next) ? "(?<m>0[1-9]|1[012])" :
        ((df[i] == 'm') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<m>0[1-9]|1[012])" :
        ((df[i] == 'u') && (repeat_count == 1)) ? "(?<u>[A-Za-z\u00C0-\u017F]{$(ule[1]),$(ule[2])})" :
        ((df[i] == 'U') && (repeat_count == 1)) ? "(?<U>[A-Za-z\u00C0-\u017F]{$(Ule[1]),$(Ule[2])})" :
        ((df[i] == 'e') && (repeat_count == 1)) ? "(?<e>[A-Za-z\u00C0-\u017F]{$(ele[1]),$(ele[2])})" :
        ((df[i] == 'E') && (repeat_count == 1)) ? "(?<E>[A-Za-z\u00C0-\u017F]{$(Ele[1]),$(Ele[2])})" :
        ((df[i] == 'd') && (repeat_count == 1) && !repeat_next) ? "(?<d>0?[1-9]|[12]\\d|3[01])" :
        ((df[i] == 'd') && (repeat_count == 2) && !repeat_next) ? "(?<d>0[1-9]|[12]\\d|3[01])" :
        ((df[i] == 'd') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<d>0[1-9]|[12]\\d|3[01])" :
        ((df[i] == 'H') && (repeat_count == 1) && !repeat_next) ? "(?<H>0?\\d|1\\d|2[0-3])" :
        ((df[i] == 'H') && (repeat_count == 2) && !repeat_next) ? "(?<H>0\\d|1\\d|2[0-3])" :
        ((df[i] == 'H') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<H>0\\d|1\\d|2[0-3])" :
        ((df[i] == 'M') && (repeat_count == 1) && !repeat_next) ? "(?<M>\\d|[0-5]\\d)" :
        ((df[i] == 'M') && (repeat_count == 2) && !repeat_next) ? "(?<M>[0-5]\\d)" :
        ((df[i] == 'M') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<M>[0-5]\\d)" :
        ((df[i] == 'S') && (repeat_count == 1) && !repeat_next) ? "(?<S>\\d|[0-5]\\d)" :
        ((df[i] == 'S') && (repeat_count == 2) && !repeat_next) ? "(?<S>[0-5]\\d)" :
        ((df[i] == 'S') && (repeat_count > 2) && !repeat_next) ? "0{$(repeat_count-2)}(?<S>[0-5]\\d)" :
        ((df[i] == '.') && dotsec) ? "" :
        ((df[i] == '.')) ? "\\." :
        ((df[i] == 's') && (dotsec == true) && (repeat_count < 4) && !repeat_next) ? "(\\.(?<s>\\d{0,3}0{0,6}))?" :
        ((df[i] == 's') && (dotsec == true) && (repeat_count > 3) && !repeat_next) ? "(\\.(?<s>\\d{$(repeat_count)}))?" :
        ((df[i] == 's') && (dotsec == false) && (repeat_count < 4) && !repeat_next) ? "(?<s>\\d{3})?" :
        ((df[i] == 's') && (dotsec == false) && (repeat_count > 3) && !repeat_next) ? "(?<s>\\d{$(repeat_count)})?" :
        ((df[i] == 'z') && !repeat_next) ? "(?<z>[\\+|\\-]?(0\\d|1\\d|2[0-3]):?[0-5]\\d)" :
        ((df[i] == 'Z') && !repeat_next) ? "(?<Z>[A-Z]{3,14})" :
        in(df[i], codechars) ? "" : string(df[i])
        )
    end
    return Regex(r * " *" * string('$'))
end
