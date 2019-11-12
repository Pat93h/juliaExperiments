mutable struct Agent2
    opinion::Integer
    mood::String

    function Agent2(opinion)
        opinion = 10
        mood = "angry"
    end
end

newagent = Agent2(20)

newagent
