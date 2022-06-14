
abstract type AbstractStatefulFunction{V} <: Function end

struct StatefulFunction{F,V} <: AbstractStatefulFunction{V}
    f::F
    v::Base.RefValue{V}
end

func(f::StatefulFunction) = f.f
fval(f::StatefulFunction) = f.v[]


function setv!(f::StatefulFunction, v)
    f.v[] = v
end

getv(f::StatefulFunction) = fval(f)


function (f::StatefulFunction)(s)
    f.f
end