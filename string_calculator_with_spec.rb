
require "test/unit"


class StringCalculator
	NEGATIVES_NUMBER_MSG = "negatives not allowed"
	START_CUSTOM_INDEX = 3
	TOO_LARGE = 1001


	def add(numbers)
		remove_eol = remove_eol(numbers) 
		unless remove_eol.include?(",")
			return handle_single_number(remove_eol)
		end
		remove_eol = replace_delimters(remove_eol)
		actual = turn_into_actual_numbers(remove_eol)
		disallow_negatives(actual)
		good_numbers = filter_allowable_numbers(actual)
		
		return good_numbers.inject(&:+)
	end

	def remove_eol(numbers)
		numbers.strip.gsub("\n", ",")
	end

	def replace_delimters(numbers)
		return numbers unless numbers.include?("//")

		endindex = numbers.index(",")

		delims = numbers[START_CUSTOM_INDEX..endindex].delete("[").split("]")
		delims.each do |delim|
			numbers = numbers.gsub!(delim,",")
		end
		delim_char = numbers[2].chr
		return numbers.gsub(delim_char,",")
	end

	def handle_single_number(number)
		raise "#{NEGATIVES_NUMBER_MSG} #{number}" if number.include?("-")
		return number.to_i
	end

	def turn_into_actual_numbers(numbers)
		numbers.split(',').map(&:to_i) 
	end

	def disallow_negatives(numbers)
		negatives= numbers.find_all do |number|
			number<0
		end
		raise "#{NEGATIVES_NUMBER_MSG} #{negatives}" unless negatives.empty?
	end

	def filter_allowable_numbers(numbers)
		numbers.find_all do |number|
			number < TOO_LARGE
		end		
	end
end

class StringCalculatorTests < Test::Unit::TestCase
	def calc
		StringCalculator.new
	end

	def test_add_emptystring_zero
		result = calc.add("")
		assert_equal 0,result
	end

	def test_add_singlenumber_returnsThatNumber
		result = calc.add("1")
		assert_equal 1,result
	end

	def test_add_singlenumber_returnsThatNumber_1
		result = calc.add("2")
		assert_equal 2,result
	end

	def test_add_twonumbers_sumsThem
		result = calc.add("1,2")
		assert_equal 3,result
	end
	def test_add_twonumbers_sumsThem1
		result = calc.add("1,3")
		assert_equal 4,result
	end
	def test_add_twolargernumbers_sumsThem1
		result = calc.add("10,30")
		assert_equal 40,result
	end
	def test_add_newline_zero
		result = calc.add("\n")
		assert_equal 0,result
	end
	def test_add_newlinebetweennumbers_treatsasseperator
		result = calc.add("1\n2")
		assert_equal 3,result
	end
	def test_add_differentDelimiter_usedToParseTheSum
		result = calc.add("//A\n1A2")
		assert_equal 3,result
	end
	def test_add_differentDelimiter_usedToParseTheSum2
		result = calc.add("//B\n1B2")
		assert_equal 3,result
	end
	def test_add_neagative_throws
		ex = assert_raise RuntimeError do
			calc.add("-1")
		end
		assert_match /negatives not/, ex.message
	end
	def test_add_multiple_neagative_throws
		ex = assert_raise RuntimeError do
			calc.add("-1,-2")
		end
		assert_match /-1/, ex.message
		assert_match /-2/, ex.message
	end
	def test_add_negativeandpositive_throwsonlythenegative
		ex = assert_raise RuntimeError do
			calc.add("-1,2")
		end
		assert_match /-1/, ex.message
		assert_no_match /2/, ex.message
	end
	def test_add_numbersbiggerthan1000_ignored
		result=	calc.add("2,1001")
		assert_equal 2,result
	end

	def test_add_delimiterslongerthanonechar_stillaccepted
		result=	calc.add("//AAA\n1AAA2AAA3")
		assert_equal 6,result
	end
	def test_add_multipledelimiters_allused
		result=	calc.add("//[A][b]\n1A2b3")
		assert_equal 6,result
	end
	def test_add_multipledelimiters_allused2
		result=	calc.add("//[AB][bc]\n1AB2bc3")
		assert_equal 6,result
	end

end