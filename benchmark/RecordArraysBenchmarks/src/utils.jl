module Utils

using Base: llvmcall

# https://github.com/JuliaCI/BenchmarkTools.jl/pull/92
@inline function clobber()
    llvmcall("""
        call void asm sideeffect "", "~{memory}"()
        ret void
    """, Cvoid, Tuple{})
end

end  # module
