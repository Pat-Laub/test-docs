### A Pluto.jl notebook ###
# v0.17.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 7499784c-0ffd-48af-9b0d-d6937bcf9b0a
begin
	using DataFrames
	using LaTeXStrings
	using Latexify
	using SymEngine
	using PlutoUI
	using Random
	using Statistics
	using Printf
end

# ╔═╡ 7e2459b4-70fe-489c-958e-b6476ffaac9f
md"### What does `edm explore x` do?"

# ╔═╡ a9be623f-ada5-46c4-bdf3-d0a89a9812c9
begin
	obs = 12
	t = [symbols("t_$i") for i in 1:obs]
	x = [symbols("x_$i") for i in 1:obs]
	y = [symbols("y_$i") for i in 1:obs]
	z = [symbols("z_$i") for i in 1:obs]
	
	traw = [symbols(raw"t_{" * Base.string(i) * raw"}") for i in 1:obs]
	xraw = [symbols(raw"x_{" * Base.string(i) * raw"}") for i in 1:obs]
	#yraw = [symbols(raw"y_{" * Base.string(i) * raw"}") for i in 1:obs]
	#zraw = [symbols(raw"z_{" * Base.string(i) * raw"}") for i in 1:obs]
	
	#df = DataFrame(t = latexify.(traw), x = latexify.(xraw), y = latexify.(yraw), z = latexify.(zraw))
	df = DataFrame(t = latexify.(traw), x = latexify.(xraw))
end;

# ╔═╡ 5cd973e8-078e-4d7e-9ddd-1a227e44801c
md"##### First split into library and prediction sets"

# ╔═╡ 9b69d2ce-7612-4588-9b43-44a1f99c0314
md"""
Firstly, the manifold $M_x$ is split into two separate parts, called the *library set* denoted $\mathscr{L}$ and the *prediction set* denoted $\mathscr{P}$.
By default, it takes the points of the $M_x$ and randomly assigns half of them to $\mathscr{L}$ and the other half to $\mathscr{P}$.
In this case we create a partition of the manifold, though if Stata is given other options then the same point may appear in both sets.
"""

# ╔═╡ b5df41e1-5d14-45be-abbf-0611d3c0d0cc
md"Starting with the time-delayed embedding of $x$:"

# ╔═╡ 92dfa63d-3799-491b-b2a6-512a44a98f09
md"Choose a value for $E$:"

# ╔═╡ 8630c42d-1357-4d7e-8d26-75aa5afe404a
begin 
	@bind E Slider(2:4; default=3, show_value=true)
end

# ╔═╡ afd006ee-2600-4a0b-a475-4172d22e4f6f
md"Choose a value for $\tau$:"

# ╔═╡ ce054612-97a2-48a0-9a49-4664d708823c
@bind τ Slider(1:3; default=2, show_value=true)

# ╔═╡ 6f9345ef-a557-4271-a9a7-23cdef85c98b
md"""
The time-delayed embedding of the $x$ time series with the given size E = $E and τ = $τ, is the manifold:
"""

# ╔═╡ 152aa84f-71e7-446a-b435-b5daa57fd4b1
begin
	function manifold(x, E, tau)
		Mrows = [reshape(x[(i + tau*(E-1)):-tau:(i)], 1, E) for i = 1:(obs-(E-1)*tau)]
		reduce(vcat, Mrows)
	end;
	
	M_x = manifold(x, E, τ);
	
	M_x_str = latexify(M_x)
	L"M_x := \text{Manifold}(x, E,\tau) = %$(M_x_str)"
end

# ╔═╡ c76bfd49-486d-48c9-936e-e19d06669dfe
begin
	rng = MersenneTwister(1234);
	unifs = rand(rng, size(M_x, 1));
	med = median(unifs);
	
	libraryPoints = findall(unifs .<= med)
	predictionPoints = findall(unifs .> med)
	
	L = M_x[libraryPoints,:];
	P = M_x[predictionPoints,:];
	
	md"Then we may take the points $(Base.string(libraryPoints)) to create the library set, which leaves the remaining $(Base.string(predictionPoints)) points to create the prediction set."
