using Test

macro test_error(ex)
    @gensym err
    quote
        let $err = nothing
            $Test.@test try
                $ex
                false
            catch _err
                $err = _err
                true
            end
            $err
        end
    end |> esc
end

const ⊏ = occursin
