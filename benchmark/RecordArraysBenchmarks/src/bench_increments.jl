module BenchIncrements

using BenchmarkTools
using RecordArrays

using ..Utils: clobber

@inline function unsafe_inc!(xs::RecordArray)
    @inbounds xs.a[end] += 1
end

@inline function unsafe_inc!(xs)
    x = @inbounds xs[end]
    x = merge(x, (; a = x.a + 1))
    @inbounds xs[end] = x
end

@noinline function repeat_inc!(xs, n = 2^10)
    isempty(xs) && return
    for _ in 1:n
        unsafe_inc!(xs)
        clobber()
    end
end

function setup()
    suite = BenchmarkGroup()

    suite["base"] = @benchmarkable(
        repeat_inc!(xs),
        setup = begin
            xs = fill((a = 0, b = 0, c = 0, d = 0), 10)
        end,
    )

    suite["rec"] = @benchmarkable(
        repeat_inc!(xs),
        setup = begin
            xs = RecordArrays.fill((a = 0, b = 0, c = 0, d = 0), 10)
        end,
    )

    return suite
end

function clear() end

end  # module
