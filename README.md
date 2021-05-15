# RecordArrays.jl: flexible Array-of-Structures representation for Julia

**NOTE**: [StructArrays.jl](https://github.com/JuliaArrays/StructArrays.jl)
provides the abstract array interface for Structure-of-Arrays representation
which is much more appropriate for many performance-oriented programs.

RecordArrays.jl is a package for using Array-of-Structures representation with
more control than `Array{T}`.  For example, it can be used for creating
task-local state aligned to cache line.  Updating a single field at single
index does not mutate other fields.

## Usage

```julia
julia> using RecordArrays

julia> xs = RecordArrays.fill((a = 1, b = 2), 5; align = 64)
5-element RecordArray{NamedTuple{(:a, :b), Tuple{Int64, Int64}},1,…}:
 (a = 1, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)

julia> all(i -> mod(UInt(pointer(xs, i)), 64) == 0, eachindex(xs))
true

julia> xs[1] = (a = 111, b = 222);

julia> xs
5-element RecordArray{NamedTuple{(:a, :b), Tuple{Int64, Int64}},1,…}:
 (a = 111, b = 222)
 (a = 1, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)

julia> xs.a
5-element FieldArray{:a,Int64,1,…}:
 111
   1
   1
   1
   1

julia> xs.a[2] = 11111;

julia> xs
5-element RecordArray{NamedTuple{(:a, :b), Tuple{Int64, Int64}},1,…}:
 (a = 111, b = 222)
 (a = 11111, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)

julia> x3 = view(xs, 3)  # acts like a `NamedTuple` of `Ref`s
1-element RecordArray{NamedTuple{(:a, :b), Tuple{Int64, Int64}},0,…}:
(a = 1, b = 2)

julia> x3.a[]
1

julia> x3.a[] = 333;

julia> xs
5-element RecordArray{NamedTuple{(:a, :b), Tuple{Int64, Int64}},1,…}:
 (a = 111, b = 222)
 (a = 11111, b = 2)
 (a = 333, b = 2)
 (a = 1, b = 2)
 (a = 1, b = 2)
```

Use `RecordArray{T}(undef, dims)` to allocate a new uninitialized array:

```julia
julia> using RecordArrays

julia> xs = RecordArray{Some{Union{Nothing,Int}}}(undef, 3);

julia> xs .= Some.(1:3)
3-element RecordArray{Some{Union{Nothing, Int64}},1,…}:
 1
 2
 3
```

Another way to allocate a new array is to use `RecordArrays.unsafe_zeros`:

```julia
julia> using RecordArrays

julia> xs = RecordArrays.unsafe_zeros(NTuple{5, UInt8}, 3)
3-element RecordArray{NTuple{5, UInt8},1,…}:
 (0x00, 0x00, 0x00, 0x00, 0x00)
 (0x00, 0x00, 0x00, 0x00, 0x00)
 (0x00, 0x00, 0x00, 0x00, 0x00)
```

## See also

* https://github.com/Vitaliy-Yakovchuk/StructViews.jl
