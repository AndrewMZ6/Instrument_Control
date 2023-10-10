function outputArg = parse_web_array(arr)

    %PARSE_WEB_ARRAY Summary of this function goes here
    %   Detailed explanation goes here
    arr_real = arr.answer.real;
    arr_imag = arr.answer.imag;

    x = arr_real(2:end-1);
    y = arr_imag(2:end-1);



    x_sp = split(x, ',');
    y_sp = split(y, ',');

    x_nums = cellfun(@str2num, x_sp);
    y_nums = cellfun(@str2num, y_sp);


    outputArg = complex(x_nums, y_nums);


end

