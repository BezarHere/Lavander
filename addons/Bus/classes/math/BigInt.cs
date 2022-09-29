using System;
using System.Diagnostics;
using System.Globalization;

namespace System.Numerics
{
	/// <summary>Represents an arbitrarily large signed integer.</summary>
	// Token: 0x02000006 RID: 6
	public struct BigInteger : IFormattable, IComparable, IComparable<BigInteger>, IEquatable<BigInteger>
	{
		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure using a 32-bit signed integer value.</summary>
		/// <param name="value">A 32-bit signed integer.</param>
		// Token: 0x06000055 RID: 85 RVA: 0x00003AB8 File Offset: 0x00001CB8
		public BigInteger(int value)
		{
			if (value == -2147483648)
			{
				this = BigInteger.s_bnMinInt;
				return;
			}
			this._sign = value;
			this._bits = null;
		}

		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure using an unsigned 32-bit integer value.</summary>
		/// <param name="value">An unsigned 32-bit integer value.</param>
		// Token: 0x06000056 RID: 86 RVA: 0x00003ADC File Offset: 0x00001CDC
		[CLSCompliant(false)]
		public BigInteger(uint value)
		{
			if (value <= 2147483647U)
			{
				this._sign = (int)value;
				this._bits = null;
				return;
			}
			this._sign = 1;
			this._bits = new uint[1];
			this._bits[0] = value;
		}

		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure using a 64-bit signed integer value.</summary>
		/// <param name="value">A 64-bit signed integer.</param>
		// Token: 0x06000057 RID: 87 RVA: 0x00003B14 File Offset: 0x00001D14
		public BigInteger(long value)
		{
			if (-2147483648L < value && value <= 2147483647L)
			{
				this._sign = (int)value;
				this._bits = null;
				return;
			}
			if (value == -2147483648L)
			{
				this = BigInteger.s_bnMinInt;
				return;
			}
			ulong num;
			if (value < 0L)
			{
				num = (ulong)(-(ulong)value);
				this._sign = -1;
			}
			else
			{
				num = (ulong)value;
				this._sign = 1;
			}
			if (num <= (ulong)-1)
			{
				this._bits = new uint[1];
				this._bits[0] = (uint)num;
				return;
			}
			this._bits = new uint[2];
			this._bits[0] = (uint)num;
			this._bits[1] = (uint)(num >> 32);
		}

		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure with an unsigned 64-bit integer value.</summary>
		/// <param name="value">An unsigned 64-bit integer.</param>
		// Token: 0x06000058 RID: 88 RVA: 0x00003BB4 File Offset: 0x00001DB4
		[CLSCompliant(false)]
		public BigInteger(ulong value)
		{
			if (value <= 2147483647UL)
			{
				this._sign = (int)value;
				this._bits = null;
				return;
			}
			if (value <= (ulong)-1)
			{
				this._sign = 1;
				this._bits = new uint[1];
				this._bits[0] = (uint)value;
				return;
			}
			this._sign = 1;
			this._bits = new uint[2];
			this._bits[0] = (uint)value;
			this._bits[1] = (uint)(value >> 32);
		}

		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure using a single-precision floating-point value.</summary>
		/// <param name="value">A single-precision floating-point value.</param>
		/// <exception cref="T:System.OverflowException">The value of <paramref name="value" /> is <see cref="F:System.Single.NaN" />.-or-The value of <paramref name="value" /> is <see cref="F:System.Single.NegativeInfinity" />.-or-The value of <paramref name="value" /> is <see cref="F:System.Single.PositiveInfinity" />.</exception>
		// Token: 0x06000059 RID: 89 RVA: 0x00003C27 File Offset: 0x00001E27
		public BigInteger(float value)
		{
			this = new BigInteger((double)value);
		}

		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure using a double-precision floating-point value.</summary>
		/// <param name="value">A double-precision floating-point value.</param>
		/// <exception cref="T:System.OverflowException">The value of <paramref name="value" /> is <see cref="F:System.Double.NaN" />.-or-The value of <paramref name="value" /> is <see cref="F:System.Double.NegativeInfinity" />.-or-The value of <paramref name="value" /> is <see cref="F:System.Double.PositiveInfinity" />.</exception>
		// Token: 0x0600005A RID: 90 RVA: 0x00003C34 File Offset: 0x00001E34
		public BigInteger(double value)
		{
			if (double.IsInfinity(value))
			{
				throw new OverflowException(SR.Overflow_BigIntInfinity);
			}
			if (double.IsNaN(value))
			{
				throw new OverflowException(SR.Overflow_NotANumber);
			}
			this._sign = 0;
			this._bits = null;
			int num;
			int num2;
			ulong num3;
			bool flag;
			NumericsHelpers.GetDoubleParts(value, out num, out num2, out num3, out flag);
			if (num3 == 0UL)
			{
				this = BigInteger.Zero;
				return;
			}
			if (num2 <= 0)
			{
				if (num2 <= -64)
				{
					this = BigInteger.Zero;
					return;
				}
				this = num3 >> -num2;
				if (num < 0)
				{
					this._sign = -this._sign;
					return;
				}
			}
			else if (num2 <= 11)
			{
				this = num3 << num2;
				if (num < 0)
				{
					this._sign = -this._sign;
					return;
				}
			}
			else
			{
				num3 <<= 11;
				num2 -= 11;
				int num4 = (num2 - 1) / 32 + 1;
				int num5 = num4 * 32 - num2;
				this._bits = new uint[num4 + 2];
				this._bits[num4 + 1] = (uint)(num3 >> num5 + 32);
				this._bits[num4] = (uint)(num3 >> num5);
				if (num5 > 0)
				{
					this._bits[num4 - 1] = (uint)num3 << 32 - num5;
				}
				this._sign = num;
			}
		}

		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure using a <see cref="T:System.Decimal" /> value.</summary>
		/// <param name="value">A decimal number.</param>
		// Token: 0x0600005B RID: 91 RVA: 0x00003D70 File Offset: 0x00001F70
		public BigInteger(decimal value)
		{
			int[] bits = decimal.GetBits(decimal.Truncate(value));
			int num = 3;
			while (num > 0 && bits[num - 1] == 0)
			{
				num--;
			}
			if (num == 0)
			{
				this = BigInteger.s_bnZeroInt;
				return;
			}
			if (num == 1 && bits[0] > 0)
			{
				this._sign = bits[0];
				this._sign *= (((bits[3] & int.MinValue) != 0) ? -1 : 1);
				this._bits = null;
				return;
			}
			this._bits = new uint[num];
			this._bits[0] = (uint)bits[0];
			if (num > 1)
			{
				this._bits[1] = (uint)bits[1];
			}
			if (num > 2)
			{
				this._bits[2] = (uint)bits[2];
			}
			this._sign = (((bits[3] & int.MinValue) != 0) ? -1 : 1);
		}

		/// <summary>Initializes a new instance of the <see cref="T:System.Numerics.BigInteger" /> structure using the values in a byte array.</summary>
		/// <param name="value">An array of byte values in little-endian order.</param>
		/// <exception cref="T:System.ArgumentNullException">
		///   <paramref name="value" /> is null.</exception>
		// Token: 0x0600005C RID: 92 RVA: 0x00003E2C File Offset: 0x0000202C
		[CLSCompliant(false)]
		public BigInteger(byte[] value)
		{
			if (value == null)
			{
				throw new ArgumentNullException("value");
			}
			int num = value.Length;
			bool flag = num > 0 && (value[num - 1] & 128) == 128;
			while (num > 0 && value[num - 1] == 0)
			{
				num--;
			}
			if (num == 0)
			{
				this._sign = 0;
				this._bits = null;
				return;
			}
			if (num <= 4)
			{
				if (flag)
				{
					this._sign = -1;
				}
				else
				{
					this._sign = 0;
				}
				for (int i = num - 1; i >= 0; i--)
				{
					this._sign <<= 8;
					this._sign |= (int)value[i];
				}
				this._bits = null;
				if (this._sign < 0 && !flag)
				{
					this._bits = new uint[1];
					this._bits[0] = (uint)this._sign;
					this._sign = 1;
				}
				if (this._sign == -2147483648)
				{
					this = BigInteger.s_bnMinInt;
					return;
				}
			}
			else
			{
				int num2 = num % 4;
				int num3 = num / 4 + ((num2 == 0) ? 0 : 1);
				bool flag2 = true;
				uint[] array = new uint[num3];
				int j = 3;
				int k;
				for (k = 0; k < num3 - ((num2 == 0) ? 0 : 1); k++)
				{
					for (int l = 0; l < 4; l++)
					{
						if (value[j] != 0)
						{
							flag2 = false;
						}
						array[k] <<= 8;
						array[k] |= (uint)value[j];
						j--;
					}
					j += 8;
				}
				if (num2 != 0)
				{
					if (flag)
					{
						array[num3 - 1] = uint.MaxValue;
					}
					for (j = num - 1; j >= num - num2; j--)
					{
						if (value[j] != 0)
						{
							flag2 = false;
						}
						array[k] <<= 8;
						array[k] |= (uint)value[j];
					}
				}
				if (flag2)
				{
					this = BigInteger.s_bnZeroInt;
					return;
				}
				if (flag)
				{
					NumericsHelpers.DangerousMakeTwosComplement(array);
					int num4 = array.Length;
					while (num4 > 0 && array[num4 - 1] == 0U)
					{
						num4--;
					}
					if (num4 == 1 && array[0] > 0U)
					{
						if (array[0] == 1U)
						{
							this = BigInteger.s_bnMinusOneInt;
							return;
						}
						if (array[0] == 2147483648U)
						{
							this = BigInteger.s_bnMinInt;
							return;
						}
						this._sign = (int)(uint.MaxValue * array[0]);
						this._bits = null;
						return;
					}
					else
					{
						if (num4 != array.Length)
						{
							this._sign = -1;
							this._bits = new uint[num4];
							Array.Copy(array, 0, this._bits, 0, num4);
							return;
						}
						this._sign = -1;
						this._bits = array;
						return;
					}
				}
				else
				{
					this._sign = 1;
					this._bits = array;
				}
			}
		}

		// Token: 0x0600005D RID: 93 RVA: 0x000040B5 File Offset: 0x000022B5
		internal BigInteger(int n, uint[] rgu)
		{
			this._sign = n;
			this._bits = rgu;
		}

		// Token: 0x0600005E RID: 94 RVA: 0x000040C8 File Offset: 0x000022C8
		internal BigInteger(uint[] value, bool negative)
		{
			if (value == null)
			{
				throw new ArgumentNullException("value");
			}
			int num = value.Length;
			while (num > 0 && value[num - 1] == 0U)
			{
				num--;
			}
			if (num == 0)
			{
				this = BigInteger.s_bnZeroInt;
				return;
			}
			if (num == 1 && value[0] < 2147483648U)
			{
				this._sign = (int)(negative ? (-(int)value[0]) : value[0]);
				this._bits = null;
				if (this._sign == -2147483648)
				{
					this = BigInteger.s_bnMinInt;
					return;
				}
			}
			else
			{
				this._sign = (negative ? -1 : 1);
				this._bits = new uint[num];
				Array.Copy(value, 0, this._bits, 0, num);
			}
		}

