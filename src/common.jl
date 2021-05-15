Base.size(A::_AbstractRecordArray) = getfield(A, :size)

_buffer(A) = getfield(A, :buffer)
_step(A) = getfield(A, :step)
stepof(A) = valueof(_step(A))

Base.parent(A::_AbstractRecordArray) = _buffer(A)::AbstractArray

@inline Base.pointer(A::_AbstractRecordArray) = getfield(A, :pointer)
@inline Base.pointer(A::_AbstractRecordArray, i::Integer) = pointer(A) + (i - 1) * stepof(A)

@inline Base.getindex(A::_AbstractRecordArray{<:Any,0}) = A[1]
@inline Base.setindex!(A::_AbstractRecordArray{<:Any,0}, x) = A[1] = x

@inline function Base.getindex(A::_AbstractRecordArray, i::Int)
    @boundscheck checkbounds(A, i)
    buf = _buffer(A)
    GC.@preserve buf begin
        return unwrap_union_value(unsafe_load(pointer(A, i)))
    end
end

@inline function Base.setindex!(A::_AbstractRecordArray, x, i::Int)
    @boundscheck checkbounds(A, i)
    buf = _buffer(A)
    v = field_convert(eltype(A), x)
    GC.@preserve buf begin
        unsafe_store!(pointer(A, i), v)
    end
end

@propagate_inbounds Base.getindex(A::_AbstractRecordArray, I::Int...) =
    A[LinearIndices(A)[I...]]

@propagate_inbounds Base.setindex!(A::_AbstractRecordArray, v, I::Int...) =
    A[LinearIndices(A)[I...]] = v

function check_eltype(::Type{T}) where {T}
    if T isa Union
        check_eltype(T.a)
        check_eltype(T.b)
        return
    end
    ismutabletype(T) && noinline() do
        error("mutable types are not supported; got: $T")
    end
    isconcretetype(T) || noinline() do
        error("a concrete type is required; got: $T")
    end
    Base.datatype_pointerfree(T) || noinline() do
        error("containing GC-managed object: $T")
    end
    return
end
