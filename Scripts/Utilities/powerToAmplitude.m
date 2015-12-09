function amplitude = powerToAmplitude(power)
	% amplitudeToPower function takes in an array of amplitudes (column vector)
	% and outputs an elementwise squaring of the vector.

	sizeOfPower = size(power);
	nIterations = sizeOfPower(1, 2);
    for i = 1 : nIterations
    	if power(i) > 0
        	power(i) = power(i)^(0.5);
    	else
    		power(i) = 0;
    	end
    end
    
    amplitude = power;
end