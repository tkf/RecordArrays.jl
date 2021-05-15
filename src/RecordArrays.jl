baremodule RecordArrays

export
    #
    FieldArray,
    FieldVector,
    RecordArray,
    RecordVector

import Base

abstract type _AbstractRecordArray{T,N} <: Base.AbstractArray{T,N} end

struct RecordArray{T,N,Buffer,Storage,Step} <: _AbstractRecordArray{T,N}
    buffer::Buffer
    pointer::Base.Ptr{Storage}
    eltype::Base.Val{T}
    size::NTuple{N,Int}
    step::Base.Val{Step}
end

const RecordVector{T} = RecordArray{T,1}

struct FieldArray{Field,T,N,Buffer,Storage,Step} <: _AbstractRecordArray{T,N}
    buffer::Buffer
    pointer::Base.Ptr{Storage}
    eltype::Base.Val{T}
    size::NTuple{N,Int}
    step::Base.Val{Step}
    field::Base.Val{Field}
end

const FieldVector{Field,T} = FieldArray{Field,T,1}

function fill end
function unsafe_zeros end

module Implementations

using Base: @propagate_inbounds
using ..RecordArrays:
    #
    FieldArray,
    RecordArray,
    RecordArrays,
    _AbstractRecordArray

include("utils.jl")
include("common.jl")
include("records.jl")
include("fields.jl")

end  # module Implementations

Implementations.define_docstrings()

end  # baremodule RecordArrays
