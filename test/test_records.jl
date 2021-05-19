module TestRecords

using RecordArrays
using Test

@testset "fill((a = 1, b = 2), 10)" begin
    @testset "$(sprint(show, align))" for align in [nothing, 64]
        A = RecordArrays.fill((a = 1, b = 2), 10; align = align)
        @test A.a == fill(1, 10)
        @test A.b == fill(2, 10)
        A.a .= 1:10
        A.b .= reverse(1:10)
        @test A[1] == (a = 1, b = 10)
        @test A[2] == (a = 2, b = 9)
        @test A.a == 1:10
        @test A.b == 10:-1:1
    end
end

struct OneValue{T}
    value::T
end

@testset "fill(OneValue{Union{Nothing,Int}}, 10)" begin
    Eltype = OneValue{Union{Nothing,Int}}
    @testset "$(sprint(show, align))" for align in [nothing, 64]
        A = RecordArrays.fill(Eltype(0), 10; align = align)
        @test A[1] === Eltype(0)
        @test A.value[1] === 0
        A[2] = Eltype(2)
        A[3] = Eltype(nothing)
        @test A[2] === Eltype(2)
        @test A[3] === Eltype(nothing)
        @test A.value[2] === 2
        @test A.value[3] === nothing
        A.value[4] = 4
        A.value[5] = nothing
        @test A[4] === Eltype(4)
        @test A[5] === Eltype(nothing)
        @test A.value[4] === 4
        @test A.value[5] === nothing
        vals = [[0, 2, nothing, 4, nothing]; fill(0, 5)]
        @test collect(A) == Eltype.(vals)
        @test collect(A.value) == vals
    end
end

# Maybe stop using `Vector{UInt8}` and use padding objects, so that we can put
# GC-managed objects in the array?
#=
struct Node{T}
    head::T
    tail::Union{Nothing,Node{T}}
end

list() = nothing
list(x, xs...) = Node(x, list(xs...))

@testset "fill(Node{Int}(...), 10)" begin
    @testset for align in [nothing, 64]
        A = RecordArrays.fill(list(1, 2), 10; align = align)
        @test A[1] === list(1, 2)
        @test A.head[1] === 1
        @test A.tail[1] === list(2)
        A[1] = list(1, 2, 3)
        @test A[1] === list(1, 2, 3)
        @test A.tail[1] === list(2, 3)
        @test A[2] === list(1, 2)
    end
end
=#

end  # module
