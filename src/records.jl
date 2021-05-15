"""
    RecordArray{T,N}(undef, dims; [align])
    RecordVector{T}(undef, length; [align])

Create an array with array-of-structures memory layout.

Optionally accept alignment `align` of each element (i.e.,
`pointer(A:;RecordArray, i)` is divisible by `align` for all `i in
eachindex(A)`).

See also [`RecordArrays.fill`](@ref) and [`RecordArrays.unsafe_zeros`](@ref).

```jldoctest
julia> using RecordArrays

julia> xs = RecordArray{@NamedTuple{a::Float64, b::Char}}(undef, 3);

julia> xs.a .= 1:3;

julia> xs.b .= 'a':'c';

julia> xs
3-element RecordArray{NamedTuple{(:a, :b), Tuple{Float64, Char}},1,…}:
 (a = 1.0, b = 'a')
 (a = 2.0, b = 'b')
 (a = 3.0, b = 'c')
````
"""
(RecordArrays.RecordArray, RecordArrays.RecordVector)

function RecordArrays.RecordArray{T,N}(
    ::UndefInitializer,
    dims::NTuple{N,Integer};
    align = nothing,
) where {T,N}
    check_eltype(T)
    Storage = wrap_union_type(T)
    if align === nothing
    elseif sizeof(Storage) <= Int(align)
    else
        noinline() do
            error("`align = $align` smaller than `sizeof($Storage) = $(sizeof(Storage))`")
        end
    end
    step = Int(something(align, sizeof(T)))
    buffer = Vector{UInt8}(undef, *(step, dims...) + something(align, 0))
    ptr = Ptr{Storage}(alignto(pointer(buffer), align))
    return RecordArray(buffer, ptr, Val(T), dims, Val(step))
end

RecordArrays.RecordArray{T,N}(
    undef::UndefInitializer,
    dims::Vararg{Integer,N};
    kwargs...,
) where {T,N} = RecordArray{T,N}(undef, dims; kwargs...)
RecordArrays.RecordArray{T}(
    undef::UndefInitializer,
    dims::NTuple{N,Integer};
    kwargs...,
) where {T,N} = RecordArray{T,N}(undef, dims; kwargs...)
RecordArrays.RecordArray{T}(
    undef::UndefInitializer,
    dims::Vararg{Integer,N};
    kwargs...,
) where {T,N} = RecordArray{T,N}(undef, dims; kwargs...)

Base.getproperty(A::RecordArray, name::Symbol) = FieldArray{name}(A)
Base.propertynames(A::RecordArray) = fieldnames(eltype(A))

@noinline function Base.setproperty!(A::RecordArray, name::Symbol, _)
    error(
        "$(ndims(A))-dim `RecordArray` does not support `setproperty!`;",
        " use, e.g., `A.$name .= array` instead",
    )
end

function _view_scalar(A, i)
    ptr = pointer(A, i)
    return RecordArray(_buffer(A), ptr, Val(eltype(A)), (), _step(A))
end

Base.view(A::RecordArray, i::Integer) = _view_scalar(A, i)
Base.view(A::RecordArray{T,N}, I::Vararg{Integer,N}) where {T,N} =
    _view_scalar(A, LinearIndices(A)[I...])

"""
    RecordArrays.fill(x::T, dims::NTuple{N,Integer}) -> A::RecordArray{T,N}

Create a `RecordArray` filled with `x`.
"""
RecordArrays.fill
RecordArrays.fill(x, dims::Integer...; kwargs...) = RecordArrays.fill(x, dims; kwargs...)
function RecordArrays.fill(x, dims::Tuple; kwargs...)
    A = RecordArray{typeof(x)}(undef, dims; kwargs...)
    fill!(A, x)
    return A
end

"""
    RecordArrays.unsafe_zeros(T, dims::NTuple{N,Integer}) -> A::RecordArray{T,N}

Create a `RecordArray` filled with zeros for all elements and all fields.
"""
RecordArrays.unsafe_zeros
RecordArrays.unsafe_zeros(T::Type, dims::Integer...; kwargs...) =
    RecordArrays.unsafe_zeros(T, dims; kwargs...)
function RecordArrays.unsafe_zeros(T::Type, dims::Tuple; kwargs...)
    A = RecordArray{T}(undef, dims; kwargs...)
    fill!(_buffer(A), 0)
    return A
end

function Base.summary(io::IO, A::RecordArray{T,N,Vector{UInt8},Storage}) where {T,N,Storage}
    @nospecialize A
    is_standard = T isa Type
    is_standard &= N isa Int
    is_standard &= if T isa Union
        Storage === UnionValue{T}
    else
        T === Storage
    end
    is_standard || return invoke(summary, Tuple{IO,AbstractArray}, io, A)
    print(io, length(A), "-element ")
    print(io, RecordArray)
    print(io, '{')
    show(io, T)
    print(io, ',')
    show(io, N)
    print(io, ",…")
    print(io, '}')
end
