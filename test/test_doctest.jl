module TestDoctest

import RecordArrays
using Documenter: doctest
using Test

@testset "doctest" begin
    doctest(RecordArrays; manual = false)
end

end  # module