		// Token: 0x0600005F RID: 95 RVA: 0x00004170 File Offset: 0x00002370
		private BigInteger(uint[] value)
		{
			if (value == null)
			{
				throw new ArgumentNullException("value");
			}
			int num = value.Length;
			bool flag = num > 0 && (value[num - 1] & 2147483648U) == 2147483648U;
			while (num > 0 && value[num - 1] == 0U)
			{
				num--;
			}
			if (num == 0)
			{
				this = BigInteger.s_bnZeroInt;
				return;
			}
			if (num == 1)
			{
				if (value[0] < 0U && !flag)
				{
					this._bits = new uint[1];
					this._bits[0] = value[0];
					this._sign = 1;
					return;
				}
				if (2147483648U == value[0])
				{
					this = BigInteger.s_bnMinInt;
					return;
				}
				this._sign = (int)value[0];
				this._bits = null;
				return;
			}
			else if (!flag)
			{
				if (num != value.Length)
				{
					this._sign = 1;
					this._bits = new uint[num];
					Array.Copy(value, 0, this._bits, 0, num);
					return;
				}
				this._sign = 1;
				this._bits = value;
				return;
			}
			else
			{
				NumericsHelpers.DangerousMakeTwosComplement(value);
				int num2 = value.Length;
				while (num2 > 0 && value[num2 - 1] == 0U)
				{
					num2--;
				}
				if (num2 == 1 && value[0] > 0U)
				{
					if (value[0] == 1U)
					{
						this = BigInteger.s_bnMinusOneInt;
						return;
					}
					if (value[0] == 2147483648U)
					{
						this = BigInteger.s_bnMinInt;
						return;
					}
					this._sign = (int)(uint.MaxValue * value[0]);
					this._bits = null;
					return;
				}
				else
				{
					if (num2 != value.Length)
					{
						this._sign = -1;
						this._bits = new uint[num2];
						Array.Copy(value, 0, this._bits, 0, num2);
						return;
					}
					this._sign = -1;
					this._bits = value;
					return;
				}
			}
		}

		/// <summary>Gets a value that represents the number 0 (zero).</summary>
		/// <returns>An integer whose value is 0 (zero).</returns>
		// Token: 0x17000011 RID: 17
		// (get) Token: 0x06000060 RID: 96 RVA: 0x000042EE File Offset: 0x000024EE
		public static BigInteger Zero
		{
			get
			{
				return BigInteger.s_bnZeroInt;
			}
		}

		/// <summary>Gets a value that represents the number one (1).</summary>
		/// <returns>An object whose value is one (1).</returns>
		// Token: 0x17000012 RID: 18
		// (get) Token: 0x06000061 RID: 97 RVA: 0x000042F5 File Offset: 0x000024F5
		public static BigInteger One
		{
			get
			{
				return BigInteger.s_bnOneInt;
			}
		}

		/// <summary>Gets a value that represents the number negative one (-1).</summary>
		/// <returns>An integer whose value is negative one (-1).</returns>
		// Token: 0x17000013 RID: 19
		// (get) Token: 0x06000062 RID: 98 RVA: 0x000042FC File Offset: 0x000024FC
		public static BigInteger MinusOne
		{
			get
			{
				return BigInteger.s_bnMinusOneInt;
			}
		}

		/// <summary>Indicates whether the value of the current <see cref="T:System.Numerics.BigInteger" /> object is a power of two.</summary>
		/// <returns>true if the value of the <see cref="T:System.Numerics.BigInteger" /> object is a power of two; otherwise, false.</returns>
		// Token: 0x17000014 RID: 20
		// (get) Token: 0x06000063 RID: 99 RVA: 0x00004304 File Offset: 0x00002504
		public bool IsPowerOfTwo
		{
			get
			{
				if (this._bits == null)
				{
					return (this._sign & this._sign - 1) == 0 && this._sign != 0;
				}
				if (this._sign != 1)
				{
					return false;
				}
				int num = this._bits.Length - 1;
				if ((this._bits[num] & this._bits[num] - 1U) != 0U)
				{
					return false;
				}
				while (--num >= 0)
				{
					if (this._bits[num] != 0U)
					{
						return false;
					}
				}
				return true;
			}
		}

		/// <summary>Indicates whether the value of the current <see cref="T:System.Numerics.BigInteger" /> object is <see cref="P:System.Numerics.BigInteger.Zero" />.</summary>
		/// <returns>true if the value of the <see cref="T:System.Numerics.BigInteger" /> object is <see cref="P:System.Numerics.BigInteger.Zero" />; otherwise, false.</returns>
		// Token: 0x17000015 RID: 21
		// (get) Token: 0x06000064 RID: 100 RVA: 0x00004378 File Offset: 0x00002578
		public bool IsZero
		{
			get
			{
				return this._sign == 0;
			}
		}

		/// <summary>Indicates whether the value of the current <see cref="T:System.Numerics.BigInteger" /> object is <see cref="P:System.Numerics.BigInteger.One" />.</summary>
		/// <returns>true if the value of the <see cref="T:System.Numerics.BigInteger" /> object is <see cref="P:System.Numerics.BigInteger.One" />; otherwise, false.</returns>
		// Token: 0x17000016 RID: 22
		// (get) Token: 0x06000065 RID: 101 RVA: 0x00004383 File Offset: 0x00002583
		public bool IsOne
		{
			get
			{
				return this._sign == 1 && this._bits == null;
			}
		}

		/// <summary>Indicates whether the value of the current <see cref="T:System.Numerics.BigInteger" /> object is an even number.</summary>
		/// <returns>true if the value of the <see cref="T:System.Numerics.BigInteger" /> object is an even number; otherwise, false.</returns>
		// Token: 0x17000017 RID: 23
		// (get) Token: 0x06000066 RID: 102 RVA: 0x00004399 File Offset: 0x00002599
		public bool IsEven
		{
			get
			{
				if (this._bits != null)
				{
					return (this._bits[0] & 1U) == 0U;
				}
				return (this._sign & 1) == 0;
			}
		}

		/// <summary>Gets a number that indicates the sign (negative, positive, or zero) of the current <see cref="T:System.Numerics.BigInteger" /> object.</summary>
		/// <returns>A number that indicates the sign of the <see cref="T:System.Numerics.BigInteger" /> object, as shown in the following table.NumberDescription-1The value of this object is negative.0The value of this object is 0 (zero).1The value of this object is positive.</returns>
		// Token: 0x17000018 RID: 24
		// (get) Token: 0x06000067 RID: 103 RVA: 0x000043BC File Offset: 0x000025BC
		public int Sign
		{
			get
			{
				return (this._sign >> 31) - (-this._sign >> 31);
			}
		}

		/// <summary>Converts the string representation of a number to its <see cref="T:System.Numerics.BigInteger" /> equivalent.</summary>
		/// <returns>A value that is equivalent to the number specified in the <paramref name="value" /> parameter.</returns>
		/// <param name="value">A string that contains the number to convert.</param>
		/// <exception cref="T:System.ArgumentNullException">
		///   <paramref name="value" /> is null.</exception>
		/// <exception cref="T:System.FormatException">
		///   <paramref name="value" /> is not in the correct format.</exception>
		// Token: 0x06000068 RID: 104 RVA: 0x000043D2 File Offset: 0x000025D2
		public static BigInteger Parse(string value)
		{
			return BigInteger.Parse(value, NumberStyles.Integer);
		}

		/// <summary>Converts the string representation of a number in a specified style to its <see cref="T:System.Numerics.BigInteger" /> equivalent.</summary>
		/// <returns>A value that is equivalent to the number specified in the <paramref name="value" /> parameter.</returns>
		/// <param name="value">A string that contains a number to convert. </param>
		/// <param name="style">A bitwise combination of the enumeration values that specify the permitted format of <paramref name="value" />.</param>
		/// <exception cref="T:System.ArgumentException">
		///   <paramref name="style" /> is not a <see cref="T:System.Globalization.NumberStyles" /> value.-or-<paramref name="style" /> includes the <see cref="F:System.Globalization.NumberStyles.AllowHexSpecifier" /> or <see cref="F:System.Globalization.NumberStyles.HexNumber" /> flag along with another value.</exception>
		/// <exception cref="T:System.ArgumentNullException">
		///   <paramref name="value" /> is null.</exception>
		/// <exception cref="T:System.FormatException">
		///   <paramref name="value" /> does not comply with the input pattern specified by <see cref="T:System.Globalization.NumberStyles" />.</exception>
		// Token: 0x06000069 RID: 105 RVA: 0x000043DB File Offset: 0x000025DB
		public static BigInteger Parse(string value, NumberStyles style)
		{
			return BigInteger.Parse(value, style, NumberFormatInfo.CurrentInfo);
		}

		/// <summary>Converts the string representation of a number in a specified culture-specific format to its <see cref="T:System.Numerics.BigInteger" /> equivalent.</summary>
		/// <returns>A value that is equivalent to the number specified in the <paramref name="value" /> parameter.</returns>
		/// <param name="value">A string that contains a number to convert.</param>
		/// <param name="provider">An object that provides culture-specific formatting information about <paramref name="value" />.</param>
		/// <exception cref="T:System.ArgumentNullException">
		///   <paramref name="value" /> is null.</exception>
		/// <exception cref="T:System.FormatException">
		///   <paramref name="value" /> is not in the correct format.</exception>
		// Token: 0x0600006A RID: 106 RVA: 0x000043E9 File Offset: 0x000025E9
		public static BigInteger Parse(string value, IFormatProvider provider)
		{
			return BigInteger.Parse(value, NumberStyles.Integer, NumberFormatInfo.GetInstance(provider));
		}

		/// <summary>Converts the string representation of a number in a specified style and culture-specific format to its <see cref="T:System.Numerics.BigInteger" /> equivalent.</summary>
		/// <returns>A value that is equivalent to the number specified in the <paramref name="value" /> parameter.</returns>
		/// <param name="value">A string that contains a number to convert.</param>
		/// <param name="style">A bitwise combination of the enumeration values that specify the permitted format of <paramref name="value" />.</param>
		/// <param name="provider">An object that provides culture-specific formatting information about <paramref name="value" />.</param>
		/// <exception cref="T:System.ArgumentException">
		///   <paramref name="style" /> is not a <see cref="T:System.Globalization.NumberStyles" /> value.-or-<paramref name="style" /> includes the <see cref="F:System.Globalization.NumberStyles.AllowHexSpecifier" /> or <see cref="F:System.Globalization.NumberStyles.HexNumber" /> flag along with another value.</exception>
		/// <exception cref="T:System.ArgumentNullException">
		///   <paramref name="value" /> is null.</exception>
		/// <exception cref="T:System.FormatException">
		///   <paramref name="value" /> does not comply with the input pattern specified by <paramref name="style" />.</exception>
		// Token: 0x0600006B RID: 107 RVA: 0x000043F8 File Offset: 0x000025F8
		public static BigInteger Parse(string value, NumberStyles style, IFormatProvider provider)
		{
			return BigNumber.ParseBigInteger(value, style, NumberFormatInfo.GetInstance(provider));
		}

		/// <summary>Tries to convert the string representation of a number to its <see cref="T:System.Numerics.BigInteger" /> equivalent, and returns a value that indicates whether the conversion succeeded.</summary>
		/// <returns>true if <paramref name="value" /> was converted successfully; otherwise, false.</returns>
		/// <param name="value">The string representation of a number.</param>
		/// <param name="result">When this method returns, contains the <see cref="T:System.Numerics.BigInteger" /> equivalent to the number that is contained in <paramref name="value" />, or zero (0) if the conversion fails. The conversion fails if the <paramref name="value" /> parameter is null or is not of the correct format. This parameter is passed uninitialized.</param>
		/// <exception cref="T:System.ArgumentNullException">
		///   <paramref name="value" /> is null.</exception>
		// Token: 0x0600006C RID: 108 RVA: 0x00004407 File Offset: 0x00002607
		public static bool TryParse(string value, out BigInteger result)
		{
			return BigInteger.TryParse(value, NumberStyles.Integer, NumberFormatInfo.CurrentInfo, out result);
		}

		/// <summary>Tries to convert the string representation of a number in a specified style and culture-specific format to its <see cref="T:System.Numerics.BigInteger" /> equivalent, and returns a value that indicates whether the conversion succeeded.</summary>
		/// <returns>true if the <paramref name="value" /> parameter was converted successfully; otherwise, false.</returns>
		/// <param name="value">The string representation of a number. The string is interpreted using the style specified by <paramref name="style" />.</param>
		/// <param name="style">A bitwise combination of enumeration values that indicates the style elements that can be present in <paramref name="value" />. A typical value to specify is <see cref="F:System.Globalization.NumberStyles.Integer" />.</param>
		/// <param name="provider">An object that supplies culture-specific formatting information about <paramref name="value" />.</param>
		/// <param name="result">When this method returns, contains the <see cref="T:System.Numerics.BigInteger" /> equivalent to the number that is contained in <paramref name="value" />, or <see cref="P:System.Numerics.BigInteger.Zero" /> if the conversion failed. The conversion fails if the <paramref name="value" /> parameter is null or is not in a format that is compliant with <paramref name="style" />. This parameter is passed uninitialized.</param>
		/// <exception cref="T:System.ArgumentException">
		///   <paramref name="style" /> is not a <see cref="T:System.Globalization.NumberStyles" /> value.-or-<paramref name="style" /> includes the <see cref="F:System.Globalization.NumberStyles.AllowHexSpecifier" /> or <see cref="F:System.Globalization.NumberStyles.HexNumber" /> flag along with another value. </exception>
		// Token: 0x0600006D RID: 109 RVA: 0x00004416 File Offset: 0x00002616
		public static bool TryParse(string value, NumberStyles style, IFormatProvider provider, out BigInteger result)
		{
			return BigNumber.TryParseBigInteger(value, style, NumberFormatInfo.GetInstance(provider), out result);
		}