end

# ╔═╡ 7c0c12f9-e348-4af3-a4d7-323bba09c95f
md"In that case, the *library set* is"

# ╔═╡ 45fa3658-3855-48b4-9eaa-a9a9bac55f9d
begin

	latexalign([LaTeXString(raw"\mathscr{L}")], [L])
end

# ╔═╡ a0d44f17-df31-4662-9777-f867fcfa44c7
md"and the *prediction set* is"

# ╔═╡ 8a934063-6348-48cb-9c30-532b44052fd9
latexalign([LaTeXString(raw"\mathscr{P}")], [P])

# ╔═╡ 6219fd69-62b7-4736-8fc2-82b7fd062da2
md"""
It will help to introduce a notation to refer to a specific point in these sets based on its row number.
E.g. in the example above, the first point in the library set takes the value:
"""

# ╔═╡ 963a24c4-743a-484e-a50d-8c5605c7f98f
latexalign([LaTeXString(raw"\mathscr{L}_1")], [L[[1],:]])

# ╔═╡ d7e2fa8d-7b9b-484d-91f2-a4237babc707
md"""
More generally $\mathscr{L}_{i}$ refers to the $i$th point in $\mathscr{L}$
and similarly $\mathscr{P}_{j}$ refers to the $j$th point in $\mathscr{P}$.
"""

# ╔═╡ 3de1fca8-13ac-4358-bb41-ce947bbce460
# begin
# t_all = manifold(t, E, τ)
# firstTime = t_all[trainingSlices[1],1]
	
# Markdown.parse(raw"The first observation in this slice was measured at time $" * Base.string(firstTime) * raw"$.")
# md"TODO: Alternative notation based on time."
# end;

# ╔═╡ 0fe181b0-c244-4b67-97a0-cf452aa6f277
md"##### Next, look at the future values of each point"

# ╔═╡ aaa5b419-65ca-41e0-a0fe-34af564c09d3
md"""
Each point on the manifold refers to a small trajectory of a time series, and for each point we look $p$ observations into the future of the time series.
"""

# ╔═╡ faf7fd88-aa9f-4b87-9e44-7a7dbfa14927
md"Choose a value for $p$:"

# ╔═╡ 2aa0c807-f3ab-426f-bf3b-6ec87c4ad2e9
@bind p Slider(-2:2; default=1, show_value=true)

# ╔═╡ 20628228-a140-4b56-bc63-5742660822c7
md"We have $p$ = $p."

# ╔═╡ 07bbe29b-41ab-4b9b-9c37-7a93f7c7f1fb
md"""
So if we take the first point of the prediction set $\mathscr{P}_{1}$ and say that $y_1^{\mathscr{P}}$ is the value it takes $p$ observations in the future, we get:
"""

# ╔═╡ 7b4b123c-6c91-48e4-9b08-70df7049f304
begin
	ahead = p
	x_fut = [symbols("x_$(i + τ*(E-1) + ahead)") for i = 1:(obs-(E-1)*τ)]
	y_fut = [symbols("y_$(i + τ*(E-1) + ahead)") for i = 1:(obs-(E-1)*τ)]
	z_fut = [symbols("z_$(i + τ*(E-1) + ahead)") for i = 1:(obs-(E-1)*τ)]
	
	x_fut_train = x_fut[libraryPoints]
	x_fut_pred = x_fut[predictionPoints]
	
	first_P_point = latexify(P[[1],:], env=:raw)
	first_y_P = latexify(x_fut_pred[[1],:], env=:raw)
	
	L"\mathscr{P}_{1} = %$first_P_point \quad \underset{\small \text{Matches}}{\Rightarrow} \quad y_1^{\mathscr{P}} = %$first_y_P"
end

# ╔═╡ e9f56664-6d86-4a9c-b1a5-65d0af9bf1b0
md"""
This $p$ may be thought of as the *prediction horizon*, and in `explore` mode is defaults to τ and in `xmap` mode it defaults to 0.
"""

