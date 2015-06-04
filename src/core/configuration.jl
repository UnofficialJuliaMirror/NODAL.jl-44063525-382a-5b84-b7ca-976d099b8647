type Configuration{T <: Parameter} <: Parameter
    parameters::Dict{Symbol, T}
    name::Symbol
    value::Dict{Symbol, Any}

    Configuration(parameters::Array{T, 1}, name::Symbol) = begin
        params = Dict{Symbol, T}()
        values = Dict{Symbol, Any}()
        for parameter in parameters
            @inbounds params[parameter.name] = parameter
            @inbounds values[parameter.name] = parameter.value
        end
        new(params, name, values)
    end

    Configuration(parameters::Dict{Symbol, T}, name::Symbol) = begin
        values = Dict{Symbol, Any}()
        for key in keys(parameters)
            @inbounds values[key] = parameters[key].value
        end
        new(parameters, name, values)
    end

    Configuration(name::Symbol) = begin
        values = Dict{Symbol, Any}()
        params = Dict{Symbol, T}()
        new(params, name, values)
    end
end

Configuration{T <: Parameter}(parameters::Array{T, 1}, name::Symbol) = begin
    Configuration{T}(parameters, name)
end

Configuration{T <: Parameter}(parameters::Dict{Symbol, T}, name::Symbol) = begin
    Configuration{T}(parameters, name)
end

Configuration(name::Symbol) = begin
    Configuration{Parameter}(name)
end

Base.convert{T <: Parameter}(::Type{Array{T}}, configuration::Configuration) = begin
    parameter_array = T[]
    for key in collect(keys(configuration.parameters))
        @inbounds push!(parameter_array, configuration[key])
    end
    parameter_array
end

Base.convert{T <: Any}(::Type{Array{T}}, configuration::Configuration, dict::Array{Symbol}) = begin
    parameter_array = T[]
    for key in collect(keys(configuration.value))
        @inbounds parameter = configuration[key]
        push!(parameter_array, parameter.value)
        push!(parameter_array, parameter.min)
        push!(parameter_array, parameter.max)
        push!(dict, key)
    end
    parameter_array
end

getindex(configuration::Configuration, index::Symbol) = begin
    configuration.parameters[index]
end

setindex!{T <: Parameter}(configuration::Configuration, value::T, index::Symbol) = begin
    configuration.parameters[index] = value
end
