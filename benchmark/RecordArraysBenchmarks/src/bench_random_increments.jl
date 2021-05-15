module BenchRandomIncrements

using BenchmarkTools
using RecordArrays

const CACHE = Ref{Any}()

@inline function unsafe_inc!(counters::RecordArray, i)
    @inbounds counters.a[i] += 1
end

@inline function unsafe_inc!(counters, i)
    x = @inbounds counters[end]
    x = merge(x, (; a = x.a + 1))
    @inbounds counters[i] = x
end

@noinline function inc!(counters, indices)
    for i in indices
        unsafe_inc!(counters, i)
    end
end

function generate(nindices = 2^10, ncounters = 10)
    return (
        counters_base = fill((a = 0, b = 0, c = 0, d = 0), ncounters),
        counters_rec = RecordArrays.fill((a = 0, b = 0, c = 0, d = 0), ncounters),
        indices = rand(1:ncounters, nindices),
    )
end

function setup()
    CACHE[] = generate()

    suite = BenchmarkGroup()

    suite["base"] = @benchmarkable(
        inc!(counters, indices),
        setup = begin
            counters = CACHE[].counters_base::$(typeof(CACHE[].counters_base))
            indices = CACHE[].indices::$(typeof(CACHE[].indices))
        end,
    )

    suite["rec"] = @benchmarkable(
        inc!(counters, indices),
        setup = begin
            counters = CACHE[].counters_rec::$(typeof(CACHE[].counters_rec))
            indices = CACHE[].indices::$(typeof(CACHE[].indices))
        end,
    )

    return suite
end

function clear()
    CACHE[] = nothing
end

end  # module