# ╔═╡ ad158c77-8a83-4ee0-9df6-bff0852ff896
md"""
In the literature, instead of measuring the number of observations $p$ ahead, authors normally use the value $T_p$ to denote the amount of time this corresponds to.
When data is regularly sampled (e.g. $t_i = i$) then there is no difference (e.g. $T_p = p$), however for irregularly sampled data the actual time difference may be different for each prediction.
"""

# ╔═╡ e4f62eab-a061-41a1-82a6-cf1cf4860ddf
md"In the training set, this means each point of $\mathscr{L}$ matches the corresponding value in $y^{\,\mathscr{L}}$:"

# ╔═╡ bf3906d4-729b-4f35-b0a1-b1eff5797602
begin
	L_str = latexify(L, env=:raw)
	y_L_str = latexify(x_fut_train, env=:raw)
	
 	L"\mathscr{L} = %$L_str \quad \underset{\small \text{Matches}}{\Rightarrow} \quad y^{\,\mathscr{L}} = %$y_L_str"
end

# ╔═╡ 0c676a7d-1b7a-432b-8058-320a37188ab3
md"Similarly, for the prediction set:"

# ╔═╡ 7ac81a86-de83-4fb8-9415-5a8d71d58ca4
begin
	P_str = latexify(P, env=:raw)
	y_P_str = latexify(x_fut_pred, env=:raw) # [1:size(P,1)]
	L"\mathscr{P} = %$P_str \quad \underset{\small \text{Matches}}{\Rightarrow} \quad y^{\mathscr{P}} = %$y_P_str"
end

# ╔═╡ b26cfd13-0749-4986-97d7-0dffc899757b
md"""
We may refer to elements of the $y^{\mathscr{L}}$ vector as *projections* as they come about by taking the $x$ time series and projecting it into the future by $p$ observations.
"""

# ╔═╡ 71fdd13f-19de-46e5-b11f-3e2824275505
md"### What does `edm explore x` predict?"

# ╔═╡ 7be9628d-4f92-4d4a-a1b1-a77141e77c30
md"""
When running `edm explore x`, we pretend that we don't know the values in $y^{\mathscr{P}}$ and that we want to predict them given we know $\mathscr{P}$, $\mathscr{L}$ and $y^{\,\mathscr{L}}$.
"""

# ╔═╡ ed5c583a-8cc2-4bdf-9696-fcc58dcb22fb
md"""
The first prediction is to try to find the value of $y_1^{\mathscr{P}}$ given the corresponding point $\mathscr{P}_1$:
"""

# ╔═╡ b0cb6b70-9c50-48d6-8e96-15b591d53221
L"\mathscr{P}_{1} = %$(latexify(P[[1],:], env=:raw)) \quad \underset{\small \text{Matches}}{\Rightarrow} \quad y_1^{\mathscr{P}} = \, ???"

# ╔═╡ 1e4c550e-ae5a-4fbd-867c-88e5b8013397
md"""
The terminology we use is that $y_1^{\mathscr{P}}$ is the *target* and the point $\mathscr{P}_1$ is the *predictee*.
"""

# ╔═╡ 216f4400-2b75-4472-9661-c477d8931d45
md"""
Looking over all the points in $\mathscr{L}$, we find the indices of the $k$ points which are the most similar to $\mathscr{P}_{1}$.

Let's pretend we have $k=2$ and the most similar points are $\mathscr{L}_{3}$ and $\mathscr{L}_{5}$.
We will choose the notation $\mathcal{NN}_k(1) = \{ 3, 5 \}$ to describe this set of $k$ nearest neighbours of $\mathscr{P}_{1}$.
"""

# ╔═╡ f29669bf-e5e1-4828-a4b0-311f5665a9c3
md"###### Using the simplex algorithm
Then, if we have chosen the `algorithm` to be the simplex algorithm, we predict that
"

# ╔═╡ 535aaf80-9130-4417-81ef-8031da2f7c73
L"y_{1}^{\mathscr{P}} \approx \hat{y}_1^{\mathscr{P}} := w_1 \times y_{3}^{\,\mathscr{L}} + w_2 \times y_{5}^{\,\mathscr{L}}"

