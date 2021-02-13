#=
List of reasonably large problems:

pnames = CUTEst.select(max_var=3000, min_var=1000, min_con=1, only_free_var=true, only_equ_con=true, objtype=3:6)
9-element Array{String,1}:
 "SPINOP" --> work with the agressive step :-)
 "EIGENA2" #easy :)
 "MSS3" --> cycle / Fail cgls computation Lagrange multiplier: maximum number of iterations exceeded
 "EIGENBCO" - not after 10 minutes, but it is decreasing (only 40 iterations)
 "LCH" --> works ! Youhou, about 270 iterations
                    many unnecessary factorizations though (reduce γ increase γ)
 "EIGENB2" --> ran for 30minutes but stuck
 "EIGENC2" --> 25 itérations, 250 secondes :)
 "EIGENCCO" --> not after 10 minutes :( (but slowly getting there I think) - too many unnecessary factorizations (reduce γ increase γ)
                isposdef(Symmetric(hess(nlp, nlp.meta.x0),:L)) is false 
"EIGENACO" easy :) 

Check that our limits are size dependent.

#Our formula for Infeasibility:
infeasible = norm(d) < ctol * ρ * min(normcz, one(T)) #should probably depend on Δ also?
#Alternative: scaling
#Unproductive steps

There are two annoying points:
i) infeasible stationary points of the feasibility problem. (-> move from the current point)
ii) infeasible stationary points of the optimization problem. (-> need to move from the current point AND change ρ)

Small tangent step: "Execution stats: unhandled exception"
What is the value of λ when it is stalling?
=#

using NLPModels, CUTEst, DCI

nlp = CUTEstModel("EIGENBCO")

stats = dci(nlp, nlp.meta.x0, linear_solver = :ma57, max_time = 600., max_iter = 1000)

@show nlp.counters

finalize(nlp)