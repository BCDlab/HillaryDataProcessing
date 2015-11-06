function power = amplitudeToPower(amplitude)
	% amplitudeToPower function takes in an array of amplitudes (column vector)
	% and outputs an elementwise squaring of the vector.

	sizeOfAmplitude = size(amplitude);
	nIterations = sizeOfAmplitude(1, 2);
    for i = 1 : nIterations
        amplitude(i) = amplitude(i)^2;
    end
    power = amplitude;
end