# ╔═╡ 69dee0fe-4266-4444-a0f1-44db01b38dbd
md"""where $w_1$ and $w_2$ are some weights with add up to 1. Basically we are predicting that $y_1^{\mathscr{P}}$ is a weighted average of the points $\{ y_j^{\,\mathscr{L}} \}_{j \in \mathcal{NN}_k(1)}$."""

# ╔═╡ 657baf6f-4e4b-408c-918d-f007211699ea
md"To summarise the whole simplex procedure:"

# ╔═╡ d790cbae-85ed-46b7-b0c2-75568802f115
begin
	extractStr = raw"\underset{\small \text{Extracts}}{\Rightarrow} "
	getStr = raw"\underset{\small \text{Get predictee}}{\Rightarrow} "
	findInLStr = raw"\underset{\small \text{Find neighbours in } \mathscr{L}}{\Rightarrow} "
	predictStr = raw"\underset{\small \text{Make prediction}}{\Rightarrow} "
	
	L"
	\begin{align}
	\text{For target }y_i^{\mathscr{P}}
	&%$getStr
	\mathscr{P}_{i}
	%$findInLStr
	\mathcal{NN}_k(i) \\
	&\,\,\,\,%$extractStr
	\{ y_j^{\,\mathscr{L}} \}_{j \in \mathcal{NN}_k(i)}
	%$predictStr
	\hat{y}_i^{\mathscr{P}}
	\end{align}"
end

# ╔═╡ 28e51576-d9bb-46ff-bf24-4c16736b625c
md"###### Using the S-map algorithm
If however we chose `algorithm` to be the S-map algorithm, then we predict
"

# ╔═╡ 0b9081dd-5100-4232-a6be-c2d3d8e3f66f
L"y_{1}^{\mathscr{P}} \approx \hat{y}_1^{\mathscr{P}} := \sum_{j=1}^E w_{1j} \times  \mathscr{P}_{1j}"

# ╔═╡ 0a0df400-ca3f-4c5a-82b6-a536671e7d51
md"""
where the $\{ w_{1j} \}_{j=1,\cdots,E}$ weights are calculated by solving a linear system based on the points in $\{ \mathscr{L}_j \}_{j \in \mathcal{NN}_k(1)}$ and $\{ y_j^{\,\mathscr{L}} \}_{j \in \mathcal{NN}_k(1)}$.
"""

# ╔═╡ bd345675-ab21-4bdf-bbf3-99966a3d46bd
md"Given the specific"

# ╔═╡ fb293078-489d-4f86-afe2-abf75040af6d
L"\mathscr{P}_1 = %$(latexify(P[[1],:]))"

# ╔═╡ 2265c861-f5cf-468b-a523-e7352359c17f
md"in this example, the prediction would look like:"

# ╔═╡ 9c7a4ecb-37bb-448e-8d13-f608725a1f2e
begin
	weights = [symbols("w_{1$i}") for i in 1:E]
	weightedSum = sum(weights.*P[1,:])
	L"y_{1}^{\mathscr{P}} \approx \hat{y}_1^{\mathscr{P}} :=  %$weightedSum"
end

# ╔═╡ 94660506-0de1-4013-b7bf-79f49e09820b
md"To summarise the whole S-map procedure:"

# ╔═╡ 5d65f348-3a8e-4185-b9a1-24c5dec2303f
begin
	weightStr = raw"\underset{\small \text{Calculate}}{\Rightarrow}"
	
	L"
	\begin{align}
	\text{For target }y_i^{\mathscr{P}}
	&%$getStr
	\mathscr{P}_{i}
	%$findInLStr
	\mathcal{NN}_k(i) \\
	&\,\,\,\,%$extractStr
	\{ \mathscr{L}_j, y_j^{\,\mathscr{L}} \}_{j \in \mathcal{NN}_k(i)}
	%$weightStr
	\{ w_{ij} \}_{j=1,\ldots,E} 
	%$predictStr
	\hat{y}_i^{\mathscr{P}}
	\end{align}"
end

