valueof(::Val{x}) where {x} = x

# @inline fieldindex(::T, field::Val) where {T} = fieldindex(T, field)
@generated function fieldindex(::Type{T}, ::Val{field}) where {T,field}
    field isa Symbol || return :(error("`field` must be a symbol; given: $field"))
    return findfirst(n -> n === field, fieldnames(T))
end

if !isdefined(Base, :ismutabletype)
    function ismutabletype(@nospecialize(t::Type))
        t = Base.unwrap_unionall(t)
        # TODO: what to do for `Union`?
        return isa(t, DataType) && t.mutable
    end
end

function noinline(f)
    @noinline wrapper() = f()
    wrapper()
end

alignto(ptr, ::Nothing) = ptr
function alignto(ptr, align)
    ispow2(align) || noinline() do
        error("not a power of 2: `align = $align`")
    end
    # return ptr + (align - mod(UInt(ptr), align))
    return ptr + (align - (UInt(ptr) & (align - 1)))
end

struct UnionValue{T}
    value::T
end

unwrap_union_value(x) = x
unwrap_union_value(x::UnionValue) = x.value

function wrap_union_type(::Type{T}) where {T}
    if T isa Union
        return UnionValue{T}
    else
        return T
    end
end

@inline function field_convert(::Type{T}, x) where {T}
    if T isa Union
        return UnionValue{T}(convert(T, x))
    else
        return convert(T, x)
    end
end

function define_docstrings()
    docstrings = [:RecordArrays => joinpath(dirname(@__DIR__), "README.md")]
    #=
    docsdir = joinpath(@__DIR__, "docs")
    for filename in readdir(docsdir)
        stem, ext = splitext(filename)
        ext == ".md" || continue
        name = Symbol(stem)
        name in names(RecordArrays, all=true) || continue
        push!(docstrings, name => joinpath(docsdir, filename))
    end
    =#
    for (name, path) in docstrings
        include_dependency(path)
        doc = read(path, String)
        doc = replace(doc, r"^```julia"m => "```jldoctest $name")
        doc = replace(doc, "<kbd>TAB</kbd>" => "_TAB_")
        @eval RecordArrays $Base.@doc $doc $name
    end
end
