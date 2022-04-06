"""
    FieldArray{Field}(A::RecordArray)
    A.\$Field

Create a view to a field of elements in a `RecordArray`.

```jldoctest
julia> using RecordArrays

julia> xs = RecordArrays.fill((a = 1, b = 2), 3);

julia> xs.a
3-element FieldArray{:a,Int64,1,…}:
 1
 1
 1
```
"""
function RecordArrays.FieldArray{Field}(A::RecordArray) where {Field}
    T = fieldtype(eltype(A), Field)
    check_eltype(eltype(A))
    check_eltype(T)
    offset = fieldoffset(eltype(A), fieldindex(eltype(A), Val(Field)))
    ptr = Ptr{wrap_union_type(T)}(pointer(A) + offset)
    buf = _buffer(A)
    return FieldArray(buf, ptr, Val(T), size(A), _step(A), Val(Field))
end

function Base.summary(
    io::IO,
    A::FieldArray{Field,T,N,Vector{UInt8},Storage},
) where {Field,T,N,Storage}
    @nospecialize A
    is_standard = T isa Type
    is_standard &= N isa Int
    is_standard &= Field isa Union{Symbol,Integer}
    is_standard &= if T isa Union
        Storage === UnionValue{T}
    else
        T === Storage
    end
    is_standard || return invoke(summary, Tuple{IO,AbstractArray}, io, A)
    print(io, length(A), "-element ")
    print(io, FieldArray)
    print(io, '{')
    show(io, Field)
    print(io, ',')
    show(io, T)
    print(io, ',')
    show(io, N)
    print(io, ",…")
    print(io, '}')
end