		/// <summary>Compares two <see cref="T:System.Numerics.BigInteger" /> values and returns an integer that indicates whether the first value is less than, equal to, or greater than the second value.</summary>
		/// <returns>A signed integer that indicates the relative values of <paramref name="left" /> and <paramref name="right" />, as shown in the following table.ValueConditionLess than zero<paramref name="left" /> is less than <paramref name="right" />.Zero<paramref name="left" /> equals <paramref name="right" />.Greater than zero<paramref name="left" /> is greater than <paramref name="right" />.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x0600006E RID: 110 RVA: 0x00004426 File Offset: 0x00002626
		public static int Compare(BigInteger left, BigInteger right)
		{
			return left.CompareTo(right);
		}

		/// <summary>Gets the absolute value of a <see cref="T:System.Numerics.BigInteger" /> object.</summary>
		/// <returns>The absolute value of <paramref name="value" />.</returns>
		/// <param name="value">A number.</param>
		// Token: 0x0600006F RID: 111 RVA: 0x00004430 File Offset: 0x00002630
		public static BigInteger Abs(BigInteger value)
		{
			if (!(value >= BigInteger.Zero))
			{
				return -value;
			}
			return value;
		}

		/// <summary>Adds two <see cref="T:System.Numerics.BigInteger" /> values and returns the result.</summary>
		/// <returns>The sum of <paramref name="left" /> and <paramref name="right" />.</returns>
		/// <param name="left">The first value to add.</param>
		/// <param name="right">The second value to add.</param>
		// Token: 0x06000070 RID: 112 RVA: 0x00004447 File Offset: 0x00002647
		public static BigInteger Add(BigInteger left, BigInteger right)
		{
			return left + right;
		}

		/// <summary>Subtracts one <see cref="T:System.Numerics.BigInteger" /> value from another and returns the result.</summary>
		/// <returns>The result of subtracting <paramref name="right" /> from <paramref name="left" />.</returns>
		/// <param name="left">The value to subtract from (the minuend).</param>
		/// <param name="right">The value to subtract (the subtrahend).</param>
		// Token: 0x06000071 RID: 113 RVA: 0x00004450 File Offset: 0x00002650
		public static BigInteger Subtract(BigInteger left, BigInteger right)
		{
			return left - right;
		}

		/// <summary>Returns the product of two <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The product of the <paramref name="left" /> and <paramref name="right" /> parameters.</returns>
		/// <param name="left">The first number to multiply.</param>
		/// <param name="right">The second number to multiply.</param>
		// Token: 0x06000072 RID: 114 RVA: 0x00004459 File Offset: 0x00002659
		public static BigInteger Multiply(BigInteger left, BigInteger right)
		{
			return left * right;
		}

		/// <summary>Divides one <see cref="T:System.Numerics.BigInteger" /> value by another and returns the result.</summary>
		/// <returns>The quotient of the division.</returns>
		/// <param name="dividend">The value to be divided.</param>
		/// <param name="divisor">The value to divide by.</param>
		/// <exception cref="T:System.DivideByZeroException">
		///   <paramref name="divisor" /> is 0 (zero).</exception>
		// Token: 0x06000073 RID: 115 RVA: 0x00004462 File Offset: 0x00002662
		public static BigInteger Divide(BigInteger dividend, BigInteger divisor)
		{
			return dividend / divisor;
		}

		/// <summary>Performs integer division on two <see cref="T:System.Numerics.BigInteger" /> values and returns the remainder.</summary>
		/// <returns>The remainder after dividing <paramref name="dividend" /> by <paramref name="divisor" />.</returns>
		/// <param name="dividend">The value to be divided.</param>
		/// <param name="divisor">The value to divide by.</param>
		/// <exception cref="T:System.DivideByZeroException">
		///   <paramref name="divisor" /> is 0 (zero).</exception>
		// Token: 0x06000074 RID: 116 RVA: 0x0000446B File Offset: 0x0000266B
		public static BigInteger Remainder(BigInteger dividend, BigInteger divisor)
		{
			return dividend % divisor;
		}

		/// <summary>Divides one <see cref="T:System.Numerics.BigInteger" /> value by another, returns the result, and returns the remainder in an output parameter.</summary>
		/// <returns>The quotient of the division.</returns>
		/// <param name="dividend">The value to be divided.</param>
		/// <param name="divisor">The value to divide by.</param>
		/// <param name="remainder">When this method returns, contains a <see cref="T:System.Numerics.BigInteger" /> value that represents the remainder from the division. This parameter is passed uninitialized.</param>
		/// <exception cref="T:System.DivideByZeroException">
		///   <paramref name="divisor" /> is 0 (zero).</exception>
		// Token: 0x06000075 RID: 117 RVA: 0x00004474 File Offset: 0x00002674
		public static BigInteger DivRem(BigInteger dividend, BigInteger divisor, out BigInteger remainder)
		{
			bool flag = dividend._bits == null;
			bool flag2 = divisor._bits == null;
			if (flag && flag2)
			{
				remainder = dividend._sign % divisor._sign;
				return dividend._sign / divisor._sign;
			}
			if (flag)
			{
				remainder = dividend;
				return BigInteger.s_bnZeroInt;
			}
			if (flag2)
			{
				uint num;
				uint[] value = BigIntegerCalculator.Divide(dividend._bits, NumericsHelpers.Abs(divisor._sign), out num);
				remainder = (long)((dividend._sign < 0) ? (ulong.MaxValue * (ulong)num) : ((ulong)num));
				return new BigInteger(value, dividend._sign < 0 ^ divisor._sign < 0);
			}
			if (dividend._bits.Length < divisor._bits.Length)
			{
				remainder = dividend;
				return BigInteger.s_bnZeroInt;
			}
			uint[] value3;
			uint[] value2 = BigIntegerCalculator.Divide(dividend._bits, divisor._bits, out value3);
			remainder = new BigInteger(value3, dividend._sign < 0);
			return new BigInteger(value2, dividend._sign < 0 ^ divisor._sign < 0);
		}

		/// <summary>Negates a specified <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>The result of the <paramref name="value" /> parameter multiplied by negative one (-1).</returns>
		/// <param name="value">The value to negate.</param>
		// Token: 0x06000076 RID: 118 RVA: 0x0000458C File Offset: 0x0000278C
		public static BigInteger Negate(BigInteger value)
		{
			return -value;
		}

		/// <summary>Returns the natural (base e) logarithm of a specified number.</summary>
		/// <returns>The natural (base e) logarithm of <paramref name="value" />, as shown in the table in the Remarks section.</returns>
		/// <param name="value">The number whose logarithm is to be found.</param>
		/// <exception cref="T:System.ArgumentOutOfRangeException">The natural log of <paramref name="value" /> is out of range of the <see cref="T:System.Double" /> data type.</exception>
		// Token: 0x06000077 RID: 119 RVA: 0x00004594 File Offset: 0x00002794
		public static double Log(BigInteger value)
		{
			return BigInteger.Log(value, 2.7182818284590451);
		}

		/// <summary>Returns the logarithm of a specified number in a specified base.</summary>
		/// <returns>The base <paramref name="baseValue" /> logarithm of <paramref name="value" />, as shown in the table in the Remarks section.</returns>
		/// <param name="value">A number whose logarithm is to be found.</param>
		/// <param name="baseValue">The base of the logarithm.</param>
		/// <exception cref="T:System.ArgumentOutOfRangeException">The log of <paramref name="value" /> is out of range of the <see cref="T:System.Double" /> data type.</exception>
		// Token: 0x06000078 RID: 120 RVA: 0x000045A8 File Offset: 0x000027A8
		public static double Log(BigInteger value, double baseValue)
		{
			if (value._sign < 0 || baseValue == 1.0)
			{
				return double.NaN;
			}
			if (baseValue == double.PositiveInfinity)
			{
				if (!value.IsOne)
				{
					return double.NaN;
				}
				return 0.0;
			}
			else
			{
				if (baseValue == 0.0 && !value.IsOne)
				{
					return double.NaN;
				}
				if (value._bits == null)
				{
					return Math.Log((double)value._sign, baseValue);
				}
				ulong num = (ulong)value._bits[value._bits.Length - 1];
				ulong num2 = (ulong)((value._bits.Length > 1) ? value._bits[value._bits.Length - 2] : 0U);
				ulong num3 = (ulong)((value._bits.Length > 2) ? value._bits[value._bits.Length - 3] : 0U);
				int num4 = NumericsHelpers.CbitHighZero((uint)num);
				long num5 = (long)value._bits.Length * 32L - (long)num4;
				ulong num6 = num << 32 + num4 | num2 << num4 | num3 >> 32 - num4;
				return Math.Log(num6, baseValue) + (double)(num5 - 64L) / Math.Log(baseValue, 2.0);
			}
		}

		/// <summary>Returns the base 10 logarithm of a specified number.</summary>
		/// <returns>The base 10 logarithm of <paramref name="value" />, as shown in the table in the Remarks section.</returns>
		/// <param name="value">A number whose logarithm is to be found.</param>
		/// <exception cref="T:System.ArgumentOutOfRangeException">The base 10 log of <paramref name="value" /> is out of range of the <see cref="T:System.Double" /> data type.</exception>
		// Token: 0x06000079 RID: 121 RVA: 0x000046DF File Offset: 0x000028DF
		public static double Log10(BigInteger value)
		{
			return BigInteger.Log(value, 10.0);
		}

		/// <summary>Finds the greatest common divisor of two <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The greatest common divisor of <paramref name="left" /> and <paramref name="right" />.</returns>
		/// <param name="left">The first value.</param>
		/// <param name="right">The second value.</param>
		// Token: 0x0600007A RID: 122 RVA: 0x000046F0 File Offset: 0x000028F0
		public static BigInteger GreatestCommonDivisor(BigInteger left, BigInteger right)
		{
			bool flag = left._bits == null;
			bool flag2 = right._bits == null;
			if (flag && flag2)
			{
				return BigIntegerCalculator.Gcd(NumericsHelpers.Abs(left._sign), NumericsHelpers.Abs(right._sign));
			}
			if (flag)
			{
				if (left._sign == 0)
				{
					return new BigInteger(right._bits, false);
				}
				return BigIntegerCalculator.Gcd(right._bits, NumericsHelpers.Abs(left._sign));
			}
			else if (flag2)
			{
				if (right._sign == 0)
				{
					return new BigInteger(left._bits, false);
				}
				return BigIntegerCalculator.Gcd(left._bits, NumericsHelpers.Abs(right._sign));
			}
			else
			{
				if (BigIntegerCalculator.Compare(left._bits, right._bits) < 0)
				{
					return BigInteger.GreatestCommonDivisor(right._bits, left._bits);
				}
				return BigInteger.GreatestCommonDivisor(left._bits, right._bits);
			}
		}

		// Token: 0x0600007B RID: 123 RVA: 0x000047D8 File Offset: 0x000029D8
		private static BigInteger GreatestCommonDivisor(uint[] leftBits, uint[] rightBits)
		{
			if (rightBits.Length == 1)
			{
				uint right = BigIntegerCalculator.Remainder(leftBits, rightBits[0]);
				return BigIntegerCalculator.Gcd(rightBits[0], right);
			}
			if (rightBits.Length == 2)
			{
				uint[] array = BigIntegerCalculator.Remainder(leftBits, rightBits);
				ulong left = (ulong)rightBits[1] << 32 | (ulong)rightBits[0];
				ulong right2 = (ulong)array[1] << 32 | (ulong)array[0];
				return BigIntegerCalculator.Gcd(left, right2);
			}
			uint[] value = BigIntegerCalculator.Gcd(leftBits, rightBits);
			return new BigInteger(value, false);
		}

