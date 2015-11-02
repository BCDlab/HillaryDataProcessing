function power = amplitudeToPower(amplitude)
	% amplitudeToPower function takes in an array of amplitudes (column vector)
	% and outputs an elementwise square rooting of the vector.

	amplitude = amplitude';
    for i = 1 : size(amplitude)
        amplitude(i) = sqrt(amplitude(i));
    end
    power = amplitude';
end