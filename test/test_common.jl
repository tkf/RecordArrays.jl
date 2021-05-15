module TestCommon

include("preamble.jl")

using RecordArrays.Implementations: check_eltype

struct Node{T}
    head::T
    tail::Union{Nothing,Node{T}}
end

@testset "check_eltype" begin
    @test check_eltype(Some{Int}) === nothing
    @test check_eltype(typeof((a = 1, b = 2))) === nothing
    @testset "Ref" begin
        err = @test_error check_eltype(typeof(Ref(0))) === nothing
        @test "mutable type" ⊏ sprint(showerror, err)
    end
    @testset "Integer" begin
        err = @test_error check_eltype(Integer) === nothing
        @test "concrete type is required" ⊏ sprint(showerror, err)
    end
    @testset "Node{Int}" begin
        err = @test_error check_eltype(Node{Int}) === nothing
        @test "GC-managed" ⊏ sprint(showerror, err)
    end
end

end  # module