		/// <summary>Returns the larger of two <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The <paramref name="left" /> or <paramref name="right" /> parameter, whichever is larger.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x0600007C RID: 124 RVA: 0x0000484A File Offset: 0x00002A4A
		public static BigInteger Max(BigInteger left, BigInteger right)
		{
			if (left.CompareTo(right) < 0)
			{
				return right;
			}
			return left;
		}

		/// <summary>Returns the smaller of two <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The <paramref name="left" /> or <paramref name="right" /> parameter, whichever is smaller.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x0600007D RID: 125 RVA: 0x0000485A File Offset: 0x00002A5A
		public static BigInteger Min(BigInteger left, BigInteger right)
		{
			if (left.CompareTo(right) <= 0)
			{
				return left;
			}
			return right;
		}

		/// <summary>Performs modulus division on a number raised to the power of another number.</summary>
		/// <returns>The remainder after dividing <paramref name="value" />exponent by <paramref name="modulus" />.</returns>
		/// <param name="value">The number to raise to the <paramref name="exponent" /> power.</param>
		/// <param name="exponent">The exponent to raise <paramref name="value" /> by.</param>
		/// <param name="modulus">The number by which to divide <paramref name="value" /> raised to the <paramref name="exponent" /> power.</param>
		/// <exception cref="T:System.DivideByZeroException">
		///   <paramref name="modulus" /> is zero.</exception>
		/// <exception cref="T:System.ArgumentOutOfRangeException">
		///   <paramref name="exponent" /> is negative.</exception>
		// Token: 0x0600007E RID: 126 RVA: 0x0000486C File Offset: 0x00002A6C
		public static BigInteger ModPow(BigInteger value, BigInteger exponent, BigInteger modulus)
		{
			if (exponent.Sign < 0)
			{
				throw new ArgumentOutOfRangeException("exponent", SR.ArgumentOutOfRange_MustBeNonNeg);
			}
			bool flag = value._bits == null;
			bool flag2 = exponent._bits == null;
			bool flag3 = modulus._bits == null;
			if (flag3)
			{
				uint num = (flag && flag2) ? BigIntegerCalculator.Pow(NumericsHelpers.Abs(value._sign), NumericsHelpers.Abs(exponent._sign), NumericsHelpers.Abs(modulus._sign)) : (flag ? BigIntegerCalculator.Pow(NumericsHelpers.Abs(value._sign), exponent._bits, NumericsHelpers.Abs(modulus._sign)) : (flag2 ? BigIntegerCalculator.Pow(value._bits, NumericsHelpers.Abs(exponent._sign), NumericsHelpers.Abs(modulus._sign)) : BigIntegerCalculator.Pow(value._bits, exponent._bits, NumericsHelpers.Abs(modulus._sign))));
				return (long)((value._sign < 0 && !exponent.IsEven) ? (ulong.MaxValue * (ulong)num) : ((ulong)num));
			}
			uint[] value2 = (flag && flag2) ? BigIntegerCalculator.Pow(NumericsHelpers.Abs(value._sign), NumericsHelpers.Abs(exponent._sign), modulus._bits) : (flag ? BigIntegerCalculator.Pow(NumericsHelpers.Abs(value._sign), exponent._bits, modulus._bits) : (flag2 ? BigIntegerCalculator.Pow(value._bits, NumericsHelpers.Abs(exponent._sign), modulus._bits) : BigIntegerCalculator.Pow(value._bits, exponent._bits, modulus._bits)));
			return new BigInteger(value2, value._sign < 0 && !exponent.IsEven);
		}

		/// <summary>Raises a <see cref="T:System.Numerics.BigInteger" /> value to the power of a specified value.</summary>
		/// <returns>The result of raising <paramref name="value" /> to the <paramref name="exponent" /> power.</returns>
		/// <param name="value">The number to raise to the <paramref name="exponent" /> power.</param>
		/// <param name="exponent">The exponent to raise <paramref name="value" /> by.</param>
		/// <exception cref="T:System.ArgumentOutOfRangeException">The value of the <paramref name="exponent" /> parameter is negative.</exception>
		// Token: 0x0600007F RID: 127 RVA: 0x00004A10 File Offset: 0x00002C10
		public static BigInteger Pow(BigInteger value, int exponent)
		{
			if (exponent < 0)
			{
				throw new ArgumentOutOfRangeException("exponent", SR.ArgumentOutOfRange_MustBeNonNeg);
			}
			if (exponent == 0)
			{
				return BigInteger.s_bnOneInt;
			}
			if (exponent == 1)
			{
				return value;
			}
			bool flag = value._bits == null;
			if (flag)
			{
				if (value._sign == 1)
				{
					return value;
				}
				if (value._sign == -1)
				{
					if ((exponent & 1) == 0)
					{
						return BigInteger.s_bnOneInt;
					}
					return value;
				}
				else if (value._sign == 0)
				{
					return value;
				}
			}
			uint[] value2 = flag ? BigIntegerCalculator.Pow(NumericsHelpers.Abs(value._sign), NumericsHelpers.Abs(exponent)) : BigIntegerCalculator.Pow(value._bits, NumericsHelpers.Abs(exponent));
			return new BigInteger(value2, value._sign < 0 && (exponent & 1) != 0);
		}

		/// <summary>Returns the hash code for the current <see cref="T:System.Numerics.BigInteger" /> object.</summary>
		/// <returns>A 32-bit signed integer hash code.</returns>
		// Token: 0x06000080 RID: 128 RVA: 0x00004AC0 File Offset: 0x00002CC0
		public override int GetHashCode()
		{
			if (this._bits == null)
			{
				return this._sign;
			}
			int num = this._sign;
			int num2 = this._bits.Length;
			while (--num2 >= 0)
			{
				num = NumericsHelpers.CombineHash(num, (int)this._bits[num2]);
			}
			return num;
		}

		/// <summary>Returns a value that indicates whether the current instance and a specified object have the same value.</summary>
		/// <returns>true if the <paramref name="obj" /> parameter is a <see cref="T:System.Numerics.BigInteger" /> object or a type capable of implicit conversion to a <see cref="T:System.Numerics.BigInteger" /> value, and its value is equal to the value of the current <see cref="T:System.Numerics.BigInteger" /> object; otherwise, false.</returns>
		/// <param name="obj">The object to compare. </param>
		// Token: 0x06000081 RID: 129 RVA: 0x00004B06 File Offset: 0x00002D06
		public override bool Equals(object obj)
		{
			return obj is BigInteger && this.Equals((BigInteger)obj);
		}

		/// <summary>Returns a value that indicates whether the current instance and a signed 64-bit integer have the same value.</summary>
		/// <returns>true if the signed 64-bit integer and the current instance have the same value; otherwise, false.</returns>
		/// <param name="other">The signed 64-bit integer value to compare.</param>
		// Token: 0x06000082 RID: 130 RVA: 0x00004B20 File Offset: 0x00002D20
		public bool Equals(long other)
		{
			if (this._bits == null)
			{
				return (long)this._sign == other;
			}
			int num;
			if (((long)this._sign ^ other) < 0L || (num = this._bits.Length) > 2)
			{
				return false;
			}
			ulong num2 = (ulong)((other < 0L) ? (-(ulong)other) : other);
			if (num == 1)
			{
				return (ulong)this._bits[0] == num2;
			}
			return NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) == num2;
		}

