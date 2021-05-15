try
    using RecordArraysBenchmarks
    true
catch
    false
end || begin
    let path = joinpath(@__DIR__, "../benchmark/RecordArraysBenchmarks/Project.toml")
        path in LOAD_PATH || push!(LOAD_PATH, path)
    end
    using RecordArraysBenchmarks
end