# ╔═╡ f6e12684-be4a-4fa9-8a2a-3ea6b205fe9a
md"##### Assessing the prediction quality"

# ╔═╡ ec5e9c90-f7e8-49fa-a7c5-36fc527ebb1d
md"""
We calculate the $\hat{y}_i^{\mathscr{P}}$ predictions for each target in the prediction set (so $i = 1, \dots, |\mathscr{P}|$), and store the predictions in a vector $\hat{y}^{\mathscr{P}}$.

As we have the true value of $y_i^{\mathscr{P}}$ for each target in the prediction set, we can compare our $\hat{y}_i^{\mathscr{P}}$ predictions and assess their quality using their correlation
"""

# ╔═╡ 6b7788e1-4dfa-4249-b3ae-9323c144d8a5
L" \rho := \mathrm{Correlation}(y^{\mathscr{P}} , \hat{y}^{\mathscr{P}}) "

# ╔═╡ e14e6991-ab3e-4ee3-84df-65474d682f95
md"""
or using the mean absolute error
"""

# ╔═╡ 98e1b0ae-da11-4abc-b82a-39f57d86eafb
L"\text{MAE} := \frac{1}{| \mathscr{P} |} \sum_{i=1}^{| \mathscr{P} |} | y_i^{\mathscr{P}} - \hat{y}_i^{\mathscr{P}} | ."

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Printf = "de0858da-6303-5e67-8744-51eddeeeb8d7"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[compat]
DataFrames = "~1.3.0"
LaTeXStrings = "~1.3.0"
Latexify = "~0.15.9"
PlutoUI = "~0.7.23"
SymEngine = "~0.8.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "abb72771fd8895a7ebd83d5632dc4b989b022b5b"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.2"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "2e993336a3f68216be91eb8ee4625ebbaba19147"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MPC_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "MPFR_jll", "Pkg"]
git-tree-sha1 = "9618bed470dcb869f944f4fe4a9e76c4c8bf9a11"
uuid = "2ce0c516-f11f-5db3-98ad-e0e1048fbd70"
version = "1.2.1+0"

[[MPFR_jll]]
deps = ["Artifacts", "GMP_jll", "Libdl"]
uuid = "3a97d323-0669-5f0c-9066-3539efd106a3"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "5152abbdab6488d5eec6a01029ca6697dff4ec8f"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.23"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "db3a23166af8aebf4db5ef87ac5b00d36eb771e2"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "8f82019e525f4d5c669692772a6f4b0a58b06a6a"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.2.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "e08890d19787ec25029113e88c34ec20cac1c91e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.0.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[SymEngine]]
deps = ["Compat", "Libdl", "LinearAlgebra", "RecipesBase", "SpecialFunctions", "SymEngine_jll"]
git-tree-sha1 = "6cf88a0b98c758a36e6e978a41e8a12f6f5cdacc"
uuid = "123dc426-2d89-5057-bbad-38513e3affd8"
version = "0.8.7"

