def pi_est(vmax,i,vs,dist, eps):
    """calculate the """
    argmax, maxim = pi_opt(vmax,i,vs,dist)
    
    #ensure we are near the right solution
    eqn = lambda p:(pi_u(p,vmax,i,vs,dist) - maxim)
    cons = [{'type': 'ineq', 'fun':lambda p: eps - eqn(p)**2 }]
    
    #solve for lb, but allow for error
    init1 = scipy.optimize.fsolve(eqn,argmax*.9)
    obj1 = lambda p: -p
    bnds1 = [(0,argmax)]
    result1 = scipy.optimize.minimize(obj1, init1, method='SLSQP',
                                      bounds=bnds1, constraints=cons )
    
    #solve for ub, but allow for error
    init2 =  scipy.optimize.fsolve(eqn,argmax*1.1)
    obj2 = lambda p: p
    bnds2 = [(argmax,vmax)]
    result2 = scipy.optimize.minimize(obj2, init2, method='SLSQP',
                                      bounds=bnds2, constraints=cons )
    
    return np.concatenate([result1.x, result2.x])
