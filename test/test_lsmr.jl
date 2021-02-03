#=
We test here the computation of a direction d such that
````
 \minimize_d q(d):=∇f(z)'d + 1/2 d'B(z)d \st ||d|| ≤ Δ, ||∇h(z)d|| ≤ Δ²,
 where B represents the Lagrangian Hessian.

 This is a first try to see how `lsmr` works. From the documentation it should solve
    [ B^{-1} J'][r] = [-g]
    [ J      0 ][μ] = [ 0]
=#
using Krylov, LinearAlgebra, NLPModels, Test

#@testset "Example 1" begin
    nlp = ADNLPModel(
        x->0.01 * (x[1] - 1)^2 + (x[2] - x[1]^2)^2,
        [2.0; 2.0; 2.0],
        #x->[x[1]^2 + x[3]^2 + 1.0],
        x->[x[1]^2 - x[3]^2 - 1.0],
        zeros(1),
        zeros(1)
    )

    x  = [0.; 1.; 0.]
    λ  = rand(1)
    B  = hess(nlp, x, λ)
    cx = cons(nlp, x)
    Jx = jac(nlp, x)

    Δ = .5

    c = grad(nlp, x)
    #=
    This is a first try to see how `lsmr` works. From the documentation it should solve
        [ B^{-1} J'][r] = [-g]
        [ J      0 ][μ] = [ 0]
    =#
    (μ, stats) = lsmr(jac_op(nlp, x)', -c, M = B, verbose = true)
    @test μ == [0.]
    r = - c - jac_op(nlp, x)' * μ
    nres = sqrt(r' * B *r)
    @test [nres] == stats.residuals

    #Est-ce qu'il y a un problème ici ?
    #Depuis la doc, je pensais que ça résolvait ce problème:
    @test [inv(B) Jx'; Jx  zeros(1,1)] * vcat(r, μ) - vcat(-c, zeros(1)) != zeros(4)
    #ou au pire celui-là (^^)
    @test [B Jx'; Jx  zeros(1,1)] * vcat(r, μ) - vcat(-c, zeros(1)) != zeros(4)
    #mais il a l'air d'ignorer B
    @test [I Jx'; Jx  zeros(1,1)] * vcat(r, μ) - vcat(-c, zeros(1)) == zeros(4)

#end