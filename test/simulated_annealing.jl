using StochasticSearch, FactCheck, Base.Test

facts("[Search]") do
    context("optimize and simulated_annealing") do
        function rosenbrock(x::Configuration, parameters::Dict{Symbol, Any} = Dict{Symbol, Any}())
            return (1.0 - x["i0"].value)^2 + 100.0 * (x["i1"].value - x["i0"].value^2)^2
        end
        configuration = Configuration([NumberParameter(-2.0,2.0,0.0,"i0"),
                                       NumberParameter(-2.0,2.0,0.0,"i1")],
                                       "rosenbrock_config")
        methods       = [:simulated_annealing]
        instances     = [1]
        parameters    = Dict(:cost               => rosenbrock,
                             :initial_config     => configuration,
                             :methods            => methods,
                             :stopping_criterion => elapsed_time_criterion,
                             :seconds            => 1,
                             :measurement_method => sequential_measure_mean!,
                             :instances          => instances)

        search_task = @task optimize(parameters)
        result = consume(search_task)
        print(result)
        while result.is_final == false
            result = consume(search_task)
            print(result)
        end
        rr = rosenbrock(result.minimum)
        rc = result.cost_minimum
        @test_approx_eq rc rr
        @fact (rosenbrock(result.minimum) <= rosenbrock(configuration))   --> true
        @fact_throws Exception optimize(rosenbrock, configuration, [:bozo_search])
        println(rosenbrock(result.minimum))
    end
end
