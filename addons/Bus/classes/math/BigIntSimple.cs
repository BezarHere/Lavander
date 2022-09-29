internal static string FormatBigInteger(BigInteger value, string format, NumberFormatInfo info)
{
	int num = 0;
	//char c = BigNumber.ParseFormatSpecifier(format, out num); // c = "R"
	//bool flag = c == 'g' || c == 'G' || c == 'd' || c == 'D' || c == 'r' || c == 'R'; // flag = true
	//int num2 = value._bits.Length; // num2 = 256
	// int num3; // num3 = 286
	// try
	// {
		// num3 = checked(num2 * 10 / 9 + 2);
	// }
	// catch (OverflowException innerException)
	// {
		// throw new FormatException(SR.Format_TooLarge, innerException);
	// }
	uint[] array = new uint[num3];
	int num4 = 0;
	int num5 = num2;
	while (--num5 >= 0)
	{
		uint num6 = value._bits[num5];
		for (int i = 0; i < num4; i++)
		{
			ulong num7 = (array[i] << 32) | num6;
			array[i] = (uint)(num7 % 1000000000UL);
			num6 = (uint)(num7 / 1000000000UL);
		}
		if (num6 != 0U)
		{
			array[num4++] = num6 % 1000000000U;
			num6 /= 1000000000U;
			if (num6 != 0U)
			{
				array[num4++] = num6;
			}
		}
	}
	int num8;
	char[] array2;
	int num10;
	checked
	{
		try
		{
			num8 = num4 * 9;
		}
		catch (OverflowException innerException2)
		{
			throw new FormatException(SR.Format_TooLarge, innerException2);
		}
		if (num > 0 && num > num8)
		{
			num8 = num;
		}
		if (value._sign < 0)
		{
			try
			{
				num8 += info.NegativeSign.Length;
			}
			catch (OverflowException innerException3)
			{
				throw new FormatException(SR.Format_TooLarge, innerException3);
			}
		}
		
		int num9;
		try
		{
			num9 = num8 + 1;
		}
		catch (OverflowException innerException4)
		{
			throw new FormatException(SR.Format_TooLarge, innerException4);
		}
		array2 = new char[num9];
		num10 = num8;
	}
	for (int j = 0; j < num4 - 1; j++)
	{
		uint num11 = array[j];
		int num12 = 9;
		while (--num12 >= 0)
		{
			array2[--num10] = (char)(48U + num11 % 10U);
			num11 /= 10U;
		}
	}
	for (uint num13 = array[num4 - 1]; num13 != 0U; num13 /= 10U)
	{
		array2[--num10] = (char)(48U + num13 % 10U);
	}
	// if (!flag) flag will never be false
	// {
		// bool sign = value._sign < 0;
		// int precision = 29;
		// int scale = num8 - num10;
		// return FormatProvider.FormatBigInteger(precision, scale, sign, format, info, array2, num10);
	// }
	int num14 = num8 - num10;
	while (num > 0 && num > num14)
	{
		array2[--num10] = '0';
		num--;
	}
	return new string(array2, num10, num8 - num10);
}