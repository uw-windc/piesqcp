using JuMP, JSON, Ipopt


d = JSON.Parser.parsefile("piesqcp_data.json")


function parse_data(key)
    x = Dict()

    if d[key]["type"] == "GamsSet"
        if d[key]["dimension"] == 1
            x = d[key]["elements"]
            return x
        end
    end

    # need to work on import multidimentional sets (i.e., mappings)

    if d[key]["type"] == "GamsParameter"
        if d[key]["dimension"] == 0
            x = d[key]["values"]
            return x
        end

        if d[key]["dimension"] == 1
            for i in 1:length(d[key]["values"]["domain"])
                a = d[key]["values"]["domain"][i]
                x[a] = d[key]["values"]["data"][i]
            end
            return x
        end

        if d[key]["dimension"] > 1
            for i in 1:length(d[key]["values"]["domain"])
                a = tuple(d[key]["values"]["domain"][i]...)
                x[a] = d[key]["values"]["data"][i]
            end
        return x
        end
    end
end

# data pull
i = parse_data("i")
j = parse_data("j")
k = parse_data("k")
r = parse_data("r")
c = parse_data("c")
o = parse_data("o")
p = parse_data("p")
g = parse_data("g")
table1 = parse_data("table1")
table2 = parse_data("table2")
table3 = parse_data("table3")
table4 = parse_data("table4")
table5 = parse_data("table5")
table6 = parse_data("table6")
table7 = parse_data("table7")
table8 = parse_data("table8")
table9 = parse_data("table9")
pref = parse_data("pref")
qref = parse_data("qref")
epsilon = parse_data("epsilon")
d0 = parse_data("d0")
p0 = parse_data("p0")
sigma = parse_data("sigma")
savail = parse_data("savail")
kavail = parse_data("kavail")



# model object
pies = Model(with_optimizer(Ipopt.Optimizer, print_level = 0))

# add variables and initial point to model object
@variable(pies, 0 <= QC[z in i, zz in c] <= table1[z,zz,"cap"])
@variable(pies, 0 <= QO[z in k, zz in o] <= table3[z,zz,"cap"])
@variable(pies, QR[z in r] >= 0)
@variable(pies, D[z in p, zz in j] >= 0)
@variable(pies, XR[z in r, zz in g, zzz in j] >= 0)
@variable(pies, XC[z in i, zz in j] >= 0)
@variable(pies, XO[z in k, zz in r] >= 0)
@variable(pies, TCOST >= 0)
@variable(pies, OCOST >= 0)
@variable(pies, CS >= 0)
@variable(pies, OBJ)


# add constartins to model object
@constraint(pies, oilresource[z in k], sum(QO[z,zz] for zz in o) >= sum(XO[z,zz] for zz in r) )
@constraint(pies, crudeoil[z in r], sum(XO[zz,z] for zz in k) >= QR[z] )
@constraint(pies, refinedoil[z in r, zz in g], QR[z] * table5[zz,z] >= sum(XR[z,zz,zzz] for zzz in j) )
@constraint(pies, oildemand[z in j, zz in g], sum(XR[zzz,zz,z] for zzz in r) >= D[zz,z] )
@constraint(pies, coalsupply[z in i], sum(QC[z,zz] for zz in c) >= sum(XC[z,zz] for zz in j) )
@constraint(pies, coaldemand[z in j], sum(XC[zz,z] for zz in i) >= D["Coal",z] )


@constraint(pies, transportcost, TCOST == sum(XR[z,zz,zzz] * table6[z,zzz] for z in r for zz in g for zzz in j)
                                            + sum(XO[z,zz] * table4[z,zz] for z in k for zz in r)
                                            + sum(XC[z,zz] * table2[z,zz] for z in i for zz in j) )

@constraint(pies, othercost, OCOST == sum(QO[z,zz] * table3[z,zz,"c0"] for z in k for zz in o)
                                            + sum(QC[z,zz] * table1[z,zz,"c0"] for z in i for zz in c)
                                            + sum(QR[z] * table5["cost",z] for z in r) )


# First use a simple integrable demand function to define consumer surplus
# We can use the @constraint macro because the nonlinear term is limited to quadratic terms,
# the @NLconstraint is for general nonlinear functions
@constraint(pies, surplus, CS == sum(D[z,zz] * pref[z] * (1 + (1 - D[z,zz]/(2*qref[z])/epsilon[z])) for z in p for zz in j ))

# objective
@objective(pies, Max, CS - TCOST - OCOST)


# solve
optimize!(pies)

# post processing / output solution check
print(termination_status(pies))
print(primal_status(pies))
print(dual_status(pies))


# output final objective value
print(objective_value(pies))