		/// <summary>Returns a value that indicates whether the current instance and an unsigned 64-bit integer have the same value.</summary>
		/// <returns>true if the current instance and the unsigned 64-bit integer have the same value; otherwise, false.</returns>
		/// <param name="other">The unsigned 64-bit integer to compare.</param>
		// Token: 0x06000083 RID: 131 RVA: 0x00004B90 File Offset: 0x00002D90
		[CLSCompliant(false)]
		public bool Equals(ulong other)
		{
			if (this._sign < 0)
			{
				return false;
			}
			if (this._bits == null)
			{
				return (long)this._sign == (long)other;
			}
			int num = this._bits.Length;
			if (num > 2)
			{
				return false;
			}
			if (num == 1)
			{
				return (ulong)this._bits[0] == other;
			}
			return NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) == other;
		}

		/// <summary>Returns a value that indicates whether the current instance and a specified <see cref="T:System.Numerics.BigInteger" /> object have the same value.</summary>
		/// <returns>true if this <see cref="T:System.Numerics.BigInteger" /> object and <paramref name="other" /> have the same value; otherwise, false.</returns>
		/// <param name="other">The object to compare.</param>
		// Token: 0x06000084 RID: 132 RVA: 0x00004BF4 File Offset: 0x00002DF4
		public bool Equals(BigInteger other)
		{
			if (this._sign != other._sign)
			{
				return false;
			}
			if (this._bits == other._bits)
			{
				return true;
			}
			if (this._bits == null || other._bits == null)
			{
				return false;
			}
			int num = this._bits.Length;
			if (num != other._bits.Length)
			{
				return false;
			}
			int diffLength = BigInteger.GetDiffLength(this._bits, other._bits, num);
			return diffLength == 0;
		}

		/// <summary>Compares this instance to a signed 64-bit integer and returns an integer that indicates whether the value of this instance is less than, equal to, or greater than the value of the signed 64-bit integer.</summary>
		/// <returns>A signed integer value that indicates the relationship of this instance to <paramref name="other" />, as shown in the following table.Return valueDescriptionLess than zeroThe current instance is less than <paramref name="other" />.ZeroThe current instance equals <paramref name="other" />.Greater than zeroThe current instance is greater than <paramref name="other" />.</returns>
		/// <param name="other">The signed 64-bit integer to compare.</param>
		// Token: 0x06000085 RID: 133 RVA: 0x00004C60 File Offset: 0x00002E60
		public int CompareTo(long other)
		{
			if (this._bits == null)
			{
				return ((long)this._sign).CompareTo(other);
			}
			int num;
			if (((long)this._sign ^ other) < 0L || (num = this._bits.Length) > 2)
			{
				return this._sign;
			}
			ulong value = (ulong)((other < 0L) ? (-(ulong)other) : other);
			ulong num2 = (num == 2) ? NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) : ((ulong)this._bits[0]);
			return this._sign * num2.CompareTo(value);
		}

		/// <summary>Compares this instance to an unsigned 64-bit integer and returns an integer that indicates whether the value of this instance is less than, equal to, or greater than the value of the unsigned 64-bit integer.</summary>
		/// <returns>A signed integer that indicates the relative value of this instance and <paramref name="other" />, as shown in the following table.Return valueDescriptionLess than zeroThe current instance is less than <paramref name="other" />.ZeroThe current instance equals <paramref name="other" />.Greater than zeroThe current instance is greater than <paramref name="other" />.</returns>
		/// <param name="other">The unsigned 64-bit integer to compare.</param>
		// Token: 0x06000086 RID: 134 RVA: 0x00004CE8 File Offset: 0x00002EE8
		[CLSCompliant(false)]
		public int CompareTo(ulong other)
		{
			if (this._sign < 0)
			{
				return -1;
			}
			if (this._bits == null)
			{
				return ((ulong)((long)this._sign)).CompareTo(other);
			}
			int num = this._bits.Length;
			if (num > 2)
			{
				return 1;
			}
			return ((num == 2) ? NumericsHelpers.MakeUlong(this._bits[1], this._bits[0]) : ((ulong)this._bits[0])).CompareTo(other);
		}

		/// <summary>Compares this instance to a second <see cref="T:System.Numerics.BigInteger" /> and returns an integer that indicates whether the value of this instance is less than, equal to, or greater than the value of the specified object.</summary>
		/// <returns>A signed integer value that indicates the relationship of this instance to <paramref name="other" />, as shown in the following table.Return valueDescriptionLess than zeroThe current instance is less than <paramref name="other" />.ZeroThe current instance equals <paramref name="other" />.Greater than zeroThe current instance is greater than <paramref name="other" />.</returns>
		/// <param name="other">The object to compare.</param>
		// Token: 0x06000087 RID: 135 RVA: 0x00004D58 File Offset: 0x00002F58
		public int CompareTo(BigInteger other)
		{
			if ((this._sign ^ other._sign) < 0)
			{
				if (this._sign >= 0)
				{
					return 1;
				}
				return -1;
			}
			else if (this._bits == null)
			{
				if (other._bits != null)
				{
					return -other._sign;
				}
				if (this._sign < other._sign)
				{
					return -1;
				}
				if (this._sign <= other._sign)
				{
					return 0;
				}
				return 1;
			}
			else
			{
				int num;
				int num2;
				if (other._bits == null || (num = this._bits.Length) > (num2 = other._bits.Length))
				{
					return this._sign;
				}
				if (num < num2)
				{
					return -this._sign;
				}
				int diffLength = BigInteger.GetDiffLength(this._bits, other._bits, num);
				if (diffLength == 0)
				{
					return 0;
				}
				if (this._bits[diffLength - 1] >= other._bits[diffLength - 1])
				{
					return this._sign;
				}
				return -this._sign;
			}
		}

		/// <summary>Compares the current instance with another object of the same type and returns an integer that indicates whether the current instance precedes, follows, or occurs in the same position in the sort order as the other object.</summary>
		/// <returns>A signed integer that indicates the relative order of this instance and <paramref name="obj" />.Return value Description Less than zero This instance precedes <paramref name="obj" /> in the sort order. Zero This instance occurs in the same position as <paramref name="obj" /> in the sort order. Greater than zero This instance follows <paramref name="obj" /> in the sort order.-or- <paramref name="value" /> is null. </returns>
		/// <param name="obj">An object to compare with this instance, or null. </param>
		/// <exception cref="T:System.ArgumentException">
		///   <paramref name="obj" /> is not a <see cref="T:System.Numerics.BigInteger" />. </exception>
		// Token: 0x06000088 RID: 136 RVA: 0x00004E29 File Offset: 0x00003029
		int IComparable.CompareTo(object obj)
		{
			if (obj == null)
			{
				return 1;
			}
			if (!(obj is BigInteger))
			{
				throw new ArgumentException(SR.Argument_MustBeBigInt, "obj");
			}
			return this.CompareTo((BigInteger)obj);
		}

		/// <summary>Converts a <see cref="T:System.Numerics.BigInteger" /> value to a byte array.</summary>
		/// <returns>The value of the current <see cref="T:System.Numerics.BigInteger" /> object converted to an array of bytes.</returns>
		// Token: 0x06000089 RID: 137 RVA: 0x00004E54 File Offset: 0x00003054
		public byte[] ToByteArray()
		{
			int sign = this._sign;
			if (sign == 0)
			{
				return new byte[1];
			}
			int num = 0;
			uint[] bits = this._bits;
			byte b;
			uint num2;
			if (bits == null)
			{
				b = ((sign < 0) ? byte.MaxValue : 0);
				num2 = (uint)sign;
			}
			else if (sign == -1)
			{
				b = byte.MaxValue;
				while (bits[num] == 0U)
				{
					num++;
				}
				num2 = ~bits[bits.Length - 1];
				if (bits.Length - 1 == num)
				{
					num2 += 1U;
				}
			}
			else
			{
				b = 0;
				num2 = bits[bits.Length - 1];
			}
			byte b2;
			int num3;
			if ((b2 = (byte)(num2 >> 24)) != b)
			{
				num3 = 3;
			}
			else if ((b2 = (byte)(num2 >> 16)) != b)
			{
				num3 = 2;
			}
			else if ((b2 = (byte)(num2 >> 8)) != b)
			{
				num3 = 1;
			}
			else
			{
				b2 = (byte)num2;
				num3 = 0;
			}
			bool flag = (b2 & 128) != (b & 128);
			int num4 = 0;
			byte[] array;
			if (bits == null)
			{
				array = new byte[num3 + 1 + (flag ? 1 : 0)];
			}
			else
			{
				array = new byte[checked(4 * (bits.Length - 1) + num3 + 1 + (flag ? 1 : 0))];
				for (int i = 0; i < bits.Length - 1; i++)
				{
					uint num5 = bits[i];
					if (sign == -1)
					{
						num5 = ~num5;
						if (i <= num)
						{
							num5 += 1U;
						}
					}
					for (int j = 0; j < 4; j++)
					{
						array[num4++] = (byte)num5;
						num5 >>= 8;
					}
				}
			}
			for (int k = 0; k <= num3; k++)
			{
				array[num4++] = (byte)num2;
				num2 >>= 8;
			}
			if (flag)
			{
				array[array.Length - 1] = b;
			}
			return array;
		}

		// Token: 0x0600008A RID: 138 RVA: 0x00004FD8 File Offset: 0x000031D8
		private uint[] ToUInt32Array()
		{
			if (this._bits == null && this._sign == 0)
			{
				return new uint[1];
			}
			uint[] array;
			uint num;
			if (this._bits == null)
			{
				array = new uint[]
				{
					(uint)this._sign
				};
				num = ((this._sign < 0) ? uint.MaxValue : 0U);
			}
			else if (this._sign == -1)
			{
				array = (uint[])this._bits.Clone();
				NumericsHelpers.DangerousMakeTwosComplement(array);
				num = uint.MaxValue;
			}
			else
			{
				array = this._bits;
				num = 0U;
			}
			int num2 = array.Length - 1;
			while (num2 > 0 && array[num2] == num)
			{
				num2--;
			}
			bool flag = (array[num2] & 2147483648U) != (num & 2147483648U);
			uint[] array2 = new uint[num2 + 1 + (flag ? 1 : 0)];
			Array.Copy(array, 0, array2, 0, num2 + 1);
			if (flag)
			{
				array2[array2.Length - 1] = num;
			}
			return array2;
		}

		/// <summary>Converts the numeric value of the current <see cref="T:System.Numerics.BigInteger" /> object to its equivalent string representation.</summary>
		/// <returns>The string representation of the current <see cref="T:System.Numerics.BigInteger" /> value.</returns>
		// Token: 0x0600008B RID: 139 RVA: 0x000050AB File Offset: 0x000032AB
		public override string ToString()
		{
			return BigNumber.FormatBigInteger(this, null, NumberFormatInfo.CurrentInfo);
		}

		/// <summary>Converts the numeric value of the current <see cref="T:System.Numerics.BigInteger" /> object to its equivalent string representation by using the specified culture-specific formatting information.</summary>
		/// <returns>The string representation of the current <see cref="T:System.Numerics.BigInteger" /> value in the format specified by the <paramref name="provider" /> parameter.</returns>
		/// <param name="provider">An object that supplies culture-specific formatting information.</param>
		// Token: 0x0600008C RID: 140 RVA: 0x000050BE File Offset: 0x000032BE
		public string ToString(IFormatProvider provider)
		{
			return BigNumber.FormatBigInteger(this, null, NumberFormatInfo.GetInstance(provider));
		}

		/// <summary>Converts the numeric value of the current <see cref="T:System.Numerics.BigInteger" /> object to its equivalent string representation by using the specified format.</summary>
		/// <returns>The string representation of the current <see cref="T:System.Numerics.BigInteger" /> value in the format specified by the <paramref name="format" /> parameter.</returns>
		/// <param name="format">A standard or custom numeric format string.</param>
		/// <exception cref="T:System.FormatException">
		///   <paramref name="format" /> is not a valid format string.</exception>
		// Token: 0x0600008D RID: 141 RVA: 0x000050D2 File Offset: 0x000032D2
		public string ToString(string format)
		{
			return BigNumber.FormatBigInteger(this, format, NumberFormatInfo.CurrentInfo);
		}

		/// <summary>Converts the numeric value of the current <see cref="T:System.Numerics.BigInteger" /> object to its equivalent string representation by using the specified format and culture-specific format information.</summary>
		/// <returns>The string representation of the current <see cref="T:System.Numerics.BigInteger" /> value as specified by the <paramref name="format" /> and <paramref name="provider" /> parameters.</returns>
		/// <param name="format">A standard or custom numeric format string.</param>
		/// <param name="provider">An object that supplies culture-specific formatting information.</param>
		/// <exception cref="T:System.FormatException">
		///   <paramref name="format" /> is not a valid format string.</exception>
		// Token: 0x0600008E RID: 142 RVA: 0x000050E5 File Offset: 0x000032E5
		public string ToString(string format, IFormatProvider provider)
		{
			return BigNumber.FormatBigInteger(this, format, NumberFormatInfo.GetInstance(provider));
		}

		// Token: 0x0600008F RID: 143 RVA: 0x000050FC File Offset: 0x000032FC
		private static BigInteger Add(uint[] leftBits, int leftSign, uint[] rightBits, int rightSign)
		{
			bool flag = leftBits == null;
			bool flag2 = rightBits == null;
			if (flag && flag2)
			{
				return (long)leftSign + (long)rightSign;
			}
			if (flag)
			{
				uint[] value = BigIntegerCalculator.Add(rightBits, NumericsHelpers.Abs(leftSign));
				return new BigInteger(value, leftSign < 0);
			}
			if (flag2)
			{
				uint[] value2 = BigIntegerCalculator.Add(leftBits, NumericsHelpers.Abs(rightSign));
				return new BigInteger(value2, leftSign < 0);
			}
			if (leftBits.Length < rightBits.Length)
			{
				uint[] value3 = BigIntegerCalculator.Add(rightBits, leftBits);
				return new BigInteger(value3, leftSign < 0);
			}
			uint[] value4 = BigIntegerCalculator.Add(leftBits, rightBits);
			return new BigInteger(value4, leftSign < 0);
		}

		/// <summary>Subtracts a <see cref="T:System.Numerics.BigInteger" /> value from another <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>The result of subtracting <paramref name="right" /> from <paramref name="left" />.</returns>
		/// <param name="left">The value to subtract from (the minuend).</param>
		/// <param name="right">The value to subtract (the subtrahend).</param>
		// Token: 0x06000090 RID: 144 RVA: 0x0000518C File Offset: 0x0000338C
		public static BigInteger operator -(BigInteger left, BigInteger right)
		{
			if (left._sign < 0 != right._sign < 0)
			{
				return BigInteger.Add(left._bits, left._sign, right._bits, -1 * right._sign);
			}
			return BigInteger.Subtract(left._bits, left._sign, right._bits, right._sign);
		}

		// Token: 0x06000091 RID: 145 RVA: 0x000051EC File Offset: 0x000033EC
		private static BigInteger Subtract(uint[] leftBits, int leftSign, uint[] rightBits, int rightSign)
		{
			bool flag = leftBits == null;
			bool flag2 = rightBits == null;
			if (flag && flag2)
			{
				return (long)leftSign - (long)rightSign;
			}
			if (flag)
			{
				uint[] value = BigIntegerCalculator.Subtract(rightBits, NumericsHelpers.Abs(leftSign));
				return new BigInteger(value, leftSign >= 0);
			}
			if (flag2)
			{
				uint[] value2 = BigIntegerCalculator.Subtract(leftBits, NumericsHelpers.Abs(rightSign));
				return new BigInteger(value2, leftSign < 0);
			}
			if (BigIntegerCalculator.Compare(leftBits, rightBits) < 0)
			{
				uint[] value3 = BigIntegerCalculator.Subtract(rightBits, leftBits);
				return new BigInteger(value3, leftSign >= 0);
			}
			uint[] value4 = BigIntegerCalculator.Subtract(leftBits, rightBits);
			return new BigInteger(value4, leftSign < 0);
		}

		/// <summary>Defines an implicit conversion of an unsigned byte to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000092 RID: 146 RVA: 0x00005282 File Offset: 0x00003482
		public static implicit operator BigInteger(byte value)
		{
			return new BigInteger((int)value);
		}

		/// <summary>Defines an implicit conversion of an 8-bit signed integer to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000093 RID: 147 RVA: 0x00005282 File Offset: 0x00003482
		[CLSCompliant(false)]
		public static implicit operator BigInteger(sbyte value)
		{
			return new BigInteger((int)value);
		}

		/// <summary>Defines an implicit conversion of a signed 16-bit integer to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000094 RID: 148 RVA: 0x00005282 File Offset: 0x00003482
		public static implicit operator BigInteger(short value)
		{
			return new BigInteger((int)value);
		}

		/// <summary>Defines an implicit conversion of a 16-bit unsigned integer to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000095 RID: 149 RVA: 0x00005282 File Offset: 0x00003482
		[CLSCompliant(false)]
		public static implicit operator BigInteger(ushort value)
		{
			return new BigInteger((int)value);
		}

		/// <summary>Defines an implicit conversion of a signed 32-bit integer to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000096 RID: 150 RVA: 0x00005282 File Offset: 0x00003482
		public static implicit operator BigInteger(int value)
		{
			return new BigInteger(value);
		}

		/// <summary>Defines an implicit conversion of a 32-bit unsigned integer to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000097 RID: 151 RVA: 0x0000528A File Offset: 0x0000348A
		[CLSCompliant(false)]
		public static implicit operator BigInteger(uint value)
		{
			return new BigInteger(value);
		}

		/// <summary>Defines an implicit conversion of a signed 64-bit integer to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000098 RID: 152 RVA: 0x00005292 File Offset: 0x00003492
		public static implicit operator BigInteger(long value)
		{
			return new BigInteger(value);
		}

		/// <summary>Defines an implicit conversion of a 64-bit unsigned integer to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x06000099 RID: 153 RVA: 0x0000529A File Offset: 0x0000349A
		[CLSCompliant(false)]
		public static implicit operator BigInteger(ulong value)
		{
			return new BigInteger(value);
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Single" /> object to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is <see cref="F:System.Single.NaN" />.-or-<paramref name="value" /> is <see cref="F:System.Single.PositiveInfinity" />.-or-<paramref name="value" /> is <see cref="F:System.Single.NegativeInfinity" />.</exception>
		// Token: 0x0600009A RID: 154 RVA: 0x000052A2 File Offset: 0x000034A2
		public static explicit operator BigInteger(float value)
		{
			return new BigInteger(value);
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Double" /> value to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is <see cref="F:System.Double.NaN" />.-or-<paramref name="value" /> is <see cref="F:System.Double.PositiveInfinity" />.-or-<paramref name="value" /> is <see cref="F:System.Double.NegativeInfinity" />.</exception>
		// Token: 0x0600009B RID: 155 RVA: 0x000052AA File Offset: 0x000034AA
		public static explicit operator BigInteger(double value)
		{
			return new BigInteger(value);
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Decimal" /> object to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Numerics.BigInteger" />.</param>
		// Token: 0x0600009C RID: 156 RVA: 0x000052B2 File Offset: 0x000034B2
		public static explicit operator BigInteger(decimal value)
		{
			return new BigInteger(value);
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to an unsigned byte value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Byte" />.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.Byte.MinValue" />. -or-<paramref name="value" /> is greater than <see cref="F:System.Byte.MaxValue" />.</exception>
		// Token: 0x0600009D RID: 157 RVA: 0x000052BA File Offset: 0x000034BA
		public static explicit operator byte(BigInteger value)
		{
			return checked((byte)((int)value));
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to a signed 8-bit value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a signed 8-bit value.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.SByte.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.SByte.MaxValue" />.</exception>
		// Token: 0x0600009E RID: 158 RVA: 0x000052C3 File Offset: 0x000034C3
		[CLSCompliant(false)]
		public static explicit operator sbyte(BigInteger value)
		{
			return checked((sbyte)((int)value));
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to a 16-bit signed integer value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a 16-bit signed integer.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.Int16.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.Int16.MaxValue" />.</exception>
		// Token: 0x0600009F RID: 159 RVA: 0x000052CC File Offset: 0x000034CC
		public static explicit operator short(BigInteger value)
		{
			return checked((short)((int)value));
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to an unsigned 16-bit integer value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter</returns>
		/// <param name="value">The value to convert to an unsigned 16-bit integer.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.UInt16.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.UInt16.MaxValue" />. </exception>
		// Token: 0x060000A0 RID: 160 RVA: 0x000052D5 File Offset: 0x000034D5
		[CLSCompliant(false)]
		public static explicit operator ushort(BigInteger value)
		{
			return checked((ushort)((int)value));
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to a 32-bit signed integer value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a 32-bit signed integer. </param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.Int32.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.Int32.MaxValue" />.</exception>
		// Token: 0x060000A1 RID: 161 RVA: 0x000052E0 File Offset: 0x000034E0
		public static explicit operator int(BigInteger value)
		{
			if (value._bits == null)
			{
				return value._sign;
			}
			if (value._bits.Length > 1)
			{
				throw new OverflowException(SR.Overflow_Int32);
			}
			if (value._sign > 0)
			{
				return checked((int)value._bits[0]);
			}
			if (value._bits[0] > 2147483648U)
			{
				throw new OverflowException(SR.Overflow_Int32);
			}
			return (int)(-(int)value._bits[0]);
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to an unsigned 32-bit integer value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to an unsigned 32-bit integer.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.UInt32.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.UInt32.MaxValue" />.</exception>
		// Token: 0x060000A2 RID: 162 RVA: 0x00005348 File Offset: 0x00003548
		[CLSCompliant(false)]
		public static explicit operator uint(BigInteger value)
		{
			if (value._bits == null)
			{
				return checked((uint)value._sign);
			}
			if (value._bits.Length > 1 || value._sign < 0)
			{
				throw new OverflowException(SR.Overflow_UInt32);
			}
			return value._bits[0];
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to a 64-bit signed integer value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a 64-bit signed integer.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.Int64.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.Int64.MaxValue" />.</exception>
		// Token: 0x060000A3 RID: 163 RVA: 0x00005384 File Offset: 0x00003584
		public static explicit operator long(BigInteger value)
		{
			if (value._bits == null)
			{
				return (long)value._sign;
			}
			int num = value._bits.Length;
			if (num > 2)
			{
				throw new OverflowException(SR.Overflow_Int64);
			}
			ulong num2;
			if (num > 1)
			{
				num2 = NumericsHelpers.MakeUlong(value._bits[1], value._bits[0]);
			}
			else
			{
				num2 = (ulong)value._bits[0];
			}
			long num3 = (long)((value._sign > 0) ? num2 : (-(long)num2));
			if ((num3 > 0L && value._sign > 0) || (num3 < 0L && value._sign < 0))
			{
				return num3;
			}
			throw new OverflowException(SR.Overflow_Int64);
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to an unsigned 64-bit integer value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to an unsigned 64-bit integer.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.UInt64.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.UInt64.MaxValue" />. </exception>
		// Token: 0x060000A4 RID: 164 RVA: 0x00005418 File Offset: 0x00003618
		[CLSCompliant(false)]
		public static explicit operator ulong(BigInteger value)
		{
			if (value._bits == null)
			{
				return checked((ulong)value._sign);
			}
			int num = value._bits.Length;
			if (num > 2 || value._sign < 0)
			{
				throw new OverflowException(SR.Overflow_UInt64);
			}
			if (num > 1)
			{
				return NumericsHelpers.MakeUlong(value._bits[1], value._bits[0]);
			}
			return (ulong)value._bits[0];
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to a single-precision floating-point value.</summary>
		/// <returns>An object that contains the closest possible representation of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a single-precision floating-point value.</param>
		// Token: 0x060000A5 RID: 165 RVA: 0x00005479 File Offset: 0x00003679
		public static explicit operator float(BigInteger value)
		{
			return (float)((double)value);
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to a <see cref="T:System.Double" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Double" />.</param>
		// Token: 0x060000A6 RID: 166 RVA: 0x00005484 File Offset: 0x00003684
		public static explicit operator double(BigInteger value)
		{
			int sign = value._sign;
			uint[] bits = value._bits;
			if (bits == null)
			{
				return (double)sign;
			}
			int num = bits.Length;
			if (num <= 32)
			{
				ulong num2 = (ulong)bits[num - 1];
				ulong num3 = (ulong)((num > 1) ? bits[num - 2] : 0U);
				ulong num4 = (ulong)((num > 2) ? bits[num - 3] : 0U);
				int num5 = NumericsHelpers.CbitHighZero((uint)num2);
				int exp = (num - 2) * 32 - num5;
				ulong man = num2 << 32 + num5 | num3 << num5 | num4 >> 32 - num5;
				return NumericsHelpers.GetDoubleFromParts(sign, exp, man);
			}
			if (sign == 1)
			{
				return double.PositiveInfinity;
			}
			return double.NegativeInfinity;
		}

		/// <summary>Defines an explicit conversion of a <see cref="T:System.Numerics.BigInteger" /> object to a <see cref="T:System.Decimal" /> value.</summary>
		/// <returns>An object that contains the value of the <paramref name="value" /> parameter.</returns>
		/// <param name="value">The value to convert to a <see cref="T:System.Decimal" />.</param>
		/// <exception cref="T:System.OverflowException">
		///   <paramref name="value" /> is less than <see cref="F:System.Decimal.MinValue" />.-or-<paramref name="value" /> is greater than <see cref="F:System.Decimal.MaxValue" />.</exception>
		// Token: 0x060000A7 RID: 167 RVA: 0x0000552C File Offset: 0x0000372C
		public static explicit operator decimal(BigInteger value)
		{
			if (value._bits == null)
			{
				return value._sign;
			}
			int num = value._bits.Length;
			if (num > 3)
			{
				throw new OverflowException(SR.Overflow_Decimal);
			}
			int lo = 0;
			int mid = 0;
			int hi = 0;
			if (num > 2)
			{
				hi = (int)value._bits[2];
			}
			if (num > 1)
			{
				mid = (int)value._bits[1];
			}
			if (num > 0)
			{
				lo = (int)value._bits[0];
			}
			return new decimal(lo, mid, hi, value._sign < 0, 0);
		}

		/// <summary>Performs a bitwise And operation on two <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The result of the bitwise And operation.</returns>
		/// <param name="left">The first value.</param>
		/// <param name="right">The second value.</param>
		// Token: 0x060000A8 RID: 168 RVA: 0x000055A4 File Offset: 0x000037A4
		public static BigInteger operator &(BigInteger left, BigInteger right)
		{
			if (left.IsZero || right.IsZero)
			{
				return BigInteger.Zero;
			}
			uint[] array = left.ToUInt32Array();
			uint[] array2 = right.ToUInt32Array();
			uint[] array3 = new uint[Math.Max(array.Length, array2.Length)];
			uint num = (left._sign < 0) ? uint.MaxValue : 0U;
			uint num2 = (right._sign < 0) ? uint.MaxValue : 0U;
			for (int i = 0; i < array3.Length; i++)
			{
				uint num3 = (i < array.Length) ? array[i] : num;
				uint num4 = (i < array2.Length) ? array2[i] : num2;
				array3[i] = (num3 & num4);
			}
			return new BigInteger(array3);
		}

		/// <summary>Performs a bitwise Or operation on two <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The result of the bitwise Or operation.</returns>
		/// <param name="left">The first value.</param>
		/// <param name="right">The second value.</param>
		// Token: 0x060000A9 RID: 169 RVA: 0x0000564C File Offset: 0x0000384C
		public static BigInteger operator |(BigInteger left, BigInteger right)
		{
			if (left.IsZero)
			{
				return right;
			}
			if (right.IsZero)
			{
				return left;
			}
			uint[] array = left.ToUInt32Array();
			uint[] array2 = right.ToUInt32Array();
			uint[] array3 = new uint[Math.Max(array.Length, array2.Length)];
			uint num = (left._sign < 0) ? uint.MaxValue : 0U;
			uint num2 = (right._sign < 0) ? uint.MaxValue : 0U;
			for (int i = 0; i < array3.Length; i++)
			{
				uint num3 = (i < array.Length) ? array[i] : num;
				uint num4 = (i < array2.Length) ? array2[i] : num2;
				array3[i] = (num3 | num4);
			}
			return new BigInteger(array3);
		}

		/// <summary>Performs a bitwise exclusive Or (XOr) operation on two <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The result of the bitwise Or operation.</returns>
		/// <param name="left">The first value.</param>
		/// <param name="right">The second value.</param>
		// Token: 0x060000AA RID: 170 RVA: 0x000056F0 File Offset: 0x000038F0
		public static BigInteger operator ^(BigInteger left, BigInteger right)
		{
			uint[] array = left.ToUInt32Array();
			uint[] array2 = right.ToUInt32Array();
			uint[] array3 = new uint[Math.Max(array.Length, array2.Length)];
			uint num = (left._sign < 0) ? uint.MaxValue : 0U;
			uint num2 = (right._sign < 0) ? uint.MaxValue : 0U;
			for (int i = 0; i < array3.Length; i++)
			{
				uint num3 = (i < array.Length) ? array[i] : num;
				uint num4 = (i < array2.Length) ? array2[i] : num2;
				array3[i] = (num3 ^ num4);
			}
			return new BigInteger(array3);
		}

		/// <summary>Shifts a <see cref="T:System.Numerics.BigInteger" /> value a specified number of bits to the left.</summary>
		/// <returns>A value that has been shifted to the left by the specified number of bits.</returns>
		/// <param name="value">The value whose bits are to be shifted.</param>
		/// <param name="shift">The number of bits to shift <paramref name="value" /> to the left.</param>
		// Token: 0x060000AB RID: 171 RVA: 0x00005780 File Offset: 0x00003980
		public static BigInteger operator <<(BigInteger value, int shift)
		{
			if (shift == 0)
			{
				return value;
			}
			if (shift == -2147483648)
			{
				return value >> int.MaxValue >> 1;
			}
			if (shift < 0)
			{
				return value >> -shift;
			}
			int num = shift / 32;
			int num2 = shift - num * 32;
			uint[] array;
			int num3;
			bool partsForBitManipulation = BigInteger.GetPartsForBitManipulation(ref value, out array, out num3);
			int num4 = num3 + num + 1;
			uint[] array2 = new uint[num4];
			if (num2 == 0)
			{
				for (int i = 0; i < num3; i++)
				{
					array2[i + num] = array[i];
				}
			}
			else
			{
				int num5 = 32 - num2;
				uint num6 = 0U;
				int j;
				for (j = 0; j < num3; j++)
				{
					uint num7 = array[j];
					array2[j + num] = (num7 << num2 | num6);
					num6 = num7 >> num5;
				}
				array2[j + num] = num6;
			}
			return new BigInteger(array2, partsForBitManipulation);
		}

		/// <summary>Shifts a <see cref="T:System.Numerics.BigInteger" /> value a specified number of bits to the right.</summary>
		/// <returns>A value that has been shifted to the right by the specified number of bits.</returns>
		/// <param name="value">The value whose bits are to be shifted.</param>
		/// <param name="shift">The number of bits to shift <paramref name="value" /> to the right.</param>
		// Token: 0x060000AC RID: 172 RVA: 0x00005850 File Offset: 0x00003A50
		public static BigInteger operator >>(BigInteger value, int shift)
		{
			if (shift == 0)
			{
				return value;
			}
			if (shift == -2147483648)
			{
				return value << int.MaxValue << 1;
			}
			if (shift < 0)
			{
				return value << -shift;
			}
			int num = shift / 32;
			int num2 = shift - num * 32;
			uint[] array;
			int num3;
			bool partsForBitManipulation = BigInteger.GetPartsForBitManipulation(ref value, out array, out num3);
			if (partsForBitManipulation)
			{
				if (shift >= 32 * num3)
				{
					return BigInteger.MinusOne;
				}
				uint[] array2 = new uint[num3];
				Array.Copy(array, 0, array2, 0, num3);
				array = array2;
				NumericsHelpers.DangerousMakeTwosComplement(array);
			}
			int num4 = num3 - num;
			if (num4 < 0)
			{
				num4 = 0;
			}
			uint[] array3 = new uint[num4];
			if (num2 == 0)
			{
				for (int i = num3 - 1; i >= num; i--)
				{
					array3[i - num] = array[i];
				}
			}
			else
			{
				int num5 = 32 - num2;
				uint num6 = 0U;
				for (int j = num3 - 1; j >= num; j--)
				{
					uint num7 = array[j];
					if (partsForBitManipulation && j == num3 - 1)
					{
						array3[j - num] = (num7 >> num2 | uint.MaxValue << num5);
					}
					else
					{
						array3[j - num] = (num7 >> num2 | num6);
					}
					num6 = num7 << num5;
				}
			}
			if (partsForBitManipulation)
			{
				NumericsHelpers.DangerousMakeTwosComplement(array3);
			}
			return new BigInteger(array3, partsForBitManipulation);
		}

		/// <summary>Returns the bitwise one's complement of a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>The bitwise one's complement of <paramref name="value" />.</returns>
		/// <param name="value">An integer value.</param>
		// Token: 0x060000AD RID: 173 RVA: 0x0000597A File Offset: 0x00003B7A
		public static BigInteger operator ~(BigInteger value)
		{
			return -(value + BigInteger.One);
		}

		/// <summary>Negates a specified BigInteger value. </summary>
		/// <returns>The result of the <paramref name="value" /> parameter multiplied by negative one (-1).</returns>
		/// <param name="value">The value to negate.</param>
		// Token: 0x060000AE RID: 174 RVA: 0x0000598C File Offset: 0x00003B8C
		public static BigInteger operator -(BigInteger value)
		{
			return new BigInteger(-value._sign, value._bits);
		}

		/// <summary>Returns the value of the <see cref="T:System.Numerics.BigInteger" /> operand. (The sign of the operand is unchanged.)</summary>
		/// <returns>The value of the <paramref name="value" /> operand.</returns>
		/// <param name="value">An integer value.</param>
		// Token: 0x060000AF RID: 175 RVA: 0x000059A0 File Offset: 0x00003BA0
		public static BigInteger operator +(BigInteger value)
		{
			return value;
		}

		/// <summary>Increments a <see cref="T:System.Numerics.BigInteger" /> value by 1.</summary>
		/// <returns>The value of the <paramref name="value" /> parameter incremented by 1.</returns>
		/// <param name="value">The value to increment.</param>
		// Token: 0x060000B0 RID: 176 RVA: 0x000059A3 File Offset: 0x00003BA3
		public static BigInteger operator ++(BigInteger value)
		{
			return value + BigInteger.One;
		}

		/// <summary>Decrements a <see cref="T:System.Numerics.BigInteger" /> value by 1.</summary>
		/// <returns>The value of the <paramref name="value" /> parameter decremented by 1.</returns>
		/// <param name="value">The value to decrement.</param>
		// Token: 0x060000B1 RID: 177 RVA: 0x000059B0 File Offset: 0x00003BB0
		public static BigInteger operator --(BigInteger value)
		{
			return value - BigInteger.One;
		}

		/// <summary>Adds the values of two specified <see cref="T:System.Numerics.BigInteger" /> objects.</summary>
		/// <returns>The sum of <paramref name="left" /> and <paramref name="right" />.</returns>
		/// <param name="left">The first value to add.</param>
		/// <param name="right">The second value to add.</param>
		// Token: 0x060000B2 RID: 178 RVA: 0x000059C0 File Offset: 0x00003BC0
		public static BigInteger operator +(BigInteger left, BigInteger right)
		{
			if (left._sign < 0 != right._sign < 0)
			{
				return BigInteger.Subtract(left._bits, left._sign, right._bits, -1 * right._sign);
			}
			return BigInteger.Add(left._bits, left._sign, right._bits, right._sign);
		}

		/// <summary>Multiplies two specified <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The product of <paramref name="left" /> and <paramref name="right" />.</returns>
		/// <param name="left">The first value to multiply.</param>
		/// <param name="right">The second value to multiply.</param>
		// Token: 0x060000B3 RID: 179 RVA: 0x00005A20 File Offset: 0x00003C20
		public static BigInteger operator *(BigInteger left, BigInteger right)
		{
			bool flag = left._bits == null;
			bool flag2 = right._bits == null;
			if (flag && flag2)
			{
				return (long)left._sign * (long)right._sign;
			}
			if (flag)
			{
				uint[] value = BigIntegerCalculator.Multiply(right._bits, NumericsHelpers.Abs(left._sign));
				return new BigInteger(value, left._sign < 0 ^ right._sign < 0);
			}
			if (flag2)
			{
				uint[] value2 = BigIntegerCalculator.Multiply(left._bits, NumericsHelpers.Abs(right._sign));
				return new BigInteger(value2, left._sign < 0 ^ right._sign < 0);
			}
			if (left._bits == right._bits)
			{
				uint[] value3 = BigIntegerCalculator.Square(left._bits);
				return new BigInteger(value3, left._sign < 0 ^ right._sign < 0);
			}
			if (left._bits.Length < right._bits.Length)
			{
				uint[] value4 = BigIntegerCalculator.Multiply(right._bits, left._bits);
				return new BigInteger(value4, left._sign < 0 ^ right._sign < 0);
			}
			uint[] value5 = BigIntegerCalculator.Multiply(left._bits, right._bits);
			return new BigInteger(value5, left._sign < 0 ^ right._sign < 0);
		}

		/// <summary>Divides a specified <see cref="T:System.Numerics.BigInteger" /> value by another specified <see cref="T:System.Numerics.BigInteger" /> value by using integer division.</summary>
		/// <returns>The integral result of the division.</returns>
		/// <param name="dividend">The value to be divided.</param>
		/// <param name="divisor">The value to divide by.</param>
		/// <exception cref="T:System.DivideByZeroException">
		///   <paramref name="divisor" /> is 0 (zero).</exception>
		// Token: 0x060000B4 RID: 180 RVA: 0x00005B68 File Offset: 0x00003D68
		public static BigInteger operator /(BigInteger dividend, BigInteger divisor)
		{
			bool flag = dividend._bits == null;
			bool flag2 = divisor._bits == null;
			if (flag && flag2)
			{
				return dividend._sign / divisor._sign;
			}
			if (flag)
			{
				return BigInteger.s_bnZeroInt;
			}
			if (flag2)
			{
				uint[] value = BigIntegerCalculator.Divide(dividend._bits, NumericsHelpers.Abs(divisor._sign));
				return new BigInteger(value, dividend._sign < 0 ^ divisor._sign < 0);
			}
			if (dividend._bits.Length < divisor._bits.Length)
			{
				return BigInteger.s_bnZeroInt;
			}
			uint[] value2 = BigIntegerCalculator.Divide(dividend._bits, divisor._bits);
			return new BigInteger(value2, dividend._sign < 0 ^ divisor._sign < 0);
		}

		/// <summary>Returns the remainder that results from division with two specified <see cref="T:System.Numerics.BigInteger" /> values.</summary>
		/// <returns>The remainder that results from the division.</returns>
		/// <param name="dividend">The value to be divided.</param>
		/// <param name="divisor">The value to divide by.</param>
		/// <exception cref="T:System.DivideByZeroException">
		///   <paramref name="divisor" /> is 0 (zero).</exception>
		// Token: 0x060000B5 RID: 181 RVA: 0x00005C24 File Offset: 0x00003E24
		public static BigInteger operator %(BigInteger dividend, BigInteger divisor)
		{
			bool flag = dividend._bits == null;
			bool flag2 = divisor._bits == null;
			if (flag && flag2)
			{
				return dividend._sign % divisor._sign;
			}
			if (flag)
			{
				return dividend;
			}
			if (flag2)
			{
				uint num = BigIntegerCalculator.Remainder(dividend._bits, NumericsHelpers.Abs(divisor._sign));
				return (long)((dividend._sign < 0) ? (ulong.MaxValue * (ulong)num) : ((ulong)num));
			}
			if (dividend._bits.Length < divisor._bits.Length)
			{
				return dividend;
			}
			uint[] value = BigIntegerCalculator.Remainder(dividend._bits, divisor._bits);
			return new BigInteger(value, dividend._sign < 0);
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is less than another <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is less than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000B6 RID: 182 RVA: 0x00005CC9 File Offset: 0x00003EC9
		public static bool operator <(BigInteger left, BigInteger right)
		{
			return left.CompareTo(right) < 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is less than or equal to another <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is less than or equal to <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000B7 RID: 183 RVA: 0x00005CD6 File Offset: 0x00003ED6
		public static bool operator <=(BigInteger left, BigInteger right)
		{
			return left.CompareTo(right) <= 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is greater than another <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000B8 RID: 184 RVA: 0x00005CE6 File Offset: 0x00003EE6
		public static bool operator >(BigInteger left, BigInteger right)
		{
			return left.CompareTo(right) > 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is greater than or equal to another <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000B9 RID: 185 RVA: 0x00005CF3 File Offset: 0x00003EF3
		public static bool operator >=(BigInteger left, BigInteger right)
		{
			return left.CompareTo(right) >= 0;
		}

		/// <summary>Returns a value that indicates whether the values of two <see cref="T:System.Numerics.BigInteger" /> objects are equal.</summary>
		/// <returns>true if the <paramref name="left" /> and <paramref name="right" /> parameters have the same value; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000BA RID: 186 RVA: 0x00005D03 File Offset: 0x00003F03
		public static bool operator ==(BigInteger left, BigInteger right)
		{
			return left.Equals(right);
		}

		/// <summary>Returns a value that indicates whether two <see cref="T:System.Numerics.BigInteger" /> objects have different values.</summary>
		/// <returns>true if <paramref name="left" /> and <paramref name="right" /> are not equal; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000BB RID: 187 RVA: 0x00005D0D File Offset: 0x00003F0D
		public static bool operator !=(BigInteger left, BigInteger right)
		{
			return !left.Equals(right);
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is less than a 64-bit signed integer.</summary>
		/// <returns>true if <paramref name="left" /> is less than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000BC RID: 188 RVA: 0x00005D1A File Offset: 0x00003F1A
		public static bool operator <(BigInteger left, long right)
		{
			return left.CompareTo(right) < 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is less than or equal to a 64-bit signed integer.</summary>
		/// <returns>true if <paramref name="left" /> is less than or equal to <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000BD RID: 189 RVA: 0x00005D27 File Offset: 0x00003F27
		public static bool operator <=(BigInteger left, long right)
		{
			return left.CompareTo(right) <= 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> is greater than a 64-bit signed integer value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000BE RID: 190 RVA: 0x00005D37 File Offset: 0x00003F37
		public static bool operator >(BigInteger left, long right)
		{
			return left.CompareTo(right) > 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is greater than or equal to a 64-bit signed integer value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000BF RID: 191 RVA: 0x00005D44 File Offset: 0x00003F44
		public static bool operator >=(BigInteger left, long right)
		{
			return left.CompareTo(right) >= 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value and a signed long integer value are equal.</summary>
		/// <returns>true if the <paramref name="left" /> and <paramref name="right" /> parameters have the same value; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C0 RID: 192 RVA: 0x00005D54 File Offset: 0x00003F54
		public static bool operator ==(BigInteger left, long right)
		{
			return left.Equals(right);
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value and a 64-bit signed integer are not equal.</summary>
		/// <returns>true if <paramref name="left" /> and <paramref name="right" /> are not equal; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C1 RID: 193 RVA: 0x00005D5E File Offset: 0x00003F5E
		public static bool operator !=(BigInteger left, long right)
		{
			return !left.Equals(right);
		}

		/// <summary>Returns a value that indicates whether a 64-bit signed integer is less than a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is less than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C2 RID: 194 RVA: 0x00005D6B File Offset: 0x00003F6B
		public static bool operator <(long left, BigInteger right)
		{
			return right.CompareTo(left) > 0;
		}

		/// <summary>Returns a value that indicates whether a 64-bit signed integer is less than or equal to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is less than or equal to <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C3 RID: 195 RVA: 0x00005D78 File Offset: 0x00003F78
		public static bool operator <=(long left, BigInteger right)
		{
			return right.CompareTo(left) >= 0;
		}

		/// <summary>Returns a value that indicates whether a 64-bit signed integer is greater than a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C4 RID: 196 RVA: 0x00005D88 File Offset: 0x00003F88
		public static bool operator >(long left, BigInteger right)
		{
			return right.CompareTo(left) < 0;
		}

		/// <summary>Returns a value that indicates whether a 64-bit signed integer is greater than or equal to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C5 RID: 197 RVA: 0x00005D95 File Offset: 0x00003F95
		public static bool operator >=(long left, BigInteger right)
		{
			return right.CompareTo(left) <= 0;
		}

		/// <summary>Returns a value that indicates whether a signed long integer value and a <see cref="T:System.Numerics.BigInteger" /> value are equal.</summary>
		/// <returns>true if the <paramref name="left" /> and <paramref name="right" /> parameters have the same value; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C6 RID: 198 RVA: 0x00005DA5 File Offset: 0x00003FA5
		public static bool operator ==(long left, BigInteger right)
		{
			return right.Equals(left);
		}

		/// <summary>Returns a value that indicates whether a 64-bit signed integer and a <see cref="T:System.Numerics.BigInteger" /> value are not equal.</summary>
		/// <returns>true if <paramref name="left" /> and <paramref name="right" /> are not equal; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C7 RID: 199 RVA: 0x00005DAF File Offset: 0x00003FAF
		public static bool operator !=(long left, BigInteger right)
		{
			return !right.Equals(left);
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is less than a 64-bit unsigned integer.</summary>
		/// <returns>true if <paramref name="left" /> is less than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C8 RID: 200 RVA: 0x00005DBC File Offset: 0x00003FBC
		[CLSCompliant(false)]
		public static bool operator <(BigInteger left, ulong right)
		{
			return left.CompareTo(right) < 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is less than or equal to a 64-bit unsigned integer.</summary>
		/// <returns>true if <paramref name="left" /> is less than or equal to <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000C9 RID: 201 RVA: 0x00005DC9 File Offset: 0x00003FC9
		[CLSCompliant(false)]
		public static bool operator <=(BigInteger left, ulong right)
		{
			return left.CompareTo(right) <= 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is greater than a 64-bit unsigned integer.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000CA RID: 202 RVA: 0x00005DD9 File Offset: 0x00003FD9
		[CLSCompliant(false)]
		public static bool operator >(BigInteger left, ulong right)
		{
			return left.CompareTo(right) > 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is greater than or equal to a 64-bit unsigned integer value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000CB RID: 203 RVA: 0x00005DE6 File Offset: 0x00003FE6
		[CLSCompliant(false)]
		public static bool operator >=(BigInteger left, ulong right)
		{
			return left.CompareTo(right) >= 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value and an unsigned long integer value are equal.</summary>
		/// <returns>true if the <paramref name="left" /> and <paramref name="right" /> parameters have the same value; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000CC RID: 204 RVA: 0x00005DF6 File Offset: 0x00003FF6
		[CLSCompliant(false)]
		public static bool operator ==(BigInteger left, ulong right)
		{
			return left.Equals(right);
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value and a 64-bit unsigned integer are not equal.</summary>
		/// <returns>true if <paramref name="left" /> and <paramref name="right" /> are not equal; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000CD RID: 205 RVA: 0x00005E00 File Offset: 0x00004000
		[CLSCompliant(false)]
		public static bool operator !=(BigInteger left, ulong right)
		{
			return !left.Equals(right);
		}

		/// <summary>Returns a value that indicates whether a 64-bit unsigned integer is less than a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is less than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000CE RID: 206 RVA: 0x00005E0D File Offset: 0x0000400D
		[CLSCompliant(false)]
		public static bool operator <(ulong left, BigInteger right)
		{
			return right.CompareTo(left) > 0;
		}

		/// <summary>Returns a value that indicates whether a 64-bit unsigned integer is less than or equal to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is less than or equal to <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000CF RID: 207 RVA: 0x00005E1A File Offset: 0x0000401A
		[CLSCompliant(false)]
		public static bool operator <=(ulong left, BigInteger right)
		{
			return right.CompareTo(left) >= 0;
		}

		/// <summary>Returns a value that indicates whether a <see cref="T:System.Numerics.BigInteger" /> value is greater than a 64-bit unsigned integer.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000D0 RID: 208 RVA: 0x00005E2A File Offset: 0x0000402A
		[CLSCompliant(false)]
		public static bool operator >(ulong left, BigInteger right)
		{
			return right.CompareTo(left) < 0;
		}

		/// <summary>Returns a value that indicates whether a 64-bit unsigned integer is greater than or equal to a <see cref="T:System.Numerics.BigInteger" /> value.</summary>
		/// <returns>true if <paramref name="left" /> is greater than <paramref name="right" />; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000D1 RID: 209 RVA: 0x00005E37 File Offset: 0x00004037
		[CLSCompliant(false)]
		public static bool operator >=(ulong left, BigInteger right)
		{
			return right.CompareTo(left) <= 0;
		}

		/// <summary>Returns a value that indicates whether an unsigned long integer value and a <see cref="T:System.Numerics.BigInteger" /> value are equal.</summary>
		/// <returns>true if the <paramref name="left" /> and <paramref name="right" /> parameters have the same value; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000D2 RID: 210 RVA: 0x00005E47 File Offset: 0x00004047
		[CLSCompliant(false)]
		public static bool operator ==(ulong left, BigInteger right)
		{
			return right.Equals(left);
		}

		/// <summary>Returns a value that indicates whether a 64-bit unsigned integer and a <see cref="T:System.Numerics.BigInteger" /> value are not equal.</summary>
		/// <returns>true if <paramref name="left" /> and <paramref name="right" /> are not equal; otherwise, false.</returns>
		/// <param name="left">The first value to compare.</param>
		/// <param name="right">The second value to compare.</param>
		// Token: 0x060000D3 RID: 211 RVA: 0x00005E51 File Offset: 0x00004051
		[CLSCompliant(false)]
		public static bool operator !=(ulong left, BigInteger right)
		{
			return !right.Equals(left);
		}

		// Token: 0x060000D4 RID: 212 RVA: 0x00005E60 File Offset: 0x00004060
		private static bool GetPartsForBitManipulation(ref BigInteger x, out uint[] xd, out int xl)
		{
			if (x._bits == null)
			{
				if (x._sign < 0)
				{
					xd = new uint[]
					{
						(uint)(-(uint)x._sign)
					};
				}
				else
				{
					xd = new uint[]
					{
						(uint)x._sign
					};
				}
			}
			else
			{
				xd = x._bits;
			}
			xl = ((x._bits == null) ? 1 : x._bits.Length);
			return x._sign < 0;
		}

		// Token: 0x060000D5 RID: 213 RVA: 0x00005ECC File Offset: 0x000040CC
		internal static int GetDiffLength(uint[] rgu1, uint[] rgu2, int cu)
		{
			int num = cu;
			while (--num >= 0)
			{
				if (rgu1[num] != rgu2[num])
				{
					return num + 1;
				}
			}
			return 0;
		}

		// Token: 0x060000D6 RID: 214 RVA: 0x00005EF2 File Offset: 0x000040F2
		[Conditional("DEBUG")]
		private void AssertValid()
		{
			uint[] bits = this._bits;
		}

		// Token: 0x060000D7 RID: 215 RVA: 0x00005EFB File Offset: 0x000040FB
		// Note: this type is marked as 'beforefieldinit'.
		static BigInteger()
		{
		}

		// Token: 0x04000007 RID: 7
		private const int knMaskHighBit = -2147483648;

		// Token: 0x04000008 RID: 8
		private const uint kuMaskHighBit = 2147483648U;

		// Token: 0x04000009 RID: 9
		private const int kcbitUint = 32;

		// Token: 0x0400000A RID: 10
		private const int kcbitUlong = 64;

		// Token: 0x0400000B RID: 11
		private const int DecimalScaleFactorMask = 16711680;

		// Token: 0x0400000C RID: 12
		private const int DecimalSignMask = -2147483648;

		// Token: 0x0400000D RID: 13
		internal readonly int _sign;

		// Token: 0x0400000E RID: 14
		internal readonly uint[] _bits;

		// Token: 0x0400000F RID: 15
		private static readonly BigInteger s_bnMinInt = new BigInteger(-1, new uint[]
		{
			2147483648U
		});

		// Token: 0x04000010 RID: 16
		private static readonly BigInteger s_bnOneInt = new BigInteger(1);

		// Token: 0x04000011 RID: 17
		private static readonly BigInteger s_bnZeroInt = new BigInteger(0);

		// Token: 0x04000012 RID: 18
		private static readonly BigInteger s_bnMinusOneInt = new BigInteger(-1);
	}
}
