using POMDPs
using RockSample
using SARSOP # POMDP Solver
using POMDPGifs # to make gifs
using Cairo # for making/saving the gif
using JSON
using POMDPTools

# Define the POMDP
pomdp = RockSamplePOMDP(rocks_positions=[(2,3), (4,4), (4,2)], 
                        sensor_efficiency=20.0,
                        discount_factor=0.95, 
                        good_rock_reward = 20.0)

# Define the solver
# Uncomment the following line if you want to use the SARSOP solver
solver = SARSOPSolver(precision=1e-3)
policy = solve(solver, pomdp)
# policy = RandomPolicy(pomdp)
gif_simulator = GifSimulator(filename="test.gif", max_steps=30)
simulate(gif_simulator, pomdp, policy)
# Ensure DiscreteUpdater is defined correctly
updater = DiscreteUpdater(pomdp) # assuming it's correctly imported or defined
# data = Dict{String, Any}()
data = Dict("history" => [])
# Open the file in append mode and write the list in JSON format
open("/Users/ibenatar/Desktop/JuliaPOMDP/output.json", "w+") do file
    for i in 1:15
        action_observation_list = []
        belief_state = []
        # data = Dict{String, Any}()

        # Iterate through the POMDP steps
        for (index, (b, s, a, o, r)) in enumerate(stepthrough(pomdp, policy, updater, "b,s,a,o,r"))
            # Append the filtered belief states
            if index == 1
                filtered_belief = [(state, prob) for (state, prob) in zip(b.state_list, b.b) if prob > 0.0]
                belief_state = filtered_belief
            end
            # Append action and observation pairs
            push!(action_observation_list, (a, o))
        end

        # Store the belief state and action-observation pairs in a dictionary
        if !haskey(data, "belief_state")
            data["belief_state"] = belief_state
        end
        push!(data["history"], action_observation_list)

        # Convert the dictionary to JSON and write it to the file
    end
    write(file, JSON.json(data))
end