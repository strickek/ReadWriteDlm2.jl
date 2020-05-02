#2020 Klaus Stricker - Tests for ReadWriteDlm2
#License is MIT: http://julialang.org/license

# runtests.jl

using DelimitedFiles
using ReadWriteDlm2
using Test
using Random
using Dates
import Tables

import ReadWriteDlm2.dfregex

include("rwd2tests_1.jl")
include("rwd2tests_2.jl")
include("rwd2tests_3.jl")
include("rwd2tests_4.jl")
include("rwd2tests_5.jl")
include("rwd2tests_6.jl")
