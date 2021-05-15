module TestFill

using Test
using RecordArrays

rawdata = """
fill((a = 1, b = 2))
fill((a = 1, b = 2), 10)
fill((a = 1, b = 2), 2, 3)
fill((a = 1, b = 2), 2, 3, 4)
fill(Some(0))
fill(Some(0), 10)
fill(Some(0), 2, 3)
fill(Some{Union{Int,Missing}}(0))
fill(Some{Union{Int,Missing}}(0), 10)
fill(Some{Union{Int,Missing}}(0), 2, 3)
""" |> x -> split(x, "\n", keepempty = false)

@testset "$code" for code in rawdata
    base = Base.include_string(@__MODULE__, code)
    rec = Base.include_string(@__MODULE__, "RecordArrays.$code")
    @test collect(rec) == base
end

end  # module
