let rec sum = ((n, acc) : (int,int)): int =>
    if (n < 1) {acc;} else {sum ((n-1,acc+n));};