[[SymEngine_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "MPC_jll", "MPFR_jll", "Pkg"]
git-tree-sha1 = "3cd0f249ae20a0093f839738a2f2c1476d5581fe"
uuid = "3428059b-622b-5399-b16f-d347a77089a4"
version = "0.8.1+0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "bb1064c9a84c52e277f1096cf41434b675cd368b"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.1"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─7499784c-0ffd-48af-9b0d-d6937bcf9b0a
# ╟─7e2459b4-70fe-489c-958e-b6476ffaac9f
# ╟─a9be623f-ada5-46c4-bdf3-d0a89a9812c9
# ╟─5cd973e8-078e-4d7e-9ddd-1a227e44801c
# ╟─9b69d2ce-7612-4588-9b43-44a1f99c0314
# ╟─b5df41e1-5d14-45be-abbf-0611d3c0d0cc
# ╟─92dfa63d-3799-491b-b2a6-512a44a98f09
# ╟─8630c42d-1357-4d7e-8d26-75aa5afe404a
# ╟─afd006ee-2600-4a0b-a475-4172d22e4f6f
# ╟─ce054612-97a2-48a0-9a49-4664d708823c
# ╟─6f9345ef-a557-4271-a9a7-23cdef85c98b
# ╟─152aa84f-71e7-446a-b435-b5daa57fd4b1
# ╟─c76bfd49-486d-48c9-936e-e19d06669dfe
# ╟─7c0c12f9-e348-4af3-a4d7-323bba09c95f
# ╟─45fa3658-3855-48b4-9eaa-a9a9bac55f9d
# ╟─a0d44f17-df31-4662-9777-f867fcfa44c7
# ╟─8a934063-6348-48cb-9c30-532b44052fd9
# ╟─6219fd69-62b7-4736-8fc2-82b7fd062da2
# ╟─963a24c4-743a-484e-a50d-8c5605c7f98f
# ╟─d7e2fa8d-7b9b-484d-91f2-a4237babc707
# ╟─3de1fca8-13ac-4358-bb41-ce947bbce460
# ╟─0fe181b0-c244-4b67-97a0-cf452aa6f277
# ╟─aaa5b419-65ca-41e0-a0fe-34af564c09d3
# ╟─faf7fd88-aa9f-4b87-9e44-7a7dbfa14927
# ╟─2aa0c807-f3ab-426f-bf3b-6ec87c4ad2e9
# ╟─20628228-a140-4b56-bc63-5742660822c7
# ╟─07bbe29b-41ab-4b9b-9c37-7a93f7c7f1fb
# ╟─7b4b123c-6c91-48e4-9b08-70df7049f304
# ╟─e9f56664-6d86-4a9c-b1a5-65d0af9bf1b0
# ╟─ad158c77-8a83-4ee0-9df6-bff0852ff896
# ╟─e4f62eab-a061-41a1-82a6-cf1cf4860ddf
# ╟─bf3906d4-729b-4f35-b0a1-b1eff5797602
# ╟─0c676a7d-1b7a-432b-8058-320a37188ab3
# ╟─7ac81a86-de83-4fb8-9415-5a8d71d58ca4
# ╟─b26cfd13-0749-4986-97d7-0dffc899757b
# ╟─71fdd13f-19de-46e5-b11f-3e2824275505
# ╟─7be9628d-4f92-4d4a-a1b1-a77141e77c30
# ╟─ed5c583a-8cc2-4bdf-9696-fcc58dcb22fb
# ╟─b0cb6b70-9c50-48d6-8e96-15b591d53221
# ╟─1e4c550e-ae5a-4fbd-867c-88e5b8013397
# ╟─216f4400-2b75-4472-9661-c477d8931d45
# ╟─f29669bf-e5e1-4828-a4b0-311f5665a9c3
# ╟─535aaf80-9130-4417-81ef-8031da2f7c73
# ╟─69dee0fe-4266-4444-a0f1-44db01b38dbd
# ╟─657baf6f-4e4b-408c-918d-f007211699ea
# ╟─d790cbae-85ed-46b7-b0c2-75568802f115
# ╟─28e51576-d9bb-46ff-bf24-4c16736b625c
# ╟─0b9081dd-5100-4232-a6be-c2d3d8e3f66f
# ╟─0a0df400-ca3f-4c5a-82b6-a536671e7d51
# ╟─bd345675-ab21-4bdf-bbf3-99966a3d46bd
# ╟─fb293078-489d-4f86-afe2-abf75040af6d
# ╟─2265c861-f5cf-468b-a523-e7352359c17f
# ╟─9c7a4ecb-37bb-448e-8d13-f608725a1f2e
# ╟─94660506-0de1-4013-b7bf-79f49e09820b
# ╟─5d65f348-3a8e-4185-b9a1-24c5dec2303f
# ╟─f6e12684-be4a-4fa9-8a2a-3ea6b205fe9a
# ╟─ec5e9c90-f7e8-49fa-a7c5-36fc527ebb1d
# ╟─6b7788e1-4dfa-4249-b3ae-9323c144d8a5
# ╟─e14e6991-ab3e-4ee3-84df-65474d682f95
# ╟─98e1b0ae-da11-4abc-b82a-39f57d86eafb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
