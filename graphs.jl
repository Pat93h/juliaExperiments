using LightGraphs
using GraphPlot
using MetaGraphs
using GraphRecipes
using Plots
using StatsPlots
using Distributions
using Random
using Colors

##########################################
### Helper Functions

function getnormalDistforX(n::Integer)
    randNumbers = Float16[]
    for i in 1:n
        push!(randNumbers, normalDistRanged())
    end

    return(randNumbers)
end

function normalDistRanged()
    randNumber = round(rand(Normal(0,3)), digits=2)
    if (randNumber >= -10 && randNumber <=10)
        return randNumber
    else
        return normalDistRanged()
    end
end

##########################################
### Agent Network Setup

function setupAgentNetwork(agentcount::Integer)
    network = MetaDiGraph(barabasi_albert(agentcount,trunc(Integer,round(agentcount/3)),3))

    # Assign weights to the edges based on a normal distribution

    Random.seed!(20191104)
    dist = Normal(3,1)
    distributions = rand(dist, ne(network))

    for (index,e) in enumerate(edges(network))
        set_prop!(network,e, :weight, distributions[index])
    end

    # newNeighbors = Integer[]
    opinions = getnormalDistforX(agentcount)

    for (index,v) in enumerate(vertices(network))
        set_prop!(network,v, :newNeighbors, Integer[])
        set_prop!(network,v, :opinion, opinions[index])
    end

    println("Current Vertex count: " * string(nv(network)))

    return network
end

##########################################
### Simulation Step

function simulation_step(network::MetaDiGraph)

    println("=== New Simulation Step ===")

    # Let network grow with 10%
    #for i in 1:Integer(trunc(nv(network)/10))
    #    add_vertex!(network, :newNeighbors, Integer[])
    #    set_prop!(network,nv(network), :opinion, getnormalDistforX(1)[1])
    #end

    # Remove edges that are too close to unsignificance
    for e in edges(network)
        if (get_prop(network,e, :weight) < 2)
            rem_edge!(network, e)
        end
    end

    # Add new edges. The lower the outdegree of a vertice, the higher the count
    # of possible new connections
    for v in vertices(network)

        println("Current Vertex count: " * string(nv(network)))

        # reset newneighborlist

        if outdegree(network,v) == 0
            newconnections = rand(2:4)
        elseif outdegree(network,v) < 3
            newconnections = rand(1:3)
        elseif outdegree(network,v) > 10
            newconnections = rand(0:1)
        elseif outdegree(network,v) == (nv(network) - 1)
            newconnections = 0
        else
            newconnections = rand(0:2)
        end



        # Selecting candidates for new connections using the difference
        # of all nodes with neighbors of v and v itself
        newcandidates = setdiff([1:v-1;v+1:nv(network)],neighbors(network,v))

        println("Vertex $v has outdegree " * string(outdegree(network,v)) * " and gets $newconnections new connections.")


        for i in 1:newconnections
            # Randomly choose one of the candidates
            newdst = rand(1:length(newcandidates))
            # newneighbor = newcandidates[newdst]
            # println("Chosen neighbor is $newneighbor.")


            push!(props(network,newcandidates[newdst])[:newNeighbors],v)

            add_edge!(network,v,newcandidates[newdst])
            set_prop!(network, v,newcandidates[newdst], :weight, rand(1:20))
            # newneighbor = newcandidates[newdst]
            # println("Edge $newEdge added. Weight of new edge is " * string(get_prop(network, newEdge, :weight)))

            deleteat!(newcandidates,newdst)
        end

        # Check if vertex got new Neighbors during last run. If yes,
        # check if opinion is tolerated and if yes, create a reverse connection to new neighbor.
        # Copy the weight of the incoming connection.

        if (!isempty(get_prop(network,v, :newNeighbors)))

            println("Current vertex is $v. New neighbors: " * string(get_prop(network,v, :newNeighbors)))

            for newNeighbor in get_prop(network,v, :newNeighbors)
                ownOpinion = get_prop(network, v, :opinion)
                neighborOpinion = get_prop(network, newNeighbor, :opinion)

                if (abs(ownOpinion-neighborOpinion) < 1 && !in(newNeighbor,neighbors(network, v)))
                    add_edge!(network,v,newNeighbor)
                    if has_edge(network,newNeighbor,v)
                        println("Irgendwas ist richtig!")
                        println(props(network,newNeighbor, v))
                    end
                    neighborWeight = get_prop(network, newNeighbor, v, :weight)
                    set_prop!(network, v, newNeighbor, :weight, neighborWeight)
                end
            end
        end

        set_prop!(network,v, :newNeighbors, Integer[])

    end

end

##########################################
### Graph Visualization

function showGraph(network::MetaDiGraph)

    nodesizes = Integer[]

    for v in vertices(network)
        push!(nodesizes, indegree(network,v) + 5)
    end

    edgeweights = Float64[]
    for e in edges(network)
        weight = round(get_prop(network,e, :weight), digits=2)
        push!(edgeweights, weight)
    end

    nodecolors = Color

    gplot(network, nodelabel=1:nv(mynetwork), edgelabel= edgeweights, nodesize=nodesizes)
end

mynetwork = setupAgentNetwork(10)
simulation_step(mynetwork)
showGraph(mynetwork)


for e in edges(mynetwork)
    println(weight)
    # println("Vertex $e has opinion $opinion.")
end




nodecolors = range(colorant"red",colorant"blue", length=1000)
